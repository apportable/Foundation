//
//  NSSortDescriptor.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/NSSortDescriptor.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSException.h>
#import <Foundation/NSKeyValueCoding.h>
#import <Foundation/NSSet.h>
#import <objc/runtime.h>
#import <stdlib.h>

@interface NSSet (Internal)
- (void)getObjects:(id *)objects count:(NSUInteger)count;
@end

CF_EXPORT void CFMergeSortArray(void *list, CFIndex count, CFIndex elementSize, CFComparatorFunction comparator, void *context);

enum {
    NSSortDescriptorDescending = 0x0,
    NSSortDescriptorAscending = 0x1,
    NSSortDescriptorComparator = 0x2,
};

@implementation NSSortDescriptor {
    NSUInteger _sortDescriptorFlags;
    NSString *_key;
    SEL _selector;
    id _selectorOrBlock;
}

+ (id)sortDescriptorWithKey:(NSString *)key ascending:(BOOL)ascending
{
    return [[[self alloc] initWithKey:key ascending:ascending] autorelease];
}

+ (id)sortDescriptorWithKey:(NSString *)key ascending:(BOOL)ascending selector:(SEL)selector
{
    return [[[self alloc] initWithKey:key ascending:ascending selector:selector] autorelease];
}

+ (id)sortDescriptorWithKey:(NSString *)key ascending:(BOOL)ascending comparator:(NSComparator)comparator
{
    return [[[self alloc] initWithKey:key ascending:ascending comparator:comparator] autorelease];
}

- (id)initWithKey:(NSString *)key ascending:(BOOL)ascending
{
    return [self initWithKey:key ascending:ascending selector:NULL];
}

/*!
 Replicated behavior:
 @note  When key is nil, it will specify that it should compare the objects and not the keys
 @note  If selector is NULL, it will fall back to @selector(compare:)
 */
- (id)initWithKey:(NSString *)key ascending:(BOOL)ascending selector:(SEL)selector
{
    // key = nil is "valid"...?
    self = [super init];
    if (self)
    {
        _key = [key copy];
        if (selector == NULL)
        {
            _selector = @selector(compare:);
        }
        else
        {
            _selector = selector;
        }
        _sortDescriptorFlags = ascending ? NSSortDescriptorAscending : NSSortDescriptorDescending;
    }
    return self;
}

/*!
 Replicated behavior:
 @note  When key is nil, it will specify that it should compare the objects and not the keys
 @bug   If comparator is nil, it will cause crashes
 */
