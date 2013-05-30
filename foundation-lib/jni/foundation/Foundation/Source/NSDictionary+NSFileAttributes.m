#include "common.h"
#include <Foundation/Foundation.h>
#include <sys/stat.h>

/**
 * Convenience methods for accessing named file attributes in a dictionary.
 */
@implementation NSDictionary (NSFileAttributes)

/**
 * Return the file creation date attribute (or nil if not found).
 */
- (NSDate*)fileCreationDate
{
    return [self objectForKey:NSFileCreationDate];
}

/**
 * Return the file extension hidden attribute (or NO if not found).
 */
- (BOOL)fileExtensionHidden
{
    return [[self objectForKey:NSFileExtensionHidden] boolValue];
}

/**
 *  Returns HFS creator attribute (OS X).
 */
- (OSType)fileHFSCreatorCode
{
    return [[self objectForKey:NSFileHFSCreatorCode] unsignedLongValue];
}

/**
 *  Returns HFS type code attribute (OS X).
 */
- (OSType)fileHFSTypeCode
{
    return [[self objectForKey:NSFileHFSTypeCode] unsignedLongValue];
}

/**
 * Return the file append only attribute (or NO if not found).
 */
- (BOOL)fileIsAppendOnly
{
    return [[self objectForKey:NSFileAppendOnly] boolValue];
}

/**
 * Return the file immutable attribute (or NO if not found).
 */
- (BOOL)fileIsImmutable
{
    return [[self objectForKey:NSFileImmutable] boolValue];
}

/**
 * Return the size of the file, or NSNotFound if the file size attribute
 * is not found in the dictionary.
 */
- (unsigned long long)fileSize
{
    NSNumber  *n = [self objectForKey:NSFileSize];

    if (n == nil)
    {
        return NSNotFound;
    }
    return [n unsignedLongLongValue];
}

/**
 * Return the file type attribute or nil if not present.
 */
- (NSString*)fileType
{
    return [self objectForKey:NSFileType];
}

/**
 * Return the file owner account name attribute or nil if not present.
 */
- (NSString*)fileOwnerAccountName
{
    return [self objectForKey:NSFileOwnerAccountName];
}

/**
 * Return an NSNumber with the numeric value of the NSFileOwnerAccountID
 *attribute
 * in the dictionary, or nil if the attribute is not present.
 */
- (NSNumber*)fileOwnerAccountID
{
    return [self objectForKey:NSFileOwnerAccountID];
}

/**
 * Return the file group owner account name attribute or nil if not present.
 */
- (NSString*)fileGroupOwnerAccountName
{
    return [self objectForKey:NSFileGroupOwnerAccountName];
}

/**
 * Return an NSNumber with the numeric value of the NSFileGroupOwnerAccountID
 *attribute
 * in the dictionary, or nil if the attribute is not present.
 */
- (NSNumber*)fileGroupOwnerAccountID
{
    return [self objectForKey:NSFileGroupOwnerAccountID];
}

/**
 * Return the file modification date attribute (or nil if not found)
 */
- (NSDate*)fileModificationDate
{
    return [self objectForKey:NSFileModificationDate];
}

/**
 * Return the file posix permissions attribute (or NSNotFound if
 * the attribute is not present in the dictionary).
 */
- (NSUInteger)filePosixPermissions
{
    NSNumber  *n = [self objectForKey:NSFilePosixPermissions];

    if (n == nil)
    {
        return NSNotFound;
    }
    return [n unsignedIntegerValue];
}

/**
 * Return the file system number attribute (or NSNotFound if
 * the attribute is not present in the dictionary).
 */
- (NSUInteger)fileSystemNumber
{
    NSNumber  *n = [self objectForKey:NSFileSystemNumber];

    if (n == nil)
    {
        return NSNotFound;
    }
    return [n unsignedIntegerValue];
}

/**
 * Return the file system file identification number attribute
 * or NSNotFound if the attribute is not present in the dictionary).
 */
- (NSUInteger)fileSystemFileNumber
{
    NSNumber  *n = [self objectForKey:NSFileSystemFileNumber];

    if (n == nil)
    {
        return NSNotFound;
    }
    return [n unsignedIntegerValue];
}
@end

