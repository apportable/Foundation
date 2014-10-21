#import <Foundation/NSObject.h>
#import <Foundation/NSString.h>

@class NSNumber, NSData, NSDictionary;

FOUNDATION_EXPORT NSString * const NSURLFileScheme;
FOUNDATION_EXPORT NSString * const NSURLKeysOfUnsetValuesKey;
FOUNDATION_EXPORT NSString * const NSURLNameKey;
FOUNDATION_EXPORT NSString * const NSURLLocalizedNameKey;
FOUNDATION_EXPORT NSString * const NSURLIsRegularFileKey;
FOUNDATION_EXPORT NSString * const NSURLIsDirectoryKey;
FOUNDATION_EXPORT NSString * const NSURLIsSymbolicLinkKey;
FOUNDATION_EXPORT NSString * const NSURLIsVolumeKey;
FOUNDATION_EXPORT NSString * const NSURLIsPackageKey;
FOUNDATION_EXPORT NSString * const NSURLIsSystemImmutableKey;
FOUNDATION_EXPORT NSString * const NSURLIsUserImmutableKey;
FOUNDATION_EXPORT NSString * const NSURLIsHiddenKey;
FOUNDATION_EXPORT NSString * const NSURLHasHiddenExtensionKey;
FOUNDATION_EXPORT NSString * const NSURLCreationDateKey;
FOUNDATION_EXPORT NSString * const NSURLContentAccessDateKey;
FOUNDATION_EXPORT NSString * const NSURLContentModificationDateKey;
FOUNDATION_EXPORT NSString * const NSURLAttributeModificationDateKey;
FOUNDATION_EXPORT NSString * const NSURLLinkCountKey;
FOUNDATION_EXPORT NSString * const NSURLParentDirectoryURLKey;
FOUNDATION_EXPORT NSString * const NSURLVolumeURLKey;
FOUNDATION_EXPORT NSString * const NSURLTypeIdentifierKey;
FOUNDATION_EXPORT NSString * const NSURLLocalizedTypeDescriptionKey;
FOUNDATION_EXPORT NSString * const NSURLLabelNumberKey;
FOUNDATION_EXPORT NSString * const NSURLLabelColorKey;
FOUNDATION_EXPORT NSString * const NSURLLocalizedLabelKey;
FOUNDATION_EXPORT NSString * const NSURLEffectiveIconKey;
FOUNDATION_EXPORT NSString * const NSURLCustomIconKey;
FOUNDATION_EXPORT NSString * const NSURLFileResourceIdentifierKey;
FOUNDATION_EXPORT NSString * const NSURLVolumeIdentifierKey;
FOUNDATION_EXPORT NSString * const NSURLPreferredIOBlockSizeKey;
FOUNDATION_EXPORT NSString * const NSURLIsReadableKey;
FOUNDATION_EXPORT NSString * const NSURLIsWritableKey;
FOUNDATION_EXPORT NSString * const NSURLIsExecutableKey;
FOUNDATION_EXPORT NSString * const NSURLFileSecurityKey;
FOUNDATION_EXPORT NSString * const NSURLIsExcludedFromBackupKey;
FOUNDATION_EXPORT NSString * const NSURLPathKey;
FOUNDATION_EXPORT NSString * const NSURLIsMountTriggerKey;
FOUNDATION_EXPORT NSString * const NSURLFileResourceTypeKey;
FOUNDATION_EXPORT NSString * const NSURLFileResourceTypeNamedPipe;
FOUNDATION_EXPORT NSString * const NSURLFileResourceTypeCharacterSpecial;
FOUNDATION_EXPORT NSString * const NSURLFileResourceTypeDirectory;
FOUNDATION_EXPORT NSString * const NSURLFileResourceTypeBlockSpecial;
FOUNDATION_EXPORT NSString * const NSURLFileResourceTypeRegular;
FOUNDATION_EXPORT NSString * const NSURLFileResourceTypeSymbolicLink;
FOUNDATION_EXPORT NSString * const NSURLFileResourceTypeSocket;
FOUNDATION_EXPORT NSString * const NSURLFileResourceTypeUnknown;
FOUNDATION_EXPORT NSString * const NSURLFileSizeKey;
FOUNDATION_EXPORT NSString * const NSURLFileAllocatedSizeKey;
FOUNDATION_EXPORT NSString * const NSURLTotalFileSizeKey;
FOUNDATION_EXPORT NSString * const NSURLTotalFileAllocatedSizeKey;
FOUNDATION_EXPORT NSString * const NSURLIsAliasFileKey;
FOUNDATION_EXPORT NSString * const NSURLVolumeLocalizedFormatDescriptionKey;
FOUNDATION_EXPORT NSString * const NSURLVolumeTotalCapacityKey;
FOUNDATION_EXPORT NSString * const NSURLVolumeAvailableCapacityKey;
FOUNDATION_EXPORT NSString * const NSURLVolumeResourceCountKey;
FOUNDATION_EXPORT NSString * const NSURLVolumeSupportsPersistentIDsKey;
FOUNDATION_EXPORT NSString * const NSURLVolumeSupportsSymbolicLinksKey;
FOUNDATION_EXPORT NSString * const NSURLVolumeSupportsHardLinksKey;
FOUNDATION_EXPORT NSString * const NSURLVolumeSupportsJournalingKey;
FOUNDATION_EXPORT NSString * const NSURLVolumeIsJournalingKey;
FOUNDATION_EXPORT NSString * const NSURLVolumeSupportsSparseFilesKey;
FOUNDATION_EXPORT NSString * const NSURLVolumeSupportsZeroRunsKey;
FOUNDATION_EXPORT NSString * const NSURLVolumeSupportsCaseSensitiveNamesKey;
FOUNDATION_EXPORT NSString * const NSURLVolumeSupportsCasePreservedNamesKey;
FOUNDATION_EXPORT NSString * const NSURLVolumeSupportsRootDirectoryDatesKey;
FOUNDATION_EXPORT NSString * const NSURLVolumeSupportsVolumeSizesKey;
FOUNDATION_EXPORT NSString * const NSURLVolumeSupportsRenamingKey;
FOUNDATION_EXPORT NSString * const NSURLVolumeSupportsAdvisoryFileLockingKey;
FOUNDATION_EXPORT NSString * const NSURLVolumeSupportsExtendedSecurityKey;
FOUNDATION_EXPORT NSString * const NSURLVolumeIsBrowsableKey;
FOUNDATION_EXPORT NSString * const NSURLVolumeMaximumFileSizeKey;
FOUNDATION_EXPORT NSString * const NSURLVolumeIsEjectableKey;
FOUNDATION_EXPORT NSString * const NSURLVolumeIsRemovableKey;
FOUNDATION_EXPORT NSString * const NSURLVolumeIsInternalKey;
FOUNDATION_EXPORT NSString * const NSURLVolumeIsAutomountedKey;
FOUNDATION_EXPORT NSString * const NSURLVolumeIsLocalKey;
FOUNDATION_EXPORT NSString * const NSURLVolumeIsReadOnlyKey;
FOUNDATION_EXPORT NSString * const NSURLVolumeCreationDateKey;
FOUNDATION_EXPORT NSString * const NSURLVolumeURLForRemountingKey;
FOUNDATION_EXPORT NSString * const NSURLVolumeUUIDStringKey;
FOUNDATION_EXPORT NSString * const NSURLVolumeNameKey;
FOUNDATION_EXPORT NSString * const NSURLVolumeLocalizedNameKey;
FOUNDATION_EXPORT NSString * const NSURLIsUbiquitousItemKey;
FOUNDATION_EXPORT NSString * const NSURLUbiquitousItemHasUnresolvedConflictsKey;
FOUNDATION_EXPORT NSString * const NSURLUbiquitousItemIsDownloadedKey;
FOUNDATION_EXPORT NSString * const NSURLUbiquitousItemIsDownloadingKey;
FOUNDATION_EXPORT NSString * const NSURLUbiquitousItemIsUploadedKey;
FOUNDATION_EXPORT NSString * const NSURLUbiquitousItemIsUploadingKey;
FOUNDATION_EXPORT NSString * const NSURLUbiquitousItemPercentDownloadedKey;
FOUNDATION_EXPORT NSString * const NSURLUbiquitousItemPercentUploadedKey;

