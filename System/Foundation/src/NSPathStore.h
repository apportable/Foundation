#import <Foundation/NSString.h>
#import <Foundation/NSCache.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSPathUtilities.h>
#import <dispatch/dispatch.h>
#import <alloca.h>

#define BUG_COMPLIANT_PATH_MAX 1024

#ifndef NSPathSep
#define NSPathSep @"/"
#endif

#ifndef NSPathDot
#define NSPathDot @"."
#endif

#ifndef NSPathDotDot
#define NSPathDotDot @".."
#endif

#ifndef NSPathHome
#define NSPathHome @"~"
#endif

#ifndef PATH_SEP
#define PATH_SEP '/'
#endif

#ifndef PATH_DOT
#define PATH_DOT '.'
#endif

#ifndef PATH_HOME
#define PATH_HOME '~'
#endif

@class NSMutableArray;

/*
 In addition to  storing the characters, length, and ref count,to quickly return path
 components, store the NSArray of path components to reference
 lastPathComponent, pathExtension quickly. Additionally, I am not quite certain
 why this manages a ref count unless it is assigning the characters pointer without
 malloc/memcpy.
*/
CF_PRIVATE
@interface NSPathStore2 : NSString {
    NSArray *_components;
    NSUInteger _lengthAndRefCount; // only using the length part, iOS seems to be using upper bits for this (>> 0x14)
    unichar _characters[0];
}

+ (id)pathWithComponents:(NSArray *)components;
+ (id)pathStoreWithCharacters:(const unichar *)chars length:(NSUInteger)len;
- (id)stringByResolvingSymlinksInPath;
- (id)_stringByResolvingSymlinksInPathUsingCache:(BOOL)shouldCache;
- (id)stringByStandardizingPath;
- (id)_stringByStandardizingPathUsingCache:(BOOL)shouldCache;
- (id)stringByExpandingTildeInPath;
- (id)stringByAbbreviatingWithTildeInPath;
- (id)stringByAppendingPathExtension:(NSString *)ext;
- (id)stringByDeletingPathExtension;
- (id)pathExtension;
- (id)stringByAppendingPathComponent:(NSString *)comp;
- (id)stringByDeletingLastPathComponent;
- (id)lastPathComponent;
- (BOOL)isAbsolutePath;
- (id)pathComponents;
- (BOOL)isEqualToString:(NSString *)string;
- (NSUInteger)hash;
- (id)copyWithZone:(NSZone *)zone;
- (void)getCharacters:(unichar *)chars range:(NSRange)r;
- (unichar)characterAtIndex:(NSUInteger)index;
- (NSUInteger)length;

@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-function"

static inline NSUInteger _NSExpandTildeInPath(unichar *buffer, NSUInteger length)
{
    if (length == 0 || buffer[0] != PATH_HOME)
    {
        return length;
    }
    NSString *homeDir = NSHomeDirectory();
    NSUInteger homeLen = [homeDir length];
    memmove(&buffer[homeLen - 1], buffer, length * sizeof(unichar)); // chop off the ~
    [homeDir getCharacters:buffer range:NSMakeRange(0, homeLen)];
    return homeLen + length - 1;
}

static NSString *_NSStandardizePathUsingCache(NSString *self, BOOL useCache)
{
    static NSCache *standardizedPathCache = nil;
    NSUInteger length = [self length];
    NSString *result = nil;
    if (useCache)
    {
        static dispatch_once_t once = 0L;
        dispatch_once(&once, ^{
            standardizedPathCache = [[NSCache alloc] init]; // used soley for it's auto evitction concepts
        });
        result = [standardizedPathCache objectForKey:self];
        if (result != nil)
        {
            return result;
        }
    }
    NSUInteger capacity = MAX([self length], BUG_COMPLIANT_PATH_MAX);
    unichar *buffer = alloca(capacity * sizeof(unichar));
    [self getCharacters:buffer range:NSMakeRange(0, length)];
    length = _NSExpandTildeInPath(buffer, length);

    NSString *str = (NSString *)[NSPathStore2 pathStoreWithCharacters:buffer length:length];
    NSMutableArray *components = [[str pathComponents] mutableCopy];
    
    NSUInteger lastCount, currentCount;
    do {
        BOOL foundUpDir = NO;
        BOOL foundCurrentDir = NO;
        currentCount = [components count];
        NSUInteger idx = [components indexOfObject:NSPathDotDot];
        if (idx != NSNotFound)
        {
            foundUpDir = YES;
            [components removeObjectAtIndex:idx];
            if (idx > 0)
            {
                [components removeObjectAtIndex:idx - 1];
            }
        }
        idx = [components indexOfObject:NSPathDot];
        if (idx != NSNotFound)
        {
            foundCurrentDir = YES;
            [components removeObjectAtIndex:idx];
        }
        if (!foundUpDir && !foundCurrentDir)
        {
            break;
        }
        lastCount = [components count];
    } while (lastCount != currentCount);

    result = [NSPathStore2 pathWithComponents:components];
    [components release];
    if (useCache)
    {
        NSString *key = [self copy]; // NSCache does not copy keys
        [standardizedPathCache setObject:result forKey:key cost:length];
        [key release];
    }
    return result;
}

#pragma clang diagnostic pop
