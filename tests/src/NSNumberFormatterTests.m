//
//  NSNumberFormatterTests.m
//  FoundationTests
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "FoundationTests.h"

@testcase(NSNumberFormatter)

test(NSNumberFormatterInit)
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    
    testassert([formatter allowsFloats]);
    testassert([formatter formatterBehavior] == NSNumberFormatterBehavior10_4);
    testassert([[formatter nilSymbol] isEqualToString:@""]);
    testassert([[formatter negativeInfinitySymbol] isEqualToString:[NSString stringWithUTF8String:"-∞"]]);
    testassert([[formatter positiveInfinitySymbol] isEqualToString:[NSString stringWithUTF8String:"+∞"]]);
    [formatter release];
    return YES;
}

test(NSNumberFormatterDecimal)
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    NSString *formattedOutput = [formatter stringFromNumber:@1234567];
    testassert([formattedOutput isEqualToString:@"1,234,567"]);
    [formatter release];
    return YES;
}

test(NSNumberFormatterDecimalFloat)
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    NSString *formattedOutput = [formatter stringFromNumber:[NSNumber numberWithFloat:12.932f]];
    testassert([formattedOutput isEqualToString:@"12.932"]);
    [formatter release];
    return YES;
}

test(NSNumberFormatterPercent)
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterPercentStyle];
    NSString *formattedOutput = [formatter stringFromNumber:[NSNumber numberWithFloat:12.932f]];
    testassert([formattedOutput isEqualToString:@"1,293%"]);
    [formatter release];
    return YES;
}

test(NSNumberFormatterSpellOut)
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterSpellOutStyle];
    NSString *formattedOutput = [formatter stringFromNumber:@1203456789];
    testassert([formattedOutput isEqualToString:@"one billion two hundred three million four hundred fifty-six thousand seven hundred eighty-nine"]);
    [formatter release];
    return YES;
}

test(NSNumberFormatterCurrency)
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    NSString *formattedOutput = [formatter stringFromNumber:[NSNumber numberWithFloat:12.932f]];
    testassert([formattedOutput isEqualToString:@"$12.93"]);
    [formatter release];
    return YES;
}

test(NSNumberFormatterGrouping)
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setGroupingSize:2];
    [formatter setGroupingSeparator:@"#"];
    NSString *formattedOutput = [formatter stringFromNumber:@1234567];
    testassert([formattedOutput isEqualToString:@"1#23#45#67"]);
    [formatter release];
    return YES;
}

test(FormattedDecimal)
{    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    NSDecimalNumber *dn = [NSDecimalNumber decimalNumberWithString:@"49.0"];
    NSString *formattedOutput = [formatter stringFromNumber:dn];
    testassert([formattedOutput isEqualToString:@"49"]);
    [formatter release];
    return YES;
}

test(NSNumberMaximumFractionDigits)
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    
    NSDecimalNumber *dn = [NSDecimalNumber decimalNumberWithString:@"1.9726345"];
    [formatter setMaximumFractionDigits:3];
    NSString *formattedOutput = [formatter stringFromNumber:dn];
    testassert([formattedOutput isEqualToString:@"1.973"]);
    [formatter release];
    return YES;
}

test(NSNumberLocaleOther)
{
    NSLocale *frLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"fr_FR"];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setLocale:frLocale];
    
    NSDecimalNumber *dn = [NSDecimalNumber decimalNumberWithString:@"1.9726345"];
    [formatter setMaximumFractionDigits:3];
    
    NSString *formattedOutput = [formatter stringFromNumber:dn];
    testassert([formattedOutput isEqualToString:@"1,973"]);
    [formatter release];
    [frLocale release];
    return YES;
}

@end
