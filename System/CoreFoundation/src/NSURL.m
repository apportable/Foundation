//
//  NSURL.m
//  CoreFoundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/NSURL.h>
#import <Foundation/NSException.h>
#import <Foundation/NSPathUtilities.h>
#import <CoreFoundation/CFString.h>
#import <CoreFoundation/CFURL.h>
#import <CoreFoundation/CFDictionary.h>
#import "CFInternal.h"
#import "CFPriv.h"
#import "NSURLInternal.h"
#import <objc/runtime.h>

#define STACK_BUFFER_SIZE 100 // pretty safe bet this will be quite unlikely to use more than this since there are only 94 properties

NSString *const NSURLFileScheme = @"file";
NSString *const NSURLKeysOfUnsetValuesKey = @"NSURLKeysOfUnsetValuesKey";
NSString *const NSURLNameKey = @"NSURLNameKey";
NSString *const NSURLLocalizedNameKey = @"NSURLLocalizedNameKey";
NSString *const NSURLIsRegularFileKey = @"NSURLIsRegularFileKey";
NSString *const NSURLIsDirectoryKey = @"NSURLIsDirectoryKey";
NSString *const NSURLIsSymbolicLinkKey = @"NSURLIsSymbolicLinkKey";
NSString *const NSURLIsVolumeKey = @"NSURLIsVolumeKey";
NSString *const NSURLIsPackageKey = @"NSURLIsPackageKey";
NSString *const NSURLIsSystemImmutableKey = @"NSURLIsSystemImmutableKey";
NSString *const NSURLIsUserImmutableKey = @"NSURLIsUserImmutableKey";
NSString *const NSURLIsHiddenKey = @"NSURLIsHiddenKey";
NSString *const NSURLHasHiddenExtensionKey = @"NSURLHasHiddenExtensionKey";
NSString *const NSURLCreationDateKey = @"NSURLCreationDateKey";
NSString *const NSURLContentAccessDateKey = @"NSURLContentAccessDateKey";
NSString *const NSURLContentModificationDateKey = @"NSURLContentModificationDateKey";
NSString *const NSURLAttributeModificationDateKey = @"NSURLAttributeModificationDateKey";
NSString *const NSURLLinkCountKey = @"NSURLLinkCountKey";
NSString *const NSURLParentDirectoryURLKey = @"NSURLParentDirectoryURLKey";
NSString *const NSURLVolumeURLKey = @"NSURLVolumeURLKey";
NSString *const NSURLTypeIdentifierKey = @"NSURLTypeIdentifierKey";
NSString *const NSURLLocalizedTypeDescriptionKey = @"NSURLLocalizedTypeDescriptionKey";
NSString *const NSURLLabelNumberKey = @"NSURLLabelNumberKey";
NSString *const NSURLLabelColorKey = @"NSURLLabelColorKey";
NSString *const NSURLLocalizedLabelKey = @"NSURLLocalizedLabelKey";
NSString *const NSURLEffectiveIconKey = @"NSURLEffectiveIconKey";
NSString *const NSURLCustomIconKey = @"NSURLCustomIconKey";
NSString *const NSURLFileResourceIdentifierKey = @"NSURLFileResourceIdentifierKey";
NSString *const NSURLVolumeIdentifierKey = @"NSURLVolumeIdentifierKey";
NSString *const NSURLPreferredIOBlockSizeKey = @"NSURLPreferredIOBlockSizeKey";
NSString *const NSURLIsReadableKey = @"NSURLIsReadableKey";
NSString *const NSURLIsWritableKey = @"NSURLIsWritableKey";
NSString *const NSURLIsExecutableKey = @"NSURLIsExecutableKey";
NSString *const NSURLFileSecurityKey = @"NSURLFileSecurityKey";
NSString *const NSURLIsExcludedFromBackupKey = @"NSURLIsExcludedFromBackupKey";
NSString *const NSURLPathKey = @"_NSURLPathKey";
NSString *const NSURLIsMountTriggerKey = @"NSURLIsMountTriggerKey";
NSString *const NSURLFileResourceTypeKey = @"NSURLFileResourceTypeKey";
NSString *const NSURLFileResourceTypeNamedPipe = @"NSURLFileResourceTypeNamedPipe";
NSString *const NSURLFileResourceTypeCharacterSpecial = @"NSURLFileResourceTypeCharacterSpecial";
NSString *const NSURLFileResourceTypeDirectory = @"NSURLFileResourceTypeDirectory";
NSString *const NSURLFileResourceTypeBlockSpecial = @"NSURLFileResourceTypeBlockSpecial";
NSString *const NSURLFileResourceTypeRegular = @"NSURLFileResourceTypeRegular";
NSString *const NSURLFileResourceTypeSymbolicLink = @"NSURLFileResourceTypeSymbolicLink";
NSString *const NSURLFileResourceTypeSocket = @"NSURLFileResourceTypeSocket";
NSString *const NSURLFileResourceTypeUnknown = @"NSURLFileResourceTypeUnknown";
NSString *const NSURLFileSizeKey = @"NSURLFileSizeKey";
NSString *const NSURLFileAllocatedSizeKey = @"NSURLFileAllocatedSizeKey";
NSString *const NSURLTotalFileSizeKey = @"NSURLTotalFileSizeKey";
NSString *const NSURLTotalFileAllocatedSizeKey = @"NSURLTotalFileAllocatedSizeKey";
NSString *const NSURLIsAliasFileKey = @"NSURLIsAliasFileKey";
NSString *const NSURLVolumeLocalizedFormatDescriptionKey = @"NSURLVolumeLocalizedFormatDescriptionKey";
NSString *const NSURLVolumeTotalCapacityKey = @"NSURLVolumeTotalCapacityKey";
NSString *const NSURLVolumeAvailableCapacityKey = @"NSURLVolumeAvailableCapacityKey";
NSString *const NSURLVolumeResourceCountKey = @"NSURLVolumeResourceCountKey";
NSString *const NSURLVolumeSupportsPersistentIDsKey = @"NSURLVolumeSupportsPersistentIDsKey";
NSString *const NSURLVolumeSupportsSymbolicLinksKey = @"NSURLVolumeSupportsSymbolicLinksKey";
NSString *const NSURLVolumeSupportsHardLinksKey = @"NSURLVolumeSupportsHardLinksKey";
NSString *const NSURLVolumeSupportsJournalingKey = @"NSURLVolumeSupportsJournalingKey";
NSString *const NSURLVolumeIsJournalingKey = @"NSURLVolumeIsJournalingKey";
NSString *const NSURLVolumeSupportsSparseFilesKey = @"NSURLVolumeSupportsSparseFilesKey";
NSString *const NSURLVolumeSupportsZeroRunsKey = @"NSURLVolumeSupportsZeroRunsKey";
NSString *const NSURLVolumeSupportsCaseSensitiveNamesKey = @"NSURLVolumeSupportsCaseSensitiveNamesKey";
NSString *const NSURLVolumeSupportsCasePreservedNamesKey = @"NSURLVolumeSupportsCasePreservedNamesKey";
NSString *const NSURLVolumeSupportsRootDirectoryDatesKey = @"NSURLVolumeSupportsRootDirectoryDatesKey";
NSString *const NSURLVolumeSupportsVolumeSizesKey = @"NSURLVolumeSupportsVolumeSizesKey";
NSString *const NSURLVolumeSupportsRenamingKey = @"NSURLVolumeSupportsRenamingKey";
NSString *const NSURLVolumeSupportsAdvisoryFileLockingKey = @"NSURLVolumeSupportsAdvisoryFileLockingKey";
NSString *const NSURLVolumeSupportsExtendedSecurityKey = @"NSURLVolumeSupportsExtendedSecurityKey";
NSString *const NSURLVolumeIsBrowsableKey = @"NSURLVolumeIsBrowsableKey";
NSString *const NSURLVolumeMaximumFileSizeKey = @"NSURLVolumeMaximumFileSizeKey";
NSString *const NSURLVolumeIsEjectableKey = @"NSURLVolumeIsEjectableKey";
NSString *const NSURLVolumeIsRemovableKey = @"NSURLVolumeIsRemovableKey";
NSString *const NSURLVolumeIsInternalKey = @"NSURLVolumeIsInternalKey";
NSString *const NSURLVolumeIsAutomountedKey = @"NSURLVolumeIsAutomountedKey";
NSString *const NSURLVolumeIsLocalKey = @"NSURLVolumeIsLocalKey";
NSString *const NSURLVolumeIsReadOnlyKey = @"NSURLVolumeIsReadOnlyKey";
NSString *const NSURLVolumeCreationDateKey = @"NSURLVolumeCreationDateKey";
NSString *const NSURLVolumeURLForRemountingKey = @"NSURLVolumeURLForRemountingKey";
NSString *const NSURLVolumeUUIDStringKey = @"NSURLVolumeUUIDStringKey";
NSString *const NSURLVolumeNameKey = @"NSURLVolumeNameKey";
NSString *const NSURLVolumeLocalizedNameKey = @"NSURLVolumeLocalizedNameKey";
NSString *const NSURLIsUbiquitousItemKey = @"NSURLIsUbiquitousItemKey";
NSString *const NSURLUbiquitousItemHasUnresolvedConflictsKey = @"NSURLUbiquitousItemHasUnresolvedConflictsKey";
NSString *const NSURLUbiquitousItemIsDownloadedKey = @"NSURLUbiquitousItemIsDownloadedKey";
NSString *const NSURLUbiquitousItemIsDownloadingKey = @"NSURLUbiquitousItemIsDownloadingKey";
NSString *const NSURLUbiquitousItemIsUploadedKey = @"NSURLUbiquitousItemIsUploadedKey";
NSString *const NSURLUbiquitousItemIsUploadingKey = @"NSURLUbiquitousItemIsUploadingKey";
NSString *const NSURLUbiquitousItemPercentDownloadedKey = @"NSURLUbiquitousItemPercentDownloadedKey";
NSString *const NSURLUbiquitousItemPercentUploadedKey = @"NSURLUbiquitousItemPercentUploadedKey";

