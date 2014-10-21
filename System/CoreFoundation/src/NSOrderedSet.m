//
//  NSOrderedSet.m
//  CoreFoundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/NSOrderedSet.h>

#import <Foundation/NSArray.h>
#import <Foundation/NSEnumerator.h>
#import <Foundation/NSSet.h>
#import <Foundation/NSIndexSet.h>
#import <Foundation/NSLocale.h>

#import "CFBasicHash.h"
#import "ForFoundationOnly.h"

#import "NSBasicHash.h"
#import "NSFastEnumerationEnumerator.h"
#import "NSObjectInternal.h"

@interface __NSPlaceholderOrderedSet : NSMutableOrderedSet
+ (id)mutablePlaceholder;
+ (id)immutablePlaceholder;
@end

@interface __NSOrderedSetI : NSOrderedSet
+ (id)__new:(const id *)addr :(NSUInteger)count :(BOOL)tbd;
@end

@interface __NSOrderedSetM : NSMutableOrderedSet
+ (id)__new:(const id *)addr :(NSUInteger)count :(BOOL)tbd;
@end

@interface __NSOrderedSetArrayProxy : NSArray
- (id)initWithOrderedSet:(NSOrderedSet *)orderedSet;
@end

@interface __NSOrderedSetSetProxy : NSSet
- (id)initWithOrderedSet:(NSOrderedSet *)orderedSet;
@end

@interface __NSOrderedSetReversed : NSOrderedSet
@end

@interface __NSOrderedSetReverseEnumerator : NSEnumerator
- (id)initWithObject:(id)object;
@end

@interface NSMutableArray ()
- (void)_mutate;
@end

@interface NSSet ()
- (void)getObjects:(id *)objects count:(NSUInteger)count;
@end

#define STACK_BUFFER_SIZE 256

@implementation NSOrderedSet

+ (id)allocWithZone:(NSZone *)zone
{
    if (self == [NSOrderedSet class])
    {
        return [__NSPlaceholderOrderedSet immutablePlaceholder];
    }
    else if (self == [NSMutableOrderedSet class])
    {
        return [__NSPlaceholderOrderedSet mutablePlaceholder];
    }
    else
    {
        return [super allocWithZone:zone];
    }
}

+ (BOOL)supportsSecureCoding
{
    return YES;
}

+ (id)orderedSet
{
    return [[[self alloc] initWithObjects:NULL count:0] autorelease];
}

+ (id)orderedSetWithObject:(id)object
{
    return [[[self alloc] initWithObjects:&object count:1] autorelease];
}

+ (id)orderedSetWithObjects:(const id [])objects count:(NSUInteger)count
{
    return [[[self alloc] initWithObjects:objects count:count] autorelease];
}

+ (id)orderedSetWithObjects:(id)firstObj, ... NS_REQUIRES_NIL_TERMINATION
{
    NSUInteger argCount = 1;

    va_list args;
    va_list copy;

    va_start(args, firstObj);
    va_copy(copy, args);

    while (va_arg(args, id) != nil)
    {
        argCount++;
    }

    va_end(args);

    id *objects = malloc(argCount * sizeof(id));

    if (objects == NULL)
    {
        [NSException raise:NSMallocException format:@"Could not allocate buffer"];
        return nil;
    }

    objects[0] = firstObj;

    for (NSUInteger idx = 1; idx < argCount; idx++)
    {
        objects[idx] = va_arg(copy, id);
    }

    va_end(copy);

    NSOrderedSet *orderedSet = [[[self alloc] initWithObjects:objects count:argCount] autorelease];

    free(objects);

    return orderedSet;
}

+ (id)orderedSetWithOrderedSet:(NSOrderedSet *)orderedSet
{
    NSRange range = NSMakeRange(0, [orderedSet count]);
    return [[[self alloc] initWithOrderedSet:orderedSet range:range copyItems:NO] autorelease];
}

+ (id)orderedSetWithOrderedSet:(NSOrderedSet *)orderedSet range:(NSRange)range copyItems:(BOOL)copyItems
{
    return [[[self alloc] initWithOrderedSet:orderedSet range:range copyItems:copyItems] autorelease];
}

+ (id)orderedSetWithArray:(NSArray *)array
{
    NSRange range = NSMakeRange(0, [array count]);
    return [[[self alloc] initWithArray:array range:range copyItems:NO] autorelease];
}

+ (id)orderedSetWithArray:(NSArray *)array range:(NSRange)range copyItems:(BOOL)copyItems
{
    return [[[self alloc] initWithArray:array range:range copyItems:copyItems] autorelease];
}

+ (id)orderedSetWithSet:(NSSet *)set
{
    return [[[self alloc] initWithSet:set copyItems:NO] autorelease];
}

+ (id)orderedSetWithSet:(NSSet *)set copyItems:(BOOL)copyItems
{
    return [[[self alloc] initWithSet:set copyItems:copyItems] autorelease];
}

+ (id)orderedSetWithOrderedSet:(NSOrderedSet *)orderedSet copyItems:(BOOL)copyItems
{
    return [[[self alloc] initWithOrderedSet:orderedSet copyItems:copyItems] autorelease];
}

+ (id)orderedSetWithOrderedSet:(NSOrderedSet *)orderedSet range:(NSRange)range
{
    return [[[self alloc] initWithOrderedSet:orderedSet range:range copyItems:NO] autorelease];
}

+ (id)orderedSetWithArray:(NSArray *)array copyItems:(BOOL)copyItems
{
    return [[[self alloc] initWithArray:array copyItems:copyItems] autorelease];
}

+ (id)orderedSetWithArray:(NSArray *)array range:(NSRange)range
{
    return [[[self alloc] initWithArray:array range:range copyItems:NO] autorelease];
}

+ (id)newOrderedSetWithObjects:(const id *)objects count:(NSUInteger)count
{
    if (self == [__NSOrderedSetI class])
    {
        return [[__NSOrderedSetI class] __new:objects :count :NO];
    }

    if (self == [__NSOrderedSetM class])
    {
        return [[__NSOrderedSetM class] __new:objects :count :NO];
    }

    NSRequestConcreteImplementation();
    return nil;
}

- (id)initWithObject:(id)object
{
    return [self initWithObjects:&object count:1];
}

- (id)initWithObjects:(const id [])objects count:(NSUInteger)count
{
    NSRequestConcreteImplementation();
    return nil;
}

- (id)initWithObjects:(id)firstObj, ... NS_REQUIRES_NIL_TERMINATION
{
    NSUInteger argCount = 1;

    va_list args;
    va_list copy;

    va_start(args, firstObj);
    va_copy(copy, args);

    while (va_arg(args, id) != nil)
    {
        argCount++;
    }

    va_end(args);

    id *objects = malloc(argCount * sizeof(id));

    if (objects == NULL)
    {
        [NSException raise:NSMallocException format:@"Could not allocate buffer"];
        return nil;
    }

    objects[0] = firstObj;

    for (NSUInteger idx = 1; idx < argCount; idx++)
    {
        objects[idx] = va_arg(copy, id);
    }

    va_end(copy);

    self = [self initWithObjects:objects count:argCount];

    free(objects);

    return self;
}

- (id)initWithOrderedSet:(NSOrderedSet *)orderedSet
{
    NSRange range = NSMakeRange(0, [orderedSet count]);
    return [self initWithOrderedSet:orderedSet range:range copyItems:NO];
}

- (id)initWithOrderedSet:(NSOrderedSet *)orderedSet copyItems:(BOOL)copyItems
{
    NSRange range = NSMakeRange(0, [orderedSet count]);
    return [self initWithOrderedSet:orderedSet range:range copyItems:copyItems];
}

- (id)initWithOrderedSet:(NSOrderedSet *)orderedSet range:(NSRange)range
{
    return [self initWithOrderedSet:orderedSet range:range copyItems:NO];
}

- (id)initWithOrderedSet:(NSOrderedSet *)orderedSet range:(NSRange)range copyItems:(BOOL)copyItems
{
    if (NSMaxRange(range) > [orderedSet count])
    {
        [self release];
        [NSException raise:NSRangeException format:@"Range out of bounds for ordered set"];
        return nil;
    }

    if (orderedSet == nil && range.length > 0)
    {
        [self release];
        [NSException raise:NSInvalidArgumentException format:@"Cannot init ordered set with nonzero range and nil ordered set"];
        return nil;
    }

    if (range.length == 0)
    {
        return [self initWithObjects:NULL count:0];
    }

    id *objects = malloc(range.length * sizeof(id));
    if (objects == NULL)
    {
        [self release];
        [NSException raise:NSMallocException format:@"Failed to allocate buffer"];
        return nil;
    }

    [orderedSet getObjects:objects range:range];

    if (copyItems)
    {
        for (NSUInteger idx = 0; idx < range.length; idx++)
        {
            objects[idx] = [objects[idx] copy];
        }
    }

    self = [self initWithObjects:objects count:range.length];

    if (copyItems)
    {
        for (NSUInteger idx = 0; idx < range.length; idx++)
        {
            [objects[idx] release];
        }
    }

    free(objects);

    return self;
}

- (id)initWithArray:(NSArray *)array
{
    NSRange range = NSMakeRange(0, [array count]);
    return [self initWithArray:array range:range copyItems:NO];
}

- (id)initWithArray:(NSArray *)array copyItems:(BOOL)copyItems
{
    NSRange range = NSMakeRange(0, [array count]);
    return [self initWithArray:array range:range copyItems:copyItems];
}

- (id)initWithArray:(NSArray *)array range:(NSRange)range
{
    return [self initWithArray:array range:range copyItems:NO];
}

- (id)initWithArray:(NSArray *)array range:(NSRange)range copyItems:(BOOL)copyItems
{
    if (NSMaxRange(range) > [array count])
    {
        [self release];
        [NSException raise:NSRangeException format:@"Range out of bounds for ordered set"];
        return nil;
    }

    if (array == nil && range.length > 0)
    {
        [self release];
        [NSException raise:NSInvalidArgumentException format:@"Cannot init ordered set with nonzero range and nil ordered set"];
        return nil;
    }

    if (range.length == 0)
    {
        return [self initWithObjects:NULL count:0];
    }

    id *objects = malloc(range.length * sizeof(id));

    if (objects == NULL)
    {
        [self release];
        [NSException raise:NSMallocException format:@"Failed to allocate buffer"];
        return nil;
    }

    [array getObjects:objects range:range];

    if (copyItems)
    {
        for (NSUInteger idx = 0; idx < range.length; idx++)
        {
            objects[idx] = [objects[idx] copy];
        }
    }

    self = [self initWithObjects:objects count:range.length];

    if (copyItems)
    {
        for (NSUInteger idx = 0; idx < range.length; idx++)
        {
            [objects[idx] release];
        }
    }

    free(objects);

    return self;
}

- (id)initWithSet:(NSSet *)set
{
    return [self initWithSet:set copyItems:NO];
}

- (id)initWithSet:(NSSet *)set copyItems:(BOOL)copyItems
{
    if (set == nil)
    {
        return [self initWithObjects:NULL count:0];
    }

    NSUInteger count = [set count];

    if (count == 0)
    {
        return [self initWithObjects:NULL count:0];
    }

    id *objects = malloc(count * sizeof(id));

    if (objects == NULL)
    {
        [self release];
        [NSException raise:NSMallocException format:@"Failed to allocate buffer"];
        return nil;
    }

    [set getObjects:objects count:count];

    if (copyItems)
    {
        for (NSUInteger idx = 0; idx < count; idx++)
        {
            objects[idx] = [objects[idx] copy];
        }
    }

    self = [self initWithObjects:objects count:count];

    if (copyItems)
    {
        for (NSUInteger idx = 0; idx < count; idx++)
        {
            [objects[idx] release];
        }
    }

    free(objects);

    return self;
}

- (NSUInteger)count
{
    NSRequestConcreteImplementation();
    return 0;
}

