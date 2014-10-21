//
//  NSPathStore.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "NSPathStore.h"

#import "ForFoundationOnly.h"
#import <Foundation/NSArray.h>
#import <Foundation/NSException.h>
#import <Foundation/NSURL.h>
#import "NSStringInternal.h"
#import "NSObjectInternal.h"

@implementation NSPathStore2

+ (NSPathStore2 *)pathWithComponents:(NSArray *)components
{
    if (!components || ![components isNSArray__])
    {
         [NSException raise:NSInvalidArgumentException format:@"Argument is not an array"];
         return nil;
    }
    
    unichar characters[PATH_MAX];

    // Simply join strings with slashes. It easier to eliminate unwanted slashes like this.
    NSUInteger dst = 0;
    for (NSString *item in components)
    {
        NSUInteger itemLength = [item length];

        if (PATH_MAX - dst < itemLength + 1)
        {
            [NSException raise:NSInvalidArgumentException format:@"Path too long"];
            return nil;
        }

        [item getCharacters:&characters[dst] range:NSMakeRange(0, itemLength)];
        dst += itemLength;

        if (dst > 0)
        {
            characters[dst] = PATH_SEP;
            ++dst;
        }
    }

    // Multiple contiguous slashes are reduced to a single slash.
    // Trailing slashes are removed.
    // If the first component starts with a slash, this is preserved.
    NSUInteger length = dst;
    BOOL lastCharWasSlash = NO;
    NSUInteger src;
    for (src=0, dst=0; src<length; ++src)
    {
        if (characters[src] == PATH_SEP)
        {
            if (src == 0)
            {
                // Keep first slash
                ++dst;
            }
            lastCharWasSlash = YES;
        }
        else
        {
            if (lastCharWasSlash && characters[dst-1] != PATH_SEP)
            {
                characters[dst] = PATH_SEP;
                ++dst;
            }

            characters[dst] = characters[src];
            ++dst;
            lastCharWasSlash = NO;
        }
    }

    length = dst;

    NSMutableArray *extractedComponents = [[NSMutableArray alloc] init];

    NSUInteger componentStart = 0;
    for (src=0; src<length; ++src)
    {
        if (characters[src] == PATH_SEP)
        {
            if (src == 0)
            {
                [extractedComponents addObject:NSPathSep];
            }
            else
            {
                NSAssert(src > componentStart, @"Empty component");
                NSString* component = [[NSString alloc] initWithCharacters:&characters[componentStart] length:src-componentStart];
                [extractedComponents addObject:component];
                [component release];
            }
            componentStart = src + 1;
        }
    }

    // Add last component
    if (src > componentStart)
    {
        NSString* component = [[NSString alloc] initWithCharacters:&characters[componentStart] length:src-componentStart];
        [extractedComponents addObject:component];
        [component release];
    }
    
    NSUInteger extraBytes = length * sizeof(unichar);
    NSPathStore2 *store = NSAllocateObject(self, extraBytes, NSDefaultMallocZone());
    store = [store init];
    
    store->_components = [[NSArray alloc] initWithArray:extractedComponents];
    store->_lengthAndRefCount = length << 20;
    memcpy(store->_characters, characters, extraBytes);
    
    [extractedComponents release];

    return [store autorelease];
}

+ (id)pathStoreWithCharacters:(const unichar *)characters length:(NSUInteger)length
{
    NSMutableArray *components = [NSMutableArray array];

    NSUInteger idx = 0;

    if (characters[0] == PATH_SEP)
    {
        [components addObject:NSPathSep];
        idx++;
    }

    if (characters[0] == PATH_HOME)
    {
        [components addObject:NSPathHome];
        idx++;
    }

    while (idx < length)
    {
        if (characters[idx] == PATH_SEP)
        {
            idx++;
            continue;
        }
        else
        {
            NSUInteger end = idx;

            while (end < length && characters[end] != PATH_SEP)
            {
                end++;
            }

            [components addObject:[NSString stringWithCharacters:(characters + idx) length:(end - idx)]];

            idx = end;
        }
    }

    return [self pathWithComponents:components];
}

- (void)dealloc
{
    [_components release];

    [super dealloc];
}