static void posixError(CFErrorRef *error) {
    const CFStringRef keys[1] = {
        kCFErrorUnderlyingErrorKey,
    };
    CFStringRef err = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("%s"), strerror(errno));
    CFTypeRef values[1] = {
        err,
    };

    if (error != NULL)
    {
        *error = CFErrorCreateWithUserInfoKeysAndValues(kCFAllocatorDefault, kCFErrorDomainPOSIX, errno, (const void *const *)keys, (const void *const *)values, 1);
    }

    CFRelease(err);
}

static Boolean CFURLStat(CFURLRef url, struct stat *info) {
    UInt8 path[PATH_MAX] = { 0 };

    if (CFURLGetFileSystemRepresentation(url, true, path, PATH_MAX))
    {
        return stat(path, info) != -1;
    }

    return false;
}

static pthread_mutex_t resInfoLock = PTHREAD_MUTEX_INITIALIZER;

static CFTypeRef CFURLCreatePropertyForKey(CFURLRef url, CFStringRef key, CFErrorRef *error)
{
    CFTypeRef value = NULL;
    struct stat info;
    // NOTE: not all of the properties are currently supported, however the most common ones should have quasi-reasonable implementations
    if (CFEqual(key, kCFURLNameKey))
    {
        //Key for the resource’s name in the file system, returned as a CFString object.
        CFURLRef trimmed = CFURLCreateCopyDeletingPathExtension(kCFAllocatorDefault, url);
        value = CFURLCopyLastPathComponent(trimmed);
        CFRelease(trimmed);
    }
    else if (CFEqual(key, kCFURLLocalizedNameKey))
    {
        // Key for the resource’s localized or extension-hidden name, retuned as a CFString object.
        CFURLRef trimmed = CFURLCreateCopyDeletingPathExtension(kCFAllocatorDefault, url);
        value = CFURLCopyLastPathComponent(trimmed); // this should be localized
        CFRelease(trimmed);
    }
    else if (CFEqual(key, kCFURLPathKey))
    {
        // A CFString value containing the URL’s path as a file system path. (read-only)
        value = CFURLCopyFileSystemPath(url, kCFURLPOSIXPathStyle);
    }
    else if (CFEqual(key, kCFURLIsRegularFileKey))
    {
        // Key for determining whether the resource is a regular file, as opposed to a directory or a symbolic link. Returned as a CFBoolean object.
        if (CFURLStat(url, &info))
        {
            value = S_ISREG(info.st_mode) ? kCFBooleanTrue : kCFBooleanFalse;
        }
        else
        {
            posixError(error);
        }
    }
    else if (CFEqual(key, kCFURLIsDirectoryKey))
    {
        // Key for determining whether the resource is a directory, returned as a CFBoolean object.
        if (CFURLStat(url, &info))
        {
            value = S_ISDIR(info.st_mode) ? kCFBooleanTrue : kCFBooleanFalse;
        }
        else
        {
            posixError(error);
        }
    }
    else if (CFEqual(key, kCFURLIsSymbolicLinkKey))
    {
        // Key for determining whether the resource is a directory, returned as a CFBoolean object.
        if (CFURLStat(url, &info))
        {
            value = S_ISLNK(info.st_mode) ? kCFBooleanTrue : kCFBooleanFalse;
        }
        else
        {
            posixError(error);
        }
    }
    else if (CFEqual(key, kCFURLIsVolumeKey))
    {
        // is this doable?
    }
    else if (CFEqual(key, kCFURLIsPackageKey))
    {
        // is this doable?
    }
    else if (CFEqual(key, kCFURLIsSystemImmutableKey))
    {
        // Key for determining whether the resource's system immutable bit is set, returned as a CFBoolean object.
        if (CFURLStat(url, &info))
        {
            value = (info.st_mode & S_IWOTH) != S_IWOTH ? kCFBooleanTrue : kCFBooleanFalse;
        }
        else
        {
            posixError(error);
        }
    }
    else if (CFEqual(key, kCFURLIsUserImmutableKey))
    {
        // Key for determining whether the resource's user immutable bit is set, returned as a CFBoolean object.
        if (CFURLStat(url, &info))
        {
            value = (info.st_mode & S_IWUSR) != S_IWUSR ? kCFBooleanTrue : kCFBooleanFalse;
        }
        else
        {
            posixError(error);
        }
    }
    else if (CFEqual(key, kCFURLIsHiddenKey))
    {
        CFStringRef lastPathComp = CFURLCopyLastPathComponent(url);
        Boolean isHidden = false;

        if (CFStringGetLength(lastPathComp) > 0)
        {
            isHidden = CFStringGetCharacterAtIndex(lastPathComp, 0) == '.';
        }

        value = isHidden ? kCFBooleanTrue : kCFBooleanFalse;
        CFRelease(lastPathComp);
    }
    else if (CFEqual(key, kCFURLHasHiddenExtensionKey))
    {
        value = kCFBooleanFalse;
    }
    else if (CFEqual(key, kCFURLCreationDateKey))
    {
        // Key for the resource’s creation date, returned as a CFDate object if the volume supports creation dates, or nil if creation dates are unsupported.
        if (CFURLStat(url, &info))
        {
            CFTimeInterval t = (CFTimeInterval)(info.st_ctime * NSEC_PER_SEC + info.st_ctime_nsec) / (CFTimeInterval)NSEC_PER_SEC;
            value = CFDateCreate(kCFAllocatorDefault, t);
        }
        else
        {
            posixError(error);
        }
    }
    else if (CFEqual(key, kCFURLContentAccessDateKey))
    {
        if (CFURLStat(url, &info))
        {
            CFTimeInterval t = (CFTimeInterval)(info.st_atime * NSEC_PER_SEC + info.st_atime_nsec) / (CFTimeInterval)NSEC_PER_SEC;
            value = CFDateCreate(kCFAllocatorDefault, t);
        }
        else
        {
            posixError(error);
        }
    }
    else if (CFEqual(key, kCFURLContentModificationDateKey))
    {
        if (CFURLStat(url, &info))
        {
            CFTimeInterval t = (CFTimeInterval)(info.st_mtime * NSEC_PER_SEC + info.st_mtime_nsec) / (CFTimeInterval)NSEC_PER_SEC;
            value = CFDateCreate(kCFAllocatorDefault, t);
        }
        else
        {
            posixError(error);
        }
    }
    else if (CFEqual(key, kCFURLAttributeModificationDateKey))
    {
        if (CFURLStat(url, &info))
        {
            CFTimeInterval t = (CFTimeInterval)(info.st_mtime * NSEC_PER_SEC + info.st_mtime_nsec) / (CFTimeInterval)NSEC_PER_SEC;
            value = CFDateCreate(kCFAllocatorDefault, t);
        }
        else
        {
            posixError(error);
        }
    }
    else if (CFEqual(key, kCFURLLinkCountKey))
    {
        // Key for the number of hard links to the resource, returned as a CFNumber object.
        if (CFURLStat(url, &info))
        {
            value = CFNumberCreate(kCFAllocatorDefault, kCFNumberIntType, &info.st_nlink);
        }
        else
        {
            posixError(error);
        }
    }
    else if (CFEqual(key, kCFURLParentDirectoryURLKey))
    {
        // Key for the parent directory of the resource, returned as a CFURL object, or nil if the resource is the root directory of its volume.
        value = CFURLCreateCopyDeletingLastPathComponent(kCFAllocatorDefault, url);
    }
    else if (CFEqual(key, kCFURLVolumeURLKey))
    {
        // is this doable?
    }
    else if (CFEqual(key, kCFURLTypeIdentifierKey))
    {
        // Key for the resource’s uniform type identifier (UTI), returned as a CFString object.

    }
    else if (CFEqual(key, kCFURLLocalizedTypeDescriptionKey))
    {
        // Key for the resource’s localized type description, returned as a CFString object.

    }
    else if (CFEqual(key, kCFURLLabelNumberKey))
    {
        // Key for the resource’s label number, returned as a CFNumber object.
    }
    else if (CFEqual(key, kCFURLLabelColorKey))
    {
        
    }
    else if (CFEqual(key, kCFURLLocalizedLabelKey))
    {
        
    }
    else if (CFEqual(key, kCFURLEffectiveIconKey))
    {
        
    }
    else if (CFEqual(key, kCFURLCustomIconKey))
    {
        
    }
    else if (CFEqual(key, kCFURLFileResourceIdentifierKey))
    {
        // Key for the resource’s unique identifier, returned as a CFType object.
        // This identifier can be used to determine equality between file system resources with the CFEqual function. Two resources are equal if they have the same file-system path or if their paths link to the same inode on the same file system.
        // The value of this identifier is not persistent across system restarts.
        // Available in iOS 5.0 and later.

    }
    else if (CFEqual(key, kCFURLVolumeIdentifierKey))
    {
        
    }
    else if (CFEqual(key, kCFURLPreferredIOBlockSizeKey))
    {
        // Key for the optimal block size to use when reading or writing this file's data, returned as a CFNumber object, or NULL if the preferred size is not available.
        if (CFURLStat(url, &info))
        {
            value = CFNumberCreate(kCFAllocatorDefault, kCFNumberLongType, &info.st_blksize);
        }
        else
        {
            posixError(error);
        }
    }
    else if (CFEqual(key, kCFURLIsReadableKey))
    {
        // Key for determining whether the current process (as determined by the EUID) can read the resource, returned as a CFBoolean object.
        if (CFURLStat(url, &info))
        {
            value = (info.st_mode & S_IRUSR) == S_IRUSR ? kCFBooleanTrue : kCFBooleanFalse;
        }
        else
        {
            posixError(error);
        }
    }
    else if (CFEqual(key, kCFURLIsWritableKey))
    {
        // Key for determining whether the current process (as determined by the EUID) can write to the resource, returned as a CFBoolean object.
        if (CFURLStat(url, &info))
        {
            value = (info.st_mode & S_IWUSR) == S_IWUSR ? kCFBooleanTrue : kCFBooleanFalse;
        }
        else
        {
            posixError(error);
        }
    }
    else if (CFEqual(key, kCFURLIsExecutableKey))
    {
        // Key for determining whether the current process (as determined by the EUID) can execute the resource (if it is a file) or search the resource (if it is a directory), returned as a CFBoolean object.
        if (CFURLStat(url, &info))
        {
            value = (info.st_mode & S_IXUSR) == S_IXUSR ? kCFBooleanTrue : kCFBooleanFalse;
        }
        else
        {
            posixError(error);
        }
    }
    else if (CFEqual(key, kCFURLFileSecurityKey))
    {
        
    }
    else if (CFEqual(key, kCFURLIsExcludedFromBackupKey))
    {
        value = kCFBooleanTrue;
    }
    else if (CFEqual(key, kCFURLFileResourceTypeKey))
    {
        // Key for the resource’s object type, returned as a CFString object. See “File Resource Types” for possible values.
    }

    return value;
}