- (id)objectAtIndex:(NSUInteger)idx
{
    NSRequestConcreteImplementation();
    return nil;
}

- (NSUInteger)indexOfObject:(id)object
{
    NSRequestConcreteImplementation();
    return 0;
}

- (Class)classForCoder
{
    return [NSOrderedSet class];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if (![decoder allowsKeyedCoding])
    {
        [self release];
        [NSException raise:NSInvalidArgumentException format:@"Cannot init ordered set with non keyed coder"];
        return nil;
    }

    NSUInteger capacity = 256;
    id *objects = malloc(capacity * sizeof(id));

    if (objects == NULL)
    {
        [self release];
        [NSException raise:NSMallocException format:@"Could not allocate buffer"];
        return nil;
    }

    unsigned int idx = 0;

    while (YES)
    {
        if (idx == capacity)
        {
            capacity *= 2;
            id *newObjects = realloc(objects, capacity * sizeof(id));

            if (newObjects == NULL)
            {
                for (unsigned int i = 0; i < idx; i++)
                {
                    [objects[i] release];
                }

                free(objects);
                [self release];
                [NSException raise:NSMallocException format:@"Could not allocate buffer"];
                return nil;
            }

            objects = newObjects;
        }

        CFStringRef key = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("NS.object.%u"), idx);
        id obj = [decoder decodeObjectForKey:(NSString *)key];
        CFRelease(key);

        if (obj == nil)
        {
            break;
        }

        objects[idx] = obj;
        idx++;
    };

    [self initWithObjects:objects count:idx];

    free(objects);

    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    if (![coder allowsKeyedCoding])
    {
        [NSException raise:NSInvalidArgumentException format:@"Cannot encode ordered set with non keyed coder"];
        return;
    }

    unsigned int idx = 0;

    for (id object in self)
    {
        CFStringRef key = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("NS.object.%u"), idx);
        [coder encodeObject:object forKey:(NSString *)key];
        CFRelease(key);
        idx++;
    }
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    NSRange range = NSMakeRange(0, [self count]);
    return [[NSMutableOrderedSet alloc] initWithOrderedSet:self range:range copyItems:NO];
}

- (id)copyWithZone:(NSZone *)zone
{
    NSRange range = NSMakeRange(0, [self count]);
    return [[NSOrderedSet alloc] initWithOrderedSet:self range:range copyItems:NO];
}

- (id)objectsPassingTest:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))test
{
    if (test == nil)
    {
        [NSException raise:NSInvalidArgumentException format:@"Nil test"];
        return nil;
    }

    NSIndexSet *passingIndexes = [self indexesOfObjectsPassingTest:test];
    NSArray *objects = [self objectsAtIndexes:passingIndexes];

    return [NSOrderedSet orderedSetWithArray:objects];
}

- (id)objectsWithOptions:(NSEnumerationOptions)options passingTest:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))test
{
    if (test == nil)
    {
        [NSException raise:NSInvalidArgumentException format:@"Test cannot be nil"];
        return nil;
    }

    NSIndexSet *passingIndexes = [self indexesOfObjectsWithOptions:options passingTest:test];
    NSArray *objects = [self objectsAtIndexes:passingIndexes];

    return [NSOrderedSet orderedSetWithArray:objects];
}

- (id)objectsAtIndexes:(NSIndexSet *)indexes options:(NSEnumerationOptions)options passingTest:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))test
{
    if (test == nil)
    {
        [NSException raise:NSInvalidArgumentException format:@"Test cannot be nil"];
        return nil;
    }

    if (indexes == nil)
    {
        [NSException raise:NSInvalidArgumentException format:@"Indexes cannot be nil"];
        return nil;
    }

    NSIndexSet *passingIndexes = [self indexesOfObjectsAtIndexes:indexes options:options passingTest:test];
    NSArray *objects = [self objectsAtIndexes:passingIndexes];

    return [NSOrderedSet orderedSetWithArray:objects];
}

- (id)objectPassingTest:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))test
{
    if (test == nil)
    {
        [NSException raise:NSInvalidArgumentException format:@"Test cannot be nil"];
        return nil;
    }

    return [self objectWithOptions:0 passingTest:test];
}

- (id)objectWithOptions:(NSEnumerationOptions)options passingTest:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))test
{
    if (test == nil)
    {
        [NSException raise:NSInvalidArgumentException format:@"Test cannot be nil"];
        return nil;
    }

    NSUInteger idx = [self indexOfObjectWithOptions:options passingTest:test];

    if (idx == NSNotFound)
    {
        return nil;
    }

    return [self objectAtIndex:idx];
}

- (id)objectAtIndexes:(NSIndexSet *)indexes options:(NSEnumerationOptions)options passingTest:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))test
{
    if (test == nil)
    {
        [NSException raise:NSInvalidArgumentException format:@"Test cannot be nil"];
        return nil;
    }

    if (indexes == nil)
    {
        [NSException raise:NSInvalidArgumentException format:@"Indexes cannot be nil"];
        return nil;
    }

    NSUInteger idx = [self indexOfObjectAtIndexes:indexes options:options passingTest:test];

    if (idx == NSNotFound)
    {
        return nil;
    }

    return [self objectAtIndex:idx];
}

- (BOOL)isEqual:(id)other
{
    if (self == other)
    {
        return YES;
    }
    else if ([other isNSOrderedSet__])
    {
        return [self isEqualToOrderedSet:(NSOrderedSet *)other];
    }
    else
    {
        return NO;
    }
}

- (NSUInteger)indexOfObject:(id)object inRange:(NSRange)range
{
    if (NSMaxRange(range) > [self count])
    {
        [NSException raise:NSRangeException format:@"Range out of bounds for ordered set"];
        return 0;
    }

    NSUInteger idx = [self indexOfObject:object];

    return NSLocationInRange(idx, range);
}

- (NSUInteger)hash
{
    return [self count];
}

- (void)getObjects:(id *)addr
{
    if (addr == NULL)
    {
        [NSException raise:NSInvalidArgumentException format:@"Cannot place objects from ordered set into NULL array"];
        return;
    }

    NSRange range = NSMakeRange(0, [self count]);
    return [self getObjects:addr range:range];
}

- (void)getObjects:(id __unsafe_unretained [])objects range:(NSRange)range
{
    if (objects == NULL && range.length > 0)
    {
        [NSException raise:NSInvalidArgumentException format:@"Range out of bounds of NULL array"];
        return;
    }

    if (NSMaxRange(range) > [self count])
    {
        [NSException raise:NSRangeException format:@"Range out of bounds of ordered set"];
        return;
    }

    if (range.length == 0)
    {
        return;
    }

    for (NSUInteger idx = 0; idx < range.length; idx++)
    {
        objects[idx] = [self objectAtIndex:(idx + range.location)];
    }
}

- (NSUInteger)countForObject:(id)object
{
    NSUInteger idx = [self indexOfObject:object];
    if (idx == NSNotFound)
    {
        return 0;
    }
    else
    {
        return 1;
    }
}

- (NSUInteger)countForObject:(id)object inRange:(NSRange)range
{
    if (NSMaxRange(range) > [self count])
    {
        [NSException raise:NSRangeException format:@"Range out of bounds for ordered set"];
        return NO;
    }

    NSUInteger idx = [self indexOfObject:object inRange:range];

    if (idx == NSNotFound)
    {
        return 0;
    }
    else
    {
        return 1;
    }
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)objects count:(NSUInteger)count
{
    if (state->state == -1)
    {
        return 0;
    }

    if (state->state == 0)
    {
        state->mutationsPtr = &state->extra[0];
        state->extra[0] = [self count];
    }

    state->itemsPtr = objects;

    NSUInteger returnedLength = MIN(state->extra[0] - state->state, count);
    if (returnedLength != 0)
    {
        [self getObjects:objects range:NSMakeRange(state->state, returnedLength)];
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

- (BOOL)containsObject:(id)object
{
    NSUInteger idx = [self indexOfObject:object];

    return idx != NSNotFound;
}

- (BOOL)containsObject:(id)object inRange:(NSRange)range
{
    if (NSMaxRange(range) > [self count])
    {
        [NSException raise:NSRangeException format:@"Range out of bounds for ordered set"];
        return NO;
    }

    NSUInteger idx = [self indexOfObject:object inRange:range];

    return idx != NSNotFound;
}

- (NSArray *)allObjects
{
    NSUInteger count = [self count];

    if (count == 0)
    {
        return [NSArray array];
    }

    id *objects = malloc(count * sizeof(id));

    if (objects == NULL)
    {
        [NSException raise:NSMallocException format:@"Failed to allocate buffer"];
        return nil;
    }

    NSRange range = NSMakeRange(0, count);
    [self getObjects:objects range:range];

    NSArray *array = [NSArray arrayWithObjects:objects count:count];

    free(objects);

    return array;
}

- (BOOL)isNSOrderedSet__
{
    return YES;
}

- (NSArray *)objectsAtIndexes:(NSIndexSet *)indexes
{
    if (indexes == nil)
    {
        [NSException raise:NSInvalidArgumentException format:@"Indexes cannot be nil"];
        return nil;
    }

    NSUInteger count = [indexes count];

    if (count == 0)
    {
        return [NSArray array];
    }

    if ([indexes lastIndex] >= [self count])
    {
        [NSException raise:NSInvalidArgumentException format:@"Indexes out of bounds of ordered set"];
        return nil;
    }

    id *objects = malloc(count * sizeof(id));
    if (objects == NULL)
    {
        [NSException raise:NSMallocException format:@"Failed to allocate buffer"];
        return nil;
    }

    __block id *currentObjectPtr = objects;
    [indexes enumerateRangesUsingBlock:^(NSRange range, BOOL *stop) {
        [self getObjects:currentObjectPtr range:range];
        currentObjectPtr += range.length;
    }];

    NSArray *array = [NSArray arrayWithObjects:objects count:count];

    free(objects);

    return array;
}

- (id)firstObject
{
    if (self.count == 0)
    {
        return nil;
    }

    return [self objectAtIndex:0];
}

- (id)lastObject
{
    NSUInteger count = self.count;

    if (count == 0)
    {
        return nil;
    }

    return [self objectAtIndex:count - 1];
}

- (BOOL)isEqualToOrderedSet:(NSOrderedSet *)other
{
    if ([self count] != [other count])
    {
        return NO;
    }

    if ([self count] == 0)
    {
        return YES;
    }

    NSUInteger idx = 0;
    for (id obj in self)
    {
        id otherObj = [other objectAtIndex:idx];
        if (obj != otherObj && ![obj isEqual:otherObj])
        {
            return NO;
        }
        idx++;
    }

    return YES;
}

- (BOOL)intersectsOrderedSet:(NSOrderedSet *)other
{
    for (id obj in self)
    {
        if ([other containsObject:obj])
        {
            return YES;
        }
    }

    return NO;
}

- (BOOL)intersectsSet:(NSSet *)set
{
    for (id obj in self)
    {
        if ([set containsObject:obj])
        {
            return YES;
        }
    }

    return NO;
}

- (BOOL)isSubsetOfOrderedSet:(NSOrderedSet *)other
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

- (BOOL)isSubsetOfSet:(NSSet *)set
{
    for (id obj in self)
    {
        if (![set containsObject:obj])
        {
            return NO;
        }
    }

    return YES;
}

- (id)objectAtIndexedSubscript:(NSUInteger)idx
{
    return [self objectAtIndex:idx];
}

- (NSEnumerator *)objectEnumerator
{
    return [[[__NSFastEnumerationEnumerator alloc] initWithObject:self] autorelease];
}

- (NSEnumerator *)reverseObjectEnumerator
{
    return [[[__NSOrderedSetReverseEnumerator alloc] initWithObject:self] autorelease];
}

- (NSOrderedSet *)reversedOrderedSet
{
    return [[[__NSOrderedSetReversed alloc] initWithOrderedSet:self] autorelease];
}

- (NSArray *)array
{
    return [[[__NSOrderedSetArrayProxy alloc] initWithOrderedSet:self] autorelease];
}

- (NSSet *)set
{
    return [[[__NSOrderedSetSetProxy alloc] initWithOrderedSet:self] autorelease];
}

- (void)enumerateObjectsUsingBlock:(void (^)(id obj, NSUInteger idx, BOOL *stop))block
{
    [self enumerateObjectsWithOptions:0 usingBlock:block];
}

- (void)enumerateObjectsWithOptions:(NSEnumerationOptions)opts usingBlock:(void (^)(id obj, NSUInteger idx, BOOL *stop))block
{
    NSUInteger len = [self count];
    if (opts & NSEnumerationConcurrent)
    {
        __block BOOL stop = NO;

        if (opts & NSEnumerationReverse)
        {
            dispatch_apply(len, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(size_t iter){
                if (!stop)
                {
                    NSUInteger i = len - 1 - iter;
                    block([self objectAtIndex:i], i, &stop);
                }
            });
        }
        else
        {
            dispatch_apply(len, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(size_t iter){
                if (!stop)
                {
                    block([self objectAtIndex:iter], iter, &stop);
                }
            });
        }
        return;
    }
    if (opts & NSEnumerationReverse)
    {
        for (int i = len - 1; i >= 0; i--)
        {
            BOOL stop = NO;
            block([self objectAtIndex:i], i, &stop);

            if (stop)
            {
                return;
            }
        }
    }
    else
    {
        NSUInteger i = 0;

        for (id obj in self)
        {
            BOOL stop = NO;
            block(obj, i++, &stop);

            if (stop)
            {
                return;
            }
        }
    }
}

- (void)enumerateObjectsAtIndexes:(NSIndexSet *)s options:(NSEnumerationOptions)opts usingBlock:(void (^)(id obj, NSUInteger idx, BOOL *stop))block
{
    if (block == nil)
    {
        [NSException raise:NSInvalidArgumentException format:@"block is nil"];
        return;
    }

    [s enumerateIndexesWithOptions:opts usingBlock:^(NSUInteger idx, BOOL *stop) {
        block([self objectAtIndex:idx], idx, stop);
    }];
}

- (NSUInteger)indexOfObjectPassingTest:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))predicate
{
    return [self indexOfObjectWithOptions:0 passingTest:predicate];
}

