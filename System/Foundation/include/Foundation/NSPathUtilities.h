#import <Foundation/NSString.h>
#import <Foundation/NSArray.h>

@interface NSString (NSStringPathExtensions)

+ (NSString *)pathWithComponents:(NSArray *)components;
- (NSArray *)pathComponents;
- (BOOL)isAbsolutePath;
- (NSString *)lastPathComponent;
- (NSString *)stringByDeletingLastPathComponent;
- (NSString *)stringByAppendingPathComponent:(NSString *)str;
- (NSString *)pathExtension;
- (NSString *)stringByDeletingPathExtension;
- (NSString *)stringByAppendingPathExtension:(NSString *)str;
- (NSString *)stringByAbbreviatingWithTildeInPath;
- (NSString *)stringByExpandingTildeInPath;
- (NSString *)stringByStandardizingPath;
- (NSString *)stringByResolvingSymlinksInPath;
- (NSArray *)stringsByAppendingPaths:(NSArray *)paths;
- (NSUInteger)completePathIntoString:(NSString **)outputName caseSensitive:(BOOL)flag matchesIntoArray:(NSArray **)outputArray filterTypes:(NSArray *)filterTypes;
- (const char *)fileSystemRepresentation NS_RETURNS_INNER_POINTER;
- (BOOL)getFileSystemRepresentation:(char *)cname maxLength:(NSUInteger)max;

@end

@interface NSArray (NSArrayPathExtensions)

- (NSArray *)pathsMatchingExtensions:(NSArray *)filterTypes;

@end

FOUNDATION_EXPORT NSString *NSUserName(void);
FOUNDATION_EXPORT NSString *NSFullUserName(void);
FOUNDATION_EXPORT NSString *NSHomeDirectory(void);
FOUNDATION_EXPORT NSString *NSHomeDirectoryForUser(NSString *userName);
FOUNDATION_EXPORT NSString *NSTemporaryDirectory(void);
FOUNDATION_EXPORT NSString *NSOpenStepRootDirectory(void);

typedef NS_ENUM(NSUInteger, NSSearchPathDirectory) {
    NSApplicationDirectory = 1,
    NSDemoApplicationDirectory,
    NSDeveloperApplicationDirectory,
    NSAdminApplicationDirectory,
    NSLibraryDirectory,
    NSDeveloperDirectory,
    NSUserDirectory,
    NSDocumentationDirectory,
    NSDocumentDirectory,
    NSCoreServiceDirectory,
    NSAutosavedInformationDirectory = 11,
    NSDesktopDirectory = 12,
    NSCachesDirectory = 13,
    NSApplicationSupportDirectory = 14,
    NSDownloadsDirectory = 15,
    NSInputMethodsDirectory = 16,
    NSMoviesDirectory = 17,
    NSMusicDirectory = 18,
    NSPicturesDirectory = 19,
    NSPrinterDescriptionDirectory = 20,
    NSSharedPublicDirectory = 21,
    NSPreferencePanesDirectory = 22,
    NSApplicationScriptsDirectory = 23,
    NSItemReplacementDirectory = 99,
    NSAllApplicationsDirectory = 100,
    NSAllLibrariesDirectory = 101
};

typedef NS_OPTIONS(NSUInteger, NSSearchPathDomainMask) {
    NSUserDomainMask = 1,
    NSLocalDomainMask = 2,
    NSNetworkDomainMask = 4,
    NSSystemDomainMask = 8,
    NSAllDomainsMask = 0x0ffff
};

FOUNDATION_EXPORT NSArray *NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory directory, NSSearchPathDomainMask domainMask, BOOL expandTilde);
