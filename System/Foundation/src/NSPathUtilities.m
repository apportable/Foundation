//
//  NSPathUtilities.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/NSPathUtilities.h>
#import "NSPathStore.h"
#import <Foundation/NSDictionary.h>
#import <Foundation/NSException.h>
#import "NSFileManagerInternal.h"
#import <Foundation/NSData.h>
#import "NSObjectInternal.h"
#import <stdlib.h>

@implementation NSString (NSStringPathExtensions)

+ (NSString *)pathWithComponents:(NSArray *)components
{
    return [NSPathStore2 pathWithComponents:components];
}

- (NSArray *)pathComponents
{
    NSMutableArray *comps = [[NSMutableArray alloc] init];
    NSRange r = NSMakeRange(0, [self length]);
    BOOL isDir = NO;

    if ([self hasPrefix:NSPathSep])
    {
        [comps addObject:NSPathSep];
        r.location += 1;
        r.length -= 1;
    }

    if (r.length > 0 && [self hasSuffix:NSPathSep])
    {
        r.length -= 1;
        isDir = YES;
    }

    NSArray *items = [[self substringWithRange:r] componentsSeparatedByString:NSPathSep];
    for (NSString *item in items)
    {
        if ([item length] > 0)
        {
            [comps addObject:item];
        }
    }

    if (isDir)
    {
        [comps addObject:NSPathSep];
    }

    return [comps autorelease];
}

- (BOOL)isAbsolutePath
{
    if ([self length] > 0)
    {
        unichar c = [self characterAtIndex:0];
        if (c == PATH_SEP || c == PATH_HOME)
        {
            return YES;
        }
    }

    return NO;
}

- (NSString *)lastPathComponent
{
    if ([self length] == 0)
    {
        return @"";
    }
    
    return [[self pathComponents] lastObject];
}

- (NSString *)stringByDeletingLastPathComponent
{
    int index = [self length];

    // First delete any trailing slashes except in first character
    while (index > 1 && [self characterAtIndex:index - 1] == PATH_SEP)
    {
        index--;
    }

    // Now find any previous slash
    while (index > 0 && [self characterAtIndex:index - 1] != PATH_SEP)
    {
        index--;
    }

    // Delete any trailing slashes except in first character
    while (index > 1 && [self characterAtIndex:index - 1] == PATH_SEP)
    {
        index--;
    }

    if (index == 0)
    {
        return @"";
    }

    unichar *characters = malloc(index * sizeof(*characters));
    if (characters == NULL)
    {
        [NSException raise:NSMallocException format:@"Could not allocate character buffer"];
        return nil;
    }
    [self getCharacters:characters range:NSMakeRange(0, index)];
    NSString *path = [NSPathStore2 pathStoreWithCharacters:characters length:index];
    free(characters);
    return path;
}

- (NSString *)stringByAppendingPathComponent:(NSString *)str
{
    NSString *first;
    NSString *second;
    NSString *result;
    NSUInteger length = [self length];

    // Remove trailing '/'s from self (except one in position zero)
    NSInteger index = length - 1;
    while (index >= 1 && [self characterAtIndex:index] == PATH_SEP) index--;
    first = [self substringToIndex:index + 1];

    // Remove leading '/'s from str
    NSInteger appendLength = [str length];
    index = 0;
    while (index < appendLength && [str characterAtIndex:index] == PATH_SEP) index++;
    if (index > 0 && length == 0)
    {
        // Keep a PATH_SEP when appending to empty string
        index--;
    }
    second = [str substringWithRange:NSMakeRange(index, appendLength - index)];

    // Generate first/second
    if ([first length] == 0)
    {
        result = second;  // No '/'
    }
    else if ([first length] == 1 && [first characterAtIndex:0] == PATH_SEP)
    {
        result = [NSString stringWithFormat:@"%c%@", PATH_SEP, second]; // Keep '/'
    }
    else
    {
        result = [NSString stringWithFormat:@"%@%c%@", first, PATH_SEP, second];
    }

    // Remove trailing '/'s from result
    length = [result length];
    index = length - 1;
    while (index >= 1 && [result characterAtIndex:index] == PATH_SEP) index--;
    result = [result substringToIndex:index + 1];

    return result;
}

