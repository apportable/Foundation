#import <Foundation/NSObject.h>

@class NSArray, NSDictionary, NSString, NSURL, NSError;

#define NSLocalizedString(key, comment) \
    [[NSBundle mainBundle] localizedStringForKey : (key) value : @"" table : nil]
#define NSLocalizedStringFromTable(key, tbl, comment) \
    [[NSBundle mainBundle] localizedStringForKey : (key) value : @"" table : (tbl)]
#define NSLocalizedStringFromTableInBundle(key, tbl, bundle, comment) \
    [bundle localizedStringForKey : (key) value : @"" table : (tbl)]
#define NSLocalizedStringWithDefaultValue(key, tbl, bundle, val, comment) \
    [bundle localizedStringForKey : (key) value : (val) table : (tbl)]

__BEGIN_DECLS

extern NSString * const NSBundleDidLoadNotification;
extern NSString * const NSLoadedClasses;

__END_DECLS

enum {
    NSBundleExecutableArchitectureARM       = 0x0000000C, // Non-standard
                                                          // declaration (but
                                                          // correct value)
    NSBundleExecutableArchitectureMIPS      = 0x0000000D, // Non-standard (not
                                                          // present in Apple's
                                                          // Foundation)
    NSBundleExecutableArchitectureI386      = 0x00000007,
    NSBundleExecutableArchitecturePPC       = 0x00000012,
    NSBundleExecutableArchitectureX86_64    = 0x01000007,
    NSBundleExecutableArchitecturePPC64     = 0x01000012,
    NSBundleExecutableArchitectureARM64     = 0x0100000C, // Non-standard (not
                                                          // present in Apple's
                                                          // Foundation)
};

@interface NSBundle : NSObject
+ (NSBundle *)mainBundle;
+ (NSBundle *)bundleWithPath:(NSString *)path;

+ (NSBundle *)bundleWithURL:(NSURL *)url;
+ (NSBundle *)bundleForClass:(Class)aClass;
+ (NSBundle *)bundleWithIdentifier:(NSString *)identifier;

+ (NSArray *)allBundles;
+ (NSArray *)allFrameworks;

+ (NSURL *)URLForResource:(NSString *)name withExtension:(NSString *)ext subdirectory:(NSString *)subpath inBundleWithURL:(NSURL *)bundleURL;
+ (NSArray *)URLsForResourcesWithExtension:(NSString *)ext subdirectory:(NSString *)subpath inBundleWithURL:(NSURL *)bundleURL;
+ (NSString *)pathForResource:(NSString *)name ofType:(NSString *)ext inDirectory:(NSString *)bundlePath;
+ (NSArray *)pathsForResourcesOfType:(NSString *)ext inDirectory:(NSString *)bundlePath;
+ (NSArray *)preferredLocalizationsFromArray:(NSArray *)localizationsArray;
+ (NSArray *)preferredLocalizationsFromArray:(NSArray *)localizationsArray forPreferences:(NSArray *)preferencesArray;

- (id)initWithPath:(NSString *)path;
- (id)initWithURL:(NSURL *)url;

- (BOOL)load;
- (BOOL)isLoaded;
- (BOOL)unload;

- (BOOL)preflightAndReturnError:(NSError **)error;
- (BOOL)loadAndReturnError:(NSError **)error;

- (NSURL *)bundleURL;
- (NSURL *)resourceURL;
- (NSURL *)executableURL;
- (NSURL *)URLForAuxiliaryExecutable:(NSString *)executableName;

- (NSURL *)privateFrameworksURL;
- (NSURL *)sharedFrameworksURL;
- (NSURL *)sharedSupportURL;
- (NSURL *)builtInPlugInsURL;

- (NSString *)bundlePath;
- (NSString *)resourcePath;
- (NSString *)executablePath;
- (NSString *)pathForAuxiliaryExecutable:(NSString *)executableName;

- (NSString *)privateFrameworksPath;
- (NSString *)sharedFrameworksPath;
- (NSString *)sharedSupportPath;
- (NSString *)builtInPlugInsPath;

- (NSURL *)URLForResource:(NSString *)name withExtension:(NSString *)ext;
- (NSURL *)URLForResource:(NSString *)name withExtension:(NSString *)ext subdirectory:(NSString *)subpath;
- (NSURL *)URLForResource:(NSString *)name withExtension:(NSString *)ext subdirectory:(NSString *)subpath localization:(NSString *)localizationName;

- (NSArray *)URLsForResourcesWithExtension:(NSString *)ext subdirectory:(NSString *)subpath;
- (NSArray *)URLsForResourcesWithExtension:(NSString *)ext subdirectory:(NSString *)subpath localization:(NSString *)localizationName;

- (NSString *)pathForResource:(NSString *)name ofType:(NSString *)ext;
- (NSString *)pathForResource:(NSString *)name ofType:(NSString *)ext inDirectory:(NSString *)subpath;
- (NSString *)pathForResource:(NSString *)name ofType:(NSString *)ext inDirectory:(NSString *)subpath forLocalization:(NSString *)localizationName;

- (NSArray *)pathsForResourcesOfType:(NSString *)ext inDirectory:(NSString *)subpath;
- (NSArray *)pathsForResourcesOfType:(NSString *)ext inDirectory:(NSString *)subpath forLocalization:(NSString *)localizationName;

- (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)tableName NS_FORMAT_ARGUMENT(1);

- (NSString *)bundleIdentifier;
- (NSDictionary *)infoDictionary;
- (NSDictionary *)localizedInfoDictionary;
- (id)objectForInfoDictionaryKey:(NSString *)key;
- (Class)classNamed:(NSString *)className;
- (Class)principalClass;

- (NSArray *)localizations;
- (NSArray *)preferredLocalizations;
- (NSString *)developmentLocalization;

- (NSArray *)executableArchitectures;

@end
