//
//  NSSet.m
//  CoreFoundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/NSSet.h>

#import <Foundation/NSArray.h>
#import "NSObjectInternal.h"
#import "NSFastEnumerationEnumerator.h"

CF_PRIVATE
@interface __NSPlaceholderSet : NSMutableSet
+ (id)mutablePlaceholder;
+ (id)immutablePlaceholder;
@end

CF_PRIVATE
@interface __NSCFSet : NSMutableSet
@end

CF_EXPORT Boolean _CFSetIsMutable(CFSetRef hc);
CF_EXPORT NSUInteger _CFSetFastEnumeration(CFSetRef set, NSFastEnumerationState *state, id __unsafe_unretained stackbuffer[], NSUInteger count);


static const NSUInteger kRemoveAllObjectsStackSize = 32;

@implementation NSSet

+ (id)allocWithZone:(NSZone *)zone
{
    if (self == [NSMutableSet class])
    {
        return [__NSPlaceholderSet mutablePlaceholder];
    }
    else if (self == [NSSet class])
    {
        return [__NSPlaceholderSet immutablePlaceholder];
    }
    else
    {
        return [super allocWithZone:zone];
    }
}

- (NSUInteger)count
{
    NSRequestConcreteImplementation();
    return 0;
}

- (id)member:(id)object
{
    NSRequestConcreteImplementation();
    return nil;
}

- (NSEnumerator *)objectEnumerator
{
    NSRequestConcreteImplementation();
    return nil;
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])buffer count:(NSUInteger)len
{
    if (buffer == NULL && len != 0)
    {
        [NSException raise:NSInvalidArgumentException format:@"Cannot enumerate into NULL buffer"];
        return 0;
    }

    NSEnumerator *enumerator;
    if (state->state == 0)
    {
        state->mutationsPtr = &state->extra[0];
        state->extra[0] = [self count];
        enumerator = [self objectEnumerator];
        memcpy(&state->extra[1], &enumerator, sizeof(enumerator));

        if (!enumerator)
        {
            return 0;
        }
    }
    else
    {
        memcpy(&enumerator, &state->extra[1], sizeof(enumerator));
    }

    if (state->state == -1)
    {
        return 0;
    }

    state->itemsPtr = buffer;
    NSUInteger returnedLength = MIN(state->extra[0] - state->state, len);
    for (int i=0; i != returnedLength; ++i)
    {
        id object = [enumerator nextObject];
        if (object == nil)
        {
            state->state = -1;
            return i;
        }
        buffer[i] = object;
    }

    if (state->state + returnedLength >= state->extra[0])
    {
        state->state = -1;
    }
    else
    {
        state->state += returnedLength;
    }

    return returnedLength;
}

- (void)getObjects:(id *)objects
{
    [self getObjects:objects count:[self count]];
}

- (void)getObjects:(id *)objects count:(NSUInteger)count
{
    NSEnumerator *enumerator = [self objectEnumerator];
    id obj = nil;
    NSUInteger idx = 0;
    while ((obj = [enumerator nextObject]) && idx < count)
    {
        objects[idx] = obj;
        idx++;
    }
}

- (id)copyWithZone:(NSZone *)zone
{
    return [[NSSet alloc] initWithSet:self copyItems:NO];
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    return [[NSMutableSet alloc] initWithSet:self copyItems:NO];
}

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (CFTypeID)_cfTypeID
{
    return CFSetGetTypeID();
}

- (BOOL)isNSSet__
{
    return YES;
}

- (NSUInteger)countForObject:(id)obj
{
    return [self member:obj] == nil ? 0 : 1;
}

- (NSUInteger)hash
{
    return [self count];
}

- (BOOL)isEqual:(NSSet *)other
{
    if (self == other)
    {
        return YES;
    }

    if (![other isNSSet__])
    {
        return NO;
    }

    return [self isEqualToSet:other];
}

@end

@implementation NSMutableSet

- (void)addObject:(id)object
{
    NSRequestConcreteImplementation();
}

- (void)removeObject:(id)object
{
    NSRequestConcreteImplementation();
}

@end

static __NSPlaceholderSet *mutablePlaceholder = nil;
static __NSPlaceholderSet *immutablePlaceholder = nil;

@implementation __NSPlaceholderSet

+ (id)immutablePlaceholder
{
    static dispatch_once_t once = 0L;
    dispatch_once(&once, ^{
        immutablePlaceholder = [__NSPlaceholderSet allocWithZone:nil];
    });
    return immutablePlaceholder;
}