static const void *nullSafeRetain(CFAllocatorRef allocator, const void *value)
{
    if (value != NULL)
    {
        return (const void *)CFRetain((CFTypeRef)value);
    }
    else
    {
        return NULL;
    }
}

static void nullSafeRelease(CFAllocatorRef allocator, const void *value)
{
    if (value != NULL)
    {
        CFRelease((CFTypeRef)value);
    }
}

static CFStringRef nullSafeCopyDescription(const void *value)
{
    if (value != NULL)
    {
        return CFCopyDescription((CFTypeRef)value);
    }
    else
    {
        return CFSTR("(null)");
    }
}

static Boolean nullSafeEqual(const void *value1, const void *value2)
{
    if (value1 == NULL || value2 == NULL)
    {
        return value1 == value2;
    }
    else
    {
        return CFEqual((CFTypeRef)value1, (CFTypeRef)value2);
    }
}


static CFDictionaryValueCallBacks nullSafeCallbacks = {
    0,
    &nullSafeRetain,
    &nullSafeRelease,
    &nullSafeCopyDescription,
    &nullSafeEqual,
};

static inline CFMutableDictionaryRef CFURLResourceInfo(CFURLRef url)
{
    CFMutableDictionaryRef resourceInfo = __CFURLResourceInfoPtr(url);
    pthread_mutex_lock(&resInfoLock);

    if (resourceInfo == NULL)
    {
        resourceInfo = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFCopyStringDictionaryKeyCallBacks, &nullSafeCallbacks);
        __CFURLSetResourceInfoPtr(url, resourceInfo); // retains the info
        CFRelease(resourceInfo);
    }

    resourceInfo = (CFMutableDictionaryRef)CFRetain(resourceInfo);
    pthread_mutex_unlock(&resInfoLock);
    return resourceInfo;
}