- (NSUInteger)indexOfObjectWithOptions:(NSEnumerationOptions)opts passingTest:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))predicate
{
    NSUInteger len = [self count];
    __block NSUInteger found = NSNotFound;
    if (opts & NSEnumerationConcurrent)
    {
        __block BOOL stop = NO;

        if (opts & NSEnumerationReverse)
        {
            dispatch_apply(len, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(size_t iter){
                if (!stop)
                {
                    NSUInteger i = len - 1 - iter;

                    if (predicate([self objectAtIndex:i], i, &stop))
                    {
                        stop = YES;
                        found = i;
                    }
                }
            });
        }
        else
        {
            dispatch_apply(len, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(size_t iter){
                if (!stop)
                {
                    if(predicate([self objectAtIndex:iter], iter, &stop))
                    {
                        stop = YES;
                        found = iter;
                    }
                }
            });
        }
    }
    if (opts & NSEnumerationReverse)
    {
        for (int i = len - 1; i >= 0; i--)
        {
            BOOL stop = NO;

            if (predicate([self objectAtIndex:i], i, &stop))
            {
                stop = YES;
                found = i;
            }
            if (stop)
            {
                break;
            }
        }
    }
    else
    {
        NSUInteger i = 0;

        for (id obj in self)
        {
            BOOL stop = NO;

            if (predicate(obj, i++, &stop))
            {
                stop = YES;
                found = i;
            }
            if (stop)
            {
                break;
            }
        }
    }
    return found;
}

- (NSUInteger)indexOfObjectAtIndexes:(NSIndexSet *)s options:(NSEnumerationOptions)opts passingTest:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))predicate
{
    __block NSUInteger found = NSNotFound;
    [s enumerateIndexesWithOptions:opts usingBlock:^(NSUInteger idx, BOOL *stop) {
        if (predicate([self objectAtIndex:idx], idx, stop))
        {
            found = idx;
        }
    }];
    return found;
}

- (NSIndexSet *)indexesOfObjectsPassingTest:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))predicate
{
    NSObject *indexSet = [[objc_getClass("NSMutableIndexSet") alloc] init];
    NSUInteger len = [self count];
    BOOL stop = NO;
    for (NSUInteger i = 0; i < len; i++)
    {
        if (predicate([self objectAtIndex:i], i, &stop))
        {
            ((void (*)(id, SEL, NSUInteger))objc_msgSend)(indexSet, @selector(addIndex:), i);
        }
        if (stop)
        {
            break;
        }
    }
    return (NSIndexSet *)[indexSet autorelease];
}

- (NSIndexSet *)indexesOfObjectsWithOptions:(NSEnumerationOptions)opts passingTest:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))predicate
{
    NSObject *indices = [[objc_getClass("NSMutableIndexSet") alloc] init];
    NSUInteger len = [self count];

    if (opts & NSEnumerationConcurrent)
    {
        __block BOOL stop = NO;

        if (opts & NSEnumerationReverse)
        {
            dispatch_apply(len, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(size_t iter){
                if (!stop)
                {
                    NSUInteger i = len - 1 - iter;

                    if (predicate([self objectAtIndex:i], i, &stop))
                    {
                        ((void (*)(id, SEL, NSUInteger))objc_msgSend)(indices, @selector(addIndex:), i);
                    }
                }
            });
        }
        else
        {
            dispatch_apply(len, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(size_t iter){
                if (!stop)
                {
                    if(predicate([self objectAtIndex:iter], iter, &stop))
                    {
                        ((void (*)(id, SEL, NSUInteger))objc_msgSend)(indices, @selector(addIndex:), iter);
                    }
                }
            });
        }
    }
    if (opts & NSEnumerationReverse)
    {
        for (int i = len - 1; i >= 0; i--)
        {
            BOOL stop = NO;

            if (predicate([self objectAtIndex:i], i, &stop))
            {
                ((void (*)(id, SEL, NSUInteger))objc_msgSend)(indices, @selector(addIndex:), i);
            }
            if (stop)
            {
                break;
            }
        }
    }
    else
    {
        NSUInteger i = 0;
        for (id obj in self)
        {
            BOOL stop = NO;

            if (predicate(obj, i++, &stop))
            {
                ((void (*)(id, SEL, NSUInteger))objc_msgSend)(indices, @selector(addIndex:), i);
            }
            if (stop)
            {
                break;
            }
        }
    }
    return (NSIndexSet *)[indices autorelease];
}

- (NSIndexSet *)indexesOfObjectsAtIndexes:(NSIndexSet *)s options:(NSEnumerationOptions)opts passingTest:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))predicate
{
    NSObject *indices = [[objc_getClass("NSMutableIndexSet") alloc] init];
    [s enumerateIndexesWithOptions:opts usingBlock:^(NSUInteger idx, BOOL *stop) {
        if (predicate([self objectAtIndex:idx], idx, stop))
        {
            ((void (*)(id, SEL, NSUInteger))objc_msgSend)(indices, @selector(addIndex:), idx);
        }
    }];
    return (NSIndexSet *)[indices autorelease];
}

- (NSUInteger)indexOfObject:(id)obj inSortedRange:(NSRange)r options:(NSBinarySearchingOptions)opts usingComparator:(NSComparator)comparator
{
    NSUInteger minIndex = r.location;
    NSUInteger midIndex = ceil(r.length / 2.0) + r.location;
    NSUInteger maxIndex = NSMaxRange(r);
    id min = [self objectAtIndex:minIndex];
    id mid = min;

    if (r.length > 2)
    {
        mid = [self objectAtIndex:midIndex];
    }

    NSComparisonResult result = comparator(mid, obj);

    switch (result)
    {
        case NSOrderedAscending:
            if ((opts & NSBinarySearchingInsertionIndex) && midIndex == maxIndex)
            {
                return maxIndex + 1;
            }
            else if (midIndex == maxIndex)
            {
                return NSNotFound;
            }
            else
            {
                return [self indexOfObject:obj inSortedRange:NSMakeRange(midIndex, maxIndex - minIndex) options:opts usingComparator:comparator];
            }
            break;
        case NSOrderedDescending:
            if ((opts & NSBinarySearchingInsertionIndex) && midIndex == minIndex)
            {
                return minIndex;
            }
            else if (midIndex == minIndex)
            {
                return NSNotFound;
            }
            else
            {
                return [self indexOfObject:obj inSortedRange:NSMakeRange(minIndex, midIndex - minIndex) options:opts usingComparator:comparator];
            }
        case NSOrderedSame:
            if (opts & NSBinarySearchingFirstEqual)
            {
                for (NSUInteger idx = midIndex; idx > 0; idx--)
                {
                    mid = [self objectAtIndex:idx];
                    result = comparator(mid, obj);

                    if (result != NSOrderedSame)
                    {
                        return idx + 1;
                    }
                }
                return NSNotFound; // this is likely an error
            }
            else if (opts & NSBinarySearchingLastEqual)
            {
                for (NSUInteger idx = midIndex; idx < [self count]; idx++)
                {
                    mid = [self objectAtIndex:idx];
                    result = comparator(mid, obj);

                    if (result != NSOrderedSame)
                    {
                        return idx - 1;
                    }
                }
                return NSNotFound; // also likely to be an error
            }
            else
            {
                return midIndex;
            }
            break;
    }
    return NSNotFound;
}

- (NSArray *)sortedArrayFromRange:(NSRange)range options:(NSSortOptions)opts usingComparator:(NSComparator)cmptr
{
    if (cmptr == nil)
    {
        [self doesNotRecognizeSelector:_cmd];
        CFStringRef format = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("-[%s <null selector>] unrecognized selector 0x%x"), object_getClassName(self), self);
        [NSException raise:NSInvalidArgumentException format:(NSString *)format];
        CFRelease(format);
        return nil;
    }

    NSUInteger count = range.length;
    id objects[STACK_BUFFER_SIZE] = {0};
    CFIndex indices[STACK_BUFFER_SIZE] = {0};
    id *objs = &objects[0];
    CFIndex *indexes = &indices[0];

    if (count > STACK_BUFFER_SIZE)
    {
        objs = malloc(sizeof(id) * count);

        if (objs == NULL)
        {
            CFStringRef reason = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("unable to allocate space to store %d objects"), count);
            @throw [NSException exceptionWithName:NSMallocException reason:(NSString *)reason userInfo:nil];
            CFRelease(reason);
            return nil;
        }
        indexes = malloc(sizeof(CFIndex) * count);
        if (indexes == NULL)
        {
            free(objects);
            CFStringRef reason = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("unable to allocate space to store %d indices"), count);
            @throw [NSException exceptionWithName:NSMallocException reason:(NSString *)reason userInfo:nil];
            CFRelease(reason);
            return nil;
        }
    }

    [self getObjects:objs range:range];
    CFSortIndexes(indexes, count, opts, ^(CFIndex i1, CFIndex i2) {
        return (CFComparisonResult)cmptr(objs[i1], objs[i2]);
    });
    assert(sizeof(id) == sizeof(CFIndex));

    for (int i = 0; i < count; i++)
    {
        indexes[i] = (CFIndex)objs[indexes[i]]; // re-use indexes allocation
    }

    if (objs != objects)
    {
        free(objs);
    }

    // Note: the indexes is reused as an object store.
    NSArray *arr = [[NSArray alloc] initWithObjects:(id *)indexes count:count];

    if (indices != indexes)
    {
        free(indexes);
    }

    return [arr autorelease];
}

- (NSArray *)sortedArrayUsingComparator:(NSComparator)comparator
{
    return [self sortedArrayWithOptions:NSSortStable usingComparator:comparator];
}

