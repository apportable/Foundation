//
//  NSFileAttributes.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "NSFileAttributes.h"
#import <Foundation/NSDate.h>
#import <dispatch/dispatch.h> // for time macros
#import <grp.h>
#import <string.h>
#import <sys/types.h>
#import <pwd.h>

@implementation NSDictionary (NSFileAttributes)

- (NSNumber *)fileGroupOwnerAccountID
{
    return [self objectForKey:NSFileGroupOwnerAccountID];
}

- (NSNumber *)fileOwnerAccountID
{
    return [self objectForKey:NSFileOwnerAccountID];
}

- (NSDate *)fileCreationDate
{
    return [self objectForKey:NSFileCreationDate];
}

- (BOOL)fileIsAppendOnly
{
    return [[self objectForKey:NSFileAppendOnly] boolValue];
}

- (BOOL)fileIsImmutable
{
    return [[self objectForKey:NSFileImmutable] boolValue];
}

- (OSType)fileHFSTypeCode
{
    return [[self objectForKey:NSFileHFSTypeCode] unsignedLongValue];
}

- (OSType)fileHFSCreatorCode
{
    return [[self objectForKey:NSFileHFSCreatorCode] unsignedLongValue];
}

- (BOOL)fileExtensionHidden
{
    return [[self objectForKey:NSFileExtensionHidden] boolValue];
}

- (NSUInteger)fileSystemFileNumber
{
    return [[self objectForKey:NSFileSystemFileNumber] unsignedIntegerValue];
}

- (NSInteger)fileSystemNumber
{
    return [[self objectForKey:NSFileSystemNumber] integerValue];
}

- (unsigned int)fileGroupOwnerAccountNumber
{
    return 0; // never returns anything but zero
}

- (NSString *)fileGroupOwnerAccountName
{
    return [self objectForKey:NSFileGroupOwnerAccountName];
}

- (unsigned int)fileOwnerAccountNumber
{
    return 0; // never returns anything but zero
}

- (NSString *)fileOwnerAccountName
{
    return [self objectForKey:NSFileOwnerAccountName];
}

- (NSUInteger)filePosixPermissions
{
    return [[self objectForKey:NSFilePosixPermissions] unsignedIntegerValue];
}

- (NSString *)fileType
{
    return [self objectForKey:NSFileType];
}

- (NSDate *)fileModificationDate
{
    return [self objectForKey:NSFileModificationDate];
}

- (unsigned long long)fileSize
{
    // one would think this would call unsignedLongLongValue however that does not seem to be the case...
    return [[self objectForKey:NSFileSize] longLongValue];
}

@end
@implementation NSFileAttributes {
    NSMutableDictionary *dict;
    struct stat statInfo;
    struct {
        char extensionHidden;
        NSDate *creationDate;
        struct _fields {
            unsigned int extensionHidden:1;
            unsigned int creationDate:1;
            unsigned int reserved:30;
        } validFields;
    } catInfo;
    NSDictionary *extendedAttrs;
    int fileProtectionClass;
}

+ (id)attributesWithStat:(struct stat *)info
{
    return [[[self alloc] initWithStat:info] autorelease];
}