static inline void CFURLResourceInfoUpdate(CFMutableDictionaryRef info, CFStringRef key, CFTypeRef value)
{
    pthread_mutex_lock(&resInfoLock);
    CFDictionarySetValue(info, key, value);
    pthread_mutex_unlock(&resInfoLock);
}

static inline void CFURLResourceInfoUpdateRelease(CFMutableDictionaryRef info, CFStringRef key, CFTypeRef value)
{
    pthread_mutex_lock(&resInfoLock);
    CFDictionarySetValue(info, key, value);
    CFRelease(info);
    pthread_mutex_unlock(&resInfoLock);
}

static inline void CFURLResourceInfoRelease(CFMutableDictionaryRef info)
{
    pthread_mutex_lock(&resInfoLock);
    CFRelease(info);
    pthread_mutex_unlock(&resInfoLock);
}

Boolean CFURLCopyResourcePropertyForKey(CFURLRef url, CFStringRef key, void *propertyValueTypeRefPtr, CFErrorRef *error)
{
    if (propertyValueTypeRefPtr != NULL)
    {
        *(CFTypeRef *)propertyValueTypeRefPtr = NULL;
    }

    if (error != NULL)
    {
        *error = NULL;
    }

    CFMutableDictionaryRef resourceInfo = CFURLResourceInfo(url);
    CFTypeRef value = (CFTypeRef)CFDictionaryGetValue(resourceInfo, key);

    if (value == NULL)
    {
        value = CFURLCreatePropertyForKey(url, key, error);
    }
    else
    {
        value = CFRetain(value);
    }
    
    if (propertyValueTypeRefPtr != NULL)
    {
        *(CFTypeRef *)propertyValueTypeRefPtr = value;
    }
    
    CFURLResourceInfoUpdateRelease(resourceInfo, key, value);

    if (value != NULL)
    {
        CFRelease(value);
        return true;
    }

    return false;
}

