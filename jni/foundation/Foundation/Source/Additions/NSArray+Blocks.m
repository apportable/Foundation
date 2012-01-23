//
//  NSArray+Blocks.m
//  
//
//  Created by Philippe Hausler on 12/26/11.
//  Copyright (c) 2011 Apportable. All rights reserved.
//

#import "common.h"
#import "Apportable/NSArray+Blocks.h"
#import "Foundation/NSIndexSet.h"

@implementation NSArray (Blocks)

- (void)enumerateObjectsUsingBlock:(void (^)(id obj, NSUInteger idx, BOOL *stop))block 
{
    [self enumerateObjectsWithOptions:0 usingBlock:block];
}

- (void)enumerateObjectsWithOptions:(NSEnumerationOptions)opts usingBlock:(void (^)(id obj, NSUInteger idx, BOOL *stop))block
{
    [self enumerateObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [self length])] options:opts usingBlock:block];
}

- (void)enumerateObjectsAtIndexes:(NSIndexSet *)s options:(NSEnumerationOptions)opts usingBlock:(void (^)(id obj, NSUInteger idx, BOOL *stop))block
{
    NSUInteger idx = opts & NSEnumerationReverse ? [s lastIndex] : [s firstIndex];
    BOOL stop = NO;
    while(idx != NSNotFound && !stop)
    {
        id obj = [self objectAtIndex:idx];
        block(obj, idx, &stop);
        idx = opts & NSEnumerationReverse ? [s indexLessThanIndex:idx] : [s indexGreaterThanIndex:idx];
    }
}

- (NSUInteger)indexOfObjectPassingTest:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))predicate
{
    return [self indexOfObjectWithOptions:0 passingTest:predicate];
}

- (NSUInteger)indexOfObjectWithOptions:(NSEnumerationOptions)opts passingTest:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))predicate
{
    return [self indexOfObjectAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [self length])] options:opts passingTest:predicate];
}

- (NSUInteger)indexOfObjectAtIndexes:(NSIndexSet *)s options:(NSEnumerationOptions)opts passingTest:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))predicate
{
    NSUInteger idx = opts & NSEnumerationReverse ? [s lastIndex] : [s firstIndex];
    BOOL stop = NO;
    NSUInteger found = NSNotFound;
    while(idx != NSNotFound && !stop)
    {
        id obj = [self objectAtIndex:idx];
        if(predicate(obj, idx, &stop))
        {
            found = idx;
            break;
        }
        idx = opts & NSEnumerationReverse ? [s indexLessThanIndex:idx] : [s indexGreaterThanIndex:idx];
    }
    return found;
}

- (NSIndexSet *)indexesOfObjectsPassingTest:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))predicate
{
    return [self indexesOfObjectsWithOptions:0 passingTest:predicate];
}

- (NSIndexSet *)indexesOfObjectsWithOptions:(NSEnumerationOptions)opts passingTest:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))predicate
{
    return [self indexesOfObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [self length])] options:opts passingTest:predicate];
}

- (NSIndexSet *)indexesOfObjectsAtIndexes:(NSIndexSet *)s options:(NSEnumerationOptions)opts passingTest:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))predicate
{
    NSUInteger idx = opts & NSEnumerationReverse ? [s lastIndex] : [s firstIndex];
    BOOL stop = NO;
    NSMutableIndexSet *found = [NSMutableIndexSet indexSet];
    while(idx != NSNotFound && !stop)
    {
        id obj = [self objectAtIndex:idx];
        if(predicate(obj, idx, &stop))
            [found addIndex:idx];
        idx = opts & NSEnumerationReverse ? [s indexLessThanIndex:idx] : [s indexGreaterThanIndex:idx];
    }
    return found;
}

static NSInteger blockComparitor(id obj1, id obj2, void *ctx)
{
    NSComparator cmptr = (NSComparator)ctx;
    return cmptr(obj1, obj2);
}

- (NSArray *)sortedArrayUsingComparator:(NSComparator)cmptr
{
    return [self sortedArrayUsingFunction:blockComparitor context:cmptr];
}

- (NSArray *)sortedArrayWithOptions:(NSSortOptions)opts usingComparator:(NSComparator)cmptr
{
    return [self sortedArrayUsingFunction:blockComparitor context:cmptr];;
}

@end

@implementation NSMutableArray (Blocks)

- (void)sortUsingComparator:(NSComparator)cmptr
{
    [self sortUsingFunction:blockComparitor context:cmptr];
}

- (void)sortWithOptions:(NSSortOptions)opts usingComparator:(NSComparator)cmptr
{
    [self sortUsingFunction:blockComparitor context:cmptr];
}

@end