//
//  NSDictionary+Blocks.m
//  
//
//  Created by Philippe Hausler on 12/26/11.
//  Copyright (c) 2011 Apportable. All rights reserved.
//

#import "Apportable/NSDictionary+Blocks.h"
#import "Apportable/NSArray+Blocks.h"
#import "Foundation/NSSet.h"

@implementation NSDictionary (Blocks)

- (void)enumerateKeysAndObjectsUsingBlock:(void (^)(id key, id obj, BOOL *stop))block
{
    [self enumerateKeysAndObjectsWithOptions:0 usingBlock:block];
}

- (void)enumerateKeysAndObjectsWithOptions:(NSEnumerationOptions)opts usingBlock:(void (^)(id key, id obj, BOOL *stop))block
{
    NSEnumerator *enumerator = opts & NSEnumerationReverse ? [[self allKeys] reverseObjectEnumerator] : [[self allKeys] objectEnumerator];
    id key = NULL;
    BOOL stop = NO;
    while((key = [enumerator nextObject]) && !stop)
    {
        id obj = [self objectForKey:key];
        block(key, obj, &stop);
    }
}

- (NSArray *)keysSortedByValueUsingComparator:(NSComparator)cmptr
{
    return [[self allKeys] sortedArrayUsingComparator:cmptr];
}

- (NSArray *)keysSortedByValueWithOptions:(NSSortOptions)opts usingComparator:(NSComparator)cmptr
{
    return [[self allKeys] sortedArrayWithOptions:opts usingComparator:cmptr];
}

- (NSSet *)keysOfEntriesPassingTest:(BOOL (^)(id key, id obj, BOOL *stop))predicate
{
    
    return [self keysOfEntriesWithOptions:0 passingTest:predicate];
}

- (NSSet *)keysOfEntriesWithOptions:(NSEnumerationOptions)opts passingTest:(BOOL (^)(id key, id obj, BOOL *stop))predicate
{
    NSMutableSet *found = [NSMutableSet set];
    NSEnumerator *enumerator = opts & NSEnumerationReverse ? [[self allKeys] reverseObjectEnumerator] : [[self allKeys] objectEnumerator];
    id key = NULL;
    BOOL stop = NO;
    while((key = [enumerator nextObject]) && !stop)
    {
        id obj = [self objectForKey:key];
        if(predicate(key, obj, &stop))
            [found addObject:key];
    }
    return found;
}

@end
