//
//  NSDictionary.m
//  CoreFoundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/NSDictionary.h>

#import <CoreFoundation/CFData.h>
#import <CoreFoundation/CFPropertyList.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSSet.h>
#import <Foundation/NSURL.h>

#import "CFInternal.h"
#import "NSFastEnumerationEnumerator.h"
#import "NSKeyValueObserving.h"
#import "NSObjectInternal.h"
#import "NSStringInternal.h"

CF_EXPORT Boolean _CFDictionaryIsMutable(CFDictionaryRef ref);
CF_EXPORT void _CFDictionarySetKVOBit(CFDictionaryRef hc, CFIndex bit);
CF_EXPORT NSUInteger _CFDictionaryFastEnumeration(CFDictionaryRef hc, NSFastEnumerationState *state, id __unsafe_unretained stackbuffer[], NSUInteger count);
CF_EXPORT CFDataRef _CFPropertyListCreateXMLData(CFAllocatorRef allocator, CFPropertyListRef propertyList, Boolean checkValidPlist);

@interface NSDictionary (Internal)
+ (id)newWithContentsOf:(id)source immutable:(BOOL)immutable;
@end

CF_PRIVATE
@interface __NSPlaceholderDictionary : NSMutableDictionary
+ (id)mutablePlaceholder;
+ (id)immutablePlaceholder;
@end

CF_PRIVATE
@interface __NSDictionaryObjectEnumerator : __NSFastEnumerationEnumerator
@end

CF_PRIVATE
@interface __NSCFDictionary : NSMutableDictionary
@end

CF_PRIVATE
@interface __NSDictionaryI : NSDictionary
@end

@implementation __NSDictionaryObjectEnumerator : __NSFastEnumerationEnumerator

- (id)nextObject
{
    return [(NSDictionary *)_obj objectForKey:[super nextObject]];
}

@end

@implementation NSDictionary

+ (id)allocWithZone:(NSZone *)zone
{
    NSDictionary *dictionary = nil;

    if (self == [NSDictionary class])
    {
        dictionary = [__NSPlaceholderDictionary immutablePlaceholder];
    }
    else if (self == [NSMutableDictionary class])
    {
        dictionary = [__NSPlaceholderDictionary mutablePlaceholder];
    }
    else
    {
        dictionary = [super allocWithZone:zone];
    }

    return dictionary;
}

- (NSUInteger)count
{
    NSRequestConcreteImplementation();
    return 0;
}

- (id)objectForKey:(id)aKey
{
    NSRequestConcreteImplementation();
    return nil;
}

- (NSEnumerator *)keyEnumerator
{
    NSRequestConcreteImplementation();
    return nil;
}

- (NSEnumerator *)objectEnumerator
{
    return [[[__NSDictionaryObjectEnumerator alloc] initWithObject:self] autorelease];
}

- (id)copyWithZone:(NSZone *)zone
{
    return [[NSDictionary allocWithZone:zone] initWithDictionary:self copyItems:NO];
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    return [[NSMutableDictionary allocWithZone:zone] initWithDictionary:self copyItems:NO];
}

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])buffer count:(NSUInteger)len
{
    // this is technically incorrect and should be refactored to use [self keyEnumerator] instead and manage it's own state
    return [[self allKeys] countByEnumeratingWithState:state objects:buffer count:len];
}

- (CFTypeID)_cfTypeID
{
    return CFDictionaryGetTypeID();
}

- (BOOL)isNSDictionary__
{
    return YES;
}

@end

@implementation NSMutableDictionary

+ (id)dictionaryWithCapacity:(NSUInteger)numItems
{
    return [[(NSMutableDictionary *)[self alloc] initWithCapacity:numItems] autorelease];
}

- (id)initWithObjects:(const id [])objects forKeys:(const id <NSCopying> [])keys count:(NSUInteger)cnt
{
    if ((self = [self initWithCapacity:cnt]))
    {
        for (NSUInteger i=0; i<cnt; ++i)
        {
            [self setObject:objects[i] forKey:keys[i]];
        }
    }
    return self;
}

- (id)initWithCapacity:(NSUInteger)capacity
{
    NSRequestConcreteImplementation();
    [self release];
    return nil;
}

- (void)removeObjectForKey:(id)aKey
{
    NSRequestConcreteImplementation();
}

- (void)setObject:(id)anObject forKey:(id <NSCopying>)aKey
{
    NSRequestConcreteImplementation();
}

@end

