//
//  NSSharedKeyDictionary.m
//  CoreFoundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "NSSharedKeyDictionary.h"
#import "NSKeyValueObserving.h"

@implementation NSSharedKeyDictionary

+ (id)sharedKeyDictionaryWithKeySet:(NSSharedKeySet *)keySet
{
    return [[[self alloc] initWithKeySet:keySet] autorelease];
}

- (id)initWithKeySet:(NSSharedKeySet *)keySet
{
    self = [super init];

    if (self)
    {
        _keyMap = [keySet retain];
        _ifkIMP = (NSUInteger (*)(id,SEL,id))[keySet methodForSelector:@selector(indexForKey:)];
        _values = calloc(sizeof(id), [keySet count]);
    }

    return self;
}

- (void)dealloc
{
    [_keyMap release];
    [_sideDic release];
    free(_values);
    [super dealloc];
}

- (NSSharedKeySet *)keySet
{
    return _keyMap;
}

- (void)removeObjectForKey:(id)key
{
    _mutations++;
    NSUInteger idx = _ifkIMP(_keyMap, @selector(indexForKey:), key);

    if (idx == NSNotFound)
    {
        [_sideDic removeObjectForKey:key];
    }
    else
    {
        [_values[idx] release];
        _values[idx] = nil;
        _count--;
    }
}

- (void)setObject:(id)object forKey:(id)key
{
    _mutations++;
    NSUInteger idx = _ifkIMP(_keyMap, @selector(indexForKey:), key);

    if (idx == NSNotFound)
    {
        if (_sideDic == nil)
        {
            _sideDic = [[NSMutableDictionary alloc] init];
        }

        [self willChangeValueForKey:key];
        [_sideDic setObject:object forKey:key];
        [self didChangeValueForKey:key];
    }
    else
    {
        if (_values[idx] != nil)
        {
            [_values[idx] release];
        }
        else
        {
            _count++;
        }

        _values[idx] = [object retain];
    }
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])buffer count:(NSUInteger)len
{
    NSUInteger sideCount = [_sideDic count];
    if (state->state == _count + sideCount)
    {
        if (state->extra[1] != 0)
        {
            free((id *)state->extra[1]);
            state->extra[1] = 0;
        }

        return 0;
    }

    if (state->extra[0] == 0)
    {
        state->extra[0] = _count + sideCount;
    }
    
    NSUInteger num = 0;
    NSUInteger curr = state->state;

    while (num < len && curr < _count)
    {
        buffer[num] = [_keyMap keyAtIndex:curr];
        num++;
        curr++;
    }

    while (num < len && curr < _count + sideCount)
    {
        if (state->extra[1] == 0)
        {
            state->extra[1] = (unsigned long)malloc(sizeof(id) * sideCount);
            [_sideDic getObjects:NULL andKeys:(id *)state->extra[1] count:sideCount]; 
        }

        buffer[num] = ((id *)state->extra[1])[curr - sideCount];
        num++;
        curr++;
    }
    state->state = curr;
    state->itemsPtr = buffer;
    
    state->mutationsPtr = (unsigned long *)&_mutations;
    return num;
}

- (NSEnumerator *)keyEnumerator
{
    return [[[_keyMap allKeys] arrayByAddingObjectsFromArray:[_sideDic allKeys]] objectEnumerator];
}

- (void)getObjects:(id *)objects andKeys:(id *)keys count:(NSUInteger)count
{
    NSUInteger sideCount = [_sideDic count];
    NSUInteger amt = MIN(sideCount, count);
    NSUInteger remaining = count - sideCount;
    [_sideDic getObjects:objects andKeys:keys count:amt];

    if (remaining > 0)
    {
        memcpy(objects + sideCount, _values, sizeof(id) * remaining);

        for (NSUInteger idx = 0; idx < remaining; idx++)
        {
            keys[sideCount + idx] = [_keyMap keyAtIndex:idx];
        }
    }
}

- (id)objectForKey:(id)key
{
    NSUInteger idx = _ifkIMP(_keyMap, @selector(indexForKey:), key);
    
    if (idx == NSNotFound)
    {
        return [_sideDic objectForKey:key];
    }
    else
    {
        return _values[idx];
    }
}

- (NSUInteger)count
{
    return _count + [_sideDic count];
}

@end
