//
//  CFFSUtils.c
//  CFNetwork
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#include "CFFSUtils.h"

#include <errno.h>
#include <sys/stat.h>
#include <sys/mman.h>
#include <dirent.h>

static void allocatorUnmap(void* ptr, void* info);


/* Wrappers */

int _CFFSOpen(CFStringRef path, int flags, int mode) {
    char* pathRep = _CFFSCreateRepresentation(path);
    if (!pathRep) {
        return -1;
    }
    int fd = open(pathRep, flags, mode);
    free(pathRep);
    return fd;
}

int _CFFSUnlink(CFStringRef path) {
    char* pathRep = _CFFSCreateRepresentation(path);
    if (!pathRep) {
        return -1;
    }
    int result = unlink(pathRep);
    free(pathRep);
    return result;
}

CFStringRef _CFFSRealpath(CFStringRef path) {
    char* pathRep = _CFFSCreateRepresentation(path);
    if (!pathRep) {
        return NULL;
    }

    CFStringRef realPath = NULL;
    char* realPathRep = realpath(pathRep, NULL);
    if (realPathRep) {
        realPath = CFStringCreateWithFileSystemRepresentation(kCFAllocatorDefault, realPathRep);
        free(realPathRep);
    }
    free(pathRep);
    return realPath;
}

int _CFFSStat(CFStringRef path, struct stat* st) {
    char* pathRep = _CFFSCreateRepresentation(path);
    if (!pathRep) {
        return -1;
    }
    int result = stat(pathRep, st);
    free(pathRep);
    return result;
}


/* Helpers */

char* _CFFSCreateRepresentation(CFStringRef path) {
    if (!path) {
        errno = EINVAL;
        return NULL;
    }
    CFIndex length = CFStringGetMaximumSizeOfFileSystemRepresentation(path);
    char* buffer = (char*)malloc(length);
    if (!buffer) {
        return NULL;
    }
    if (!CFStringGetFileSystemRepresentation(path, buffer, length)) {
        free(buffer);
        errno = ENAMETOOLONG;
        return NULL;
    }
    return buffer;
}

Boolean _CFFSIsSamePath(CFStringRef path1, CFStringRef path2) {
    if (!path1 && !path2) {
        return true;
    }
    if (!path1 || !path2) {
        return false;
    }
    path1 = _CFFSRealpath(path1);
    path2 = _CFFSRealpath(path2);
    Boolean result = path1 && path2 && CFEqual(path1, path2);
    if (path1) {
        CFRelease(path1);
    }
    if (path2) {
        CFRelease(path2);
    }
    return result;
}

void _CFFSAppendPathComponent(CFStringRef* result, CFStringRef path, CFStringRef component) {
    if (!result) {
        errno = EINVAL;
        return;
    }
    if (!path && !component) {
        *result = NULL;
        return;
    }
    if (path) {
        if (component) {
            *result = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("%@/%@"), path, component);
        } else {
            *result = (CFStringRef)CFRetain(path);
        }
    } else {
        *result = (CFStringRef)CFRetain(component);
    }
}

void _CFFSGetLastPathComponent(CFStringRef* result, CFStringRef path) {
    if (!result) {
        return;
    }
    if (!path) {
        *result = NULL;
        return;
    }

    CFRange slash = CFStringFind(path, CFSTR("/"), kCFCompareBackwards);
    if (slash.location == kCFNotFound) {
        *result = (CFStringRef)CFRetain(path);
        return;
    }

    CFIndex lastSlashLocation = CFStringGetLength(path);
    while (slash.location == lastSlashLocation - 1) {
        lastSlashLocation = slash.location;
        Boolean found = CFStringFindWithOptions(
            path,
            CFSTR("/"),
            CFRangeMake(0, lastSlashLocation),
            kCFCompareBackwards,
            &slash);
        if (!found) {
            slash.location = -1;
            break;
        }
    }
    slash.location += 1;
    *result = CFStringCreateWithSubstring(
        kCFAllocatorDefault,
        path,
        CFRangeMake(slash.location, lastSlashLocation - slash.location));
}

Boolean _CFFSCheckCreateDirectory(CFStringRef path) {
    char* pathRep = _CFFSCreateRepresentation(path);
    if (!pathRep) {
        return false;
    }

    struct stat st = {0};
    if (stat(pathRep, &st)) {
        for (char* lastSlash = pathRep;;) {
            char* slash = strchr(lastSlash, '/');
            if (!slash) {
                mkdir(pathRep, 0755);
                break;
            }
            if (slash != lastSlash) {
                *slash = 0;
                mkdir(pathRep, 0755);
                *slash = '/';
            }
            lastSlash = slash + 1;
        }
    }

    Boolean result = !stat(pathRep, &st) && S_ISDIR(st.st_mode);
    free(pathRep);
    return result;
}