+ (id)mutablePlaceholder
{
    static dispatch_once_t once = 0L;
    dispatch_once(&once, ^{
        mutablePlaceholder = [__NSPlaceholderSet allocWithZone:nil];
    });
    return mutablePlaceholder;
}

SINGLETON_RR()

- (id)init
{
    if (self == mutablePlaceholder)
    {
        return [self initWithCapacity:0];
    }
    else
    {
        return [self initWithObjects:NULL count:0];
    }
}

- (id)initWithCapacity:(NSUInteger)capacity
{
    if (self == mutablePlaceholder)
    {
        NSCapacityCheck(capacity, 0x40000000, @"Please rethink the size of the capacity of the set you are creating: %d seems a bit exessive", capacity);
        return (id)CFSetCreateMutable(kCFAllocatorDefault, capacity, &kCFTypeSetCallBacks);
    }
    else
    {
        [self doesNotRecognizeSelector:_cmd];
        return nil;
    }
}

- (id)initWithObjects:(const id [])objects count:(NSUInteger)cnt
{
    if (self == mutablePlaceholder)
    {
        CFMutableSetRef set = CFSetCreateMutable(kCFAllocatorDefault, cnt, &kCFTypeSetCallBacks);

        for (int i = 0; i < cnt; i++)
        {
            id value = objects[i];
            CFSetAddValue(set, value);
        }

        return (id)set;
    }
    else
    {
        return (id)CFSetCreate(kCFAllocatorDefault, (const void**)objects, cnt, &kCFTypeSetCallBacks);
    }
}

@end

@implementation NSSet (NSExtendedSet)

- (void)__applyValues:(void (*)(const void *, void *))applier context:(void *)context
{
    for (id obj in self)
    {
        applier(obj, context);
    }
}

- (NSArray *)allObjects
{
    NSUInteger count = [self count];
    id *objects = malloc(sizeof(id) * count);
    if (objects == NULL)
    {
        [NSException raise:NSMallocException format:@"unable to allocate space to store %d objects", count];
    }

    [self getObjects:objects count:count];
    NSArray *array = [[NSArray alloc] initWithObjects:objects count:count];
    free(objects);
    return [array autorelease];
}

- (id)anyObject
{
    id obj = nil;
    NSFastEnumerationState state = { 0 };
    [self countByEnumeratingWithState:&state objects:&obj count:1];
    return obj;
}

- (BOOL)containsObject:(id)anObject
{
    return [self member:anObject] != nil;
}