CFDictionaryRef CFURLCopyResourcePropertiesForKeys(CFURLRef url, CFArrayRef keys, CFErrorRef *error)
{
    CFDictionaryRef props = NULL;
    CFTypeRef stack_keys[STACK_BUFFER_SIZE] = { NULL };
    CFTypeRef stack_values[STACK_BUFFER_SIZE] = { NULL };
    CFTypeRef *property_keys = &stack_keys[0];
    CFTypeRef *property_values = &stack_values[0];
    CFMutableDictionaryRef resourceInfo = CFURLResourceInfo(url);
    CFIndex count = CFArrayGetCount(keys);
    CFIndex propCount = 0;
    if (count > STACK_BUFFER_SIZE)
    {
        property_keys = malloc(sizeof(CFTypeRef) * count);

        if (property_keys == NULL)
        {
            // populate malloc error here
            return NULL;
        }

        property_values = malloc(sizeof(CFTypeRef) * count);

        if (property_values == NULL)
        {
            free(property_keys);
            // populate malloc error here
            return NULL;
        }
    }

    for (CFIndex idx = 0; idx < count; idx++)
    {
        CFStringRef key = CFArrayGetValueAtIndex(keys, idx);
        CFTypeRef value = (CFTypeRef)CFDictionaryGetValue(resourceInfo, key);

        if (value == NULL)
        {
            value = CFURLCreatePropertyForKey(url, key, error);
        }
        else
        {
            value = CFRetain(value);
        }

        CFURLResourceInfoUpdate(resourceInfo, key, value);

        if (value != NULL)
        {
            property_keys[propCount] = key;
            property_values[propCount] = value;
            propCount++;
        }

    }

    CFURLResourceInfoRelease(resourceInfo);

    props = CFDictionaryCreate(kCFAllocatorDefault, property_keys, property_values, propCount, &kCFCopyStringDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);

    if (property_keys != &stack_keys[0])
    {
        free(property_keys);
    }

    for (CFIndex idx = 0; idx < propCount; idx++)
    {
        CFRelease(property_values[idx]);
    }

    if (property_values != &stack_values[0])
    {
        free(property_values);
    }

    return props;
}

