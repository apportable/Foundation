#import "Foundation/NSBundle.h"
#import "Foundation/NSArray.h"
#import "Foundation/NSDictionary.h"
#import "Foundation/NSString.h"
#import "Foundation/NSError.h"
#import "Foundation/NSProcessInfo.h"
#import "Foundation/NSCache.h"
#import "Foundation/NSURL.h"
#import "Foundation/NSFileManager.h"
#import "Foundation/NSLocale.h"
#import <dispatch/dispatch.h>
#import <dirent.h>
#import <assert.h>
#import <map>
#import <set>
#import <string>
#import <algorithm>

static NSMutableDictionary *loadedBundles = nil;

typedef std::set<std::string> ReversedPaths;

// Keys are extensions.
// Values are created by removing extensions from files and then reversing the
// string.
typedef std::map<std::string, ReversedPaths> PathsByExtension;

@implementation NSBundle {
    NSString *_path;
    NSDictionary *_info;
    BOOL _loaded;
    NSMutableArray *_paths;
    NSMutableDictionary *_localizedStrings;

    PathsByExtension _pathsByExtension;
}

+ (void)initialize
{
    static dispatch_once_t once = 0L;
    dispatch_once(&once, ^{
                      loadedBundles = [[NSMutableDictionary alloc] init];
                  });
}

static NSBundle *mainBundle = nil;

+ (NSBundle *)mainBundle
{
    static dispatch_once_t once = 0L;
    dispatch_once(&once, ^{
                      mainBundle = [[NSBundle alloc] initWithPath:[[[[NSProcessInfo processInfo] arguments] objectAtIndex:0] stringByDeletingLastPathComponent]];
                      [mainBundle load];
                  });
    return mainBundle;
}

+ (NSBundle *)bundleWithPath:(NSString *)path
{
    return [[[self alloc] initWithPath:path] autorelease];
}

+ (NSBundle *)bundleWithURL:(NSURL *)url
{
    return [[[self alloc] initWithURL:url] autorelease];
}

+ (NSBundle *)bundleForClass:(Class)aClass
{
    return [NSBundle mainBundle]; // this is technically incorrect
}

+ (NSBundle *)bundleWithIdentifier:(NSString *)identifier
{
    NSBundle *bundle = nil;
    @synchronized(loadedBundles)
    {
        bundle = [[loadedBundles objectForKey:identifier] retain];
    }
    return [bundle autorelease];
}

+ (NSArray *)allBundles
{
    NSArray *allBundles = nil;
    @synchronized(loadedBundles)
    {
        allBundles = [[loadedBundles allValues] copy];
    }
    return [allBundles autorelease];
}

+ (NSArray *)allFrameworks
{
    return nil; // this is technically incorrect
}

+ (NSURL *)URLForResource:(NSString *)name withExtension:(NSString *)ext subdirectory:(NSString *)subpath inBundleWithURL:(NSURL *)bundleURL
{
    return [[NSBundle bundleWithURL:bundleURL] URLForResource:name withExtension:ext subdirectory:subpath];
}

+ (NSArray *)URLsForResourcesWithExtension:(NSString *)ext subdirectory:(NSString *)subpath inBundleWithURL:(NSURL *)bundleURL
{
    return [[NSBundle bundleWithURL:bundleURL] URLsForResourcesWithExtension:ext subdirectory:subpath];
}

+ (NSString *)pathForResource:(NSString *)name ofType:(NSString *)ext inDirectory:(NSString *)bundlePath
{
    return [[NSBundle bundleWithPath:bundlePath] pathForResource:name ofType:ext];
}

+ (NSArray *)pathsForResourcesOfType:(NSString *)ext inDirectory:(NSString *)bundlePath
{
    return [[NSBundle bundleWithPath:bundlePath] pathsForResourcesOfType:ext inDirectory:nil];
}

+ (NSArray *)preferredLocalizationsFromArray:(NSArray *)localizationsArray
{
    NSMutableArray *preferred = [NSMutableArray array];
    NSString *current = [[NSLocale currentLocale] localeIdentifier];
    for (NSString *localization in localizationsArray)
    {
        if ([localization isEqualToString:current])
        {
            [preferred insertObject:localization atIndex:0];
            NSArray *comps = [localization componentsSeparatedByString:@"_"];
            if ([comps count] > 1)
            {
                [preferred insertObject:[comps objectAtIndex:0] atIndex:1];
            }
        }
        else
        {
            [preferred addObject:localization];
            NSArray *comps = [localization componentsSeparatedByString:@"_"];
            if ([comps count] > 1)
            {
                [preferred addObject:[comps objectAtIndex:0]];
            }
        }
    }
    return preferred;
}