- (NSString *)pathExtension
{
    NSUInteger length = [self length];
    NSString *extension = @"";

    if (length == 0)
    {
        return extension;
    }

    unichar *characters = malloc(length * sizeof(*characters));
    if (characters == NULL)
    {
        return extension;
    }

    [self getCharacters:characters range:NSMakeRange(0, length)];

    NSUInteger idx = length;

    while (--idx > 0)
    {
        if (characters[idx] == PATH_SEP)
        {
            // We have hit the beginning of the last component without finding an extension.
            break;
        }

        if (characters[idx] == PATH_DOT)
        {
            extension = [NSString stringWithCharacters:characters + idx + 1 length:length - idx - 1];
            break;
        }
    }

    free(characters);
    return extension;
}

- (NSString *)stringByDeletingPathExtension
{
    NSUInteger length = [self length];
    if (length < 2)
    {
        return self;
    }

    unichar *buffer = malloc(length * sizeof(unichar));
    [self getCharacters:buffer range:NSMakeRange(0, length)];
    for (NSUInteger idx = length - 2; idx > 0; idx--)
    {
        if (buffer[idx] == PATH_DOT && buffer[idx-1] != PATH_SEP)
        {
            length = idx;
            break;
        }
        if (buffer[idx] == PATH_SEP)
        {
            break;
        }
    }
    NSString *str = (NSString *)[NSPathStore2 pathStoreWithCharacters:buffer length:length];
    free(buffer);
    return str;
}

- (NSString *)stringByAppendingPathExtension:(NSString *)ext
{
    if (ext == nil)
    {
        [NSException raise:NSInvalidArgumentException format:@"cannot append nil path extension"];
        return nil;
    }

    NSUInteger len1 = [self length];
    NSUInteger len2 = [ext length];

    unichar *buffer = malloc((len1 + 1 + len2)  * sizeof(unichar));
    if (buffer == NULL)
    {
        // exception?
        return nil;
    }

    [self getCharacters:buffer range:NSMakeRange(0, len1)];
    buffer[len1] = (unichar)PATH_DOT;
    [ext getCharacters:buffer + 1 + len1 range:NSMakeRange(0, len2)];

    NSString *str = (NSString *)[NSPathStore2 pathStoreWithCharacters:buffer length:len1 + 1 + len2];
    free(buffer);
    return str;
}

- (NSString *)stringByAbbreviatingWithTildeInPath
{
    NSString *homeDir = NSHomeDirectory();
    NSUInteger homeLen = [homeDir length];
    NSString *path = [self _stringByStandardizingPathUsingCache:NO];
    NSUInteger length = [path length];
    unichar *buffer = NULL;
    if ([path hasPrefix:homeDir])
    {
        buffer = malloc((1 + length - homeLen) * sizeof(unichar));
        if (buffer == NULL)
        {
            // throw?
            return nil;
        }
        buffer[0] = '~';
        [path getCharacters:buffer + 1 range:NSMakeRange(homeLen, length - homeLen)];
        length = 1 + length - homeLen;
    }
    else
    {
        buffer = malloc(length * sizeof(unichar));
        if (buffer == NULL)
        {
            // throw?
            return nil;
        }
        [path getCharacters:buffer range:NSMakeRange(0, length)];
    }

    NSString *str = (NSString *)[NSPathStore2 pathStoreWithCharacters:buffer length:length];
    free(buffer);
    return str;
}


- (id)stringByExpandingTildeInPath
{
    NSUInteger length = [self length];
    NSUInteger capacity = MAX([self length], BUG_COMPLIANT_PATH_MAX);
    unichar *buffer = alloca(capacity * sizeof(unichar));
    [self getCharacters:buffer range:NSMakeRange(0, length)];
    length = _NSExpandTildeInPath(buffer, length);
    return (NSString *)[NSPathStore2 pathStoreWithCharacters:buffer length:length];
}

- (NSString *)_stringByStandardizingPathUsingCache:(BOOL)useCache
{
    return _NSStandardizePathUsingCache(self, useCache);
}

- (NSString *)stringByStandardizingPath
{
    return [self _stringByStandardizingPathUsingCache:YES];
}