- (NSArray *)sortedArrayWithOptions:(NSSortOptions)opts usingComparator:(NSComparator)comparator
{
    return [self sortedArrayFromRange:NSMakeRange(0, [self count]) options:opts usingComparator:comparator];
}

- (NSString *)description
{
    return [self descriptionWithLocale:nil indent:0];
}

- (NSString *)descriptionWithLocale:(NSLocale *)locale
{
    return [self descriptionWithLocale:locale indent:0];
}

- (NSString *)descriptionWithLocale:(NSLocale *)locale indent:(NSUInteger)level
{
    CFMutableStringRef description = CFStringCreateMutable(kCFAllocatorDefault, 0);
    CFStringAppendFormat(description, NULL, CFSTR("%*s{(\n"), (int)level * strlen(INDENT), "");

    NSUInteger count = [self count];
    NSUInteger idx = 1;

    for (id obj in self)
    {
        NSString *objDescription = nil;
        if ([obj respondsToSelector:@selector(descriptionWithLocale:indent:)])
        {
            objDescription = [obj descriptionWithLocale:locale indent:(level + 1)];
        }
        else if ([obj respondsToSelector:@selector(descriptionWithLocale:)])
        {
            objDescription = [obj descriptionWithLocale:locale];
        }
        else
        {
            objDescription = [obj description];
        }

        CFStringRef format;

        if (idx == count)
        {
            format = CFSTR("%*s%@\n");
        }
        else
        {
            format = CFSTR("%*s%@,\n");
        }

        CFStringAppendFormat(description, NULL, format, ((int)level + 1) * strlen(INDENT), "", objDescription);

        idx++;
    }

    CFStringAppendFormat(description, NULL, CFSTR("%*s)}"), (int)level * strlen(INDENT), "");

    CFStringRef desc = CFStringCreateCopy(kCFAllocatorDefault, description);
    CFRelease(description);
    return [(NSString *)desc autorelease];
}

@end

@implementation NSMutableOrderedSet

+ (id)orderedSetWithCapacity:(NSUInteger)capacity
{
    return [[[self alloc] initWithCapacity:capacity] autorelease];
}

- (id)initWithCapacity:(NSUInteger)capacity
{
    NSRequestConcreteImplementation();
    return nil;
}

- (id)initWithObjects:(const id *)objects count:(NSUInteger)count
{
    if (objects == NULL && count > 0)
    {
        [self release];
        [NSException raise:NSInvalidArgumentException format:@"Cannot init ordered set with NULL array of and nonzero count"];
        return nil;
    }

    for (NSUInteger idx = 0; idx < count; idx++)
    {
        if (objects[idx] == nil)
        {
            [self release];
            [NSException raise:NSInvalidArgumentException format:@"Cannot init ordered set with nil"];
            return nil;
        }
    }

    self = [self initWithCapacity:count];
    if (self != nil)
    {
        [self insertObjects:objects count:count atIndex:0];
    }

    return self;
}

- (Class)classForCoder
{
    return [NSMutableOrderedSet class];
}

- (void)addObject:(id)object
{
    if (object == nil)
    {
        [NSException raise:NSInvalidArgumentException format:@"Cannot add nil to orderded set"];
        return;
    }

    [self _mutate];
    [self insertObject:object atIndex:[self count]];
}

- (void)addObjects:(const id [])objects count:(NSUInteger)count
{
    if (objects == NULL && count > 0)
    {
        [NSException raise:NSInvalidArgumentException format:@"Cannot add NULL array of objects with nonzero count to ordered set"];
        return;
    }

    for (NSUInteger idx = 0; idx < count; idx++)
    {
        id object = objects[idx];
        if (object == nil)
        {
            [NSException raise:NSInvalidArgumentException format:@"Cannot add nil to ordered set"];
            return;
        }
    }

    [self _mutate];
    [self insertObjects:objects count:count atIndex:[self count]];
}

- (void)addObjectsFromSet:(NSSet *)set
{
    [self _mutate];
    [self insertObjectsFromSet:set atIndex:[self count]];
}

- (void)addObjectsFromOrderedSet:(NSOrderedSet *)orderedSet
{
    NSRange range = NSMakeRange(0, [orderedSet count]);
    [self _mutate];
    [self insertObjectsFromOrderedSet:orderedSet range:range atIndex:[self count]];
}

- (void)addObjectsFromOrderedSet:(NSOrderedSet *)orderedSet range:(NSRange)range
{
    if (NSMaxRange(range) > [orderedSet count])
    {
        [NSException raise:NSRangeException format:@"Range out of bounds of ordered set"];
        return;
    }

    [self _mutate];
    [self insertObjectsFromOrderedSet:orderedSet range:range atIndex:[self count]];
}

- (void)addObjectsFromArray:(NSArray *)array
{
    NSRange range = NSMakeRange(0, [array count]);
    [self _mutate];
    [self insertObjectsFromArray:array range:range atIndex:[self count]];
}

- (void)addObjectsFromArray:(NSArray *)array range:(NSRange)range
{
    if (NSMaxRange(range) > [array count])
    {
        [NSException raise:NSRangeException format:@"Range out of bounds of array"];
        return;
    }

    [self _mutate];
    [self insertObjectsFromArray:array range:range atIndex:[self count]];
}

- (void)exchangeObjectAtIndex:(NSUInteger)idx1 withObjectAtIndex:(NSUInteger)idx2
{
    NSUInteger count = [self count];

    if (idx1 >= count || idx2 >= count)
    {
        [NSException raise:NSInvalidArgumentException format:@"Index out of bounds of ordered set"];
        return;
    }

    id obj1 = [[self objectAtIndex:idx1] retain];
    id obj2 = [[self objectAtIndex:idx2] retain];

    [self _mutate];

    [self removeObjectAtIndex:idx1];
    [self insertObject:obj2 atIndex:idx1];

    [self removeObjectAtIndex:idx2];
    [self insertObject:obj1 atIndex:idx2];

    [obj1 release];
    [obj2 release];
}

- (void)moveObjectsAtIndexes:(NSIndexSet *)indexes toIndex:(NSUInteger)idx
{
    NSUInteger count = [self count];

    if (idx >= count)
    {
        [NSException raise:NSInvalidArgumentException format:@"Index out of bounds of ordered set"];
        return;
    }

    NSUInteger idxCount = [indexes count];

    if (idxCount == 0)
    {
        return;
    }

    if ([indexes lastIndex] >= count)
    {
        [NSException raise:NSInvalidArgumentException format:@"Indexes out of bounds of ordered set"];
        return;
    }

    NSArray *array = [self objectsAtIndexes:indexes];

    [self _mutate];
    [self removeObjectsAtIndexes:indexes];

    id *objects = malloc(idxCount * sizeof(id));
    if (objects == NULL)
    {
        [NSException raise:NSMallocException format:@"Could not allocate buffer"];
        return;
    }

    NSRange range = NSMakeRange(0, idxCount);
    [array getObjects:objects range:range];
    [self insertObjects:objects count:idxCount atIndex:idx];

    free(objects);
}

- (void)setObject:(id)object
{
    if (object == nil)
    {
        [NSException raise:NSInvalidArgumentException format:@"Cannot add nil to orderded set"];
        return;
    }

    NSUInteger idx = [self indexOfObject:object];
    if (idx == NSNotFound)
    {
        [NSException raise:NSInvalidArgumentException format:@"Object not in ordered set"];
        return;
    }

    [self _mutate];
    [self replaceObjectAtIndex:idx withObject:object];
}

- (void)setObject:(id)object atIndex:(NSUInteger)idx
{
    if (object == nil)
    {
        [NSException raise:NSInvalidArgumentException format:@"Cannot add nil to orderded set"];
        return;
    }

    NSUInteger count = [self count];

    if (idx >= count)
    {
        [NSException raise:NSInvalidArgumentException format:@"Index out of bounds of ordered set"];
        return;
    }

    [self _mutate];

    if (idx == count)
    {
        [self insertObject:object atIndex:idx];
    }
    else
    {
        [self replaceObjectAtIndex:idx withObject:object];
    }
}

- (void)setObject:(id)object atIndexedSubscript:(NSUInteger)idx
{
    [self setObject:object atIndex:idx];
}

- (void)setSet:(NSSet *)set
{
    [self _mutate];
    [self removeAllObjects];
    [self insertObjectsFromSet:set atIndex:0];
}

- (void)setOrderedSet:(NSOrderedSet *)orderedSet
{
    [self _mutate];
    [self removeAllObjects];
    [self insertObjectsFromOrderedSet:orderedSet atIndex:0];
}

- (void)setArray:(NSArray *)array
{
    [self _mutate];
    [self removeAllObjects];
    [self insertObjectsFromArray:array atIndex:0];
}

- (void)removeObjectAtIndex:(NSUInteger)idx
{
    NSRequestConcreteImplementation();
}

- (void)removeObjectsInRange:(NSRange)range
{
    NSUInteger maxRange = NSMaxRange(range);

    if (maxRange > [self count])
    {
        [NSException raise:NSRangeException format:@"Range out of bounds of ordered set"];
        return;
    }

    if (maxRange == 0)
    {
        return;
    }

    [self _mutate];

    NSUInteger idx = range.location;

    for (NSUInteger i = 0; i < range.length; i++)
    {
        [self removeObjectAtIndex:idx];
    }
}

- (void)removeObjectsAtIndexes:(NSIndexSet *)indexes
{
    if (indexes == nil)
    {
        [NSException raise:NSInvalidArgumentException format:@"Index set cannot be nil"];
        return;
    }

    NSUInteger count = [indexes count];

    if (count > 0 && [indexes lastIndex] >= [self count])
    {
        [NSException raise:NSInvalidArgumentException format:@"Index set out of bounds of ordered set"];
        return;
    }

    if (count == 0)
    {
        return;
    }

    [self _mutate];

    [indexes enumerateRangesWithOptions:NSEnumerationReverse usingBlock:^(NSRange range, BOOL *stop) {
        [self removeObjectsInRange:range];
    }];
}

- (void)removeAllObjects
{
    NSUInteger count = [self count];

    if (count == 0)
    {
        return;
    }

    [self _mutate];

    for (NSUInteger idx = count; idx > 0; idx--)
    {
        [self removeObjectAtIndex:idx - 1];
    }
}

- (void)removeObject:(id)object
{
    NSUInteger idx = [self indexOfObject:object];

    if (idx == NSNotFound)
    {
        return;
    }

    [self _mutate];

    [self removeObjectAtIndex:idx];
}

- (void)removeObject:(id)object inRange:(NSRange)range
{
    if (NSMaxRange(range) > [self count])
    {
        [NSException raise:NSRangeException format:@"Range out of bounds of ordered set"];
        return;
    }

    NSUInteger idx = [self indexOfObject:object inRange:range];

    if (idx == NSNotFound)
    {
        return;
    }

    [self _mutate];

    [self removeObjectAtIndex:idx];
}

- (void)removeObjectsInArray:(NSArray *)array
{
    if ([array count] == 0)
    {
        return;
    }

    [self _mutate];

    for (id object in array)
    {
        NSUInteger idx = [self indexOfObject:object];
        if (idx != NSNotFound)
        {
            [self removeObjectAtIndex:idx];
        }
    }
}

- (void)removeObjectsInArray:(NSArray *)array range:(NSRange)arrayRange
{
    NSUInteger arrayCount = [array count];

    if (NSMaxRange(arrayRange) > arrayCount)
    {
        [NSException raise:NSRangeException format:@"Range out of bounds of array"];
        return;
    }

    if (arrayCount == 0)
    {
        return;
    }

    [self _mutate];

    for (NSUInteger arrayIdx = arrayRange.length; arrayIdx < NSMaxRange(arrayRange); arrayIdx++)
    {
        id obj = [array objectAtIndex:arrayIdx];
        NSUInteger idx = [self indexOfObject:obj];
        if (idx != NSNotFound)
        {
            [self removeObjectAtIndex:idx];
        }
    }
}