Boolean _CFFSCreateDataFromFile(CFDataRef* data, CFStringRef filePath) {
    if (!data) {
        errno = EINVAL;
        return false;
    }
    *data = NULL;

    int fd = -1;
    void* map = MAP_FAILED;
    int mapSize = 0;
    do {
        fd = _CFFSOpen(filePath, O_RDONLY, 0);
        if (fd == -1) {
            break;
        }

        struct stat st = {0};
        if (fstat(fd, &st)) {
            break;
        }
        if (st.st_size > INT_MAX) {
            errno = EFBIG;
            break;
        }
        mapSize = (int)st.st_size;

        map = mmap(NULL, mapSize, PROT_READ, MAP_PRIVATE, fd, 0);
        if (map == MAP_FAILED) {
            break;
        }

        CFAllocatorRef unmapper = CFAllocatorCreate(kCFAllocatorDefault, &(CFAllocatorContext){
            .info = (void*)mapSize,
            .deallocate = &allocatorUnmap
        });

        *data = CFDataCreateWithBytesNoCopy(kCFAllocatorDefault,
                                            (const UInt8*)map, mapSize, unmapper);
        if (*data) {
            map = MAP_FAILED;
        }
        CFRelease(unmapper);
    } while (0);
    if (map != MAP_FAILED) {
        munmap(map, mapSize);
    }
    if (fd != -1) {
        close(fd);
    }

    return *data != NULL;
}

Boolean _CFFSWriteDataToFile(CFDataRef data, CFStringRef filePath) {
    Boolean result = false;

    int fd = -1;
    fd = _CFFSOpen(filePath, O_WRONLY | O_TRUNC | O_CREAT, 0644);
    if (fd != -1) {
        CFIndex length = 0;
        if (data) {
            length = CFDataGetLength(data);
            const UInt8* buffer = CFDataGetBytePtr(data);
            while (length > 0) {
                ssize_t written = write(fd, buffer, length);
                if (written < 0) {
                    if (errno == EINTR) {
                        continue;
                    } else {
                        break;
                    }
                } else if (written == 0) {
                    break;
                } else {
                    length -= written;
                    buffer += written;
                }
            }
        }
        close(fd);
        if (!length) {
            result = true;
        } else {
            result = false;
            int error = errno;
            _CFFSUnlink(filePath);
            errno = error;
        }
    }

    return result;
}

Boolean _CFFSWritePropertyListToFile(CFPropertyListRef plist, CFStringRef filePath) {
    CFErrorRef error = NULL;
    CFDataRef data = CFPropertyListCreateData(kCFAllocatorDefault,
        plist, kCFPropertyListBinaryFormat_v1_0, kCFPropertyListImmutable, &error);
    if (!data) {
        if (error) {
            CFRelease(error);
        }
        errno = EINVAL;
        return false;
    }
    Boolean result = _CFFSWriteDataToFile(data, filePath);
    CFRelease(data);
    return result;
}

Boolean _CFFSCreatePropertyListFromFile(CFPropertyListRef* plist, CFStringRef filePath) {
    if (!plist) {
        errno = EINVAL;
        return false;
    }
    CFDataRef data = NULL;
    if (!_CFFSCreateDataFromFile(&data, filePath)) {
        return false;
    }
    CFErrorRef error = NULL;
    *plist = CFPropertyListCreateWithData(kCFAllocatorDefault,
        data, kCFPropertyListImmutable, NULL, &error);
    CFRelease(data);
    if (!*plist) {
        if (error) {
            CFRelease(error);
        }
        errno = EILSEQ;
        return false;
    }
    return true;
}

Boolean _CFFSListPathContents(CFStringRef path,
                              CFMutableArrayRef* files, CFMutableArrayRef* directories)
{
    if (files) {
        *files = NULL;
    }
    if (directories) {
        *directories = NULL;
    }

    char* pathRep = _CFFSCreateRepresentation(path);
    if (!pathRep) {
        return false;
    }

    CFMutableArrayRef collectedFiles = files ?
        CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks) :
        NULL;
    CFMutableArrayRef collectedDirectories = directories ?
        CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks) :
        NULL;

    Boolean result = false;
    DIR* dir = NULL;
    do {
        dir = opendir(pathRep);
        if (!dir) {
            break;
        }

        for (struct dirent state;;) {
            struct dirent* entry = NULL;
            int error = readdir_r(dir, &state, &entry);
            if (error) {
                errno = error;
                break;
            }
            if (!entry) {
                result = true;
                break;
            }

            if (!strcmp(entry->d_name, ".") || !strcmp(entry->d_name, "..")) {
                continue;
            }

            if (entry->d_type == DT_DIR) {
                if (collectedDirectories) {
                    CFStringRef name = CFStringCreateWithFileSystemRepresentation(
                        kCFAllocatorDefault,
                        entry->d_name);
                    CFArrayAppendValue(collectedDirectories, name);
                    CFRelease(name);
                }
            } else {
                if (collectedFiles) {
                    CFStringRef name = CFStringCreateWithFileSystemRepresentation(
                        kCFAllocatorDefault,
                        entry->d_name);
                    CFArrayAppendValue(collectedFiles, name);
                    CFRelease(name);
                }
            }
        }
        if (result) {
            if (files) {
                *files = (CFMutableArrayRef)CFRetain(collectedFiles);
            }
            if (directories) {
                *directories = (CFMutableArrayRef)CFRetain(collectedDirectories);
            }
        }
    }
    while (0);
    free(pathRep);
    if (dir) {
        closedir(dir);
    }
    if (collectedFiles) {
        CFRelease(collectedFiles);
    }
    if (collectedDirectories) {
        CFRelease(collectedDirectories);
    }

    return result;
}


/* Private */

static void allocatorUnmap(void* ptr, void* info) {
    int error = munmap(ptr, (size_t)info);
    assert(!error);
}