+ (NSArray *)preferredLocalizationsFromArray:(NSArray *)localizationsArray forPreferences:(NSArray *)preferencesArray
{
    return [NSBundle preferredLocalizationsFromArray:localizationsArray]; //
                                                                          // this
                                                                          // is
                                                                          // technically
                                                                          // incorrect
}

- (id)initWithPath:(NSString *)path
{
    return [self initWithURL:[NSURL fileURLWithPath:path]];
}

static BOOL bundle_paths(const char *dir_path, PathsByExtension &pathsByExtension, int depth)
{
    BOOL success = YES;
    DIR *d = opendir(dir_path);
    if (d == NULL)
    {
        return NO;
    }

    int i = 0;

    while (1) {
        struct dirent *entry;
        const char *d_name;

        entry = readdir(d);
        if (!entry)
        {
            break;
        }

        d_name = entry->d_name;
        int path_length;
        char path[PATH_MAX];

        path_length = snprintf(path, PATH_MAX, "%s/%s", dir_path, d_name);
        if (path_length >= PATH_MAX)
        {
            success = NO;
            break;
        }

        if ((entry->d_type & DT_DIR) && strcmp(d_name, "..") != 0 && strcmp(d_name, ".") != 0)
        {
            if (!bundle_paths(path, pathsByExtension, depth + 1))
            {
                success = NO;
                break;
            }
        }
        else if (entry->d_type & DT_REG)
        {
            NSString *str = [NSString stringWithUTF8String:path];

            NSString *ext = [str pathExtension];
            NSString *base = [str stringByDeletingPathExtension];

            if (!ext)
            {
                ext = @"";
            }

            std::string value([base UTF8String]);

            std::reverse(value.begin(), value.end());

            const char *cStr = [ext UTF8String];

            pathsByExtension[cStr].insert(value);
        }
    }

    if (closedir(d) != 0)
    {
        success = NO;
    }
    return success;
}


- (id)initWithURL:(NSURL *)url
{
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isDir = NO;
    if (!([url isFileURL] &&
          [fm fileExistsAtPath:[url path] isDirectory:&isDir] &&
          isDir))
    {
        [self release];
        return nil;
    }

    static NSCache *cache = nil;
    static dispatch_once_t once = 0L;
    dispatch_once(&once, ^{
                      cache = [[objc_getClass("NSCache") alloc] init];
                  });

    NSBundle *bundle = [cache objectForKey:url];
    if (bundle != nil)
    {
        [self release];
        return [bundle retain];
    }

    self = [super init];
    if (self)
    {
        _path = [[url path] retain];
        _loaded = NO;
        [cache setObject:self forKey:url];

        _localizedStrings = [[NSMutableDictionary alloc] init];

        if (!bundle_paths([[self bundlePath] UTF8String], _pathsByExtension, 0))
        {
            [self release];
            return nil;
        }
    }
    return self;
}

static void __NSBundleMainBundleDealloc() {
    RELEASE_LOG("Attempt to dealloc [NSBundle mainBundle], ignored.");
}

- (void)dealloc
{
    if (self == mainBundle) {
        __NSBundleMainBundleDealloc();
        return;
    }

    [_path release];
    [_info release];
    [_localizedStrings release];
    [super dealloc];
}

- (BOOL)load
{
    return [self loadAndReturnError:NULL];
}

- (BOOL)isLoaded
{
    return _loaded;
}

- (BOOL)unload
{
    if (_loaded)
    {
        NSString *identifier = [self bundleIdentifier];
        @synchronized(loadedBundles)
        {
            if (identifier != nil)
            {
                [loadedBundles removeObjectForKey:identifier];
            }
        }
        _loaded = NO;
    }
    return _loaded;
}

- (BOOL)preflightAndReturnError:(NSError **)error
{
    if (error != NULL)
    {
        *error = nil;
    }

    return YES;
}

