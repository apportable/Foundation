#include "common.h"
#include <Foundation/Foundation.h>
#include <sys/stat.h>

@implementation NSFileManager

NSString * const NSFileAppendOnly = @"NSFileAppendOnly";
NSString * const NSFileCreationDate = @"NSFileCreationDate";
NSString * const NSFileDeviceIdentifier = @"NSFileDeviceIdentifier";
NSString * const NSFileExtensionHidden = @"NSFileExtensionHidden";
NSString * const NSFileGroupOwnerAccountID = @"NSFileGroupOwnerAccountID";
NSString * const NSFileGroupOwnerAccountName = @"NSFileGroupOwnerAccountName";
NSString * const NSFileHFSCreatorCode = @"NSFileHFSCreatorCode";
NSString * const NSFileHFSTypeCode = @"NSFileHFSTypeCode";
NSString * const NSFileImmutable = @"NSFileImmutable";
NSString * const NSFileModificationDate = @"NSFileModificationDate";
NSString * const NSFileOwnerAccountID = @"NSFileOwnerAccountID";
NSString * const NSFileOwnerAccountName = @"NSFileOwnerAccountName";
NSString * const NSFilePosixPermissions = @"NSFilePosixPermissions";
NSString * const NSFileReferenceCount = @"NSFileReferenceCount";
NSString * const NSFileSize = @"NSFileSize";
NSString * const NSFileSystemFileNumber = @"NSFileSystemFileNumber";
NSString * const NSFileSystemFreeNodes = @"NSFileSystemFreeNodes";
NSString * const NSFileSystemFreeSize = @"NSFileSystemFreeSize";
NSString * const NSFileSystemNodes = @"NSFileSystemNodes";
NSString * const NSFileSystemNumber = @"NSFileSystemNumber";
NSString * const NSFileSystemSize = @"NSFileSystemSize";
NSString * const NSFileType = @"NSFileType";
NSString * const NSFileTypeBlockSpecial = @"NSFileTypeBlockSpecial";
NSString * const NSFileTypeCharacterSpecial = @"NSFileTypeCharacterSpecial";
NSString * const NSFileTypeDirectory = @"NSFileTypeDirectory";
NSString * const NSFileTypeFifo = @"NSFileTypeFifo";
NSString * const NSFileTypeRegular = @"NSFileTypeRegular";
NSString * const NSFileTypeSocket = @"NSFileTypeSocket";
NSString * const NSFileTypeSymbolicLink = @"NSFileTypeSymbolicLink";
NSString * const NSFileTypeUnknown = @"NSFileTypeUnknown";

static NSFileManager *defaultManager = nil;

+ (NSFileManager *) defaultManager
{
    if (!defaultManager) {
        defaultManager = [[NSFileManager alloc] init];
    }
    return defaultManager;
}

- (NSArray*) directoryContentsAtPath: (NSString*)path
{
  NSInvalidAbstractInvocation();
  return nil;

}

- (BOOL)removeItemAtPath:(NSString *)path error:(NSError **)error
{
  NSInvalidAbstractInvocation();
  return NO;
}

- (BOOL) removeFileAtPath: (NSString*)path handler: (id)handler 
{
  NSInvalidAbstractInvocation();
  return NO;
}

- (BOOL) fileExistsAtPath: (NSString*)path
{
  NSInvalidAbstractInvocation();
  return NO;
}

- (BOOL) fileExistsAtPath:(NSString*)path isDirectory:(BOOL *)isDir
{
  NSInvalidAbstractInvocation();
  return NO;
}

- (BOOL) createDirectoryAtPath: (NSString *)path
   withIntermediateDirectories: (BOOL)flag
		    attributes: (NSDictionary *)attributes
                         error: (NSError **) error
{
  NSInvalidAbstractInvocation();
  return NO;
}
- (BOOL) createDirectoryAtPath: (NSString*)path
		    attributes: (NSDictionary*)attributes
{
  NSInvalidAbstractInvocation();
  return NO;
}

- (NSDirectoryEnumerator*) enumeratorAtPath: (NSString*)path
{
  NSInvalidAbstractInvocation();
  return nil;
}

- (BOOL)copyItemAtPath:(NSString *)srcPath toPath:(NSString *)dstPath error:(NSError **)error {
  NSInvalidAbstractInvocation();
  return NO;
}

-(BOOL)readContentsOfFile:(NSString *)path bytes:(const void **)bytes length:(NSUInteger*)length {
  NSInvalidAbstractInvocation();
  return NO;
}

-(BOOL)writeContentsOfFile:(NSString *)path bytes:(const void *)bytes length:(NSUInteger)length atomically:(BOOL)atomically {
  NSInvalidAbstractInvocation();
  return NO;
}

-(BOOL)writeContentsOfFile:(NSString *)path bytes:(const void *)bytes length:(NSUInteger)length {
  NSInvalidAbstractInvocation();
  return NO;
}

-(BOOL)isWritableFileAtPath:(NSString *)path {
  NSInvalidAbstractInvocation();
  return NO;
}

-(BOOL)isExecutableFileAtPath:(NSString *)path {
  NSInvalidAbstractInvocation();
  return NO;
}

-(BOOL)createFileAtPath:(NSString *)path contents: (NSData*)contents attributes: (NSDictionary*)attributes {
  NSInvalidAbstractInvocation();
  return NO;
}

- (NSDictionary*) fileAttributesAtPath: (NSString*)path traverseLink: (BOOL)flag {
  NSInvalidAbstractInvocation();
  return NO;
}

- (BOOL) changeFileAttributes: (NSDictionary*)attributes atPath: (NSString*)path {
  NSInvalidAbstractInvocation();
  return NO;
}

- (const GSNativeChar*) fileSystemRepresentationWithPath: (NSString*)path
{
  return
    (const GSNativeChar*)[path cStringUsingEncoding: NSUTF8StringEncoding];
}

- (NSString*) stringWithFileSystemRepresentation: (const GSNativeChar*)string
					  length: (NSUInteger)len
{
  return AUTORELEASE([[NSString allocWithZone: NSDefaultMallocZone()]
    initWithBytes: string length: len encoding: NSUTF8StringEncoding]);
}
@end

@implementation	GSAttrDictionary

+ (NSDictionary*) attributesAt: (const unichar*)lpath
                  traverseLink: (BOOL)traverse
{
  NSInvalidAbstractInvocation();
  return NO;
}

- (NSDate*) fileModificationDate
{
  NSInvalidAbstractInvocation();
  return NO;
}

@end	/* GSAttrDictionary */