- (id)initWithStat:(struct stat *)info
{
    self = [super init];
    if (self)
    {
        dict = [[NSMutableDictionary alloc] init];
        memcpy(&statInfo, info, sizeof(struct stat));

        switch (info->st_mode & S_IFMT)
        {
            case S_IFREG:
                dict[NSFileType] = NSFileTypeRegular;
                break;
            case S_IFDIR:
                dict[NSFileType] = NSFileTypeDirectory;
                break;
            case S_IFLNK:
                dict[NSFileType] = NSFileTypeSymbolicLink;
                break;
            case S_IFSOCK:
                dict[NSFileType] = NSFileTypeSocket;
                break;
            case S_IFBLK:
                dict[NSFileType] = NSFileTypeBlockSpecial;
                break;
            case S_IFIFO:
                dict[NSFileType] = NSFileTypeCharacterSpecial; // verify
                break;
            default:
                dict[NSFileType] = NSFileTypeUnknown;
                break;
        }

        dict[NSFileSize] = [NSNumber numberWithLongLong:info->st_size];
#ifdef ANDROID
        dict[NSFileCreationDate] = [NSDate dateWithTimeIntervalSince1970:(NSTimeInterval)(info->st_ctime * NSEC_PER_SEC + info->st_ctime_nsec) / (NSTimeInterval)NSEC_PER_SEC];
        dict[NSFileModificationDate] = [NSDate dateWithTimeIntervalSince1970:(NSTimeInterval)(info->st_mtime * NSEC_PER_SEC + info->st_mtime_nsec) / (NSTimeInterval)NSEC_PER_SEC];
#else
#error Implementation needed for file time specs
#endif
        dict[NSFileDeviceIdentifier] = [NSNumber numberWithUnsignedLongLong:info->st_dev];
        dict[NSFileSystemNumber] = [NSNumber numberWithUnsignedLongLong:info->st_ino];
        dict[NSFileSystemFileNumber] = [NSNumber numberWithUnsignedLongLong:info->st_ino];


        dict[NSFileOwnerAccountID] = [NSNumber numberWithLong:info->st_uid];
        struct passwd *pw = getpwuid(info->st_uid);
        if (pw && pw->pw_name != NULL)
        {
            dict[NSFileOwnerAccountName] = [NSString stringWithUTF8String:pw->pw_name];   
        }
        
        dict[NSFileGroupOwnerAccountID] = [NSNumber numberWithLong:info->st_gid];
        struct group *grp = getgrgid(info->st_gid);
        if (grp != NULL && grp->gr_name != NULL)
        {
            dict[NSFileGroupOwnerAccountName] = [NSString stringWithUTF8String:grp->gr_name];
        }

        dict[NSFilePosixPermissions] = [NSNumber numberWithInt:info->st_mode & ~(S_IFMT)];
    }
    return self;
}

- (BOOL)isDirectory
{
    return S_ISDIR(statInfo.st_mode);
}

- (unsigned long long)fileSize
{
    return statInfo.st_size;
}

- (NSDate *)fileModificationDate
{
    return dict[NSFileModificationDate];
}

- (NSString *)fileType
{
    return dict[NSFileType];
}

- (NSUInteger)filePosixPermissions
{
    return statInfo.st_mode & ~(S_IFMT);
}

- (NSString *)fileOwnerAccountName
{
    return dict[NSFileOwnerAccountName];
}

- (NSString *)fileGroupOwnerAccountName
{
    return dict[NSFileGroupOwnerAccountName];
}

- (NSInteger)fileSystemNumber
{
    return statInfo.st_dev;
}

- (NSUInteger)fileSystemFileNumber
{
    return statInfo.st_ino;
}

- (BOOL)fileExtensionHidden
{
    return NO;
}

- (OSType)fileHFSCreatorCode
{
    return kUnknownType;
}

- (OSType)fileHFSTypeCode
{
    return kUnknownType;
}

- (BOOL)fileIsImmutable
{
    return NO; // where is this derived from?
}

- (BOOL)fileIsAppendOnly
{
    return NO; // where is this derived from?
}

- (NSDate *)fileCreationDate
{
    return dict[NSFileCreationDate];
}

- (NSNumber *)fileOwnerAccountID
{
    return dict[NSFileOwnerAccountID];
}

- (NSNumber *)fileGroupOwnerAccountID
{
    return dict[NSFileGroupOwnerAccountID];
}

- (id)keyEnumerator
{
    return [dict keyEnumerator];
}

- (NSUInteger)count
{
    return [dict count];
}

- (id)objectForKey:(id)key
{
    return [dict objectForKey:key];
}

- (BOOL)isEqual:(id)other
{
    if (self == other)
    {
        return YES;
    }
    if ([other isKindOfClass:[NSFileAttributes class]])
    {
        NSFileAttributes *otherAttrs = (NSFileAttributes *)other;

        return memcmp(&statInfo, &otherAttrs->statInfo, sizeof(struct stat)) == 0;
    }
    else
    {
        return [dict isEqual:other];
    }
}

- (NSUInteger)hash
{
    return [dict hash];
}

- (void)dealloc
{
    [dict release];
    [super dealloc];
}

@end