- (BOOL)loadAndReturnError:(NSError **)error
{
    if (error != NULL)
    {
        *error = nil;
    }

    if (!_loaded)
    {
        _loaded = YES;
        // TODO: add dlopen here for code loading?
        NSString *identifier = [self bundleIdentifier];
        @synchronized(loadedBundles)
        {
            if (identifier != nil)
            {
                [loadedBundles setObject:self forKey:identifier];
            }
        }
    }

    return _loaded;
}

- (NSURL *)bundleURL
{
    return [NSURL fileURLWithPath:_path];
}

- (NSURL *)resourceURL
{
    return [self bundleURL];
}

- (NSURL *)executableURL
{
    NSString *executable = [[self infoDictionary] objectForKey:@"CFBundleExecutable"];
    if (executable != nil)
    {
        return [[self bundleURL] URLByAppendingPathComponent:executable];
    }
    else
    {
        return nil;
    }
}

- (NSURL *)URLForAuxiliaryExecutable:(NSString *)executableName
{
    return [[self bundleURL] URLByAppendingPathComponent:executableName];
}

- (NSURL *)privateFrameworksURL
{
    return [[self bundleURL] URLByAppendingPathComponent:@"PrivateFrameworks"];
}

- (NSURL *)sharedFrameworksURL
{
    return [[self bundleURL] URLByAppendingPathComponent:@"Frameworks"];
}

- (NSURL *)sharedSupportURL
{
    return [[self bundleURL] URLByAppendingPathComponent:@"SharedSupport"];
}

- (NSURL *)builtInPlugInsURL
{
    return [[self bundleURL] URLByAppendingPathComponent:@"Plug-Ins"];
}

- (NSString *)bundlePath
{
    return _path;
}

- (NSString *)resourcePath
{
    return [[self resourceURL] path];
}

- (NSString *)executablePath
{
    return [[self executableURL] path];
}

- (NSString *)pathForAuxiliaryExecutable:(NSString *)executableName
{
    return [[self URLForAuxiliaryExecutable:executableName] path];
}

- (NSString *)privateFrameworksPath
{
    return [[self privateFrameworksURL] path];
}

- (NSString *)sharedFrameworksPath
{
    return [[self sharedFrameworksURL] path];
}

- (NSString *)sharedSupportPath
{
    return [[self sharedSupportURL] path];
}

- (NSString *)builtInPlugInsPath
{
    return [[self builtInPlugInsURL] path];
}

- (NSURL *)URLForResource:(NSString *)name withExtension:(NSString *)ext subdirectory:(NSString *)subpath localization:(NSString *)localizationName
{
    BOOL matchFullPath = NO;

    if(subpath.length || [[name stringByDeletingLastPathComponent] length]) {
        matchFullPath = YES;
    }

    NSString *searchPath = [self bundlePath];
    NSString *localizationContainer = nil;
    NSString *shortLocalizationContainer = nil;

    NSString *searchName = name;

    if ([ext length] > 0)
    {
        searchName = [name stringByAppendingPathExtension:ext];
    }

    if ([searchName length] == 0)
    {
        return nil;
    }

    if (subpath != nil)
    {
        searchPath = [[self bundlePath] stringByAppendingPathComponent:subpath];
    }

    NSArray *components = [searchName pathComponents];

    for (int i = 0; i < components.count; i++)
    {
        if (i < components.count - 1)
        {
            searchPath = [searchPath stringByAppendingPathComponent:[components objectAtIndex:i]];
        }
        else
        {
            searchName = [components objectAtIndex:i];
        }
    }

    if ([localizationName length] > 0)
    {
        localizationContainer = [localizationName stringByAppendingPathExtension:@"lproj"];
        NSArray *localizationComps = [localizationName componentsSeparatedByString:@"_"];
        if ([localizationComps count] > 0)
        {
            shortLocalizationContainer = [[localizationComps objectAtIndex:0] stringByAppendingPathExtension:@"lproj"];
        }
    }

    std::string extension;

    if ([searchName pathExtension])
    {
        extension = [[searchName pathExtension] UTF8String];
    }

    std::string base = [[searchName stringByDeletingPathExtension] UTF8String];

    std::reverse(base.begin(), base.end());

    ReversedPaths &reversedPaths = _pathsByExtension[extension];

    ReversedPaths::iterator result = reversedPaths.lower_bound(base);

    // Loop over likely candidates in log(n) time.
    for (; result != reversedPaths.end() && 0 == result->compare(0, base.size(), base); ++result)
    {
        std::string tmp(*result);

        std::reverse(tmp.begin(), tmp.end());

        NSString *str = [NSString stringWithUTF8String:tmp.c_str()];

        NSString *parent = [[str stringByDeletingLastPathComponent] lastPathComponent];

        // Use conditionals to restrict against false matches

        if ([parent hasSuffix:@"lproj"])
        {
            if (![shortLocalizationContainer isEqual:parent])
            {
                continue;
            }
        }

        if (matchFullPath && ![[searchPath stringByAppendingPathComponent:[searchName stringByDeletingPathExtension]] isEqual:str])
        {
            continue;
        }

        if (![[[searchName lastPathComponent] stringByDeletingPathExtension] isEqual:[str lastPathComponent]])
        {
            continue;
        }

        if ([[searchName pathExtension] length] > 0)
        {
            str = [str stringByAppendingPathExtension:[searchName pathExtension]];
        }


        return [NSURL fileURLWithPath:str];
    }

    return nil;
}