static CFDictionaryKeyCallBacks sNSCFDictionaryKeyCallBacks = {
    0,
    &_NSCFCopy,
    &_NSCFRelease2,
    &_NSCFCopyDescription,
    &_NSCFEqual,
    &_NSCFHash
};

static __NSPlaceholderDictionary *mutablePlaceholder = nil;
static __NSPlaceholderDictionary *immutablePlaceholder = nil;

@implementation __NSPlaceholderDictionary

+ (void)initialize
{

}

- (void)removeObjectForKey:(id)key
{
    NSRequestConcreteImplementation();
}

- (void)setObject:(id)obj forKey:(id)key
{
    NSRequestConcreteImplementation();
}

- (NSEnumerator *)keyEnumerator
{
    NSRequestConcreteImplementation();
    return nil;
}

- (id)objectForKey:(id)key
{
    NSRequestConcreteImplementation();
    return nil;
}

- (NSUInteger)count
{
    NSRequestConcreteImplementation();
    return 0;
}

+ (id)immutablePlaceholder
{
    static dispatch_once_t once = 0L;
    dispatch_once(&once, ^{
        immutablePlaceholder = [__NSPlaceholderDictionary allocWithZone:nil];
    });
    return immutablePlaceholder;
}

+ (id)mutablePlaceholder
{
    static dispatch_once_t once = 0L;
    dispatch_once(&once, ^{
        mutablePlaceholder = [__NSPlaceholderDictionary allocWithZone:nil];
    });
    return mutablePlaceholder;
}

SINGLETON_RR()

- (id)initWithContentsOfURL:(NSURL *)url
{
    if (url != nil && [url isNSString__])
    {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"sent NSString to initWithContentsOfURL - please send a URL" userInfo:nil];
        return nil;
    }

    return (id)[NSDictionary newWithContentsOf:url immutable:(self == immutablePlaceholder)];
}

- (id)initWithContentsOfFile:(NSString *)path
{
    return (id)[NSDictionary newWithContentsOf:path immutable:(self == immutablePlaceholder)];
}

- (id)init
{
    if (self == mutablePlaceholder)
    {
        return [self initWithCapacity:0];
    }
    else
    {
        return [self initWithObjects:NULL forKeys:NULL count:0];
    }
}