- (id)initWithKey:(NSString *)key ascending:(BOOL)ascending comparator:(NSComparator)comparator
{
    self = [super init];
    if (self)
    {
        _key = [key copy];
        _selector = NULL;
        _selectorOrBlock = [comparator copy];
        _sortDescriptorFlags = (ascending ? NSSortDescriptorAscending : NSSortDescriptorDescending) | NSSortDescriptorComparator;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
#warning TODO https://code.google.com/p/apportable/issues/detail?id=254
    [self release];
    return nil;
}

- (void)dealloc
{
    if ((_sortDescriptorFlags & NSSortDescriptorComparator)!= 0)
    {
        Block_release(_selectorOrBlock);
    }
    [_key release];
    [super dealloc];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
#warning TODO https://code.google.com/p/apportable/issues/detail?id=254
}

- (id)copyWithZone:(NSZone *)zone
{
    return [self retain];
}

- (NSString *)key
{
    return _key;
}

- (BOOL)ascending
{
    return (_sortDescriptorFlags & NSSortDescriptorAscending) != 0;
}

- (SEL)selector
{
    return _selector;
}

- (NSComparator)comparator
{
    return _selectorOrBlock;
}

/*!
 Replicated behavior:
 @note  The comparator and selector are invoked wiht obj1, obj2 (in that order
        no matter the ascending/descending state of the sort descriptor.
 */
- (NSComparisonResult)compareObject:(id)obj1 toObject:(id)obj2
{
    SEL selector = [self selector];
    NSComparisonResult result = NSOrderedSame;
    id val1 = obj1;
    if (_key != nil)
    {
        val1 = [obj1 valueForKeyPath:_key];
    }

    id val2 = obj2;
    if (_key != nil)
    {
        val2 = [obj2 valueForKeyPath:_key];
    }

    BOOL ascending = [self ascending];
    if (val1 == val2) // if it is the same pointer return early
    {
        return NSOrderedSame;
    }
    if (val2 == nil)
    {
        return ascending ? NSOrderedDescending : NSOrderedAscending;
    }
    if (val1 == nil)
    {
        return ascending ? NSOrderedAscending : NSOrderedDescending;
    }

    if (selector == NULL)
    {
        NSComparator comp = [self comparator];
        result = comp(val1, val2);
    }
    else
    {
        Class cls = object_getClass(val1);
        NSComparisonResult (*imp)(id, SEL, id) = (NSComparisonResult (*)(id, SEL, id))class_getMethodImplementation(cls, selector);
        result = imp(val1, selector, val2);
    }
    if (!ascending)
    {
        switch (result)
        {
            case NSOrderedDescending:
                return NSOrderedAscending;
            case NSOrderedSame:
                return NSOrderedSame;
            case NSOrderedAscending:
                return NSOrderedDescending;
        }
    }
    else
    {
        return result;
    }
}

- (id)reversedSortDescriptor
{
    BOOL ascending = [self ascending];
    SEL selector = [self selector];
    if (selector)
    {
        return [[[NSSortDescriptor alloc] initWithKey:_key ascending:!ascending selector:selector] autorelease];
    }
    else
    {
        return [[[NSSortDescriptor alloc] initWithKey:_key ascending:!ascending comparator:[self comparator]] autorelease];
    }
}

@end

static NSComparisonResult NSSortDescriptorSortComparator(id *obj1, id *obj2, NSArray *descriptors)
{
    NSComparisonResult result = NSOrderedSame;
    for (NSSortDescriptor *desc in descriptors)
    {
        result = [desc compareObject:*obj1 toObject:*obj2];
        if (result != NSOrderedSame)
        {
            break;
        }
    }
    return result;
}

@implementation NSSet (NSSortDescriptorSorting)

- (NSArray *)sortedArrayUsingDescriptors:(NSArray *)sortDescriptors
{
    NSUInteger count = [self count];
    if (count == 0)
    {
        return @[];
    }

    id *objects = malloc(count * sizeof(id));
    if (objects == NULL)
    {
        [NSException raise:NSMallocException format:@"Unable to allocate buffer for sorting"];
        return nil;
    }

    [self getObjects:objects count:count];

    CFMergeSortArray(objects, count, sizeof(id), (CFComparatorFunction)&NSSortDescriptorSortComparator, sortDescriptors);
    NSArray *sorted = [[NSArray alloc] initWithObjects:objects count:count];
    free(objects);
    return [sorted autorelease];
}

@end

@implementation NSArray (NSSortDescriptorSorting)

- (NSArray *)sortedArrayUsingDescriptors:(NSArray *)sortDescriptors
{
    NSUInteger count = [self count];
    if (count == 0)
    {
        return @[];
    }

    id *objects = malloc(count * sizeof(id));
    if (objects == NULL)
    {
        [NSException raise:NSMallocException format:@"Unable to allocate buffer for sorting"];
        return nil;
    }
    [self getObjects:objects range:NSMakeRange(0, count)];

    CFMergeSortArray(objects, count, sizeof(id), (CFComparatorFunction)&NSSortDescriptorSortComparator, sortDescriptors);
    NSArray *sorted = [[NSArray alloc] initWithObjects:objects count:count];
    free(objects);
    return [sorted autorelease];
}

@end

@implementation NSMutableArray (NSSortDescriptorSorting)

- (void)sortUsingDescriptors:(NSArray *)sortDescriptors
{
    NSUInteger count = [self count];
    if (count == 0)
    {
        return;
    }

    id *objects = malloc(count * sizeof(id));
    if (objects == NULL)
    {
        [NSException raise:NSMallocException format:@"Unable to allocate buffer for sorting"];
        return;
    }
    
    [self getObjects:objects range:NSMakeRange(0, count)];

    CFMergeSortArray(objects, count, sizeof(id), (CFComparatorFunction)&NSSortDescriptorSortComparator, sortDescriptors);
    NSArray *sorted = [[NSArray alloc] initWithObjects:objects count:count];
    free(objects);
    [self setArray:sorted];
    [sorted release];
}

@end