- (NSURL *)URLForResource:(NSString *)name withExtension:(NSString *)ext
{
    return [self URLForResource:name withExtension:ext subdirectory:nil];
}

- (NSURL *)URLForResource:(NSString *)name withExtension:(NSString *)ext subdirectory:(NSString *)subpath
{
    return [self URLForResource:name withExtension:ext subdirectory:subpath localization:[[NSLocale currentLocale] localeIdentifier]];
}

- (NSArray *)URLsForResourcesWithExtension:(NSString *)ext subdirectory:(NSString *)subpath
{
    return [self URLsForResourcesWithExtension:ext subdirectory:subpath localization:nil];
}

- (NSArray *)URLsForResourcesWithExtension:(NSString *)ext subdirectory:(NSString *)subpath localization:(NSString *)localizationName
{
    NSMutableArray *found = [NSMutableArray array];
    std::string extension = [ext UTF8String];

    NSString *searchPath = [self bundlePath];
    NSString *localizationContainer = nil;
    NSString *shortLocalizationContainer = nil;

    if (localizationName != nil)
    {
        localizationContainer = [localizationName stringByAppendingPathExtension:@"lproj"];
        NSArray *localizationComps = [localizationName componentsSeparatedByString:@"_"];
        if ([localizationComps count] > 0)
        {
            shortLocalizationContainer = [[localizationComps objectAtIndex:0] stringByAppendingPathExtension:@"lproj"];
        }
    }

    ReversedPaths &reversedPaths = _pathsByExtension[extension];

    for(ReversedPaths::iterator result = reversedPaths.begin(); result != reversedPaths.end(); ++result)
    {
        std::string tmp(*result);

        std::reverse(tmp.begin(), tmp.end());

        NSString *str = [NSString stringWithUTF8String:tmp.c_str()];

        if(subpath)
        {
            NSInteger len = [self bundlePath].length + 1;

            assert(len < str.length);

            if(![[str substringFromIndex:len] hasPrefix:subpath])
            {
                continue;
            }
        }

        NSString *parent = [[str stringByDeletingLastPathComponent] lastPathComponent];

        if ([parent hasSuffix:@"lproj"])
        {
            if (![shortLocalizationContainer isEqual:parent])
            {
                continue;
            }
        }

        if (ext != nil)
        {
            [found addObject:[NSURL fileURLWithPath:[str stringByAppendingPathExtension:ext]]];
        }
        else
        {
            [found addObject:[NSURL fileURLWithPath:str]];
        }
    }

    return found;
}

- (NSString *)pathForResource:(NSString *)name ofType:(NSString *)ext
{
    NSString *result = [[self URLForResource:name withExtension:ext subdirectory:nil localization:[[NSLocale currentLocale] localeIdentifier]] path];

    if (!result)
    {
        result = [[self URLForResource:name withExtension:ext subdirectory:nil localization:nil] path];

        if (!result)
        {
            result = [[self URLForResource:name withExtension:ext subdirectory:nil localization:@"en_US"] path];
        }
    }

    return result;
}

