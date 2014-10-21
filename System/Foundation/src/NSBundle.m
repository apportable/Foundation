//
//  NSBundle.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <dispatch/dispatch.h>
#import <CoreFoundation/CFBundle.h>
#import <objc/runtime.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSString.h>
#import <Foundation/NSBundle.h>
#import <Foundation/NSProcessInfo.h>
#import <Foundation/NSURL.h>
#import <Foundation/NSDictionary.h>

static NSMutableDictionary *loadedBundles = nil;
static NSBundle *mainBundle = nil;

typedef enum {
    NSBundleIsLoadedFlag = 0x01,
} NSBundleFlags;

@implementation NSBundle {
    NSBundleFlags _flags;
    CFBundleRef _cfBundle;
    Class _principalClass;
}

+ (void)initialize
{
    static dispatch_once_t once = 0L;
    dispatch_once(&once, ^{
        loadedBundles = [[NSMutableDictionary alloc] init];
    });
}

+ (NSBundle *)mainBundle
{
    static dispatch_once_t once = 0L;
    dispatch_once(&once, ^{
        mainBundle = [[NSBundle alloc] init];
        mainBundle->_cfBundle = (CFBundleRef)CFRetain(CFBundleGetMainBundle());
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
        bundle = [loadedBundles[identifier] retain];
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
    return nil; // this is technically incorrect, when we do start supporting frameworks, this will need to be fixed.
}

- (id)initWithPath:(NSString *)path
{
    NSURL *url = [[NSURL alloc] initFileURLWithPath:path isDirectory:YES];
    self = [self initWithURL:url];    
    [url release];
    return self;
}

- (id)initWithURL:(NSURL *)url
{
    self = [super init];
    if (self)
    {
        _cfBundle = CFBundleCreate(kCFAllocatorDefault, (CFURLRef)url);
        if (!_cfBundle)
        {
            [self release];
            return nil;
        }
    }
    return self;
}

static void __NSBundleMainBundleDealloc()
{
    RELEASE_LOG("Attempt to dealloc [NSBundle mainBundle], ignored.");
}

- (void)dealloc
{
    if (self == mainBundle) {
        __NSBundleMainBundleDealloc();
        return;
    }

    if (_cfBundle)
    {
        CFRelease(_cfBundle);
    }
    [super dealloc];
}

- (CFBundleRef)_cfBundle
{
    return _cfBundle;
}

- (NSURL *)URLForResource:(NSString *)name withExtension:(NSString *)ext
{
    return [self URLForResource:name withExtension:ext subdirectory:nil];
}

- (NSURL *)URLForResource:(NSString *)name withExtension:(NSString *)ext subdirectory:(NSString *)subpath
{
    return [(NSURL *)CFBundleCopyResourceURL(_cfBundle, (CFStringRef)name, (CFStringRef)ext, (CFStringRef)subpath) autorelease];
}

- (NSURL *)URLForResource:(NSString *)name withExtension:(NSString *)ext subdirectory:(NSString *)subpath localization:(NSString *)localizationName
{
    return [(NSURL *)CFBundleCopyResourceURLForLocalization(_cfBundle, (CFStringRef)name, (CFStringRef)ext, (CFStringRef)subpath, (CFStringRef)localizationName) autorelease];  
}

- (NSString *)pathForResource:(NSString *)name ofType:(NSString *)ext
{
    return [[self URLForResource:name withExtension:ext subdirectory:nil] path];
}

- (NSString *)pathForResource:(NSString *)name ofType:(NSString *)ext inDirectory:(NSString *)subpath
{
    return [[self URLForResource:name withExtension:ext subdirectory:subpath] path];
}

- (NSString *)pathForResource:(NSString *)name ofType:(NSString *)ext inDirectory:(NSString *)subpath forLocalization:(NSString *)localizationName
{
    return [[self URLForResource:name withExtension:ext subdirectory:subpath localization:localizationName] path];
}

- (NSDictionary *)infoDictionary
{
    return (NSDictionary *)CFBundleGetInfoDictionary(_cfBundle);
}

- (NSDictionary *)localizedInfoDictionary
{
    CFBundleRef bundle = [self _cfBundle];
    if (bundle != NULL)
    {
        return (NSDictionary *)CFBundleGetLocalInfoDictionary(bundle);
    }
    else
    {
        return nil;
    }
}

- (NSArray *)URLsForResourcesWithExtension:(NSString *)ext subdirectory:(NSString *)subpath
{
    return [self URLsForResourcesWithExtension:ext subdirectory:subpath localization:nil];
}

- (NSArray *)URLsForResourcesWithExtension:(NSString *)ext subdirectory:(NSString *)subpath localization:(NSString *)localizationName
{
    return [(NSArray *)CFBundleCopyResourceURLsOfTypeForLocalization(_cfBundle, (CFStringRef)ext, (CFStringRef)subpath, (CFStringRef)localizationName) autorelease];
}

- (NSArray *)pathsForResourcesOfType:(NSString *)ext inDirectory:(NSString *)subpath
{
    return [self pathsForResourcesOfType:ext inDirectory:subpath forLocalization:nil];
}

- (NSArray *)pathsForResourcesOfType:(NSString *)ext inDirectory:(NSString *)subpath forLocalization:(NSString *)localizationName
{
    NSMutableArray *paths = [[NSMutableArray alloc] init];
    NSArray *urls = [self URLsForResourcesWithExtension:ext subdirectory:subpath localization:localizationName];
    for (NSURL *url in urls)
    {
        [paths addObject:[url path]];
    }
    return [paths autorelease];
}

- (NSString*)bundlePath
{
    NSURL *url = (NSURL *)CFBundleCopyBundleURL(_cfBundle);
    NSString *path = [url path];
    CFRelease(url);
    return path;
}

- (NSURL *)bundleURL
{
    return [(NSURL *)CFBundleCopyBundleURL(_cfBundle) autorelease];
}

- (NSString *)resourcePath
{
    return [self bundlePath];
}

- (NSString *)executablePath
{
    CFBundleRef bundle = [self _cfBundle];
    if (bundle != NULL)
    {
        CFURLRef url = CFBundleCopyExecutableURL(bundle);
        NSString *path = [(NSURL *)url path];
        if (url != NULL)
        {
            CFRelease(url);
        }
        return path;
    }
    else
    {
        return nil;
    }
}

- (NSString *)pathForAuxiliaryExecutable:(NSString *)executableName
{
    CFBundleRef bundle = [self _cfBundle];
    if (bundle != NULL)
    {
        CFURLRef url = CFBundleCopyAuxiliaryExecutableURL(bundle, (CFStringRef)executableName);
        NSString *path = [(NSURL *)url path];
        if (url != NULL)
        {
            CFRelease(url);
        }
        return path;
    }
    else
    {
        return nil;
    }
}

- (NSString *)privateFrameworksPath
{
    CFBundleRef bundle = [self _cfBundle];
    if (bundle != NULL)
    {
        CFURLRef url = CFBundleCopyPrivateFrameworksURL(bundle);
        NSString *path = [(NSURL *)url path];
        if (url != NULL)
        {
            CFRelease(url);
        }
        return path;
    }
    else
    {
        return nil;
    }
}

- (NSString *)sharedFrameworksPath
{
    CFBundleRef bundle = [self _cfBundle];
    if (bundle != NULL)
    {
        CFURLRef url = CFBundleCopySharedFrameworksURL(bundle);
        NSString *path = [(NSURL *)url path];
        if (url != NULL)
        {
            CFRelease(url);
        }
        return path;
    }
    else
    {
        return nil;
    }
}

- (NSString *)sharedSupportPath
{
    CFBundleRef bundle = [self _cfBundle];
    if (bundle != NULL)
    {
        CFURLRef url = CFBundleCopySharedSupportURL(bundle);
        NSString *path = [(NSURL *)url path];
        if (url != NULL)
        {
            CFRelease(url);
        }
        return path;
    }
    else
    {
        return nil;
    }
}

- (NSString *)builtInPlugInsPath
{
    CFBundleRef bundle = [self _cfBundle];
    if (bundle != NULL)
    {
        CFURLRef url = CFBundleCopyBuiltInPlugInsURL(bundle);
        NSString *path = [(NSURL *)url path];
        if (url != NULL)
        {
            CFRelease(url);
        }
        return path;
    }
    else
    {
        return nil;
    }
}

- (NSURL *)resourceURL
{
    return [self bundleURL];
}

- (NSURL *)executableURL
{
    return [[self bundleURL] URLByAppendingPathComponent:[[self infoDictionary] objectForKey:@"CFBundleExecutable"]];
}

- (NSURL *)URLForAuxiliaryExecutable:(NSString *)executableName
{
    CFBundleRef bundle = [self _cfBundle];
    if (bundle != NULL)
    {
        return [(NSURL *)CFBundleCopyAuxiliaryExecutableURL(bundle, (CFStringRef)executableName) autorelease];
    }
    else
    {
        return nil;
    }
}

- (NSURL *)privateFrameworksURL
{
    CFBundleRef bundle = [self _cfBundle];
    if (bundle != NULL)
    {
        return [(NSURL *)CFBundleCopyPrivateFrameworksURL(bundle) autorelease];
    }
    else
    {
        return nil;
    }
}

- (NSURL *)sharedFrameworksURL
{
    CFBundleRef bundle = [self _cfBundle];
    if (bundle != NULL)
    {
        return [(NSURL *)CFBundleCopySharedFrameworksURL(bundle) autorelease];
    }
    else
    {
        return nil;
    }
}

- (NSURL *)sharedSupportURL
{
    CFBundleRef bundle = [self _cfBundle];
    if (bundle != NULL)
    {
        return [(NSURL *)CFBundleCopySharedSupportURL(bundle) autorelease];
    }
    else
    {
        return nil;
    }
}

- (NSURL *)builtInPlugInsURL
{
    CFBundleRef bundle = [self _cfBundle];
    if (bundle != NULL)
    {
        return [(NSURL *)CFBundleCopyBuiltInPlugInsURL(bundle) autorelease];
    }
    else
    {
        return nil;
    }
}

- (NSURL *)appStoreReceiptURL
{
    NSURL *url = [self bundleURL];
    if (url != nil)
    {
        url = [[url URLByDeletingLastPathComponent] URLByAppendingPathComponent:@"StoreKit" isDirectory:YES];
    }
    return [url URLByAppendingPathComponent:@"receipt" isDirectory:NO];
}


- (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)tableName
{
    return [(NSString *)CFBundleCopyLocalizedString(_cfBundle, (CFStringRef)key, (CFStringRef)value, (CFStringRef)tableName) autorelease];
}

- (id)objectForInfoDictionaryKey:(NSString *)key
{
    return (id)CFBundleGetValueForInfoDictionaryKey(_cfBundle, (CFStringRef)key);
}

- (NSString *)bundleIdentifier
{
    return [[self infoDictionary] objectForKey:@"CFBundleIdentifier"];
}

- (BOOL)load
{
    return [self loadAndReturnError:NULL];
}

- (BOOL)isLoaded
{
    return (_flags & NSBundleIsLoadedFlag) != 0;
}

- (BOOL)unload
{
    // Not supported
    return NO;
}

- (BOOL)preflightAndReturnError:(NSError **)error
{
    if (error != NULL)
    {
        *error = nil;
    }
    return CFBundlePreflightExecutable(_cfBundle, (CFErrorRef *)error);
}

- (BOOL)loadAndReturnError:(NSError **)error
{
    if (error != NULL)
    {
        *error = nil;
    }
    NSString *identifier = [self bundleIdentifier];
    Boolean loaded = false;
    @synchronized(loadedBundles)
    {

        if (loadedBundles[identifier] == nil)
        {
            loaded = CFBundleLoadExecutableAndReturnError(_cfBundle, (CFErrorRef *)error);
            if (loaded)
            {
                loadedBundles[identifier] = self;
                _flags |= NSBundleIsLoadedFlag;
            }
        }
    }

    return loaded;
}

- (Class)classNamed:(NSString *)className
{
#warning TODO: classNamed should lookup by images
    return NSClassFromString(className);
}

- (Class)principalClass
{
    if ((_flags & NSBundleIsLoadedFlag) == 0)
    {
        [self load];
    }
    if (_principalClass == Nil)
    {
        NSString *principalClassName = [[self infoDictionary] objectForKey:@"NSPrincipalClass"];
        Class cls = NSClassFromString(principalClassName);
        // ensure an initialize is triggered and the class is reasonable
        if (cls != Nil && class_respondsToSelector(object_getClass(cls), @selector(self)))
        {
            _principalClass = [cls self];    
        }
    }
    return _principalClass;
}

- (NSArray *)localizations
{
    return [(NSArray *)CFBundleCopyBundleLocalizations(_cfBundle) autorelease];
}

- (NSArray *)preferredLocalizations
{
    return [NSBundle preferredLocalizationsFromArray:[self localizations]];
}

- (NSString *)developmentLocalization
{
    return [(NSString *)CFBundleGetDevelopmentRegion(_cfBundle) autorelease];
}

+ (NSArray *)preferredLocalizationsFromArray:(NSArray *)localizationsArray
{
    return [(NSArray *)CFBundleCopyPreferredLocalizationsFromArray((CFArrayRef)localizationsArray) autorelease];
}

- (NSArray *)executableArchitectures
{
    return [(NSArray *)CFBundleCopyExecutableArchitectures(_cfBundle) autorelease];
}

@end