- (NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level
{
    CFStringRef indent = CFSTR("");

    if (level > 0)
    {
        indent = CFStringCreateWithFormat(kCFAllocatorDefault, (CFDictionaryRef)locale, CFSTR("%*c"), level * 4, ' ');
    }

    CFMutableStringRef s = CFStringCreateMutable(kCFAllocatorDefault, 0);
    CFStringAppendFormat(s, (CFDictionaryRef)locale, CFSTR("%@{("), indent);

    NSArray *items = [self allObjects];
    NSUInteger count = [items count];
    for (NSUInteger idx = 0; idx < count; idx++)
    {
        id object = [items objectAtIndex:idx];

        if ([object respondsToSelector:@selector(descriptionWithLocale:indent:)])
        {
            CFStringAppendFormat(s, (CFDictionaryRef)locale, CFSTR("\n%@    %@"), indent, [object descriptionWithLocale:locale indent:level + 1]);
        }
        else if ([object respondsToSelector:@selector(descriptionWithLocale:)])
        {
            CFStringAppendFormat(s, (CFDictionaryRef)locale, CFSTR("\n%@    %@"), indent, [object descriptionWithLocale:locale]);
        }
        else
        {
            CFStringAppendFormat(s, (CFDictionaryRef)locale, CFSTR("\n%@    %@"), indent, [object description]);
        }

        if (idx < count - 1)
        {
            CFStringAppend(s, CFSTR(","));
        }
        else
        {
            CFStringAppendFormat(s, (CFDictionaryRef)locale, CFSTR("\n%@"), indent);
        }
    }
    CFStringAppend(s, CFSTR(")}"));

    if (level > 0)
    {
        CFRelease(indent);
    }

    return [(id)s autorelease];
}

- (NSString *)description
{
    return [self descriptionWithLocale:nil indent:0];
}

- (NSString *)descriptionWithLocale:(id)locale
{
    return [self descriptionWithLocale:locale indent:0];
}

- (BOOL)intersectsSet:(NSSet *)other
{
    for (id obj in self)
    {
        if ([other containsObject:obj])
        {
            return YES;
        }
    }

    for (id obj in other)
    {
        if ([self containsObject:obj])
        {
            return YES;
        }
    }
    return NO;
}

- (BOOL)isEqualToSet:(NSSet *)other
{
    if (self == other)
    {
        return YES;
    }

    if ([self count] != [other count])
    {
        return NO;
    }

    for (id obj in self)
    {
        if (![other member:obj])
        {
            return NO;
        }
    }
    return YES;
}

- (BOOL)isSubsetOfSet:(NSSet *)other
{
    for (id obj in self)
    {
        if (![other containsObject:obj])
        {
            return NO;
        }
    }

    return YES;
}

- (void)makeObjectsPerformSelector:(SEL)sel
{
    [self makeObjectsPerformSelector:sel withObject:nil];
}

- (void)makeObjectsPerformSelector:(SEL)sel withObject:(id)argument
{
    for (id obj in self)
    {
        [obj performSelector:sel withObject:argument];
    }
}

- (NSSet *)setByAddingObject:(id)anObject
{
    NSUInteger count = [self count];
    id *objects = malloc(sizeof(id) * (count + 1));
    [self getObjects:objects count:count];
    objects[count] = anObject;
    NSSet *set = [[NSSet alloc] initWithObjects:objects count:count + 1];
    free(objects);
    return [set autorelease];
}

- (NSSet *)setByAddingObjectsFromSet:(NSSet *)other
{
    NSUInteger count = [self count];
    NSUInteger otherCount = [other count];
    id *objects = malloc(sizeof(id) * (count + otherCount));
    [self getObjects:objects count:count];
    [other getObjects:objects + count count:otherCount];
    NSSet *set = [[NSSet alloc] initWithObjects:objects count:count + otherCount];
    free(objects);
    return [set autorelease];
}

- (NSSet *)setByAddingObjectsFromArray:(NSArray *)other
{
    NSUInteger count = [self count];
    NSUInteger otherCount = [other count];
    id *objects = malloc(sizeof(id) * (count + otherCount));
    [self getObjects:objects count:count];
    [other getObjects:objects + count range:NSMakeRange(0, otherCount)];
    NSSet *set = [[NSSet alloc] initWithObjects:objects count:count + otherCount];
    free(objects);
    return [set autorelease];
}

- (void)enumerateObjectsUsingBlock:(void (^)(id obj, BOOL *stop))block
{
    [self enumerateObjectsWithOptions:0 usingBlock:block];
}

- (void)enumerateObjectsWithOptions:(NSEnumerationOptions)opts usingBlock:(void (^)(id obj, BOOL *stop))block
{
    [[self allObjects] enumerateObjectsWithOptions:opts usingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        block(obj, stop);
    }];
}

- (NSSet *)objectsPassingTest:(BOOL (^)(id obj, BOOL *stop))predicate
{
    return [self objectsWithOptions:0 passingTest:predicate];
}

- (NSSet *)objectsWithOptions:(NSEnumerationOptions)opts passingTest:(BOOL (^)(id obj, BOOL *stop))predicate
{
    NSArray *objects = [self allObjects];
    NSIndexSet *indicies = [objects indexesOfObjectsPassingTest:^(id obj, NSUInteger idx, BOOL *stop){
        return predicate(obj, stop);
    }];
    return [[[NSSet alloc] initWithArray:[objects objectsAtIndexes:indicies]] autorelease];
}

@end

@implementation NSSet (NSSetCreation)

+ (id)set
{
    return [[[self alloc] initWithObjects:NULL count:0] autorelease];
}

+ (id)setWithObject:(id)object
{
    return [[[self alloc] initWithObjects:&object count:1] autorelease];
}

+ (id)setWithObjects:(const id [])objects count:(NSUInteger)cnt
{
    return [[[self alloc] initWithObjects:objects count:cnt] autorelease];
}

