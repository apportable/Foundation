//
//  NSRegularExpressionCheckingResult.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "NSRegularExpressionCheckingResult.h"
#import <Foundation/NSArray.h>
#import <Foundation/NSValue.h>
#import <Foundation/NSRegularExpression.h>
#import "NSObjectInternal.h"

typedef NS_ENUM(NSUInteger, NSRegularExpressionCheckingResultLimits) {
    NSRegularExpressionCheckingResultSimpleLimit = 3,
    NSRegularExpressionCheckingResultExtendedLimit = 7,
};

@implementation NSRegularExpressionCheckingResult

- (id)initWithRangeArray:(NSArray *)ranges regularExpression:(NSRegularExpression *)expression
{
    NSRequestConcreteImplementation();
    [self release];
    return nil;
}

- (id)initWithRanges:(NSRangePointer)ranges count:(NSUInteger)count regularExpression:(NSRegularExpression *)expression
{
    NSRequestConcreteImplementation();
    [self release];
    return nil;
}

- (id)resultByAdjustingRangesWithOffset:(NSInteger)offset
{
    NSArray *ranges = self.rangeArray;
    NSMutableArray *newRanges = [NSMutableArray array];
    NSUInteger numRanges = ranges.count;
    
    if (numRanges != 0)
    {
        for (NSUInteger i = 0; i < numRanges; ++i)
        {
            NSValue *rangeValue = [ranges objectAtIndex:i];
            NSRange range = [rangeValue rangeValue];
            
            if (range.location != NSNotFound)
            {
                if (offset < 0 && range.location < offset)
                {
                    [NSException raise:NSInvalidArgumentException format:@"%@: %ld invalid offset for range %@", _NSFullMethodName(self, _cmd), (long)offset, NSStringFromRange(range)];
                }
                range.location += offset;
            }
            [newRanges addObject:[NSValue valueWithRange:range]];
        }
    }
    
    NSRegularExpressionCheckingResult *result = [[[[self class] alloc] initWithRangeArray:newRanges regularExpression:self.regularExpression] autorelease];
    
    return result;
}

- (BOOL)_adjustRangesWithOffset:(NSInteger)offset
{
    NSRequestConcreteImplementation();
    return NO;
}

- (NSTextCheckingType)resultType
{
    return NSTextCheckingTypeRegularExpression;
}

/*
- (NSString *)description
{

}
*/

@end

@implementation NSSimpleRegularExpressionCheckingResult {
    NSRegularExpression *_regularExpression;
    NSRange _ranges[NSRegularExpressionCheckingResultSimpleLimit];
    NSUInteger _numberOfRanges;
}

- (id)initWithRangeArray:(NSArray *)ranges regularExpression:(NSRegularExpression *)expression
{
    if ([ranges count] > NSRegularExpressionCheckingResultSimpleLimit)
    {
        [self release];
        return nil;
    }
    NSRange rangeList[NSRegularExpressionCheckingResultSimpleLimit];
    NSUInteger count = 0;
    for (NSValue *rangeValue in ranges)
    {
        [rangeValue getValue:&rangeList[count]];
        count++;
    }
    _numberOfRanges = count;
    return [self initWithRanges:rangeList count:count regularExpression:expression];
}

- (id)initWithRanges:(NSRangePointer)ranges count:(NSUInteger)count regularExpression:(NSRegularExpression *)expression
{
    self = [super init];
    if (self)
    {
        NSAssert(count <= NSRegularExpressionCheckingResultSimpleLimit, @"Should be no more than %u ranges", NSRegularExpressionCheckingResultSimpleLimit);
        _numberOfRanges = count;
        memcpy(_ranges, ranges, count * sizeof(NSRange));
        _regularExpression = [expression retain];
    }
    return self;
}

- (void)dealloc
{
    [_regularExpression release];
    [super dealloc];
}

- (NSArray *)rangeArray
{
    NSMutableArray *rangeArray = [[NSMutableArray alloc] init];
    for (NSUInteger idx = 0; idx < NSRegularExpressionCheckingResultSimpleLimit; idx++)
    {
        [rangeArray addObject:[NSValue valueWithBytes:&_ranges[idx] objCType:@encode(NSRange)]];
    }
    return [rangeArray autorelease];
}

- (NSRange)rangeAtIndex:(NSUInteger)index
{
    return _ranges[index];
}

- (NSUInteger)numberOfRanges
{
    return _numberOfRanges;
}

