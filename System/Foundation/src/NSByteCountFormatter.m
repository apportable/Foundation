//
//  NSByteCountFormatter.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/NSByteCountFormatter.h>
#import <Foundation/NSNumberFormatter.h>
#import "NSObjectInternal.h"
#import <Foundation/NSLocale.h>

@implementation NSByteCountFormatter {
    NSByteCountFormatterUnits _allowedUnits;
    char _countStyle;
    BOOL _allowsNonnumericFormatting;
    BOOL _includesUnit;
    BOOL _includesCount;
    BOOL _includesActualByteCount;
    BOOL _adaptive;
    BOOL _zeroPadsFractionDigits;
}

static NSArray *_NSByteCountFormatterUnits;

+ (void)initialize
{
    if ([self class] == [NSByteCountFormatter class])
    {
        _NSByteCountFormatterUnits = [[NSArray alloc] initWithObjects:@"bytes", @"KB", @"MB", @"GB", @"TB", @"PB", @"EB", @"ZB", @"YB", nil];
    }
}

+ (NSString *)stringFromByteCount:(long long)byteCount countStyle:(NSByteCountFormatterCountStyle)style
{
    NSByteCountFormatter *formatter = [[NSByteCountFormatter alloc] init];
    formatter->_countStyle = style;

    NSString *string = [formatter stringFromByteCount:byteCount];

    [formatter release];

    return string;
}

- (NSByteCountFormatter *)init
{
    self = [super init];

    if (self)
    {
        _adaptive = YES;
        _allowsNonnumericFormatting = YES;
        _includesUnit = YES;
        _includesCount = YES;
    }

    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    NSByteCountFormatter *copy = [[NSByteCountFormatter allocWithZone:zone] init];

    copy->_allowedUnits = _allowedUnits;
    copy->_countStyle = _countStyle;
    copy->_allowsNonnumericFormatting = _allowsNonnumericFormatting;
    copy->_includesUnit = _includesUnit;
    copy->_includesCount = _includesCount;
    copy->_includesActualByteCount = _includesActualByteCount;
    copy->_adaptive = _adaptive;
    copy->_zeroPadsFractionDigits = _zeroPadsFractionDigits;

    return copy;
}

- (id)initWithCoder:(NSCoder *)coder
{
#warning TODO coder
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
#warning TODO coder
    return;
}

// This property must be defined by hand as the type of the ivar does
// not match the declared type in the getter and setter.
- (NSByteCountFormatterCountStyle)countStyle
{
    return _countStyle;
}

- (void)setCountStyle:(NSByteCountFormatterCountStyle)countStyle
{
    _countStyle = countStyle;
}

- (BOOL)isPartialStringValid:(NSString **)partialStringPtr proposedSelectedRange:(NSRangePointer)proposedSelRangePtr
              originalString:(NSString *)origString originalSelectedRange:(NSRange)origSelRange errorDescription:(NSString **)error
{
    return NO;
}

- (BOOL)getObjectValue:(out id *)obj forString:(NSString *)string errorDescription:(out NSString **)error
{
    return NO;
}

#warning TODO localization
- (NSString *)stringFromByteCount:(long long)byteCount
{
    unsigned long long unsignedByteCount = (unsigned long long)byteCount;

    if (unsignedByteCount == 0 && _allowsNonnumericFormatting && _includesUnit && _includesCount)
    {
        // Use "Zero KB" for default or all style, or if KB is allowed and bytes isn't.
        if (_allowedUnits == NSByteCountFormatterUseAll ||
            _allowedUnits == NSByteCountFormatterUseDefault ||
            (_allowedUnits & NSByteCountFormatterUseKB && !(_allowedUnits & NSByteCountFormatterUseBytes)))
        {
            return @"Zero KB";
        }
        else
        {
            return @"Zero bytes";
        }
    }

    unsigned long long thousand = 0;
    switch (_countStyle)
    {
        case NSByteCountFormatterCountStyleBinary:
        case NSByteCountFormatterCountStyleMemory:
            thousand = 1024;
            break;
        default:
            thousand = 1000;
            break;
    }

    NSString *countString = @"";
    NSString *unitString = @"";
    NSString *spaceString = @"";

    NSUInteger unitIdx = 0;
    unsigned long long unitMax = thousand;
    unsigned long long unitMin = 1;

    if (_allowedUnits == NSByteCountFormatterUseDefault || _allowedUnits == NSByteCountFormatterUseAll)
    {
        while (unitMax < unsignedByteCount)
        {
            unitIdx++;
            unitMin = unitMax;

            if (byteCount / unitMin < thousand)
            {
                break;
            }
            else
            {
                unitMax *= thousand;
            }
        }

        if (_includesCount)
        {
            countString = [NSString stringWithFormat:@"%llu", unsignedByteCount / unitMin];
        }

        if (_includesUnit)
        {
            unitString = [_NSByteCountFormatterUnits objectAtIndex:unitIdx];
        }

        if (_includesCount && _includesUnit)
        {
            spaceString = @" ";
        }
    }
    else
    {
#warning TODO figure out these other cases
    }

    NSUInteger fractionDigits = 2;
    if (_adaptive)
    {
        if (unitIdx <= 1)
        {
            fractionDigits = 0;
        }
        else if (unitIdx == 2)
        {
            fractionDigits = 1;
        }
    }

    NSString *actualCountString = @"";
    if (_includesActualByteCount)
    {
        static NSNumberFormatter *fileSizeFormatter = nil;
        static dispatch_once_t once = 0L;
        dispatch_once(&once, ^{
            fileSizeFormatter = [[NSNumberFormatter alloc] init];
            [fileSizeFormatter setLocale:[NSLocale currentLocale]];
            [fileSizeFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
            [fileSizeFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
            [fileSizeFormatter setUsesGroupingSeparator:YES];
            [fileSizeFormatter setRoundingMode:NSNumberFormatterRoundUp];
            [fileSizeFormatter setMaximumFractionDigits:0];
            [fileSizeFormatter setGroupingSize:3];
        });
        actualCountString = [NSString stringWithFormat:@" (%@ %@)", [fileSizeFormatter stringFromNumber:@(unsignedByteCount)],
                             [_NSByteCountFormatterUnits objectAtIndex:0]];
    }

    return [NSString stringWithFormat:@"%@%@%@%@", countString, spaceString, unitString, actualCountString];
}

- (NSString *)stringForObjectValue:(id)obj
{
    if ([obj isNSNumber__])
    {
        long long byteCount = [obj longLongValue];
        return [self stringFromByteCount:byteCount];
    }
    else
    {
        return nil;
    }
}

@end