typedef NS_OPTIONS(NSUInteger, NSURLBookmarkCreationOptions) {
    NSURLBookmarkCreationPreferFileIDResolution           = ( 1UL << 8 ),
    NSURLBookmarkCreationMinimalBookmark                  = ( 1UL << 9 ),
    NSURLBookmarkCreationSuitableForBookmarkFile          = ( 1UL << 10 ),
    NSURLBookmarkCreationWithSecurityScope                = ( 1 << 11 ),
    NSURLBookmarkCreationSecurityScopeAllowOnlyReadAccess = ( 1 << 12 ),
};

typedef NS_OPTIONS(NSUInteger, NSURLBookmarkResolutionOptions) {
    NSURLBookmarkResolutionWithoutUI         = ( 1UL << 8 ),
    NSURLBookmarkResolutionWithoutMounting   = ( 1UL << 9 ),
    NSURLBookmarkResolutionWithSecurityScope = ( 1 << 10 )
};

typedef NSUInteger NSURLBookmarkFileCreationOptions;

@interface NSURL: NSObject <NSSecureCoding, NSCopying> {
    NSString *_urlString;
    NSURL *_baseURL;
    void *_clients;
    void *_reserved;
}

+ (id)fileURLWithPath:(NSString *)path isDirectory:(BOOL) isDir;
+ (id)fileURLWithPath:(NSString *)path;
+ (id)fileURLWithFileSystemRepresentation:(const char *)path isDirectory:(BOOL)isDir relativeToURL:(NSURL *)baseURL;
+ (id)URLWithString:(NSString *)URLString;
+ (id)URLWithString:(NSString *)URLString relativeToURL:(NSURL *)baseURL;
+ (id)URLByResolvingBookmarkData:(NSData *)bookmarkData options:(NSURLBookmarkResolutionOptions)options relativeToURL:(NSURL *)relativeURL bookmarkDataIsStale:(BOOL *)isStale error:(NSError **)error;
+ (NSDictionary *)resourceValuesForKeys:(NSArray *)keys fromBookmarkData:(NSData *)bookmarkData;
+ (BOOL)writeBookmarkData:(NSData *)bookmarkData toURL:(NSURL *)bookmarkFileURL options:(NSURLBookmarkFileCreationOptions)options error:(NSError **)error;
+ (NSData *)bookmarkDataWithContentsOfURL:(NSURL *)bookmarkFileURL error:(NSError **)error;
- (id)initWithScheme:(NSString *)scheme host:(NSString *)host path:(NSString *)path;
- (id)initFileURLWithPath:(NSString *)path isDirectory:(BOOL)isDir;
- (id)initFileURLWithPath:(NSString *)path;
- (id)initWithString:(NSString *)URLString;
- (id)initWithString:(NSString *)URLString relativeToURL:(NSURL *)baseURL;
- (NSString *)absoluteString;
- (NSString *)relativeString;
- (NSURL *)baseURL;
- (NSURL *)absoluteURL;
- (NSString *)scheme;
- (NSString *)resourceSpecifier;
- (NSString *)host;
- (NSNumber *)port;
- (NSString *)user;
- (NSString *)password;
- (NSString *)path;
- (NSString *)fragment;
- (NSString *)parameterString;
- (NSString *)query;
- (NSString *)relativePath;
- (BOOL)getFileSystemRepresentation:(char *)buffer maxLength:(NSUInteger)maxBufferLength;
- (const char *)fileSystemRepresentation NS_RETURNS_INNER_POINTER;
- (BOOL)isFileURL;
- (NSURL *)standardizedURL;
- (BOOL)checkResourceIsReachableAndReturnError:(NSError **)error;
- (BOOL)isFileReferenceURL;
- (NSURL *)fileReferenceURL;
- (NSURL *)filePathURL;
- (BOOL)getResourceValue:(out id *)value forKey:(NSString *)key error:(out NSError **)error;
- (NSDictionary *)resourceValuesForKeys:(NSArray *)keys error:(NSError **)error;
- (BOOL)setResourceValue:(id)value forKey:(NSString *)key error:(NSError **)error;
- (BOOL)setResourceValues:(NSDictionary *)keyedValues error:(NSError **)error;
- (NSData *)bookmarkDataWithOptions:(NSURLBookmarkCreationOptions)options includingResourceValuesForKeys:(NSArray *)keys relativeToURL:(NSURL *)relativeURL error:(NSError **)error;
- (id)initByResolvingBookmarkData:(NSData *)bookmarkData options:(NSURLBookmarkResolutionOptions)options relativeToURL:(NSURL *)relativeURL bookmarkDataIsStale:(BOOL *)isStale error:(NSError **)error;
- (BOOL)startAccessingSecurityScopedResource;
- (void)stopAccessingSecurityScopedResource;

@end

@interface NSString (NSURLUtilities)

- (NSString *)stringByAddingPercentEscapesUsingEncoding:(NSStringEncoding)enc;
- (NSString *)stringByReplacingPercentEscapesUsingEncoding:(NSStringEncoding)enc;

@end

@interface NSURL (NSURLPathUtilities)

+ (NSURL *)fileURLWithPathComponents:(NSArray *)components;
- (NSArray *)pathComponents;
- (NSString *)lastPathComponent;
- (NSString *)pathExtension;
- (NSURL *)URLByAppendingPathComponent:(NSString *)pathComponent;
- (NSURL *)URLByAppendingPathComponent:(NSString *)pathComponent isDirectory:(BOOL)isDirectory;
- (NSURL *)URLByDeletingLastPathComponent;
- (NSURL *)URLByAppendingPathExtension:(NSString *)pathExtension;
- (NSURL *)URLByDeletingPathExtension;
- (NSURL *)URLByStandardizingPath;
- (NSURL *)URLByResolvingSymlinksInPath;

@end

@interface NSFileSecurity : NSObject <NSCopying, NSCoding>

@end