- (void)removeObjectsInRange:(NSRange)range inArray:(NSArray *)array
{
    if (NSMaxRange(range) > [self count])
    {
        [NSException raise:NSRangeException format:@"Range out of bounds of ordered set"];
        return;
    }

    if ([array count] == 0)
    {
        return;
    }

    [self _mutate];

    for (id object in array)
    {
        NSUInteger idx = [self indexOfObject:object inRange:range];
        if (idx != NSNotFound)
        {
            [self removeObjectAtIndex:idx];
        }
    }
}

- (void)removeObjectsInRange:(NSRange)range inArray:(NSArray *)array range:(NSRange)arrayRange
{
    if (NSMaxRange(range) > [self count])
    {
        [NSException raise:NSRangeException format:@"Range out of bounds of ordered set"];
        return;
    }

    NSUInteger arrayCount = [array count];

    if (NSMaxRange(arrayRange) > arrayCount)
    {
        [NSException raise:NSRangeException format:@"Range out of bounds of array"];
        return;
    }

    if (arrayCount == 0)
    {
        return;
    }

    [self _mutate];

    for (NSUInteger arrayIdx = arrayRange.length; arrayIdx < NSMaxRange(arrayRange); arrayIdx++)
    {
        id obj = [array objectAtIndex:arrayIdx];
        NSUInteger idx = [self indexOfObject:obj inRange:range];
        if (idx != NSNotFound)
        {
            [self removeObjectAtIndex:idx];
        }
    }
}

- (void)removeObjectsInSet:(NSSet *)set
{
    if ([set count] == 0)
    {
        return;
    }

    [self _mutate];

    for (id object in set)
    {
        NSUInteger idx = [self indexOfObject:object];
        if (idx != NSNotFound)
        {
            [self removeObjectAtIndex:idx];
        }
    }
}

- (void)removeObjectsInRange:(NSRange)range inSet:(NSSet *)set
{
    if (NSMaxRange(range) > [self count])
    {
        [NSException raise:NSRangeException format:@"Range out of bounds of ordered set"];
        return;
    }

    if (range.length == 0)
    {
        return;
    }

    for (id object in set)
    {
        NSUInteger idx = [self indexOfObject:object inRange:range];
        if (idx != NSNotFound)
        {
            [self removeObjectAtIndex:idx];
        }
    }
}

- (void)removeObjectsInOrderedSet:(NSOrderedSet *)orderedSet
{
    if ([orderedSet count] == 0)
    {
        return;
    }

    [self _mutate];

    for (id object in orderedSet)
    {
        NSUInteger idx = [self indexOfObject:object];
        if (idx != NSNotFound)
        {
            [self removeObjectAtIndex:idx];
        }
    }
}

- (void)removeObjectsInOrderedSet:(NSOrderedSet *)orderedSet range:(NSRange)orderedSetRange
{
    NSUInteger orderedSetCount = [orderedSet count];

    if (NSMaxRange(orderedSetRange) > orderedSetCount)
    {
        [NSException raise:NSRangeException format:@"Range out of bounds of ordered set"];
        return;
    }

    if (orderedSetCount == 0)
    {
        return;
    }

    [self _mutate];

    for (NSUInteger orderedSetIdx = orderedSetRange.length; orderedSetIdx < NSMaxRange(orderedSetRange); orderedSetIdx++)
    {
        id obj = [orderedSet objectAtIndex:orderedSetIdx];
        NSUInteger idx = [self indexOfObject:obj];
        if (idx != NSNotFound)
        {
            [self removeObjectAtIndex:idx];
        }
    }
}

- (void)removeObjectsInRange:(NSRange)range inOrderedSet:(NSOrderedSet *)orderedSet
{
    if (NSMaxRange(range) > [self count])
    {
        [NSException raise:NSRangeException format:@"Range out of bounds of ordered set"];
        return;
    }

    if ([orderedSet count] == 0)
    {
        return;
    }

    [self _mutate];

    for (id obj in orderedSet)
    {
        NSUInteger idx = [self indexOfObject:obj inRange:range];
        if (idx != NSNotFound)
        {
            [self removeObjectAtIndex:idx];
        }
    }
}

- (void)removeObjectsInRange:(NSRange)range inOrderedSet:(NSOrderedSet *)orderedSet range:(NSRange)orderedSetRange
{
    if (NSMaxRange(range) > [self count])
    {
        [NSException raise:NSRangeException format:@"Range out of bounds of ordered set"];
        return;
    }

    NSUInteger orderedSetCount = [orderedSet count];

    if (NSMaxRange(orderedSetRange) > orderedSetCount)
    {
        [NSException raise:NSRangeException format:@"Range out of bounds of ordered set"];
        return;
    }

    if (orderedSetCount == 0)
    {
        return;
    }

    [self _mutate];

    for (NSUInteger orderedSetIdx = orderedSetRange.length; orderedSetIdx < NSMaxRange(orderedSetRange); orderedSetIdx++)
    {
        id obj = [orderedSet objectAtIndex:orderedSetIdx];
        NSUInteger idx = [self indexOfObject:obj inRange:range];
        if (idx != NSNotFound)
        {
            [self removeObjectAtIndex:idx];
        }
    }
}

- (void)removeFirstObject
{
    if ([self count] == 0)
    {
        return;
    }

    [self removeObjectAtIndex:0];
}

- (void)removeLastObject
{
    NSUInteger count = [self count];

    if (count == 0)
    {
        return;
    }

    [self removeObjectAtIndex:count - 1];
}

- (void)removeObjectsPassingTest:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))test
{
    if (test == nil)
    {
        [NSException raise:NSInvalidArgumentException format:@"Test block cannot be nil"];
        return;
    }

    [self removeObjectsWithOptions:0 passingTest:test];
}

- (void)removeObjectsWithOptions:(NSEnumerationOptions)options passingTest:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))test
{
#warning TODO
    DEBUG_BREAK();
}

- (void)removeObjectsAtIndexes:(NSIndexSet *)indexes options:(NSEnumerationOptions)options passingTest:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))test
{
    if (test == nil)
    {
        [NSException raise:NSInvalidArgumentException format:@"Test block cannot be nil"];
        return;
    }

#warning TODO
    DEBUG_BREAK();
}

- (void)intersectOrderedSet:(NSOrderedSet *)orderedSet
{
    id *objectsToRemove = malloc([self count] * sizeof(id));
    if (objectsToRemove == NULL)
    {
        [NSException raise:NSMallocException format:@"Could not allocate buffer"];
        return;
    }

    NSUInteger removalCount = 0;

    for (id obj in self)
    {
        if (![orderedSet containsObject:obj])
        {
            objectsToRemove[removalCount++] = obj;
        }
    }

    [self _mutate];

    for (NSUInteger idx = removalCount; idx > 0; idx--)
    {
        [self removeObjectAtIndex:idx - 1];
    }

    free(objectsToRemove);
}

- (void)minusOrderedSet:(NSOrderedSet *)orderedSet
{
    [self _mutate];

    for (id obj in orderedSet)
    {
        [self removeObject:obj];
    }
}

- (void)unionOrderedSet:(NSOrderedSet *)orderedSet
{
    [self _mutate];

    for (id obj in orderedSet)
    {
        [self addObject:obj];
    }
}

- (void)intersectSet:(NSSet *)set
{
    id *objectsToRemove = malloc([self count] * sizeof(id));

    if (objectsToRemove == NULL)
    {
        [NSException raise:NSMallocException format:@"Could not allocate buffer"];
        return;
    }

    NSUInteger removalCount = 0;

    for (id obj in self)
    {
        if (![set containsObject:obj])
        {
            objectsToRemove[removalCount++] = obj;
        }
    }

    [self _mutate];

    for (NSUInteger idx = removalCount; idx > 0; idx--)
    {
        [self removeObjectAtIndex:idx - 1];
    }

    free(objectsToRemove);
}

- (void)minusSet:(NSSet *)set
{
    [self _mutate];

    for (id obj in set)
    {
        [self removeObject:obj];
    }
}

- (void)unionSet:(NSSet *)set
{
    [self _mutate];

    for (id obj in set)
    {
        [self addObject:obj];
    }
}

#if NS_BLOCKS_AVAILABLE

- (void)sortUsingComparator:(NSComparator)comparator
{
    if (comparator == nil)
    {
        [NSException raise:NSInvalidArgumentException format:@"Comparator cannot be nil"];
        return;
    }

    NSRange range = NSMakeRange(0, [self count]);
    [self sortRange:range options:0 usingComparator:comparator];
}

- (void)sortWithOptions:(NSSortOptions)options usingComparator:(NSComparator)comparator
{
    if (comparator == nil)
    {
        [NSException raise:NSInvalidArgumentException format:@"Comparator cannot be nil"];
        return;
    }

    NSRange range = NSMakeRange(0, [self count]);
    [self sortRange:range options:options usingComparator:comparator];
}

- (void)sortRange:(NSRange)range options:(NSSortOptions)options usingComparator:(NSComparator)comparator
{
    if (comparator == nil)
    {
        [NSException raise:NSInvalidArgumentException format:@"Comparator cannot be nil"];
        return;
    }

    NSUInteger count = [self count];

    if (NSMaxRange(range) > count)
    {
        [NSException raise:NSInvalidArgumentException format:@"Range out of bounds of ordered set"];
        return;
    }

    if (range.length == 0)
    {
        return;
    }

    CFIndex *indexes = malloc(range.length * sizeof(*indexes));

    if (indexes == NULL)
    {
        [NSException raise:NSMallocException format:@"Could not allocate buffer"];
        return;
    }

    id *objects = malloc(range.length * sizeof(id));

    if (objects == NULL)
    {
        free(indexes);
        [NSException raise:NSMallocException format:@"Could not allocate buffer"];
        return;
    }

    [self getObjects:objects range:range];

    CFSortIndexes(indexes, range.length, options, ^(CFIndex idx1, CFIndex idx2) {
        return (CFComparisonResult)comparator(objects[idx1], objects[idx2]);
    });
    
    assert(sizeof(id) == sizeof(CFIndex));
    
    for (int i = 0; i < count; i++)
    {
        indexes[i] = (CFIndex)objects[indexes[i]]; // re-use indexes allocation
    }
    
    [self replaceObjectsInRange:range withObjects:(id*)indexes count:range.length];

    free(indexes);
    free(objects);
}

#endif // NS_BLOCK_AVAILABLE

- (void)rollObjectsInRange:(NSRange)range by:(NSInteger)rollAmount
{
    if (NSMaxRange(range) > [self count])
    {
        [NSException raise:NSRangeException format:@"Range out of bounds of ordered set"];
        return;
    }

    if (range.length == 0)
    {
        return;
    }

    rollAmount %= range.length;

    if (rollAmount == 0)
    {
        return;
    }

    id *objects = malloc(range.length * sizeof(id));

    if (objects == NULL)
    {
        [NSException raise:NSMallocException format:@"Could not allocate buffer"];
        return;
    }

    NSRange leftRange = NSMakeRange(range.location, range.length - rollAmount);
    NSRange rightRange = NSMakeRange(NSMaxRange(leftRange), rollAmount);

    id *rightObjects = objects;
    id *leftObjects = objects + rightRange.length;

    [self getObjects:leftObjects range:leftRange];
    [self getObjects:rightObjects range:rightRange];

    [self _mutate];

    [self removeObjectsInRange:range];
    [self insertObjects:objects count:range.length atIndex:range.location];

    for (NSUInteger idx = 0; idx < range.length; idx++)
    {
        [objects[idx] release];
    }

    free(objects);
}

- (void)replaceObjectAtIndex:(NSUInteger)idx withObject:(id)object
{
    NSRequestConcreteImplementation();
}

