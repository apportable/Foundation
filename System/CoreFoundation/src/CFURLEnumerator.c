//
//  CFURLEnumerator.c
//  CoreFoundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#include "CFBase.h"
#include "CFRuntime.h"
#include "CFURLEnumerator.h"
#include "CFNumber.h"
#include <dirent.h>
#include <errno.h>

extern const CFStringRef NSURLErrorKey;
extern const CFStringRef NSFilePathErrorKey;

static CFIndex CFURLEnumeratorPushURL(CFURLEnumeratorRef enumerator, CFURLRef url, CFErrorRef *error);
static CFIndex CFURLEnumeratorPopURL(CFURLEnumeratorRef enumerator);

static CFStringRef fileInfoNameKey = CFSTR("name");
static CFStringRef fileInfoIsDirKey = CFSTR("isDir");

struct __CFURLEnumerator {
    CFRuntimeBase _base;
    CFURLRef directoryURL;
    CFURLEnumeratorOptions options;
    CFArrayRef propertyKeys;
    CFMutableArrayRef urlStack;
    CFMutableArrayRef dirFileInfos;
};

CFComparisonResult _compareFileInfo(const void *fileInfo1, const void *fileInfo2, void *context) {
    CFStringRef name1 = (CFStringRef)CFDictionaryGetValue(((CFMutableDictionaryRef) fileInfo1), fileInfoNameKey);
    CFStringRef name2 = (CFStringRef)CFDictionaryGetValue(((CFMutableDictionaryRef) fileInfo2), fileInfoNameKey);
    return CFStringCompare(name1, name2, kCFCompareCaseInsensitive);
}

static void __CFURLEnumeratorDeallocate(CFTypeRef cf) {
    struct __CFURLEnumerator *enumerator = (struct __CFURLEnumerator *)cf;
    CFRelease(enumerator->directoryURL);

    if (enumerator->propertyKeys != NULL) {
        CFRelease(enumerator->propertyKeys);
    }

    if (enumerator->urlStack) {
        CFRelease(enumerator->urlStack);
    }

    if (enumerator->dirFileInfos) {
        CFRelease(enumerator->dirFileInfos);
    }
}

static CFTypeID __kCFURLEnumeratorTypeID = _kCFRuntimeNotATypeID;

static const CFRuntimeClass __CFURLEnumeratorClass = {
    _kCFRuntimeScannedObject,
    "CFURLEnumerator",
    NULL,   // init
    NULL,   // copy
    __CFURLEnumeratorDeallocate,
    NULL,
    NULL,
    NULL,
    NULL
};

static void __CFURLEnumeratorInitialize(void) {
    __kCFURLEnumeratorTypeID = _CFRuntimeRegisterClass(&__CFURLEnumeratorClass);
}

CFTypeID CFURLEnumeratorGetTypeID(void) {
    if (__kCFURLEnumeratorTypeID == _kCFRuntimeNotATypeID) {
        __CFURLEnumeratorInitialize();
    }
    return __kCFURLEnumeratorTypeID;
}

static struct __CFURLEnumerator *_CFURLEnumeratorCreate(CFAllocatorRef allocator) {
    CFIndex size = sizeof(struct __CFURLEnumerator) - sizeof(CFRuntimeBase);
    return (struct __CFURLEnumerator *)_CFRuntimeCreateInstance(allocator, CFURLEnumeratorGetTypeID(), size, NULL);
}

static void cocoaError(CFErrorRef *error, CFIndex code, CFURLRef url, CFStringRef path) {
    if (error) {
        const CFStringRef keys[2] = {
            NSURLErrorKey,
            NSFilePathErrorKey
        };
        CFTypeRef values[2] = {
            url,
            path,
        };
        *error = CFErrorCreateWithUserInfoKeysAndValues(kCFAllocatorDefault, kCFErrorDomainCocoa, code, (const void *const *)keys, (const void *const *)values, 2);
    }
}