static CFTypeRef CFURLSetPropertyForKey(CFURLRef url, CFStringRef key, CFTypeRef value, CFErrorRef *error) {
    CFTypeRef acceptedValue = NULL;
    // Verify that these only set meta-data and not twiddle real file system items
    if (CFEqual(key, kCFURLNameKey) && CFGetTypeID(value) == CFStringGetTypeID())
    {
        acceptedValue = CFRetain(value);
    }
    else if (CFEqual(key, kCFURLLocalizedNameKey) && CFGetTypeID(value) == CFStringGetTypeID())
    {
        acceptedValue = CFRetain(value);
    }
    else if (CFEqual(key, kCFURLPathKey) && CFGetTypeID(value) == CFStringGetTypeID())
    {
        acceptedValue = CFRetain(value);
    }
    else if (CFEqual(key, kCFURLIsRegularFileKey) && CFGetTypeID(value) == CFBooleanGetTypeID())
    {
        acceptedValue = CFRetain(value);
    }
    else if (CFEqual(key, kCFURLIsDirectoryKey) && CFGetTypeID(value) == CFBooleanGetTypeID())
    {
        acceptedValue = CFRetain(value);
    }
    else if (CFEqual(key, kCFURLIsSymbolicLinkKey) && CFGetTypeID(value) == CFBooleanGetTypeID())
    {
        acceptedValue = CFRetain(value);
    }
    else if (CFEqual(key, kCFURLIsVolumeKey) && CFGetTypeID(value) == CFBooleanGetTypeID())
    {
        acceptedValue = CFRetain(value);
    }
    else if (CFEqual(key, kCFURLIsPackageKey) && CFGetTypeID(value) == CFBooleanGetTypeID())
    {
        acceptedValue = CFRetain(value);
    }
    else if (CFEqual(key, kCFURLIsSystemImmutableKey) && CFGetTypeID(value) == CFBooleanGetTypeID())
    {
        acceptedValue = CFRetain(value);
    }
    else if (CFEqual(key, kCFURLIsUserImmutableKey) && CFGetTypeID(value) == CFBooleanGetTypeID())
    {
        acceptedValue = CFRetain(value);
    }
    else if (CFEqual(key, kCFURLIsHiddenKey) && CFGetTypeID(value) == CFBooleanGetTypeID())
    {
        acceptedValue = CFRetain(value);
    }
    else if (CFEqual(key, kCFURLHasHiddenExtensionKey) && CFGetTypeID(value) == CFBooleanGetTypeID())
    {
        acceptedValue = CFRetain(value);
    }
    else if (CFEqual(key, kCFURLCreationDateKey) && CFGetTypeID(value) == CFDateGetTypeID())
    {
        acceptedValue = CFRetain(value);
    }
    else if (CFEqual(key, kCFURLContentAccessDateKey) && CFGetTypeID(value) == CFDateGetTypeID())
    {
        acceptedValue = CFRetain(value);
    }
    else if (CFEqual(key, kCFURLContentModificationDateKey) && CFGetTypeID(value) == CFDateGetTypeID())
    {
        acceptedValue = CFRetain(value);
    }
    else if (CFEqual(key, kCFURLAttributeModificationDateKey) && CFGetTypeID(value) == CFDateGetTypeID())
    {
        acceptedValue = CFRetain(value);
    }
    else if (CFEqual(key, kCFURLLinkCountKey) && CFGetTypeID(value) == CFNumberGetTypeID())
    {
        acceptedValue = CFRetain(value);
    }
    else if (CFEqual(key, kCFURLParentDirectoryURLKey) && CFGetTypeID(value) == CFURLGetTypeID())
    {
        acceptedValue = CFRetain(value);
    }
    else if (CFEqual(key, kCFURLVolumeURLKey) && CFGetTypeID(value) == CFURLGetTypeID())
    {
        acceptedValue = CFRetain(value);
    }
    else if (CFEqual(key, kCFURLTypeIdentifierKey) && CFGetTypeID(value) == CFStringGetTypeID())
    {
        acceptedValue = CFRetain(value);
    }
    else if (CFEqual(key, kCFURLLocalizedTypeDescriptionKey) && CFGetTypeID(value) == CFStringGetTypeID())
    {
        acceptedValue = CFRetain(value);
    }
    else if (CFEqual(key, kCFURLLabelNumberKey) && CFGetTypeID(value) == CFNumberGetTypeID())
    {
        acceptedValue = CFRetain(value);
    }
    else if (CFEqual(key, kCFURLLabelColorKey))
    {
        // not supported, and what is a CFColorRef anyhow? do they mean CGColorRef?
    }
    else if (CFEqual(key, kCFURLLocalizedLabelKey) && CFGetTypeID(value) == CFStringGetTypeID())
    {
        acceptedValue = CFRetain(value);
    }
    else if (CFEqual(key, kCFURLEffectiveIconKey))
    {
        // not supported, go away!
    }
    else if (CFEqual(key, kCFURLCustomIconKey))
    {
        // same as prev
    }
    else if (CFEqual(key, kCFURLFileResourceIdentifierKey))
    {
        // NO
    }
    else if (CFEqual(key, kCFURLVolumeIdentifierKey))
    {
        // not supported
    }
    else if (CFEqual(key, kCFURLPreferredIOBlockSizeKey) && CFGetTypeID(value) == CFNumberGetTypeID())
    {
        acceptedValue = CFRetain(value);
    }
    else if (CFEqual(key, kCFURLIsReadableKey) && CFGetTypeID(value) == CFBooleanGetTypeID())
    {
        acceptedValue = CFRetain(value);
    }
    else if (CFEqual(key, kCFURLIsWritableKey) && CFGetTypeID(value) == CFBooleanGetTypeID())
    {
        acceptedValue = CFRetain(value);
    }
    else if (CFEqual(key, kCFURLIsExecutableKey) && CFGetTypeID(value) == CFBooleanGetTypeID())
    {
        acceptedValue = CFRetain(value);
    }
    else if (CFEqual(key, kCFURLFileSecurityKey))
    {
        // not supported
    }
    else if (CFEqual(key, kCFURLIsExcludedFromBackupKey) && CFGetTypeID(value) == CFBooleanGetTypeID())
    {
        acceptedValue = CFRetain(value);
    }
    else if (CFEqual(key, kCFURLFileResourceTypeKey))
    {
        // not supported
    }

    return acceptedValue;
}