- (void)replaceObject:(id)object
{
    if (object == nil)
    {
        [NSException raise:NSInvalidArgumentException format:@"Cannot add nil to ordered set"];
        return;
    }

    NSUInteger idx = [self indexOfObject:object];

    if (idx == NSNotFound)
    {
        return;
    }

    [self _mutate];

    [self replaceObjectAtIndex:idx withObject:object];
}

- (void)replaceObject:(id)object inRange:(NSRange)range
{
    if (object == nil)
    {
        [NSException raise:NSInvalidArgumentException format:@"Cannot add nil to ordered set"];
        return;
    }

    if (NSMaxRange(range) > [self count])
    {
        [NSException raise:NSRangeException format:@"Range out of bounds of ordered set"];
        return;
    }

    NSUInteger idx = [self indexOfObject:object inRange:range];

    if (idx == NSNotFound)
    {
        return;
    }

    [self _mutate];

    [self replaceObjectAtIndex:idx withObject:object];
}

- (void)replaceObjectsInRange:(NSRange)range withObjects:(const id [])objects count:(NSUInteger)count
{
    if (objects == NULL && count > 0)
    {
        [NSException raise:NSInvalidArgumentException format:@"Cannot insert NULL objects with nonzero count into ordered set"];
        return;
    }

    if (NSMaxRange(range) > [self count])
    {
        [NSException raise:NSRangeException format:@"Range out of bounds of ordered set"];
        return;
    }

    if (count == 0 && range.length == 0)
    {
        return;
    }

    for (NSUInteger idx = 0; idx < count; idx++)
    {
        if (objects[idx] == nil)
        {
            [NSException raise:NSInvalidArgumentException format:@"Cannot insert nil into ordered set"];
            return;
        }
    }

    for (NSUInteger idx = 0; idx < count; idx++)
    {
        [objects[idx] retain];
    }

    [self _mutate];

    [self removeObjectsInRange:range];
    [self insertObjects:objects count:count atIndex:range.location];

    for (NSUInteger idx = 0; idx < count; idx++)
    {
        [objects[idx] release];
    }
}

- (void)replaceObjectsAtIndexes:(NSIndexSet *)indexes withObjects:(NSArray *)objectArray
{
    NSUInteger indexCount = [indexes count];

    if (indexCount != [objectArray count])
    {
        [NSException raise:NSInvalidArgumentException format:@"Different numbers of indexes and objects"];
        return;
    }

    if (indexCount == 0)
    {
        return;
    }

    if ([indexes lastIndex] >= [self count])
    {
        [NSException raise:NSRangeException format:@"Range out of bounds of ordered set"];
        return;
    }

    id *objects = malloc(indexCount * sizeof(id));
    if (objects == NULL)
    {
        [NSException raise:NSMallocException format:@"Could not allocate buffer"];
        return;
    }

    [objectArray getObjects:objects range:NSMakeRange(0, indexCount)];

    for (NSUInteger idx = 0; idx < indexCount; idx++)
    {
        if (objects[idx] == nil)
        {
            free(objects);
            [NSException raise:NSInvalidArgumentException format:@"Cannot add nil to ordered set"];
            return;
        }
    }

    for (NSUInteger idx = 0; idx < indexCount; idx++)
    {
        [objects[idx] retain];
    }

    [self _mutate];

    [indexes enumerateRangesWithOptions:NSEnumerationReverse usingBlock:^(NSRange range, BOOL *stop) {
        [self removeObjectsInRange:range];
    }];

    __block id *currentObjectPtr = objects;
    [indexes enumerateRangesUsingBlock:^(NSRange range, BOOL *stop) {
        [self insertObjects:currentObjectPtr count:range.length atIndex:range.location];
        currentObjectPtr += range.length;
    }];

    for (NSUInteger idx = 0; idx < indexCount; idx++)
    {
        [objects[idx] release];
    }

    free(objects);
}

- (void)replaceObjectsInRange:(NSRange)range withObjectsFromSet:(NSSet *)set
{
    if (NSMaxRange(range) > [self count])
    {
        [NSException raise:NSRangeException format:@"Range out of bounds of ordered set"];
        return;
    }

    NSUInteger setCount = [set count];

    if (range.length == 0 && setCount == 0)
    {
        return;
    }

    id *objects = malloc(setCount * sizeof(id));
    if (objects == NULL)
    {
        [NSException raise:NSMallocException format:@"Failed to allocate buffer"];
        return;
    }

    [set getObjects:objects count:setCount];

    [self _mutate];
    [self replaceObjectsInRange:range withObjects:objects count:setCount];

    free(objects);
}

- (void)replaceObjectsInRange:(NSRange)range withObjectsFromOrderedSet:(NSOrderedSet *)orderedSet
{
    if (NSMaxRange(range) > [self count])
    {
        [NSException raise:NSRangeException format:@"Range out of bounds of ordered set"];
        return;
    }

    NSUInteger orderedSetCount = [orderedSet count];

    if (range.length == 0 && orderedSetCount == 0)
    {
        return;
    }

    id *objects = malloc(orderedSetCount * sizeof(id));
    if (objects == NULL)
    {
        [NSException raise:NSMallocException format:@"Failed to allocate buffer"];
        return;
    }

    [orderedSet getObjects:objects range:NSMakeRange(0, orderedSetCount)];

    [self _mutate];
    [self replaceObjectsInRange:range withObjects:objects count:orderedSetCount];

    free(objects);
}

- (void)replaceObjectsInRange:(NSRange)range withObjectsFromOrderedSet:(NSOrderedSet *)orderedSet range:(NSRange)newRange
{
    if (NSMaxRange(range) > [self count])
    {
        [NSException raise:NSRangeException format:@"Range out of bounds of ordered set"];
        return;
    }

    NSUInteger orderedSetCount = [orderedSet count];

    if (NSMaxRange(newRange) > orderedSetCount)
    {
        [NSException raise:NSRangeException format:@"Range out of bounds of ordered set"];
        return;
    }

    if (range.length == 0 && orderedSetCount == 0)
    {
        return;
    }

    id *objects = malloc(orderedSetCount * sizeof(id));
    if (objects == NULL)
    {
        [NSException raise:NSMallocException format:@"Failed to allocate buffer"];
        return;
    }

    [orderedSet getObjects:objects range:newRange];

    [self _mutate];
    [self replaceObjectsInRange:range withObjects:objects count:orderedSetCount];

    free(objects);
}

- (void)replaceObjectsInRange:(NSRange)range withObjectsFromArray:(NSArray *)array
{
    if (NSMaxRange(range) > [self count])
    {
        [NSException raise:NSRangeException format:@"Range out of bounds of ordered set"];
        return;
    }

    NSUInteger arrayCount = [array count];

    if (range.length == 0 && arrayCount == 0)
    {
        return;
    }

    id *objects = malloc(arrayCount * sizeof(id));
    if (objects == NULL)
    {
        [NSException raise:NSMallocException format:@"Failed to allocate buffer"];
        return;
    }

    [array getObjects:objects range:NSMakeRange(0, arrayCount)];

    [self _mutate];
    [self replaceObjectsInRange:range withObjects:objects count:arrayCount];

    free(objects);
}

- (void)replaceObjectsInRange:(NSRange)range withObjectsFromArray:(NSArray *)array range:(NSRange)newRange
{
    if (NSMaxRange(range) > [self count])
    {
        [NSException raise:NSRangeException format:@"Range out of bounds of ordered set"];
        return;
    }

    NSUInteger arrayCount = [array count];

    if (NSMaxRange(newRange) > arrayCount)
    {
        [NSException raise:NSRangeException format:@"Range out of bounds of array"];
        return;
    }

    if (range.length == 0 && arrayCount == 0)
    {
        return;
    }

    id *objects = malloc(arrayCount * sizeof(id));
    if (objects == NULL)
    {
        [NSException raise:NSMallocException format:@"Failed to allocate buffer"];
        return;
    }

    [array getObjects:objects range:newRange];

    [self _mutate];
    [self replaceObjectsInRange:range withObjects:objects count:arrayCount];

    free(objects);
}

- (void)insertObject:(id)object atIndex:(NSUInteger)idx
{
    NSRequestConcreteImplementation();
}

- (void)insertObjects:(NSArray *)array atIndexes:(NSIndexSet *)indexes
{
    if (indexes == nil)
    {
        [NSException raise:NSInvalidArgumentException format:@"Index set cannot be nil"];
        return;
    }

    NSUInteger indexCount = [indexes count];
    NSUInteger arrayCount = [array count];

    if (indexCount > 0 && [indexes lastIndex] >= ([self count] + indexCount))
    {
        [NSException raise:NSInvalidArgumentException format:@"Index set out of bounds of ordered set"];
        return;
    }

    if (indexCount != arrayCount)
    {
        [NSException raise:NSInvalidArgumentException format:@"Differing numbers of indexes and array elements"];
        return;
    }

    if (arrayCount == 0)
    {
        return;
    }

    id *objects = malloc(arrayCount * sizeof(id));

    if (objects == NULL)
    {
        [NSException raise:NSMallocException format:@"Failed to allocate buffer"];
        return;
    }

    NSRange range = NSMakeRange(0, arrayCount);
    [array getObjects:objects range:range];

    [self _mutate];

    __block id *currentObjectPtr = objects;
    [indexes enumerateRangesUsingBlock:^(NSRange range, BOOL *stop) {
        [self insertObjects:currentObjectPtr count:range.length atIndex:range.location];
        currentObjectPtr += range.length;
    }];
    
    free(objects);
}

- (void)insertObjectsFromSet:(NSSet *)set atIndex:(NSUInteger)idx
{
    if (idx > [self count])
    {
        [NSException raise:NSInvalidArgumentException format:@"Index out of bounds of ordered set"];
        return;
    }

    NSUInteger count = [set count];

    if (count == 0)
    {
        return;
    }

    id *objects = malloc(count * sizeof(id));

    if (objects == NULL)
    {
        [NSException raise:NSMallocException format:@"Failed to allocate buffer"];
        return;
    }

    [set getObjects:objects count:count];

    [self _mutate];
    [self insertObjects:objects count:count atIndex:idx];

    free(objects);
}

- (void)insertObjectsFromOrderedSet:(NSOrderedSet *)orderedSet atIndex:(NSUInteger)idx
{
    if (idx > [self count])
    {
        [NSException raise:NSInvalidArgumentException format:@"Index out of bounds of ordered set"];
        return;
    }

    NSUInteger count = [orderedSet count];

    if (count == 0)
    {
        return;
    }

    id *objects = malloc(count * sizeof(id));

    if (objects == NULL)
    {
        [NSException raise:NSMallocException format:@"Failed to allocate buffer"];
        return;
    }

    NSRange range = NSMakeRange(0, count);
    [orderedSet getObjects:objects range:range];

    [self _mutate];
    [self insertObjects:objects count:count atIndex:idx];

    free(objects);
}

- (void)insertObjectsFromOrderedSet:(NSOrderedSet *)orderedSet range:(NSRange)range atIndex:(NSUInteger)idx
{
    if (idx > [self count])
    {
        [NSException raise:NSInvalidArgumentException format:@"Index out of bounds of ordered set"];
        return;
    }

    NSUInteger count = [orderedSet count];

    if (count == 0)
    {
        return;
    }

    id *objects = malloc(count * sizeof(id));

    if (objects == NULL)
    {
        [NSException raise:NSMallocException format:@"Failed to allocate buffer"];
        return;
    }

    [orderedSet getObjects:objects range:range];

    [self _mutate];
    [self insertObjects:objects count:count atIndex:idx];

    free(objects);
}

- (void)insertObjectsFromArray:(NSArray *)array atIndex:(NSUInteger)idx
{
    if (idx > [self count])
    {
        [NSException raise:NSInvalidArgumentException format:@"Index out of bounds of ordered set"];
        return;
    }

    NSUInteger count = [array count];

    if (count == 0)
    {
        return;
    }

    id *objects = malloc(count * sizeof(id));

    if (objects == NULL)
    {
        [NSException raise:NSMallocException format:@"Failed to allocate buffer"];
        return;
    }

    NSRange range = NSMakeRange(0, count);
    [array getObjects:objects range:range];

    [self _mutate];
    [self insertObjects:objects count:count atIndex:idx];

    free(objects);
}

