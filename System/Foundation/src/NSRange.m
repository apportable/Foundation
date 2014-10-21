//
//  NSRange.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/NSRange.h>
#import <Foundation/NSString.h>
#import <Foundation/NSScanner.h>
#import <Foundation/NSCharacterSet.h>

NSString *NSStringFromRange(NSRange range)
{
    return [NSString stringWithFormat:@"{%lu, %lu}", (unsigned long)range.location, (unsigned long)range.length];
}

NSRange NSUnionRange(NSRange range1, NSRange range2)
{
    NSUInteger loc = MIN(range1.location, range2.location);
    NSUInteger max = MAX(NSMaxRange(range1), NSMaxRange(range2));

    return NSMakeRange(loc, max - loc);
}

NSRange NSRangeFromString(NSString *str)
{
    NSScanner *scanner = [NSScanner scannerWithString:str];
    scanner.charactersToBeSkipped = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    long long loc = 0;
    long long len = 0;
    [scanner scanLongLong:&loc]; // TODO: use scanUnsignedLongLong when it's available
    [scanner scanLongLong:&len];
    return NSMakeRange(MAX(loc, 0), MAX(len, 0));
}

NSRange NSIntersectionRange(NSRange range1, NSRange range2)
{
    NSUInteger loc = MAX(range1.location, range2.location);
    NSUInteger max = MIN(NSMaxRange(range1), NSMaxRange(range2));

    if (max <= loc)
    {
        return NSMakeRange(0, 0);
    }

    return NSMakeRange(loc, max - loc);
}

@implementation NSValue (NSValueRangeExtensions)

+ (NSValue *)valueWithRange:(NSRange)range
{
    return [NSValue valueWithBytes:&range objCType:@encode(NSRange)];
}

- (NSRange)rangeValue
{
    NSRange r;
    [self getValue:&r];
    return r;
}

@end
