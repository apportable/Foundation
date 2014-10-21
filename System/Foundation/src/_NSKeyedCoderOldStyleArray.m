//
//  _NSKeyedCoderOldStyleArray.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "NSCoderInternal.h"

#import <Foundation/NSException.h>
#import <stdlib.h>

@implementation _NSKeyedCoderOldStyleArray
{
    void *_addr;
    NSUInteger _count;
    NSUInteger _size;
    char _type;
    BOOL _decoded;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if (self != nil)
    {
        _count = [decoder decodeInt32ForKey:@"NS.count"];
        _size = [decoder decodeInt32ForKey:@"NS.size"];
        _type = (char)[decoder decodeInt32ForKey:@"NS.type"];

        NSUInteger size = 0;
        NSUInteger alignment = 0;

        NSGetSizeAndAlignment(&_type, &size, &alignment);

        _addr = malloc(size * _count);
        if (_addr == NULL)
        {
            [NSException raise:NSMallocException format:@"malloc failure"];
            return nil;
        }

        _decoded = YES;

        NSUInteger count = 0;
        while (count < _count)
        {
            [decoder decodeValueOfObjCType:&_type at:(char *)_addr + count * _size];
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeInt32:_count forKey:@"NS.count"];
    [coder encodeInt32:_size forKey:@"NS.size"];
    [coder encodeInt32:(int32_t)_type forKey:@"NS.type"];

    NSUInteger count = 0;
    while (count < _count)
    {
        [coder encodeValueOfObjCType:&_type at:(char *)_addr + count * _size];
    }
}

- (void)fillObjCType:(char)type count:(NSUInteger)count at:(void *)addr
{
    if (_size == 0)
    {
        [NSException raise:NSInternalInconsistencyException format:@"Zero size"];
    }
    if (_count == 0)
    {
        [NSException raise:NSInternalInconsistencyException format:@"Zero count"];
        return;
    }
    if (_type != type)
    {
        [NSException raise:NSInternalInconsistencyException format:@"Inconsistent type"];
        return;
    }
    if (_count != count)
    {
        [NSException raise:NSInternalInconsistencyException format:@"Inconsistent count"];
        return;
    }

    memmove(addr, _addr, _size);
}

- (void)dealloc
{
    if (_decoded && _addr != NULL)
    {
        free(_addr);
    }

    [super dealloc];
}

- (id)initWithObjCType:(char)type count:(NSUInteger)count at:(const void *)addr
{
    self = [super init];

    if (self != nil)
    {
        NSUInteger size = 0;
        NSUInteger alignment = 0;

        NSGetSizeAndAlignment(&type, &size, &alignment);

        if (size == 0)
        {
            [NSException raise:NSInternalInconsistencyException format:@"Zero size"];
            return nil;
        }

        if (alignment == 0)
        {
            [NSException raise:NSInternalInconsistencyException format:@"Zero alignment"];
            return nil;
        }

        _addr = (void *)addr;
        _count = count;
        _size = size;
        _type = type;
    }

    return self;
}

@end