- (id)initWithCapacity:(NSUInteger)capacity
{
    if (self == mutablePlaceholder)
    {
        NSCapacityCheck(capacity, 0x40000000, @"Please rethink the size of the capacity of the dictionary you are creating: %d seems a bit exessive", capacity);
        return (id)CFDictionaryCreateMutable(kCFAllocatorDefault, capacity, &sNSCFDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    }
    else
    {
        [self doesNotRecognizeSelector:_cmd];
        return nil;
    }
}

- (id)initWithObjects:(const id [])objects forKeys:(const id <NSCopying> [])keys count:(NSUInteger)cnt
{
    if (cnt != 0)
    {
        if (objects == NULL)
        {
            [self release];
            [NSException raise:NSInvalidArgumentException format:@"Tried to init dictionary with nonzero count but NULL object array"];
            return nil;
        }
        if (keys == NULL)
        {
            [self release];
            [NSException raise:NSInvalidArgumentException format:@"Tried to init dictionary with nonzero count but NULL key array"];
            return nil;
        }
    }

    for (NSUInteger idx = 0; idx < cnt; idx++)
    {
        if (objects[idx] == nil)
        {
            [self release];
            [NSException raise:NSInvalidArgumentException format:@"Tried to init dictionary with nil object"];
            return nil;
        }
        if (keys[idx] == nil)
        {
            [self release];
            [NSException raise:NSInvalidArgumentException format:@"Tried to init dictionary with nil key"];
            return nil;
        }
    }

    if (self == mutablePlaceholder)
    {
        CFMutableDictionaryRef dict = CFDictionaryCreateMutable(kCFAllocatorDefault, cnt, &sNSCFDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        for (NSUInteger idx = 0; idx < cnt; idx++)
        {
            if ([(NSObject *)keys[idx] respondsToSelector:@selector(copyWithZone:)])
            {
                CFDictionarySetValue(dict, keys[idx], objects[idx]);
            }
            else
            {
                CFRelease(dict);
                dict = NULL;
                @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"" userInfo:@{}];
            }
        }

        return (id)dict;
    }
    else
    {
        return (id)CFDictionaryCreate(kCFAllocatorDefault, (const void **)keys, (const void **)objects, cnt, &sNSCFDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    }
}

@end

@implementation NSDictionary (NSDictionaryCreation)

+ (id)dictionary
{
    return [[[self alloc] initWithObjects:NULL forKeys:NULL count:0] autorelease];
}

+ (id)dictionaryWithObject:(id)object forKey:(id <NSCopying>)key
{
    return [[[self alloc] initWithObjects:&object forKeys:&key count:1] autorelease];
}

+ (id)dictionaryWithObjects:(const id [])objects forKeys:(const id <NSCopying> [])keys count:(NSUInteger)count
{
    return [[[self alloc] initWithObjects:objects forKeys:keys count:count] autorelease];
}

+ (id)dictionaryWithObjectsAndKeys:(id)firstObject, ...
{
    va_list args;
    va_start(args, firstObject);
    id value = firstObject;
    id key = va_arg(args, id);
    size_t size = 32;
    size_t count = 0;
    id *objects = malloc(sizeof(id) * size);

    if (UNLIKELY(objects == NULL))
    {
        return nil;
    }

    id *keys = malloc(sizeof(id) * size);

    if (UNLIKELY(keys == NULL))
    {
        free(objects);
        return nil;
    }

    while(value != NULL && key != NULL)
    {
        count++;

        if (count > size)
        {
            size += 32;
            objects = (id *)realloc(objects, sizeof(id) * size);

            if (UNLIKELY(objects == NULL))
            {
                free(keys);
                return nil;
            }

            keys = (id *)realloc(keys, sizeof(id) * size);

            if (UNLIKELY(keys == NULL))
            {
                free(objects);
                return nil;
            }
        }
        objects[count - 1] = value;
        keys[count - 1] = key;
        value = va_arg(args, id);

        if (value == nil)
        {
            break;
        }

        key = va_arg(args, id);
    }

    id dict = [[self alloc] initWithObjects:objects forKeys:keys count:count];
    free(objects);
    free(keys);
    return [dict autorelease];
}

+ (id)dictionaryWithDictionary:(NSDictionary *)dict
{
    size_t count = [dict count];
    id *objects = NULL;
    id *keys = NULL;

    if (count > 0)
    {
        objects = malloc(sizeof(id) * count);

        if (UNLIKELY(objects == NULL))
        {
            return NULL;
        }

        keys = malloc(sizeof(id) * count);

        if (UNLIKELY(keys == NULL))
        {
            free(objects);
            return NULL;
        }
    }
    [dict getObjects:objects andKeys:keys];
    id obj = [[self alloc] initWithObjects:objects forKeys:keys count:count];

    if (objects != NULL)
    {
        free(objects);
    }

    if (keys != NULL)
    {
        free(keys);
    }

    return [obj autorelease];
}

+ (id)dictionaryWithObjects:(NSArray *)objectArray forKeys:(NSArray *)keyArray
{
    return [[[self alloc] initWithObjects:objectArray forKeys:keyArray] autorelease];
}

+ (id)dictionaryWithContentsOfFile:(NSString *)path
{
    if (path == nil)
    {
        return nil;
    }
    
    return [[[self alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path]] autorelease];
}

+ (id)dictionaryWithContentsOfURL:(NSURL *)url
{
    return [[[self alloc] initWithContentsOfURL:url] autorelease];
}

- (id)initWithObjectsAndKeys:(id)firstObject, ...
{
    va_list args;
    va_start(args, firstObject);
    id value = firstObject;
    id key = va_arg(args, id);
    size_t size = 32;
    size_t count = 0;
    id *values = (id *)malloc(sizeof(id) * size);

    if (UNLIKELY(values == NULL))
    {
        [self release];
        return nil;
    }

    id *keys = (id *)malloc(sizeof(id) * size);

    if (UNLIKELY(keys == NULL))
    {
        free(values);
        [self release];
        return nil;
    }

    while(value != NULL && key != NULL)
    {
        count++;

        if (count > size)
        {
            size += 32;
            values = (id *)realloc(values, sizeof(id) * size);

            if (UNLIKELY(values == NULL))
            {
                free(keys);
                [self release];
                return nil;
            }

            keys = (id *)realloc(keys, sizeof(id) * size);
            if (UNLIKELY(keys == NULL))
            {
                free(values);
                [self release];
                return nil;
            }
        }
        values[count - 1] = value;
        keys[count - 1] = key;
        value = va_arg(args, id);
        key = va_arg(args, id);
    }

    id dict = [self initWithObjects:values forKeys:keys count:count];
    free(values);
    free(keys);
    return dict;
}

- (id)initWithDictionary:(NSDictionary *)otherDictionary
{
    size_t count = [otherDictionary count];
    id *objects = NULL;
    id *keys = NULL;

    if (count > 0)
    {
        objects = malloc(sizeof(id) * count);

        if (UNLIKELY(objects == NULL))
        {
            [self release];
            return NULL;
        }

        keys = malloc(sizeof(id) * count);

        if (UNLIKELY(keys == NULL))
        {
            [self release];
            free(objects);
            return NULL;
        }
    }
    [otherDictionary getObjects:objects andKeys:keys];
    id dict = [self initWithObjects:objects forKeys:keys count:count];

    if (objects != NULL)
    {
        free(objects);
    }

    if (keys != NULL)
    {
        free(keys);
    }

    return dict;
}

- (id)initWithDictionary:(NSDictionary *)otherDictionary copyItems:(BOOL)flag
{
    size_t count = [otherDictionary count];
    id *objects = NULL;
    id *keys = NULL;

    if (count > 0)
    {
        objects = malloc(sizeof(id) * count);

        if (UNLIKELY(objects == NULL))
        {
            [self release];
            return NULL;
        }

        keys = malloc(sizeof(id) * count);

        if (UNLIKELY(keys == NULL))
        {
            free(objects);
            [self release];
            return NULL;
        }
    }

    [otherDictionary getObjects:objects andKeys:keys];

    for (int i = 0 ; i < count; i++)
    {
        if (flag && [objects[i] respondsToSelector:@selector(copyWithZone:)])
        {
            objects[i] = [objects[i] copy];
        }
        else
        {
            objects[i] = [objects[i] retain];
        }
    }

    id dict = [self initWithObjects:objects forKeys:keys count:count];

    if (objects != NULL)
    {
        free(objects);
    }

    if (keys != NULL)
    {
        free(keys);
    }

    return dict;
}

- (id)initWithObjects:(NSArray *)objectArray forKeys:(NSArray *)keyArray
{
    NSUInteger objectCount = [objectArray count];
    NSUInteger keyCount = [keyArray count];

    if (objectCount != keyCount)
    {
        [NSException raise:NSInvalidArgumentException format:@"Object and key arrays have different number of elements (%d and %d)", objectCount, keyCount];
        return nil;
    }

    id *objects = malloc(sizeof(id) * objectCount);

    if (UNLIKELY(objects == NULL))
    {
        [self release];
        return nil;
    }

    id *keys = malloc(sizeof(id) * keyCount);

    if (UNLIKELY(keys == NULL))
    {
        [self release];
        free(objects);
        return nil;
    }

    [objectArray getObjects:objects range:NSMakeRange(0, objectCount)];
    [keyArray getObjects:keys range:NSMakeRange(0, keyCount)];
    id dict = [self initWithObjects:objects forKeys:keys count:objectCount];
    free(objects);
    free(keys);
    return dict;
}

- (instancetype)initWithObjects:(const id [])objects forKeys:(const id <NSCopying> [])keys count:(NSUInteger)cnt
{
    NSRequestConcreteImplementation();
    [self release];
    return nil;
}

- (id)initWithContentsOfFile:(NSString *)path
{
    BOOL immutable = ![self isKindOfClass:[NSMutableDictionary class]];
    [self release];
    return [NSDictionary newWithContentsOf:path immutable:immutable];
}

- (id)initWithContentsOfURL:(NSURL *)url
{
    BOOL immutable = ![self isKindOfClass:[NSMutableDictionary class]];
    [self release];
    return [NSDictionary newWithContentsOf:url immutable:immutable];
}

@end


@implementation NSDictionary (NSExtendedDictionary)

- (void)__apply:(void (*)(const void *, const void *, void *))applier context:(void *)context
{
    for (id<NSCopying> key in self)
    {
        id value = [self objectForKey:key];
        applier(key, value, context);
    }
}

- (NSArray *)allKeys
{
    NSUInteger count = [self count];
    NSMutableArray *keys = [[NSMutableArray alloc] initWithCapacity:count];
    NSEnumerator *enumerator = [self keyEnumerator];
    id key = nil;

    while (key = [enumerator nextObject])
    {
        [keys addObject:key];
    }

    NSArray *retval = [keys copy];
    [keys release];
    return [retval autorelease];
}

- (NSArray *)allKeysForObject:(id)anObject
{
    NSUInteger count = [self count];
    NSMutableArray *keys = [[NSMutableArray alloc] initWithCapacity:count];
    NSEnumerator *enumerator = [self keyEnumerator];
    id key = nil;

    while (key = [enumerator nextObject])
    {
        if ([[self objectForKey:key] isEqual:anObject])
        {
            [keys addObject:key];
        }
    }

    NSArray *retval = [keys copy];
    [keys release];
    return [retval autorelease];
}

- (NSArray *)allValues
{
    NSArray *keys = [self allKeys];
    NSMutableArray *values = [[NSMutableArray alloc] initWithCapacity:[keys count]];

    for (id key in keys)
    {
        id value = [self objectForKey:key];
        [values addObject:value];
    }

    NSArray *retval = [values copy];
    [values release];
    return [retval autorelease];
}

- (NSString *)description
{
    return [self descriptionWithLocale:nil indent:0];
}

- (NSString *)descriptionWithLocale:(id)locale
{
    return [self descriptionWithLocale:locale indent:0];
}

static NSString *_getDescription(id obj, id locale, int level)
{
    if ([obj isKindOfClass:[NSDictionary class]] || [obj isKindOfClass:[NSArray class]])
    {
        return [obj descriptionWithLocale:locale indent:level + 1];
    }
    else if ([obj respondsToSelector:@selector(descriptionWithLocale:)])
    {
        return [obj descriptionWithLocale:locale];
    }
    else
    {
        return [obj description];
    }
}

- (NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level
{
    CFMutableStringRef description = CFStringCreateMutable(kCFAllocatorDefault, 0);
    CFStringAppendFormat(description, NULL, CFSTR("%*s{\n"), (int)level * strlen(INDENT), "");
    int count = [self count];
    id *keys = (id *)malloc(sizeof(id) * count);
    [self getObjects:nil andKeys:keys];

    Class checkKeyClass = nil;

    for (int i = 0; i < count; i++)
    {
        if (checkKeyClass == nil)
        {
            checkKeyClass = object_getClass(keys[i]);
        }
        else if (checkKeyClass != object_getClass(keys[i]))
        {
            checkKeyClass = nil;
            break;
        }
    }

    if (checkKeyClass && [keys[0] respondsToSelector: @selector(compare:)]) // homogeneous, sortable NSDictionary's should be sorted
    {
        CFIndex *indexes = (CFIndex *)malloc(count * sizeof(CFIndex));
        CFSortIndexes(indexes, count, 0, ^(CFIndex i1, CFIndex i2) {
            return (CFComparisonResult)[keys[i1] compare: keys[i2]];
        });

        for (int i = 0; i < count; i++)
        {
            id key = keys[indexes[i]];
            id value = [self objectForKey:key];
            NSString *valueDescription = _getDescription(value, locale, level);
            NSString *keyDescription = _getDescription(key, locale, level);
            CFStringAppendFormat(description, NULL, CFSTR("%*s%@ = %@;\n"), ((int)level + 1)  * strlen(INDENT), "", keyDescription, valueDescription);
        }

        free(indexes);
    }
    else {
        NSEnumerator *enumerator = [self keyEnumerator];

        for (id key  = [enumerator nextObject]; key != nil; key = [enumerator nextObject])
        {
            id value = [self objectForKey:key];
            NSString *valueDescription = _getDescription(value, locale, level);
            NSString *keyDescription = _getDescription(key, locale, level);
            CFStringAppendFormat(description, NULL, CFSTR("%*s%@ = %@;\n"), ((int)level + 1)  * strlen(INDENT), "", keyDescription, valueDescription);
        }
    }
    CFStringAppendFormat(description, NULL, CFSTR("%*s}"), (int)level * strlen(INDENT), "");
    CFStringRef desc = CFStringCreateCopy(kCFAllocatorDefault, description);
    CFRelease(description);
    free(keys);
    return [(NSString *)desc autorelease];
}

- (NSUInteger)hash
{
    return [self count];
}

- (BOOL)isEqual:(id)other
{
    if (![other isNSDictionary__])
    {
        return NO;
    }

    return [self isEqualToDictionary:other];
}

- (BOOL)isEqualToDictionary:(NSDictionary *)otherDictionary
{
    if (self == otherDictionary)
    {
        return YES;
    }

    if (![otherDictionary isKindOfClass:[NSDictionary class]])
    {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Second argument is not a dictionary" userInfo:nil];
        return NO;
    }

    if ([self count] != [otherDictionary count])
    {
        return NO;
    }

    for (NSString* key in [self allKeys]) 
    {
        id val = [self objectForKey:key];
        id otherVal = [otherDictionary objectForKey:key];
        if (val == otherVal)
        {
            continue;
        }

        if (![val isEqual:otherVal])
        {
            return NO;
        }
    }

    return YES;
}

- (NSEnumerator *)objectEnumerator
{
    return [[self allValues] objectEnumerator];
}

- (NSArray *)objectsForKeys:(NSArray *)keys notFoundMarker:(id)marker
{
    NSMutableArray *objects = [[NSMutableArray alloc] initWithCapacity:[keys count]];

    for (id key in keys)
    {
        id obj = [self objectForKey:key];

        if (obj == nil)
        {
            obj = marker;
        }

        if (obj != nil)
        {
            [objects addObject:obj];
        }
    }

    NSArray *objs = [objects copy];
    [objects release];
    return [objs autorelease];
}

- (BOOL)writeToFile:(NSString *)path atomically:(BOOL)atomically
{
    NSData *data = (NSData *)_CFPropertyListCreateXMLData(kCFAllocatorDefault, (CFPropertyListRef)self, true);
    BOOL success = [data writeToFile:path atomically:atomically];
    [data release];
    return success;
}

- (BOOL)writeToURL:(NSURL *)url atomically:(BOOL)atomically
{
    NSData *data = (NSData *)_CFPropertyListCreateXMLData(kCFAllocatorDefault, (CFPropertyListRef)self, true);
    BOOL success = [data writeToURL:url atomically:atomically];
    [data release];
    return success;
}

- (NSArray *)keysSortedByValueUsingSelector:(SEL)comparator
{
    return [[self allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        id val1 = [self objectForKey:obj1];
        id val2 = [self objectForKey:obj2];
        return (NSComparisonResult)[val1 performSelector:comparator withObject:val2];
    }];
}

- (void)getObjects:(id __unsafe_unretained [])objects andKeys:(id __unsafe_unretained [])keys
{
    if (objects == NULL && keys == NULL)
    {
        // nothing to do here... move along.
        return;
    }

    NSEnumerator *enumerator = [self keyEnumerator];
    id key = nil;
    NSUInteger idx = 0;
    while (key = [enumerator nextObject])
    {
        if (keys != NULL)
        {
            keys[idx] = key;
        }

        if (objects != NULL)
        {
            objects[idx] = [self objectForKey:key];
        }

        idx++;
    }
}

- (id)objectForKeyedSubscript:(id)key
{
    return [self objectForKey:key];
}

- (void)enumerateKeysAndObjectsUsingBlock:(void (^)(id key, id obj, BOOL *stop))block
{
    [self enumerateKeysAndObjectsWithOptions:0 usingBlock:block];
}

- (void)enumerateKeysAndObjectsWithOptions:(NSEnumerationOptions)opts usingBlock:(void (^)(id key, id obj, BOOL *stop))block
{
    NSArray *keys = nil;
    if (opts & NSEnumerationReverse)
    {
        keys = [[[self allKeys] reverseObjectEnumerator] allObjects];
    }
    else
    {
        keys = [self allKeys];
    }

    if (opts & NSEnumerationConcurrent)
    {
        __block BOOL stop = NO;
        dispatch_apply([keys count], dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(size_t iter){
            if (!stop)
            {
                id key = [keys objectAtIndex:iter];
                id obj = [self objectForKey:key];
                block(key, obj, &stop);
            }
        });
    }
    else
    {
        id key = NULL;
        BOOL stop = NO;
        NSUInteger idx = 0;
        NSUInteger count = [self count];

        while(idx < count && (key = [keys objectAtIndex:idx]) && !stop)
        {
            id obj = [self objectForKey:key];
            block(key, obj, &stop);
            idx++;
        }
    }
}

- (NSArray *)keysSortedByValueUsingComparator:(NSComparator)cmptr
{
    return [self keysSortedByValueWithOptions:NSSortStable usingComparator:cmptr];

}

- (NSArray *)keysSortedByValueWithOptions:(NSSortOptions)opts usingComparator:(NSComparator)cmptr
{
    return [[self allKeys] sortedArrayWithOptions:opts usingComparator:^NSComparisonResult(id obj1, id obj2) {
        id val1 = [self objectForKey:obj1];
        id val2 = [self objectForKey:obj2];
        return cmptr(val1, val2);
    }];
}

- (NSSet *)keysOfEntriesPassingTest:(BOOL (^)(id key, id obj, BOOL *stop))predicate
{
    return [self keysOfEntriesWithOptions:0 passingTest:predicate];
}

- (NSSet *)keysOfEntriesWithOptions:(NSEnumerationOptions)opts passingTest:(BOOL (^)(id key, id obj, BOOL *stop))predicate
{
    NSArray *keys = nil;
    if (opts & NSEnumerationReverse)
    {
        keys = [[[self allKeys] reverseObjectEnumerator] allObjects];
    }
    else
    {
        keys = [self allKeys];
    }

    __block NSMutableSet *found = [[NSMutableSet alloc] initWithCapacity:[keys count]];

    if (opts & NSEnumerationConcurrent)
    {
        __block BOOL stop = NO;
        dispatch_apply([keys count], dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(size_t iter){
            if (!stop)
            {
                id key = [keys objectAtIndex:iter];
                id obj = [self objectForKey:key];

                if (predicate(key, obj, &stop))
                {
                    [found addObject:key];
                }
            }
        });
    }
    else
    {
        BOOL stop = NO;
        NSUInteger idx = 0;
        NSUInteger count = [keys count];

        while (!stop && idx < count)
        {
            id key = [keys objectAtIndex:idx];
            id obj = [self objectForKey:key];

            if (predicate(key, obj, &stop))
            {
                [found addObject:key];
            }

            idx++;
        }
    }

    NSSet *set = [found copy];
    [found release];
    return [set autorelease];
}

@end


@implementation NSMutableDictionary (NSExtendedMutableDictionary)

- (void)addEntriesFromDictionary:(NSDictionary *)otherDictionary
{
    NSEnumerator *enumerator = [otherDictionary keyEnumerator];
    id key = nil;

    while (key = [enumerator nextObject])
    {
        [self setObject:[otherDictionary objectForKey:key] forKey:key];
    }
}

- (void)removeAllObjects
{
    NSEnumerator *enumerator = [self keyEnumerator];
    id key = nil;

    while (key = [enumerator nextObject])
    {
        [self removeObjectForKey:key];
    }
}

- (void)removeObjectsForKeys:(NSArray *)keyArray
{
    for (id key in keyArray)
    {
        [self removeObjectForKey:key];
    }
}

- (void)setDictionary:(NSDictionary *)otherDictionary
{
    [self removeAllObjects];
    [self addEntriesFromDictionary:otherDictionary];
}

- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key
{
    [self setObject:obj forKey:key];
}

@end

@implementation __NSCFDictionary {
    unsigned char _cfinfo[4];
    unsigned int _bits[4];
    void *_callbacks;
    id *_values;
    id *_keys;
}

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key
{
    return NO;
}

- (void)setObservationInfo:(void *)info
{
    _CFDictionarySetKVOBit((CFDictionaryRef)self, (CFIndex)info);
    [super setObservationInfo:info];
}

- (void)removeAllObjects
{
    if (_CFDictionaryIsMutable((CFDictionaryRef)self))
    {
        CFDictionaryRemoveAllValues((CFMutableDictionaryRef)self);
    }
    else
    {
        NSInvalidMutation();
    }
}

- (void)removeObjectForKey:(id)key
{
    if (_CFDictionaryIsMutable((CFDictionaryRef)self))
    {
        if (key == nil)
        {
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Cannot remove a nil key" userInfo:nil];
            return;
        }

        CFDictionaryRemoveValue((CFMutableDictionaryRef)self, (const void *)key);
    }
    else
    {
        NSInvalidMutation();
    }
}

- (void)setObject:(id)obj forKey:(id)key
{
    if (_CFDictionaryIsMutable((CFDictionaryRef)self))
    {
        if ((obj == nil) || (key == nil))
        {
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Cannot set nil objects nor nil keys" userInfo:nil];
            return;
        }

        [self willChangeValueForKey:key];
        CFDictionarySetValue((CFMutableDictionaryRef)self, (const void *)key, (const void *)obj);
        [self didChangeValueForKey:key];
    }
    else
    {
        NSInvalidMutation();
    }
}

- (NSEnumerator *)keyEnumerator
{
    return [[[__NSFastEnumerationEnumerator alloc] initWithObject:self] autorelease];
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])buffer count:(NSUInteger)len
{
    return _CFDictionaryFastEnumeration((CFDictionaryRef)self, state, buffer, len);
}

- (id)objectForKey:(id)key
{
    if (key == nil)
    {
        return nil;
    }
    return (id)CFDictionaryGetValue((CFDictionaryRef)self, (const void *)key);
}

- (NSUInteger)count
{
    return CFDictionaryGetCount((CFDictionaryRef)self);
}

- (void)getObjects:(id [])objects andKeys:(id [])keys
{
    CFDictionaryGetKeysAndValues((CFDictionaryRef)self, (const void **)keys, (const void **)objects);
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    return (id)CFDictionaryCreateMutableCopy(kCFAllocatorDefault, 0, (CFDictionaryRef)self);
}

- (id)copyWithZone:(NSZone *)zone
{
    return (id)CFDictionaryCreateCopy(kCFAllocatorDefault, (CFDictionaryRef)self);
}

- (Class)classForCoder
{
    if (_CFDictionaryIsMutable((CFDictionaryRef)self))
    {
        return [NSMutableDictionary class];
    }
    else
    {
        return [NSDictionary class];
    }
}

- (NSUInteger)retainCount
{
    return CFGetRetainCount((CFTypeRef)self);
}

- (BOOL)_isDeallocating
{
    return _CFIsDeallocating((CFTypeRef)self);
}

- (BOOL)_tryRetain
{
    return _CFTryRetain((CFTypeRef)self) != NULL;
}

- (oneway void)release
{
    CFRelease((CFTypeRef)self);
}

- (id)retain
{
    return (id)CFRetain((CFTypeRef)self);
}

- (NSUInteger)hash
{
    return CFHash((CFTypeRef)self);
}

- (BOOL)isEqual:(id)obj
{
    if (obj == nil)
    {
        return NO;
    }

    return CFEqual((CFTypeRef)self, (CFTypeRef)obj);
}

@end

@implementation __NSDictionaryI {
    unsigned int _used:26;
    unsigned int _szidx:6;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return (id)[__NSPlaceholderDictionary allocWithZone:zone];
}

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key
{
    return NO;
}

+ (id)__new:(const id *)objects :(const id *)keys :(NSUInteger)count :(BOOL)immutable :(BOOL)copyKeys
{
    NSUInteger sz = count * sizeof(id);
    __NSDictionaryI *dict = ___CFAllocateObject2(self, sz * 2);
    dict->_used = count;
    id *keysAndObjects = (id *)object_getIndexedIvars(dict);

    for (NSUInteger idx = 0; idx < count * 2; idx += 2)
    {
        keysAndObjects[idx] = [keys[idx / 2] copy];
        keysAndObjects[idx + 1] = [objects[idx / 2] retain];
    }

    return dict;
}

/*
// add this in when __NSDictionaryM is implemented
- (id)mutableCopyWithZone:(NSZone *)zone
{

}
*/

- (void)dealloc
{
    id *keysAndObjects = (id *)object_getIndexedIvars(self);

    for (NSUInteger idx = 0; idx < _used * 2; idx += 2)
    {
        [keysAndObjects[idx] release];
        [keysAndObjects[idx + 1] release];
    }

    [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone
{
    return [self retain];
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])buffer count:(NSUInteger)len
{
    id *keysAndObjects = NULL;
    state->extra[0] = [self count];

    if (state->state >= state->extra[0])
    {
        return 0;
    }
    
    if (state->extra[1] == 0)
    {
        state->extra[1] = (unsigned long)object_getIndexedIvars(self);
    }

    keysAndObjects = (id *)state->extra[1];
    
    if (state->mutationsPtr == NULL)
    {
        state->mutationsPtr = &state->extra[0];
    }
    
    id key = keysAndObjects[0];
    NSUInteger idx = 0;
    
    while (key != nil && idx < len && idx < state->extra[0])
    {
        buffer[idx] = key;
        key = keysAndObjects[idx * 2];
        idx++;
    }

    state->state += idx;
    state->extra[1] += sizeof(id) * idx * 2;
    state->itemsPtr = buffer;
    return idx;
}


- (void)getObjects:(id __unsafe_unretained [])objects andKeys:(id __unsafe_unretained [])keys
{
    id *keysAndObjects = (id *)object_getIndexedIvars(self);

    for (NSUInteger idx = 0; idx < _used * 2; idx += 2)
    {
        keys[idx] = keysAndObjects[idx];
        objects[idx] = keysAndObjects[idx + 1];
    }
}

- (NSEnumerator *)keyEnumerator
{
    return [[[__NSFastEnumerationEnumerator alloc] initWithObject:self] autorelease];
}

- (id)objectForKey:(id)key
{
    id *keysAndObjects = (id *)object_getIndexedIvars(self);
    // NOTE: This is probably ineffecient and should be refactored somewhat for speed
    // thankfully NSDictionaryI should only be used for small dictionaries so the perf
    // hit should be relatively small

    for (NSUInteger idx = 0; idx < _used * 2; idx += 2)
    {
        if ([keysAndObjects[idx] hash] == [key hash])
        {
            if ([keysAndObjects[idx] isEqual:key])
            {
                return keysAndObjects[idx + 1];
            }
        }
    }
    return nil;
}

- (NSUInteger)count
{
    return _used;
}

@end
