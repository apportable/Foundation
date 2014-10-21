//
//  NSSharedKeySet.m
//  CoreFoundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "NSSharedKeySet.h"


@implementation NSSharedKeySet

+ (id)keySetWithKeys:(NSArray *)keyArray
{
    NSUInteger count = [keyArray count];
    id *keys = malloc(sizeof(id) * count);
    [keyArray getObjects:keys range:NSMakeRange(0, count)];
    NSSharedKeySet *keySet = [[NSSharedKeySet alloc] initWithKeys:keys count:count];
    free(keys);
    return [keySet autorelease];
}

- (id)init
{
    return [self initWithKeys:NULL count:0];
}

- (id)initWithKeys:(id *)keys count:(NSUInteger)count
{
    self = [super init];

    if (self)
    {
        if (count == 0)
        {
            _keys = malloc(sizeof(id) * 1);
        }
        else
        {
            _keys = malloc(sizeof(id) * count);
        }

        for (int i = 0; i < count; i++)
        {
            _keys[i] = [keys[i] retain];
        }

        _numKey = count;
    }

    return self;
}

- (void)dealloc
{
    if (_keys != NULL)
    {
        free(_keys);
    }

    [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone
{
    return [self retain];
}

- (NSUInteger)keySetCount
{
    if (_subSharedKeySet)
    {
        return [_subSharedKeySet keySetCount] + 1;
    }
    else
    {
        return 0;
    }
}

- (NSUInteger)count
{
    return _numKey;
}

- (NSUInteger)maximumIndex
{
    return [self count] - 1;
}

- (BOOL)isEmpty
{
    return _numKey == 0;
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])buffer count:(NSUInteger)len
{
    if (state->state == _numKey)
    {
        return 0;
    }

    if (state->extra[0] == 0)
    {
        state->extra[0] = _numKey;
    }
    
    NSUInteger num = 0;
    NSUInteger curr = state->state;

    while (num < len && curr < _numKey)
    {
        buffer[num] = _keys[curr];
        num++;
        curr++;
    }

    state->state = curr;
    state->itemsPtr = buffer;
    
    state->mutationsPtr = &state->extra[0];
    return num;
}

- (id)keyAtIndex:(NSUInteger)index
{
    return _keys[index];
}

- (NSArray*)allKeys
{
    return [NSArray arrayWithObjects:_keys count:_numKey];
}

- (NSUInteger)indexForKey:(id)key
{
    for (NSUInteger i = 0; i < _numKey; i++)
    {
        if (_keys[i] == key)
        {
            return i;
        }

        if ([_keys[i] isEqual:key])
        {
            return i;
        }
    }
    
    return NSNotFound;
}

@end