- (NSString *)pathForResource:(NSString *)name ofType:(NSString *)ext inDirectory:(NSString *)subpath
{
    // From the NSBundle documentation for this method: "If subpath is nil, this
    // method searches the top-level nonlocalized resource directory and the
    // top-level of any language-specific directories."

    NSString *path = [[self URLForResource:name withExtension:ext subdirectory:subpath localization:nil] path];
    if (!path && !subpath) {
        path = [[self URLForResource:name withExtension:ext subdirectory:subpath localization:[[NSLocale currentLocale] localeIdentifier]] path];
    }

    return path;
}

- (NSString *)pathForResource:(NSString *)name ofType:(NSString *)ext inDirectory:(NSString *)subpath forLocalization:(NSString *)localizationName
{
    return [[self URLForResource:name withExtension:ext subdirectory:subpath localization:localizationName] path];
}

- (NSArray *)pathsForResourcesOfType:(NSString *)ext inDirectory:(NSString *)subpath
{
    return [self pathsForResourcesOfType:ext inDirectory:subpath forLocalization:nil];
}

- (NSArray *)pathsForResourcesOfType:(NSString *)ext inDirectory:(NSString *)subpath forLocalization:(NSString *)localizationName
{
    NSArray *urls = [self URLsForResourcesWithExtension:ext subdirectory:subpath localization:localizationName];
    NSMutableArray *paths = [NSMutableArray array];
    for (NSURL *url in urls)
    {
        [paths addObject:[url path]];
    }
    return [[paths copy] autorelease];
}

- (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)tableName
{
    NSString *localized = @"";
    @synchronized(self)
    {
        if (tableName == nil)
        {
            tableName = @"Localizable";
        }
        NSDictionary *table = [_localizedStrings objectForKey:tableName];
        if (table == nil)
        {
            NSString *fullLocale = [[NSLocale currentLocale] localeIdentifier];
            NSString *path = [self pathForResource:tableName ofType:@"strings" inDirectory:nil forLocalization:fullLocale];
            if (!path)
            {
                // fall back to English if there's no found strings file
                path = [self pathForResource:tableName ofType:@"strings" inDirectory:nil forLocalization:@"en"];
            }
            if (path)
            {
                NSString *contents = [NSString stringWithContentsOfFile:path];
                if (contents != nil)
                {
                    table = [contents propertyList];
                    if (table && [table isKindOfClass:[NSDictionary class]])
                    {
                        [_localizedStrings setObject:table forKey:tableName];
                    }
                    else
                    {
                        table = nil;
                    }
                }
            }
        }
        if ([table objectForKey:key] != nil)
        {
            localized = [[table objectForKey:key] retain];
        }
        else if (key != nil)
        {
            localized = [key copy];
        }
    }
    return [localized autorelease];
}

- (NSString *)bundleIdentifier
{
    return [[self infoDictionary] objectForKey:@"CFBundleIdentifier"];
}

- (NSDictionary *)infoDictionary
{
    @synchronized(self)
    {
        if (_info == nil)
        {
            _info = [[NSDictionary alloc] initWithContentsOfFile:[[self bundlePath] stringByAppendingPathComponent:@"Info.plist"]];
        }
    }
    return _info;
}

- (NSDictionary *)localizedInfoDictionary
{
    return nil;
}

- (id)objectForInfoDictionaryKey:(NSString *)key
{
    return [[self infoDictionary] objectForKey:key];
}

- (Class)classNamed:(NSString *)className
{
    return NSClassFromString(className);
}

- (Class)principalClass
{
    NSString *principalClassName = [[self infoDictionary] objectForKey:@"NSPrincipalClass"];
    if (principalClassName != nil)
    {
        return NSClassFromString(principalClassName);
    }
    else
    {
        return nil;
    }
}

- (NSArray *)localizations
{
    return [[self infoDictionary] objectForKey:@"CFBundleLocalizations"];
}

- (NSArray *)preferredLocalizations
{
    return [NSBundle preferredLocalizationsFromArray:[self localizations]];
}

- (NSString *)developmentLocalization
{
    return [[self infoDictionary] objectForKey:@"CFBundleDevelopmentRegion"];
}

- (NSArray *)executableArchitectures
{
    // this should really read the library format and parse it
#if __arm__
    return @[@(NSBundleExecutableArchitectureARM)];
#elif __i386__
    return @[@(NSBundleExecutableArchitectureI386)];
#elif __x86_64__
    return @[@(NSBundleExecutableArchitectureX86_64)];
#elif __mips__
    return @[@(NSBundleExecutableArchitectureMIPS)];
#else
    return nil;
#endif
}

@end