- (BOOL)_adjustRangesWithOffset:(NSInteger)offset
{
    for (NSUInteger i = 0; i < NSRegularExpressionCheckingResultSimpleLimit; ++i) {
        _ranges[i].location += offset;
    }
    return YES;
}

- (NSRange)range
{
    return _ranges[0];
}


- (NSRegularExpression *)regularExpression
{
    return _regularExpression;
}


@end

@implementation NSExtendedRegularExpressionCheckingResult {
    NSRegularExpression *_regularExpression;
    NSRange _ranges[NSRegularExpressionCheckingResultExtendedLimit];
}

- (id)initWithRangeArray:(NSArray *)ranges regularExpression:(NSRegularExpression *)expression
{
    if ([ranges count] > NSRegularExpressionCheckingResultExtendedLimit)
    {
        [self release];
        return nil;
    }
    NSRange rangeList[NSRegularExpressionCheckingResultExtendedLimit];
    NSUInteger count = 0;
    for (NSValue *rangeValue in ranges)
    {
        [rangeValue getValue:&rangeList[count]];
        count++;
    }
    return [self initWithRanges:rangeList count:count regularExpression:expression];
}

- (id)initWithRanges:(NSRangePointer)ranges count:(NSUInteger)count regularExpression:(NSRegularExpression *)expression
{
    self = [super init];
    if (self)
    {
        memcpy(_ranges, ranges, count * sizeof(NSRange));
        _regularExpression = [expression retain];
    }
    return self;
}

- (void)dealloc
{
    [_regularExpression release];
    [super dealloc];
}

- (NSArray *)rangeArray
{
    NSMutableArray *rangeArray = [[NSMutableArray alloc] init];
    for (NSUInteger idx = 0; idx < NSRegularExpressionCheckingResultExtendedLimit; idx++)
    {
        [rangeArray addObject:[NSValue valueWithBytes:&_ranges[idx] objCType:@encode(NSRange)]];
    }
    return [rangeArray autorelease];
}

- (NSRange)rangeAtIndex:(NSUInteger)index
{
    return _ranges[index];
}

- (NSUInteger)numberOfRanges
{
    return NSRegularExpressionCheckingResultExtendedLimit;
}

- (BOOL)_adjustRangesWithOffset:(NSInteger)offset
{
    for (NSUInteger i = 0; i < NSRegularExpressionCheckingResultExtendedLimit; ++i)
    {
        _ranges[i].location += offset;
    }
    return YES;
}

- (NSRange)range
{
    return _ranges[0];
}

- (NSRegularExpression *)regularExpression
{
    return _regularExpression;
}


@end

@implementation NSComplexRegularExpressionCheckingResult

- (id)initWithRangeArray:(NSArray *)ranges regularExpression:(NSRegularExpression *)expression
{
    self = [super init];
    if (self)
    {
        _rangeArray = [ranges copy];
        _regularExpression = [expression retain];
    }
    return self;
}

- (id)initWithRanges:(NSRangePointer)ranges count:(NSUInteger)count regularExpression:(NSRegularExpression *)expression
{
    NSMutableArray *rangeArray = [NSMutableArray array];
    for (NSUInteger idx = 0; idx < count; idx++)
    {
        [rangeArray addObject:[NSValue valueWithBytes:&ranges[idx] objCType:@encode(NSRange)]];
    }
    return [self initWithRangeArray:rangeArray regularExpression:expression];
}

- (void)dealloc
{
    [_rangeArray release];
    [_regularExpression release];
    [super dealloc];
}

- (NSArray *)rangeArray
{
    return _rangeArray;
}

- (NSRange)rangeAtIndex:(NSUInteger)index
{
    NSRange r;
    [(NSValue *)_rangeArray[index] getValue:&r];
    return r;
}

- (NSUInteger)numberOfRanges
{
    return [_rangeArray count];
}

- (BOOL)_adjustRangesWithOffset:(NSInteger)offset
{
    NSMutableArray *ranges = [NSMutableArray arrayWithCapacity:_rangeArray.count];
    
    for (NSValue *range in _rangeArray)
    {
        NSRange r = { 0, 0 };
        
        [range getValue:&r];
        r.location += offset;
        [ranges addObject:[NSValue valueWithBytes:&r objCType:@encode(NSRange)]];
    }
    [_rangeArray release];
    _rangeArray = ranges.copy;
    return YES;
}

- (NSRange)range
{
    NSValue *range = [_rangeArray objectAtIndex:0];
    NSRange result = { 0, 0 };
    
    [range getValue:&result];
    return result;
}

- (NSRegularExpression *)regularExpression
{
    return _regularExpression;
}

@end