- (NSArray *)stringsByAppendingPaths:(NSArray *)paths
{
    if (![paths isNSArray__])
    {
        [NSException raise:NSInvalidArgumentException format:@"paths must be an array"];
        return nil;
    }

    if ([self isEqual:@""])
    {
        return [[paths copy] autorelease];
    }

    NSUInteger count = [paths count];
    NSMutableArray *array = [NSMutableArray array];

    for (NSUInteger idx = 0; idx < count; idx++)
    {
        NSString *item = [paths objectAtIndex:idx];
        NSString *path = [self stringByAppendingPathComponent:item];
        [array addObject:path];
    }

    return array;
}

- (__strong const char *)fileSystemRepresentation NS_RETURNS_INNER_POINTER
{
    return [[NSFileManager defaultManager] fileSystemRepresentationWithPath:self];
}

- (BOOL)getFileSystemRepresentation:(char *)cname maxLength:(NSUInteger)max
{
    return [[NSFileManager defaultManager] getFileSystemRepresentation:cname maxLength:max withPath:self];
}

@end

@implementation NSArray (NSArrayPathExtensions)

- (NSArray *)pathsMatchingExtensions:(NSArray *)filterTypes
{
    NSUInteger count = [self count];
    NSMutableArray *array = [NSMutableArray array];
    for (NSUInteger idx = 0; idx < count; idx++)
    {
        NSString *item = [self objectAtIndex:idx];
        NSString *ext = [item pathExtension];
        if (![ext isEqual:@""] && [filterTypes containsObject:ext])
        {
            [array addObject:item];
        }
    }
    return array;
}

@end

extern CFStringRef CFGetUserName(void);

NSString *NSUserName(void)
{
    return (NSString *)CFGetUserName();
}

NSString *NSFullUserName(void)
{
    // not exactly correct, but probably good enough
    return (NSString *)CFGetUserName();
}

NSString *NSHomeDirectory(void)
{
    static dispatch_once_t once = 0L;
    static NSString *path = nil;
    dispatch_once(&once, ^{
        path = [[NSString alloc] initWithUTF8String:getenv("HOME")];
    });
    return path;
}

NSString *NSHomeDirectoryForUser(NSString *userName)
{
    return NSHomeDirectory();
}

NSString *NSTemporaryDirectory(void)
{
    static dispatch_once_t once = 0L;
    static NSString *path = nil;
    dispatch_once(&once, ^{
        path = [[NSString alloc] initWithUTF8String:getenv("TEMPDIR")];
    });
    return path;
}

NSString *NSOpenStepRootDirectory(void)
{
    return @"/";
}

typedef unsigned int NSSearchPathEnumerationState;

extern NSSearchPathEnumerationState NSStartSearchPathEnumeration(NSSearchPathDirectory dir, NSSearchPathDomainMask domainMask);
extern NSSearchPathEnumerationState NSGetNextSearchPathEnumeration(NSSearchPathEnumerationState state, char *path);

NSArray *NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory directory, NSSearchPathDomainMask domainMask, BOOL expandTilde)
{
    // Only NSUserDomain is supported on iOS
    if (!(domainMask & NSUserDomainMask))
    {
        return @[];
    }
    static dispatch_once_t once = 0L;
    static NSMutableDictionary *searchPaths = nil;
    dispatch_once(&once, ^{
        searchPaths = [[NSMutableDictionary alloc] init];
    });
    NSUInteger key = directory | (domainMask << 8) | (expandTilde ? (1 << 7) : 0);
    NSArray *paths = searchPaths[@(key)];
    if (paths == nil)
    {
        NSMutableArray *items = [[NSMutableArray alloc] init];
        NSSearchPathEnumerationState state = NSStartSearchPathEnumeration(directory, domainMask);
        uint8_t path[PATH_MAX];
        while ((state = NSGetNextSearchPathEnumeration(state, path)))
        {
            if (expandTilde && path[0] == PATH_HOME)
            {
                [items addObject:[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithUTF8String:&path[1]]]];
            }
            else
            {
                [items addObject:[NSString stringWithUTF8String:path]];
            }
        }
        paths = [items copy];
        [items release];
        searchPaths[@(key)] = paths;
        [paths release];
    }
    return paths; // cached
}