Boolean CFURLSetResourcePropertyForKey(CFURLRef url, CFStringRef key, CFTypeRef propertyValue, CFErrorRef *error)
{
    CFMutableDictionaryRef resourceInfo = CFURLResourceInfo(url);

    CFTypeRef value = CFURLSetPropertyForKey(url, key, propertyValue, error);
    
    CFURLResourceInfoUpdateRelease(resourceInfo, key, value);

    if (value != NULL)
    {
        return true;
    }
    else
    {
        return false;
    }
}

struct URLPropertyContext {
    CFURLRef url;
    CFErrorRef *error;
    CFMutableDictionaryRef resourceInfo;
    Boolean *success;
};

static void applyProperties(const void *key, const void *value, void *context)
{
    struct URLPropertyContext *ctx = (struct URLPropertyContext *)context;
    if (!*ctx->success)
    {
        return;
    }

    CFTypeRef acceptedValue = CFURLSetPropertyForKey(ctx->url, key, value, ctx->error);
    if (acceptedValue != NULL)
    {
        CFURLResourceInfoUpdate(ctx->resourceInfo, key, acceptedValue);
        CFRelease(acceptedValue);
    }
    else
    {
        *ctx->success = false;
    }
}

Boolean CFURLSetResourcePropertiesForKeys(CFURLRef url, CFDictionaryRef keyedPropertyValues, CFErrorRef *error)
{
    Boolean success = true;
    CFMutableDictionaryRef resourceInfo = CFURLResourceInfo(url);
    struct URLPropertyContext ctx = {
        url,
        error,
        resourceInfo,
        &success
    };

    CFDictionaryApplyFunction(resourceInfo, &applyProperties, &ctx);
    CFURLResourceInfoRelease(resourceInfo);

    return success;
}

CFDataRef CFURLCreateBookmarkDataFromFile(CFAllocatorRef allocator, CFURLRef fileURL, CFErrorRef *errorRef)
{
#warning TODO: FIXME
    return NULL;
}

Boolean CFURLWriteBookmarkDataToFile(CFDataRef bookmarkRef, CFURLRef fileURL, CFURLBookmarkFileCreationOptions options, CFErrorRef *errorRef)
{
#warning TODO: FIXME
    return false;
}

CFDictionaryRef CFURLCreateResourcePropertiesForKeysFromBookmarkData(CFAllocatorRef allocator, CFArrayRef resourcePropertiesToReturn, CFDataRef bookmark)
{
#warning TODO: FIXME
    return NULL;
}

CFURLRef CFURLCreateByResolvingBookmarkData(CFAllocatorRef allocator, CFDataRef bookmark, CFURLBookmarkResolutionOptions options, CFURLRef relativeToURL, CFArrayRef resourcePropertiesToInclude, Boolean* isStale, CFErrorRef* error)
{
#warning TODO: FIXME
    return NULL;
}

CFDataRef CFURLCreateBookmarkData(CFAllocatorRef allocator, CFURLRef url, CFURLBookmarkCreationOptions options, CFArrayRef resourcePropertiesToInclude, CFURLRef relativeToURL, CFErrorRef *error)
{
#warning TODO: FIXME
    return NULL;
}