static void posixError(CFErrorRef *error, CFURLRef url, CFStringRef path) {
    if (error) {
        const CFStringRef keys[3] = {
            kCFErrorUnderlyingErrorKey,
            NSURLErrorKey,
            NSFilePathErrorKey
        };
        CFStringRef err = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("%s"), strerror(errno));
        CFTypeRef values[3] = {
            err,
            url,
            path,
        };
        *error = CFErrorCreateWithUserInfoKeysAndValues(kCFAllocatorDefault, kCFErrorDomainPOSIX, errno, (const void *const *)keys, (const void *const *)values, 3);
        CFRelease(err);
    }
}

static CFIndex CFURLEnumeratorPushURL(CFURLEnumeratorRef enumerator, CFURLRef url, CFErrorRef *error) {
    char path[PATH_MAX] = { 0 };
    CFStringRef urlPath = CFURLCopyPath(url);
    Boolean success = CFStringGetFileSystemRepresentation(urlPath, path, PATH_MAX);
    
    if (!success) {
        cocoaError(error, -1, url, urlPath);
        CFRelease(urlPath);
        return kCFNotFound;
    }

    DIR *dir = opendir(path);
    if (dir == NULL) {
        posixError(error, url, urlPath);
        CFRelease(urlPath);
        return kCFNotFound;
    }

    CFMutableArrayRef fileInfos = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);

    struct dirent *current = NULL;
    while ((current = readdir(dir)) != NULL) {
        if (strcmp(current->d_name, ".") == 0 || strcmp(current->d_name, "..") == 0) {
            continue;
        }
        CFMutableDictionaryRef fileInfo = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        CFStringRef fileName = CFStringCreateWithBytes(kCFAllocatorDefault, current->d_name, strlen(current->d_name), kCFStringEncodingUTF8, false);
        CFDictionarySetValue(fileInfo, fileInfoNameKey, fileName);
        CFDictionarySetValue(fileInfo, fileInfoIsDirKey, current->d_type == DT_DIR ? kCFBooleanTrue : kCFBooleanFalse);
        CFArrayAppendValue(fileInfos, fileInfo);
        CFRelease(fileName);
        CFRelease(fileInfo);
    }

    CFArraySortValues(fileInfos, CFRangeMake(0, CFArrayGetCount(fileInfos)), _compareFileInfo, nil);
    CFArrayAppendValue(enumerator->urlStack, url);
    CFArrayAppendValue(enumerator->dirFileInfos, fileInfos);
    CFRelease(urlPath);
    CFRelease(fileInfos);
    closedir(dir);
    return CFArrayGetCount(enumerator->urlStack);
}

static CFDictionaryRef CFURLEnumeratorDequeueFileInfo(CFURLEnumeratorRef enumerator) {
    CFIndex count = CFArrayGetCount(enumerator->dirFileInfos);
    if (count > 0) {
        CFMutableArrayRef fileInfos = (CFMutableArrayRef)CFArrayGetValueAtIndex(enumerator->dirFileInfos, count - 1);
        count = CFArrayGetCount(fileInfos);
        if (count > 0) {
            CFDictionaryRef fileInfo = (CFDictionaryRef)CFArrayGetValueAtIndex(fileInfos, 0);
            CFRetain(fileInfo);
            CFArrayRemoveValueAtIndex(fileInfos, 0);
            return fileInfo;
        } else {
            return NULL;
        }
    } else {
        return NULL;
    } 
}

static CFIndex CFURLEnumeratorPopURL(CFURLEnumeratorRef enumerator) {
    CFIndex count = CFArrayGetCount(enumerator->urlStack);
    if (count > 0) {
        CFArrayRemoveValueAtIndex(enumerator->urlStack, count - 1);
        CFArrayRemoveValueAtIndex(enumerator->dirFileInfos, count - 1);
        return count - 1;
    } else {
        return 0;
    }
}