+ (id)setWithObjects:(id)firstObj, ...
{
    va_list args;
    va_start(args, firstObj);
    id value = firstObj;
    size_t size = 32;
    size_t count = 0;
    id *values = (id *)malloc(sizeof(id) * size);

    if (UNLIKELY(values == NULL))
    {
        return nil;
    }

    while(value != NULL)
    {
        if (count + 1 > size)
        {
            size += 32;
            id *new_values = (id *)realloc(values, sizeof(id) * size);

            if (UNLIKELY(new_values == NULL))
            {
                free(values);
                return nil;
            }

            values = new_values;
        }

        values[count] = value;
        count++;
        value = va_arg(args, id);
    }

    NSSet *set = [[self alloc] initWithObjects:values count:count];
    va_end(args);
    free(values);
    return [set autorelease];
}

+ (id)setWithSet:(NSSet *)set
{
    return [[[self alloc] initWithSet:set copyItems:NO] autorelease];
}

+ (id)setWithArray:(NSArray *)array
{
    return [[[self alloc] initWithArray:array] autorelease];
}

- (id)initWithObjects:(const id [])objects count:(NSUInteger)cnt
{
    NSRequestConcreteImplementation();
    [self release];
    return nil;
}

- (id)initWithObjects:(id)firstObj, ...
{
    va_list args;
    va_start(args, firstObj);
    id value = firstObj;
    size_t size = 32;
    size_t count = 0;
    id *values = (id *)malloc(sizeof(id) * size);

    if (UNLIKELY(values == NULL))
    {
        [self release];
        return nil;
    }

    while(value != NULL)
    {
        if (count + 1 > size)
        {
            size += 32;
            id *new_values = (id *)realloc(values, sizeof(id) * size);

            if (UNLIKELY(new_values == NULL))
            {
                free(new_values);
                [self release];
                return nil;
            }

            values = new_values;
        }
        values[count] = value;
        count++;
        value = va_arg(args, id);
    }

    NSSet *set = [self initWithObjects:values count:count];
    va_end(args);
    free(values);
    return set;
}

- (id)initWithSet:(NSSet *)set
{
    return [self initWithSet:set copyItems:NO];
}

- (id)initWithSet:(NSSet *)set copyItems:(BOOL)flag
{
    NSUInteger count = [set count];
    id *objects = NULL;

    if (count > 0)
    {
        objects = calloc(sizeof(id), count);
        if (UNLIKELY(objects == NULL))
        {
            [self release];
            return nil;
        }
    }

    [set getObjects:objects count:count];
    if (flag)
    {
        for (NSUInteger idx = 0; idx < count; idx++)
        {
            objects[idx] = [objects[idx] copy];
        }
    }

    NSSet *retVal = [self initWithObjects:objects count:count];

    if (flag)
    {
        for (NSUInteger idx = 0; idx < count; idx++)
        {
            [objects[idx] release];
        }
    }

    if (objects != NULL)
    {
        free(objects);
    }

    return retVal;
}

- (id)initWithArray:(NSArray *)array
{
    NSUInteger count = [array count];
    id *objects = NULL;

    if (count > 0)
    {
        objects = malloc(sizeof(id) * count);

        if (UNLIKELY(objects == NULL))
        {
            [self release];
            return nil;
        }
    }

    [array getObjects:objects range:NSMakeRange(0, count)];
    NSSet *set = [self initWithObjects:objects count:count];

    if (objects != NULL)
    {
        free(objects);
    }

    return set;
}

@end

@implementation NSMutableSet (NSExtendedMutableSet)

- (void)addObjectsFromArray:(NSArray *)array
{
    for (id obj in array)
    {
        [self addObject:obj];
    }
}


- (void)minusSet:(NSSet *)other
{
    NSMutableArray *remove = [NSMutableArray array];
    for (id obj in other)
    {
        if ([self countForObject:obj] > 0)
        {
            [remove addObject:obj];
        }
    }
    for (id obj in remove)
    {
        [self removeObject:obj];
    }
}

- (void)intersectSet:(NSSet *)other
{
    NSMutableArray *remove = [NSMutableArray array];
    for (id obj in self)
    {
        if ([other countForObject:obj] == 0)
        {
            [remove addObject:obj];
        }
    }
    for (id obj in remove)
    {
        [self removeObject:obj];
    }
}

- (void)unionSet:(NSSet *)other
{
    NSMutableArray *add = [NSMutableArray array];
    for (id obj in other)
    {
        if ([self countForObject:obj] == 0)
        {
            [add addObject:obj];
        }
    }
    [self addObjectsFromArray:add];
}

