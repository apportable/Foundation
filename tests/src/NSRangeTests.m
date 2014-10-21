//
//  NSRangeTests.m
//  FoundationTests
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "FoundationTests.h"

@testcase(NSRange)

test(RangeFromStringSpaceSep)
{
    NSRange r = NSRangeFromString(@"1 1");
    testassert(r.location == 1);
    testassert(r.length == 1);
    return YES;
}

test(RangeFromStringLetterSep)
{
    NSRange r = NSRangeFromString(@"1Q1");
    testassert(r.location == 1);
    testassert(r.length == 1);
    return YES;
}

test(RangeFromStringHexSep)
{
    NSRange r = NSRangeFromString(@"1a1");
    testassert(r.location == 1);
    testassert(r.length == 1);
    return YES;
}

test(RangeFromStringDashSep)
{
    NSRange r = NSRangeFromString(@"1-1");
    testassert(r.location == 1);
    testassert(r.length == 1);
    return YES;
}

test(RangeFromStringCommaSep)
{
    NSRange r = NSRangeFromString(@"1,1");
    testassert(r.location == 1);
    testassert(r.length == 1);
    return YES;
}

test(RangeFromStringDotSep)
{
    NSRange r = NSRangeFromString(@"1.1");
    testassert(r.location == 1);
    testassert(r.length == 1);
    return YES;
}

test(RangeFromStringDoubles)
{
    NSRange r = NSRangeFromString(@"1.1 2.2");
    testassert(r.location == 1);
    testassert(r.length == 1);
    return YES;
}

test(RangeFromStringNegativeValues)
{
    NSRange r = NSRangeFromString(@"-1 -1");
    testassert(r.location == 1);
    testassert(r.length == 1);
    return YES;
}

test(RangeFromStringSingleNumber)
{
    NSRange r = NSRangeFromString(@"444");
    testassert(r.location == 444);
    testassert(r.length == 0);
    return YES;
}

test(RangeFromStringThreeNumbers)
{
    NSRange r = NSRangeFromString(@"4 5 6");
    testassert(r.location == 4);
    testassert(r.length == 5);
    return YES;
}

test(RangeFromNil)
{
    NSRange r = NSRangeFromString(nil);
    testassert(r.location == 0);
    testassert(r.length == 0);
    return YES;
}

test(RangeFromHex)
{
    NSRange r = NSRangeFromString(@"0x5f 0x84");
    testassert(r.location == 0x5f);
    testassert(r.length == 0x84);
    return YES;
}

test(RangeFromGoogol)
{
    NSRange r = NSRangeFromString(@"10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 5");
    testassert(r.location == NSUIntegerMax);
    testassert(r.length = 5);
    return YES;
}

test(RangeFromNSUIntegerMaxMinusOne)
{
    NSRange r = NSRangeFromString([NSString stringWithFormat:@"%llu 4", (unsigned long long)(NSUIntegerMax - 1)]);
    testassert(r.location == NSUIntegerMax - 1);
    testassert(r.length == 4);
    return YES;
}

test(RangeFromSciNot)
{
    NSRange r = NSRangeFromString(@"1e5 4e2");
    testassert(r.location == 1);
    testassert(r.length == 5);
    return YES;
}

test(RangeFromNumberLikeCharacters)
{
    NSRange r = NSRangeFromString(@"⑴ ⑵");
    testassert(r.location == 0);
    testassert(r.length == 0);
    return YES;
}

test(RangeFromStringWithPrefix)
{
    NSRange r = NSRangeFromString(@"this is a prefix to a range 54 66");
    testassert(r.location == 54);
    testassert(r.length == 66);
    return YES;
}

test(RangeFromStringWithAbusivePrefix)
{
    NSRange r = NSRangeFromString(@"\0this is a prefix to a range 54 66");
    testassert(r.location == 0);
    testassert(r.length == 0);
    return YES;
}

@end