static CFIndex CFURLEnumeratorPeek(CFURLEnumeratorRef enumerator, CFURLRef *url) {
    CFIndex count = CFArrayGetCount(enumerator->urlStack);
    
    if (url != NULL) {
        *url = NULL;
    }

    if (count > 0) {
        if (url != NULL) {
            *url = (CFURLRef)CFArrayGetValueAtIndex(enumerator->urlStack, count - 1);
        }
    }

    return count;
}

CFURLEnumeratorRef CFURLEnumeratorCreateForDirectoryURL(CFAllocatorRef alloc, CFURLRef directoryURL, CFURLEnumeratorOptions option, CFArrayRef propertyKeys) {
    struct __CFURLEnumerator *enumerator = _CFURLEnumeratorCreate(alloc);
    enumerator->directoryURL = (CFURLRef)CFRetain(directoryURL);
    enumerator->options = option;
    if (propertyKeys != NULL) {
        enumerator->propertyKeys = CFArrayCreateCopy(alloc, propertyKeys);
    }
    enumerator->urlStack = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
    enumerator->dirFileInfos = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
    
    if (CFURLEnumeratorPushURL(enumerator, directoryURL, NULL) <= 0) {
        CFRelease(enumerator);
        return NULL;
    }

    return (CFURLEnumeratorRef)enumerator;
}

CFURLEnumeratorResult CFURLEnumeratorGetNextURL(CFURLEnumeratorRef enumer, CFURLRef *url, CFErrorRef *error) {
    struct __CFURLEnumerator *enumerator = (struct __CFURLEnumerator *)enumer;
    
    if (url != NULL) {
        *url = NULL;
    }

    if (error != NULL) {
        *error = NULL;
    }

    CFIndex count = 0;
    CFDictionaryRef fileInfo = NULL;
    CFURLRef parent = NULL;
    do {
        CFURLEnumeratorPeek(enumerator, &parent);
        if (parent != NULL) {
            fileInfo = CFURLEnumeratorDequeueFileInfo(enumerator);
        }

        if (fileInfo == NULL) {
            count = CFURLEnumeratorPopURL(enumerator);
        }
        else {
            count = 0;
        }
    } while (count > 0);
    
    if (fileInfo == NULL || parent == NULL) { // the parent being null might be an error if it happens... it doesnt seem possible however
        return kCFURLEnumeratorEnd;
    }

    Boolean isDir = CFBooleanGetValue(CFDictionaryGetValue(fileInfo, fileInfoIsDirKey));
    CFURLRef item = NULL;

    if (url != NULL) {
        CFStringRef name = (CFStringRef)CFDictionaryGetValue(fileInfo, fileInfoNameKey);
        item = CFURLCreateCopyAppendingPathComponent(kCFAllocatorDefault, parent, name, isDir);
        *url = item;
    }

    if (fileInfo) {
        CFRelease(fileInfo);
    }

    if (isDir && (enumerator->options & kCFURLEnumeratorDescendRecursively) == 0) {
        if (CFURLEnumeratorPushURL(enumerator, item, error) <= 0) {
            return kCFURLEnumeratorError; // error populated by push
        }
    }

    if (enumerator->propertyKeys) {
        CFDictionaryRef properties = CFURLCopyResourcePropertiesForKeys(item, enumerator->propertyKeys, error);
        if (properties != NULL) {
            CFRelease(properties);
            return kCFURLEnumeratorSuccess;
        } else {
            return kCFURLEnumeratorError;
        }
    } else {
        return kCFURLEnumeratorSuccess;
    }
}

void CFURLEnumeratorSkipDescendents(CFURLEnumeratorRef enumer) {
    struct __CFURLEnumerator *enumerator = (struct __CFURLEnumerator *)enumer;
    enumerator->options &= ~(kCFURLEnumeratorDescendRecursively);
}

CFIndex CFURLEnumeratorGetDescendentLevel(CFURLEnumeratorRef enumerator) {
    if (enumerator->urlStack == NULL) {
        return 0;
    }
    return CFArrayGetCount(enumerator->urlStack) + 1;
}

/*
Boolean CFURLEnumeratorGetSourceDidChange(CFURLEnumeratorRef enumerator) {
    return false;
}
*/