- (void)insertObjectsFromArray:(NSArray *)array range:(NSRange)range atIndex:(NSUInteger)idx
{
    if (idx > [self count])
    {
        [NSException raise:NSInvalidArgumentException format:@"Index out of bounds of ordered set"];
        return;
    }

    NSUInteger count = [array count];

    if (count == 0)
    {
        return;
    }

    id *objects = malloc(count * sizeof(id));

    if (objects == NULL)
    {
        [NSException raise:NSMallocException format:@"Failed to allocate buffer"];
        return;
    }

    [array getObjects:objects range:range];

    [self _mutate];
    [self insertObjects:objects count:count atIndex:idx];

    free(objects);
}

- (void)insertObjects:(const id *)objects count:(NSUInteger)count atIndex:(NSUInteger)idx
{
    if (objects == NULL && count > 0)
    {
        [NSException raise:NSInvalidArgumentException format:@"Cannot insert NULL objects with nonzero count into ordered set"];
        return;
    }

    if (idx > [self count])
    {
        [NSException raise:NSInvalidArgumentException format:@"Index out of bounds of ordered set"];
        return;
    }

    if (count == 0)
    {
        return;
    }

    [self _mutate];
    NSUInteger countBeforeLoop = [self count];
    for (NSUInteger objIdx = 0; objIdx < count; objIdx++)
    {
        id obj = objects[objIdx];
        if (obj == nil)
        {
            [NSException raise:NSInvalidArgumentException format:@"Cannot insert nil into ordered set"];
            return;
        }
        NSUInteger index = idx + [self count] - countBeforeLoop;
        [self insertObject:obj atIndex:index];
    }
}

- (void)_mutate
{
}

@end

@implementation __NSPlaceholderOrderedSet

static __NSPlaceholderOrderedSet *immutablePlaceholder = nil;
static __NSPlaceholderOrderedSet *mutablePlaceholder = nil;

+ (id)immutablePlaceholder
{
    static dispatch_once_t once = 0L;
    dispatch_once(&once, ^{
        immutablePlaceholder = [__NSPlaceholderOrderedSet allocWithZone:nil];
    });
    return immutablePlaceholder;
}

+ (id)mutablePlaceholder
{
    static dispatch_once_t once = 0L;
    dispatch_once(&once, ^{
        mutablePlaceholder = [__NSPlaceholderOrderedSet allocWithZone:nil];
    });
    return mutablePlaceholder;
}

- (id)init
{
    if (self == immutablePlaceholder)
    {
        return [self initWithObjects:NULL count:0];
    }
    else if (self == mutablePlaceholder)
    {
        return [self initWithCapacity:0];
    }
    else
    {
        DEBUG_BREAK();
        return nil;
    }
}

- (id)initWithCapacity:(NSUInteger)capacity
{
    if (self != mutablePlaceholder)
    {
        DEBUG_BREAK();
        return nil;
    }

    NSCapacityCheck(capacity, 0x40000000, @"Please rethink the size of the capacity of the ordered set you are creating: %d seems a bit excessive", capacity);
    return (__NSPlaceholderOrderedSet *)[__NSOrderedSetM __new:NULL :capacity :NO];
}

- (id)initWithObjects:(const id *)objects count:(NSUInteger)count
{
    if (self != immutablePlaceholder && self != mutablePlaceholder)
    {
        [self release];
        [NSException raise:NSInvalidArgumentException format:@"Cannot reinit ordered set"];
        return nil;
    }

    if (objects == NULL && count > 0)
    {
        [self release];
        [NSException raise:NSInvalidArgumentException format:@"Cannot init ordered set with NULL objects and nonzero count"];
        return nil;
    }

    for (NSUInteger idx = 0; idx < count; idx++)
    {
        id obj = objects[idx];
        if (obj == nil)
        {
            [self release];
            [NSException raise:NSInvalidArgumentException format:@"Cannot init ordered set with nil object"];
            return nil;
        }
        [obj retain];
    }

    if (self == immutablePlaceholder)
    {
        if (count == 0)
        {
            static __NSOrderedSetI *__NSOrderedSetI0 = nil;
            static dispatch_once_t once = 0L;
            dispatch_once(&once, ^{
                __NSOrderedSetI0 = [__NSOrderedSetI __new:NULL :0 :NO];
            });
            return (__NSPlaceholderOrderedSet *)[__NSOrderedSetI0 retain];
        }
        else
        {
            return (__NSPlaceholderOrderedSet *)[__NSOrderedSetI __new:objects :count :NO];
        }
    }
    else
    {
        return (__NSPlaceholderOrderedSet *)[__NSOrderedSetM __new:objects :count :NO];
    }
}

SINGLETON_RR()

- (void)replaceObjectAtIndex:(NSUInteger)idx withObject:(id)object
{
    [NSException raise:NSInvalidArgumentException format:@"Message sent to uninitialized ordered set"];
    return;
}

- (void)removeObjectAtIndex:(NSUInteger)idx
{
    [NSException raise:NSInvalidArgumentException format:@"Message sent to uninitialized ordered set"];
    return;
}

- (void)insertObject:(id)object atIndex:(NSUInteger)idx
{
    [NSException raise:NSInvalidArgumentException format:@"Message sent to uninitialized ordered set"];
    return;
}

- (id)objectAtIndex:(NSUInteger)idx
{
    [NSException raise:NSInvalidArgumentException format:@"Message sent to uninitialized ordered set"];
    return nil;
}

- (NSUInteger)indexOfObject:(id)object
{
    [NSException raise:NSInvalidArgumentException format:@"Message sent to uninitialized ordered set"];
    return 0;
}

- (NSUInteger)count
{
    [NSException raise:NSInvalidArgumentException format:@"Message sent to uninitialized ordered set"];
    return 0;
}

@end

@implementation __NSOrderedSetI
{
    unsigned int _used:26;
    unsigned int _szidx:6;
}

// Use the same capacities and sizes as CFBasicHash.c


+ (id)allocWithZone:(NSZone *)zone
{
    return (__NSOrderedSetI *)[__NSPlaceholderOrderedSet allocWithZone:zone];
}

+ (id)__new:(const id *)objects :(NSUInteger)count :(BOOL)tbd
{
    NSUInteger sizeIdx = 0;
    NSUInteger primeSize = 0;

    id *uniqueObjects = NSBasicHashAllocate(count, 2 * sizeof(id), &primeSize, &sizeIdx, NO);

    if (uniqueObjects == NULL)
    {
        [NSException raise:NSMallocException format:@"Failed to allocate buffer"];
        return nil;
    }

    NSUInteger *uniqueIndexes = (NSUInteger *)uniqueObjects + primeSize;

    NSUInteger uniqueCount = 0;

    for (NSUInteger idx = 0; idx < count; idx++)
    {
        id obj = objects[idx];
        NSUInteger hash = [obj hash];
        NSUInteger bucket = hash % primeSize;

        if (uniqueIndexes[bucket] == 0)
        {
            uniqueIndexes[bucket] = idx + 1;
            uniqueObjects[uniqueCount++] = obj;
            continue;
        }

        BOOL unique = YES;
        for (NSUInteger uniqueIdx = 0; uniqueIdx < uniqueCount; uniqueIdx++)
        {
            id uniqueObj = uniqueObjects[uniqueIdx];

            if (uniqueObj == nil)
            {
                continue;
            }

            if (obj == uniqueObj || (hash == [uniqueObj hash] && [obj isEqual:uniqueObj]))
            {
                unique = NO;
                break;
            }
        }

        if (unique)
        {
            uniqueObjects[uniqueCount++] = obj;
        }
    }

    size_t extraBytes = uniqueCount * sizeof(id) + primeSize * sizeof(NSUInteger);
    __NSOrderedSetI *orderedSet = ___CFAllocateObject2(self, extraBytes);

    id *indexedIvarObjects = object_getIndexedIvars(orderedSet);
    memmove(indexedIvarObjects, uniqueObjects, uniqueCount * sizeof(id));

    NSUInteger *indexedIvarIndexes = (NSUInteger *)indexedIvarObjects + uniqueCount;
    memmove(indexedIvarIndexes, uniqueIndexes, primeSize * sizeof(NSUInteger));

    orderedSet->_used = uniqueCount;
    orderedSet->_szidx = sizeIdx;

    NSBasicHashDeallocate(uniqueObjects);

    return orderedSet;
}

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key
{
    return NO;
}

