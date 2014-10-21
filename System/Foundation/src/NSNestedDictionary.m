//
//  NSNestedDictionary.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "NSNestedDictionary.h"
#import <Foundation/NSArray.h>
#import <Foundation/NSSet.h>

@implementation _NSNestedDictionary

- (void)removeObjectForKey:(id)key
{
    [_locals removeObjectForKey:key];
}

- (void)setObject:(id)object forKey:(id<NSCopying>)key
{
    if (_locals == nil)
    {
        _locals = [[NSMutableDictionary alloc] init];
    }
    [_locals setObject:object forKey:key];
}

- (NSEnumerator *)objectEnumerator
{
    return [[self _recursiveAllValues] objectEnumerator];
}

- (NSEnumerator *)keyEnumerator
{
    return [[self _recursiveAllKeys] objectEnumerator];
}

- (id)objectForKey:(id)key
{
    id object = [_locals objectForKey:key];
    if (object == nil)
    {
        object = [_bindings objectForKey:key];
    }
    return object;
}

- (NSUInteger)count
{
    if (_bindings == nil || _locals == nil)
    {
        return [_locals count] + [_bindings count];
    }
    else
    {
        return [[self _recursiveAllKeys] count];
    }
}

- (id)_recursiveAllValues
{
    NSArray *boundObjects = nil;
    NSMutableSet *objectSet = nil;
    if ([_bindings isKindOfClass:[_NSNestedDictionary class]])
    {
        boundObjects = [_bindings _recursiveAllValues];
    }
    else
    {
        boundObjects = [_bindings allValues];
    }
    if (boundObjects == nil)
    {
        objectSet = [NSMutableSet set];
    }
    else
    {
        objectSet = [[[NSMutableSet alloc] initWithArray:boundObjects] autorelease];
    }
    for (id key in _locals)
    {
        [objectSet addObject:[_locals objectForKey:key]];
    }
    return [objectSet allObjects];
}

- (id)_recursiveAllKeys
{
    NSArray *boundKeys = nil;
    NSMutableSet *keySet = nil;
    if ([_bindings isKindOfClass:[_NSNestedDictionary class]])
    {
        boundKeys = [_bindings _recursiveAllKeys];
    }
    else
    {
        boundKeys = [_bindings allKeys];
    }
    if (boundKeys == nil)
    {
        keySet = [NSMutableSet set];
    }
    else
    {
        keySet = [[[NSMutableSet alloc] initWithArray:boundKeys] autorelease];
    }
    for (id key in _locals)
    {
        [keySet addObject:key];
    }
    return [keySet allObjects];
}

@end