Boolean CFURLResourceIsReachable(CFURLRef url, CFErrorRef *error)
{
#warning TODO: FIXME
    return false;
}

@implementation NSURL

+ (NSData *)bookmarkDataWithContentsOfURL:(NSURL *)bookmarkFileURL error:(NSError **)error
{
    return [(NSData *)CFURLCreateBookmarkDataFromFile(kCFAllocatorDefault, (CFURLRef)bookmarkFileURL, (CFErrorRef *)error) autorelease];
}

+ (BOOL)writeBookmarkData:(NSData *)bookmarkData toURL:(NSURL *)bookmarkFileURL options:(NSURLBookmarkFileCreationOptions)options error:(NSError **)error
{
    return CFURLWriteBookmarkDataToFile((CFDataRef)bookmarkData, (CFURLRef)bookmarkFileURL, options, (CFErrorRef *)error);
}

+ (NSDictionary *)resourceValuesForKeys:(NSArray *)keys fromBookmarkData:(NSData *)bookmarkData
{
    return [(NSDictionary *)CFURLCreateResourcePropertiesForKeysFromBookmarkData(kCFAllocatorDefault, (CFArrayRef)keys, (CFDataRef)bookmarkData) autorelease];
}

+ (id)URLByResolvingBookmarkData:(NSData *)bookmarkData options:(NSURLBookmarkResolutionOptions)options relativeToURL:(NSURL *)relativeURL bookmarkDataIsStale:(BOOL *)isStale error:(NSError **)error
{
    return [[[self alloc] initByResolvingBookmarkData:bookmarkData options:options relativeToURL:relativeURL bookmarkDataIsStale:isStale error:error] autorelease];
}

+ (BOOL)supportsSecureCoding
{
    return NO;
}

- (id)bookmarkDataWithAliasRecord:(id)aliasRecord
{
    return nil; // what is this used for? it seems to do absolutely nothing on iOS
}

- (id)initByResolvingBookmarkData:(NSData *)bookmarkData options:(NSURLBookmarkResolutionOptions)options relativeToURL:(NSURL *)relativeURL bookmarkDataIsStale:(BOOL *)isStale error:(NSError **)error
{
    [self release];
    Boolean stale = NO;
    CFURLRef relative = [relativeURL _cfurl];
    CFURLRef url = CFURLCreateByResolvingBookmarkData(kCFAllocatorDefault, (CFDataRef)bookmarkData, options, relative, NULL, &stale, (CFErrorRef *)error);

    if (isStale)
    {
        *isStale = stale;
    }

    return (NSURL *)url;
}

- (NSData *)bookmarkDataWithOptions:(NSURLBookmarkCreationOptions)options includingResourceValuesForKeys:(NSArray *)keys relativeToURL:(NSURL *)relativeURL error:(NSError **)error
{
    return [(NSData *)CFURLCreateBookmarkData(kCFAllocatorDefault, [self _cfurl], options, (CFArrayRef)keys, (CFURLRef)relativeURL, (CFErrorRef *)error) autorelease];
}

- (NSURL *)filePathURL
{
    NSURL *url = nil;
    if ([self isFileReferenceURL])
    {
        url = [(NSURL *)CFURLCreateFilePathURL(kCFAllocatorDefault, [self _cfurl], NULL) autorelease];
    }
    else if ([self isFileURL])
    {
        url = self;
    }

    return url;
}

- (NSURL *)fileReferenceURL
{
    NSURL *url = nil;
    if ([self isFileReferenceURL])
    {
        url = self;
    }
    else if ([self isFileURL])
    {
        url = [(NSURL *)CFURLCreateFileReferenceURL(kCFAllocatorDefault, [self _cfurl], NULL) autorelease];
    }
    
    return url;
}

- (BOOL)isFileReferenceURL
{
    return _CFURLIsFileReferenceURL([self _cfurl]);
}

- (BOOL)checkResourceIsReachableAndReturnError:(NSError **)error
{
    return CFURLResourceIsReachable([self _cfurl], (CFErrorRef *)error);
}

- (BOOL)getResourceValue:(out id *)value forKey:(NSString *)key error:(out NSError **)error
{
    return CFURLCopyResourcePropertyForKey([self _cfurl], (CFStringRef)key, value, (CFErrorRef *)error);
}

- (NSDictionary *)resourceValuesForKeys:(NSArray *)keys error:(NSError **)error
{
    return [(NSDictionary *)CFURLCopyResourcePropertiesForKeys([self _cfurl], (CFArrayRef)keys, (CFErrorRef *)error) autorelease];
}

- (BOOL)setResourceValue:(id)value forKey:(NSString *)key error:(NSError **)error
{
    return CFURLSetResourcePropertyForKey([self _cfurl], (CFStringRef)key, (CFTypeRef)value, (CFErrorRef *)error);
}

- (BOOL)setResourceValues:(NSDictionary *)keyedValues error:(NSError **)error
{
    return CFURLSetResourcePropertiesForKeys([self _cfurl], (CFDictionaryRef)keyedValues, (CFErrorRef *)error);
}

@end