- (void)dealloc
{
    if (self == (__NSOrderedSetI *)immutablePlaceholder)
    {
        DEBUG_BREAK();
        [super dealloc];
    }

    id *objects = object_getIndexedIvars(self);

    NSUInteger count = [self count];

    for (NSUInteger idx = 0; idx < count; idx++)
    {
        CFRelease(objects[idx]);
    }

    [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone
{
    return [self retain];
}

- (void)enumerateObjectsWithOptions:(NSEnumerationOptions)options usingBlock:(void (^)(id obj, NSUInteger idx, BOOL *stop))block
{
    if (block == nil)
    {
        [NSException raise:NSInvalidArgumentException format:@"Block must not be nil"];
        return;
    }

    NSUInteger count = [self count];
    id *objects = object_getIndexedIvars(self);

    if ((options & NSEnumerationConcurrent) != 0)
    {
        __block BOOL stop = NO;

        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

        void (^dispatchBlock)(size_t);

        if ((options & NSEnumerationReverse) != 0)
        {
            dispatchBlock = ^(size_t iter) {
                if (!stop)
                {
                    NSUInteger idx = count - iter - 1;
                    id obj = objects[idx];
                    block(obj, idx, &stop);
                }
            };
        }
        else
        {
            dispatchBlock = ^(size_t idx) {
                if (!stop)
                {
                    id obj = objects[idx];
                    block(obj, idx, &stop);
                }
            };
        }

        dispatch_apply(count, queue, dispatchBlock);
    }
    else
    {
        BOOL stop = NO;
        if ((options & NSEnumerationReverse) != 0)
        {
            for (NSUInteger idx = count; idx > 0; idx--)
            {
                if (stop)
                {
                    return;
                }
                block(objects[idx - 1], idx - 1, &stop);
            }
        }
        else
        {
            for (NSUInteger idx = 0; idx < count; idx++)
            {
                if (stop)
                {
                    return;
                }
                block(objects[idx], idx, &stop);
            }
        }
    }
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)objects count:(NSUInteger)count
{
    if (objects == NULL && count != 0)
    {
        [NSException raise:NSInvalidArgumentException format:@"Cannot enumerate into NULL buffer of nonzero length"];
        return 0;
    }
    
    if (state->state != 0)
    {
        return 0;
    }
    
    static const unsigned long const_mu = 1;
    state->mutationsPtr = (unsigned long *)&const_mu;
    state->state = -1;
    state->itemsPtr = object_getIndexedIvars(self);

    return _used;
}

- (void)getObjects:(id *)objects range:(NSRange)range
{
    if (objects == NULL && range.length > 0)
    {
        [NSException raise:NSInvalidArgumentException format:@"Cannot place objects into NULL array"];
        return;
    }

    if (NSMaxRange(range) > [self count])
    {
        [NSException raise:NSRangeException format:@"Range exceeds bounds of ordered set"];
        return;
    }

    id *currentObjects = object_getIndexedIvars(self);
    memmove(objects, currentObjects + range.location, range.length * sizeof(id));
}

- (id)objectAtIndex:(NSUInteger)idx
{
    if (idx >= [self count])
    {
        [NSException raise:NSRangeException format:@"Index out of bounds of ordered set"];
        return nil;
    }

    id *objects = object_getIndexedIvars(self);
    return objects[idx];
}

- (NSUInteger)indexOfObject:(id)object
{
    if (object == nil)
    {
        return NSNotFound;
    }

    NSUInteger count = [self count];

    id *objects = object_getIndexedIvars(self);
    NSUInteger *indexes = (NSUInteger *)objects + count;
    NSUInteger hash = [object hash];
    NSUInteger bucket = hash % __NSBasicHashIPrimes[_szidx];

    NSUInteger possibleIdx = indexes[bucket];

    if (possibleIdx == 0)
    {
        return NSNotFound;
    }

    id possibleObject = objects[possibleIdx - 1];

    if (possibleObject == object || ([possibleObject hash] == hash && [possibleObject isEqual:object]))
    {
        return possibleIdx - 1;
    }

    NSUInteger foundIdx = NSNotFound;

    for (NSUInteger idx = 0; idx < count; idx++)
    {
        id obj = objects[idx];
        
        if (obj == nil)
        {
            continue;
        }

        if (obj == object || ([obj hash] == hash && [obj isEqual:object]))
        {
            foundIdx = idx;
            break;
        }
    }

    return foundIdx;
}

- (NSUInteger)count
{
    return _used;
}

@end

@implementation __NSOrderedSetM
{
    NSUInteger _used;
    CFBasicHashRef _set;
    NSMutableArray *_array;
}

static Boolean __NSOrderedSetMEquateKeys(uintptr_t coll_key1, uintptr_t stack_key2)
{
    if (coll_key1 == stack_key2)
    {
        return true;
    }
    return [(id)coll_key1 isEqual:(id)stack_key2] != NO;
}

static CFHashCode __NSOrderedSetMHashKey(uintptr_t stack_key)
{
    return [(id)stack_key hash];
}

static uintptr_t __NSOrderedSetMRetainValue(CFAllocatorRef allocator, uintptr_t stack_value)
{
    return stack_value;
}

static void __NSOrderedSetMReleaseValue(CFAllocatorRef allocator, uintptr_t stack_value)
{
}

static uintptr_t __NSOrderedSetMGetIndirectKey(uintptr_t coll_value)
{
    return coll_value;
}

static CFBasicHashCallbacks __NSOrderedSetMCallbacks = {
    .equateKeys = &__NSOrderedSetMEquateKeys,
    .hashKey = &__NSOrderedSetMHashKey,
    .retainValue = &__NSOrderedSetMRetainValue,
    .releaseValue = &__NSOrderedSetMReleaseValue,
    .getIndirectKey = &__NSOrderedSetMGetIndirectKey,
};

+ (id)__new:(const id *)addr :(NSUInteger)count :(BOOL)cfRelease
{
    __NSOrderedSetM *orderedSet = ___CFAllocateObject2(self, 0);

    CFOptionFlags flags = kCFBasicHashIndirectKeys | kCFBasicHashExponentialHashing;
    orderedSet->_set = CFBasicHashCreate(kCFAllocatorDefault, flags, &__NSOrderedSetMCallbacks);
    orderedSet->_array = [[NSMutableArray alloc] initWithCapacity:count];
    orderedSet->_used = 0;

    if (addr == NULL || count == 0)
    {
        return orderedSet;
    }

    for (NSUInteger idx = 0; idx < count; idx++)
    {
        const id object = addr[idx];
        CFBasicHashBucket bucket = CFBasicHashFindBucket(orderedSet->_set, (uintptr_t)object);
        if (bucket.count != 0)
        {
            continue;
        }

        orderedSet->_used++;

        CFBasicHashAddValue(orderedSet->_set, (uintptr_t)object, (uintptr_t)object);

        [orderedSet->_array _mutate];
        [orderedSet->_array addObject:object];

        if (cfRelease)
        {
            CFRelease(object);
        }
    }

    return orderedSet;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return (__NSOrderedSetM *)[__NSPlaceholderOrderedSet allocWithZone:zone];
}

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key
{
    return NO;
}

- (void)dealloc
{
    if (self == (__NSOrderedSetM *)mutablePlaceholder)
    {
        DEBUG_BREAK();
        [super dealloc];
    }

    if (_set != NULL)
    {
        CFRelease(_set);
    }
    if (_array != nil)
    {
        [_array release];
    }

    [super dealloc];
}

- (void)setObject:(id)object atIndex:(NSUInteger)idx
{
    if (object == nil)
    {
        [NSException raise:NSInvalidArgumentException format:@"Cannot set to nil object in ordered set"];
        return;
    }

    if (idx > _used)
    {
        [NSException raise:NSRangeException format:@"Index out of range of ordered set"];
        return;
    }

    CFBasicHashBucket bucket = CFBasicHashFindBucket(_set, (uintptr_t)object);
    if (bucket.count != 0)
    {
        return;
    }

    if (idx == _used)
    {
        _used++;

        CFBasicHashAddValue(_set, (uintptr_t)object, (uintptr_t)object);

        [_array _mutate];
        [_array insertObject:object atIndex:idx];
    }
    else
    {
        id currentObject = [_array objectAtIndex:idx];
        CFBasicHashRemoveValue(_set, (uintptr_t)currentObject);
        CFBasicHashAddValue(_set, (uintptr_t)object, (uintptr_t)object);

        [_array _mutate];
        [_array replaceObjectAtIndex:idx withObject:object];
    }
}

- (void)replaceObjectAtIndex:(NSUInteger)idx withObject:(id)object
{
    if (object == nil)
    {
        [NSException raise:NSInvalidArgumentException format:@"Cannot add nil object to ordered set"];
        return;
    }

    if (idx >= _used)
    {
        [NSException raise:NSRangeException format:@"Index out of range of ordered set"];
        return;
    }

    CFBasicHashBucket bucket = CFBasicHashFindBucket(_set, (uintptr_t)object);
    if (bucket.count != 0)
    {
        return;
    }

    id currentObject = [_array objectAtIndex:idx];
    CFBasicHashRemoveValue(_set, (uintptr_t)currentObject);
    CFBasicHashAddValue(_set, (uintptr_t)object, (uintptr_t)object);

    [_array _mutate];
    [_array replaceObjectAtIndex:idx withObject:object];
}

- (void)removeObjectAtIndex:(NSUInteger)idx
{
    if (idx >= _used)
    {
        [NSException raise:NSRangeException format:@"Index out of range of ordered set"];
        return;
    }

    id object = [_array objectAtIndex:idx];

    _used--;

    CFBasicHashRemoveValue(_set, (uintptr_t)object);

    [_array _mutate];
    [_array removeObjectAtIndex:idx];
}

- (void)insertObject:(id)object atIndex:(NSUInteger)idx
{
    if (object == nil)
    {
        [NSException raise:NSInvalidArgumentException format:@"Cannot add nil object to ordered set"];
        return;
    }

    if (idx > _used)
    {
        [NSException raise:NSRangeException format:@"Index out of range of ordered set"];
        return;
    }

    CFBasicHashBucket bucket = CFBasicHashFindBucket(_set, (uintptr_t)object);
    if (bucket.count != 0)
    {
        return;
    }

    _used++;

    CFBasicHashAddValue(_set, (uintptr_t)object, (uintptr_t)object);

    [_array _mutate];
    [_array insertObject:object atIndex:idx];
}

- (void)_mutate
{
    [_array _mutate];
}

- (void)enumerateObjectsWithOptions:(NSEnumerationOptions)options usingBlock:(void (^)(id obj, NSUInteger idx, BOOL *stop))block
{
    if (block == nil)
    {
        [NSException raise:NSInvalidArgumentException format:@"Block must not be nil"];
        return;
    }

    [_array enumerateObjectsWithOptions:options usingBlock:block];
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)objects count:(NSUInteger)count
{
    if (objects == NULL && count != 0)
    {
        [NSException raise:NSInvalidArgumentException format:@"Cannot enumerate NULL objects with non-zero count"];
        return 0;
    }

    return [_array countByEnumeratingWithState:state objects:objects count:count];
}

- (void)getObjects:(id *)objects range:(NSRange)range
{
    if (objects == NULL && range.length != 0)
    {
        [NSException raise:NSRangeException format:@"Cannot place objects into NULL array with non-zero length"];
        return;
    }

    if (NSMaxRange(range) > _used)
    {
        [NSException raise:NSRangeException format:@"Range out of bounds of ordered set"];
        return;
    }

    [_array getObjects:objects range:range];
}

- (id)objectAtIndex:(NSUInteger)idx
{
    if (idx >= _used)
    {
        [NSException raise:NSRangeException format:@"Index out of range"];
        return nil;
    }

    return [_array objectAtIndex:idx];
}

- (NSUInteger)indexOfObject:(id)object
{
    if (object == nil)
    {
        return NSNotFound;
    }

    CFBasicHashBucket bucket = CFBasicHashFindBucket(_set, (uintptr_t)object);
    if (bucket.count == 0)
    {
        return NSNotFound;
    }

    return [_array indexOfObjectIdenticalTo:object];
}

- (NSUInteger)count
{
    return _used;
}

@end

@implementation __NSOrderedSetArrayProxy
{
    NSOrderedSet *_orderedSet;
}

- (id)initWithOrderedSet:(NSOrderedSet *)orderedSet
{
    self = [super init];
    if (self != nil)
    {
        _orderedSet = [orderedSet retain];
    }
    return self;
}

- (void)dealloc
{
    [_orderedSet release];
    [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone
{
    return [[NSArray alloc] initWithArray:self];
}

- (id)objectAtIndex:(NSUInteger)idx
{
    return [_orderedSet objectAtIndex:idx];
}

- (NSUInteger)count
{
    return [_orderedSet count];
}

@end

@implementation __NSOrderedSetSetProxy
{
    NSOrderedSet *_orderedSet;
}

- (id)initWithOrderedSet:(NSOrderedSet *)orderedSet
{
    self = [super init];
    if (self != nil)
    {
        _orderedSet = [orderedSet retain];
    }
    return self;
}

- (void)dealloc
{
    [_orderedSet release];
    [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone
{
    return [[NSSet alloc] initWithSet:self];
}

- (id)objectEnumerator
{
    return [_orderedSet objectEnumerator];
}

- (id)member:(id)object
{
    NSUInteger idx = [_orderedSet indexOfObject:object];

    if (idx == NSNotFound)
    {
        return nil;
    }

    return [_orderedSet objectAtIndex:idx];
}

- (NSUInteger)count
{
    return [_orderedSet count];
}

@end

@implementation __NSOrderedSetReversed
{
    NSOrderedSet *_orderedSet;
    NSUInteger _cnt;
}

- (id)initWithOrderedSet:(NSOrderedSet *)orderedSet
{
    self = [super init];
    if (self != nil)
    {
        _orderedSet = [orderedSet copy];
        _cnt = [_orderedSet count];
    }
    return self;
}

- (void)dealloc
{
    [_orderedSet release];
    [super dealloc];
}

- (id)objectAtIndex:(NSUInteger)idx
{
    NSUInteger reversedIdx = _cnt - idx - 1;
    return [_orderedSet objectAtIndex:reversedIdx];
}

- (NSUInteger)indexOfObject:(id)object
{
    NSUInteger idx = [_orderedSet indexOfObject:object];
    if (idx == NSNotFound)
    {
        return NSNotFound;
    }
    return _cnt - idx - 1;
}

- (NSUInteger)count
{
    return _cnt;
}

@end

@implementation __NSOrderedSetReverseEnumerator
{
    NSOrderedSet *_obj;
    NSUInteger _idx;
}

- (id)initWithObject:(id)object
{
    _obj = [object retain];
    _idx = [_obj count];
    return nil;
}

- (void)dealloc
{
    if (_obj != nil)
    {
        [_obj release];
    }
    [super dealloc];
}

- (id)nextObject
{
    if (_obj == nil)
    {
        return nil;
    }

    if (_idx == 0)
    {
        [_obj release];
        _obj = nil;
    }

    _idx--;

    return [_obj objectAtIndex:_idx];
}

@end