- (void)removeAllObjects
{
    id stack_objects[kRemoveAllObjectsStackSize];
    id *heap_objects = NULL;
    id *objects = &stack_objects[0];
    // Distinct objects
    NSUInteger count = [self count];

    if (count > kRemoveAllObjectsStackSize)
    {
        heap_objects = malloc(sizeof(id) * count);
        objects = heap_objects;

        if (!heap_objects)
        {
            [NSException raise:NSInternalInconsistencyException format:@"Error walking heap_objects, out of memory"];
        }
    }

    [self getObjects:objects count:count];

    for (NSUInteger idx = 0; idx < count; idx++)
    {
        id obj = objects[idx];
        NSUInteger objCount = [self countForObject:obj];
        do {
            [self removeObject:obj];
            objCount--;
        } while (objCount > 0);
    }

    if (heap_objects != NULL)
    {
        free(heap_objects);
    }
}

- (void)setSet:(NSSet *)other
{
    // this is less effecient than it should be...
    [self removeAllObjects];
    for (id obj in other)
    {
        [self addObject:obj];
    }
}

@end

@implementation NSMutableSet (NSMutableSetCreation)

+ (id)setWithCapacity:(NSUInteger)numItems
{
    return [[[self alloc] initWithCapacity:numItems] autorelease];
}

- (id)initWithCapacity:(NSUInteger)numItems
{
    NSRequestConcreteImplementation();
    [self release];
    return nil;
}

@end


@implementation __NSCFSet {
    unsigned char _cfinfo[4];
    unsigned int _bits[4];
    void *_callbacks;
    id *_values;
}

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key
{
    return NO;
}

- (NSArray *)allObjects
{
    NSUInteger count = [self count];
    id *objects = malloc(sizeof(id) * count);
    if (objects == NULL)
    {
        [NSException raise:NSMallocException format:@"unable to allocate space to store %d objects", count];
    }

    CFSetGetValues((CFSetRef)self, (const void **)objects);
    NSArray *array = [[NSArray alloc] initWithObjects:objects count:count];
    free(objects);
    return [array autorelease];
}

- (void)getObjects:(id *)objects
{
    CFSetGetValues((CFSetRef)self, (const void **)objects);
}

- (void)removeAllObjects
{
    if (_CFSetIsMutable((CFSetRef)self))
    {
        CFSetRemoveAllValues((CFMutableSetRef)self);
    }
    else
    {
        NSInvalidMutation();
    }
}

- (void)removeObject:(id)object
{
    if (object == nil)
    {
        [NSException raise:NSInvalidArgumentException format:@"attempt to remove nil object from NSMutableSet"];
        return;
    }
    if (_CFSetIsMutable((CFSetRef)self))
    {
        CFSetRemoveValue((CFMutableSetRef)self, (const void *)object);
    }
    else
    {
        NSInvalidMutation();
    }
}

- (void)addObject:(id)object
{
    if (object == nil)
    {
        [NSException raise:NSInvalidArgumentException format:@"attempt to insert nil object into NSMutableSet"];
        return;
    }
    if (_CFSetIsMutable((CFSetRef)self))
    {
        CFSetAddValue((CFMutableSetRef)self, (const void *)object);
    }
    else
    {
        NSInvalidMutation();
    }
}

- (NSEnumerator *)objectEnumerator
{
    return [[[__NSFastEnumerationEnumerator alloc] initWithObject:self] autorelease];
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])buffer count:(NSUInteger)len
{
    return _CFSetFastEnumeration((CFSetRef)self, state, buffer, len);
}

- (NSUInteger)_trueCount
{
    return CFSetGetCount((CFSetRef)self);
}

- (id)member:(id)object
{
    if (object == nil)
    {
        return nil;
    }

    id found = nil;
    CFSetGetValueIfPresent((CFSetRef)self, (const void *)object, (const void **)&found);
    return found;
}

- (NSUInteger)count
{
    return CFSetGetCount((CFSetRef)self);
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    return (id)CFSetCreateMutableCopy(kCFAllocatorDefault, 0, (CFSetRef)self);
}

- (id)copyWithZone:(NSZone *)zone
{
    return (id)CFSetCreateCopy(kCFAllocatorDefault, (CFSetRef)self);
}

- (Class)classForCoder
{
    if (_CFSetIsMutable((CFSetRef)self))
    {
        return [NSMutableSet class];
    }
    else
    {
        return [NSSet class];
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

- (BOOL)isEqual:(id)object
{
    if (object == nil)
    {
        return NO;
    }
    return CFEqual((CFTypeRef)self, (CFTypeRef)object);
}

@end