- (id)stringByResolvingSymlinksInPath
{
    return [self _stringByResolvingSymlinksInPathUsingCache:NO];
}

- (id)_stringByResolvingSymlinksInPathUsingCache:(BOOL)usingCache
{
    return nil;
}

- (id)stringByStandardizingPath
{
    return [self _stringByStandardizingPathUsingCache:NO];
}

#warning TODO: Optimize NSPathStore path calculation methods https://code.google.com/p/apportable/issues/detail?id=532

- (id)_stringByStandardizingPathUsingCache:(BOOL)usingCache
{
    return _NSStandardizePathUsingCache(self, usingCache);
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

- (id)stringByAbbreviatingWithTildeInPath
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

- (id)stringByAppendingPathExtension:(NSString *)ext
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

static int _pathExtensionIndex(NSPathStore2 *aPathStore)
{
    NSUInteger idx = [aPathStore length];
    if (idx == 0)
    {
        return idx;
    }

    unichar *_characters = aPathStore->_characters;

    while (--idx > 0)
    {
        if (_characters[idx] == PATH_SEP)
        {
            // We have hit the beginning of the last component without finding an extension.
            return 0;
        }

        if (_characters[idx] == PATH_DOT)
        {
            break;
        }
    }

    return idx;
}

- (id)pathExtension
{
    NSUInteger length = [self length];
    NSUInteger idx = _pathExtensionIndex(self);

    if (idx > 0)
    {
        return [NSString stringWithCharacters:_characters + idx + 1 length:length - idx - 1];
    }

    return @"";
}

- (NSString *)stringByDeletingPathExtension
{
    NSUInteger length = [self length];
    NSUInteger idx = _pathExtensionIndex(self);
    if (!idx)
    {
        idx = length;
    }
    return [NSPathStore2 pathStoreWithCharacters:_characters length:idx];
}

- (NSString *)stringByAppendingPathComponent:(NSString *)component
{
    return [NSPathStore2 pathWithComponents:[_components arrayByAddingObject:component]];
}

- (NSString *)stringByDeletingLastPathComponent
{
    if ([_components count] > 0)
    {
        NSArray *components = [_components subarrayWithRange:NSMakeRange(0, [_components count] - 1)];
        NSString *string = [NSPathStore2 pathWithComponents:components];
        return string;
    }
    else
    {
        return self;
    }
}

- (NSString *)lastPathComponent
{
    if ([_components count] > 0)
    {
        return [_components lastObject];
    }
    else
    {
        return @"";
    }
}

- (BOOL)isAbsolutePath
{
    if ([self length] > 0)
    {
        if (_characters[0] == PATH_SEP || _characters[0] == PATH_HOME)
        {
            return YES;
        }
    }

    return NO;
}

- (NSArray *)pathComponents
{
    return _components;
}

- (BOOL)isEqualToString:(NSString *)other
{
    if (self == other)
    {
        return YES;
    }

    NSUInteger length = [self length];
    if (length != [other length])
    {
        return NO;
    }

    NSUInteger byteLength = length * sizeof(unichar);
    unichar* otherChars = (unichar*)malloc(byteLength);
    [other getCharacters:otherChars range:NSMakeRange(0, length)];

    BOOL result = memcmp(self->_characters, otherChars, byteLength) == 0;

    free(otherChars);

    return result;
}

- (NSUInteger)hash
{
    return CFStringHashCharacters(_characters, [self length]);
}

- (id)copyWithZone:(NSZone *)zone
{
    return [self retain];
}

- (void)getCharacters:(unichar *)buffer range:(NSRange)range
{
    NSUInteger length = [self length];
    if (NSMaxRange(range) > length)
    {
        [NSException raise:NSRangeException format:@"Out of range"];
    }

    memmove(buffer, _characters + range.location, range.length * sizeof(unichar));
}

- (unichar)characterAtIndex:(NSUInteger)index
{
    if (index >= [self length])
    {
        [NSException raise:NSRangeException format:@"Index %lu out of range", (unsigned long)index];
    }

    return _characters[index];
}

- (NSUInteger)length
{
    return _lengthAndRefCount >> 20;
}

- (const unichar*)_fastCharacterContents
{
    return _characters;
}

@end
