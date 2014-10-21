//
//  NSNumberTests.m
//  FoundationTests
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "FoundationTests.h"
#import <limits.h>

@interface NSObject ()
- (BOOL)isNSNumber__;
@end

@testcase(NSNumber)

test(Allocate)
{
    NSNumber *n1 = [NSNumber alloc];
    NSNumber *n2 = [NSNumber alloc];
    
    testassert(n1 == n2);
    
    return YES;
}

test(YESStringValue)
{
    NSString *result = [[NSNumber numberWithBool:YES] stringValue];
    testassert([result isEqualToString:@"1"]);
    return YES;
}

test(NOStringValue)
{
    NSString *result = [[NSNumber numberWithBool:NO] stringValue];
    testassert([result isEqualToString:@"0"]);
    return YES;
}

test(BOOLdescription)
{
    NSString *result = [[NSNumber numberWithBool:YES] description];
    testassert([result isEqualToString:@"1"]);
    return YES;
}

test(SharedBoolInstances)
{
    NSNumber *y1 = [NSNumber numberWithBool:YES];
    NSNumber *y2 = [NSNumber numberWithBool:YES];
    NSNumber *y3 = [NSNumber numberWithBool:YES];
    NSNumber *y4 = [NSNumber numberWithBool:YES];

    NSNumber *n1 = [NSNumber numberWithBool:NO];
    NSNumber *n2 = [NSNumber numberWithBool:NO];
    NSNumber *n3 = [NSNumber numberWithBool:NO];
    NSNumber *n4 = [NSNumber numberWithBool:NO];

    // NSNumber BOOL instances should be shared
    testassert(y1 == y2);
    testassert(y1 == y3);
    testassert(y1 == y4);

    testassert(n1 == n2);
    testassert(n1 == n3);
    testassert(n1 == n4);

    testassert([y1 isKindOfClass:[NSNumber class]]);
    testassert([n1 isKindOfClass:[NSNumber class]]);

    return YES;
}

test(SharedNumberInstances)
{
    NSNumber* nan = [NSNumber numberWithDouble:NAN];
    NSNumber* nan2 = [NSNumber numberWithDouble:NAN];

    testassert(nan == nan2);
    testassert([nan isKindOfClass:[NSNumber class]]);

    NSNumber* pinfinity = [NSNumber numberWithDouble:+INFINITY];
    NSNumber* pinfinity2 = [NSNumber numberWithDouble:+INFINITY];

    testassert(pinfinity == pinfinity2);
    testassert([pinfinity isKindOfClass:[NSNumber class]]);

    NSNumber* ninfinity = [NSNumber numberWithDouble:-INFINITY];
    NSNumber* ninfinity2 = [NSNumber numberWithDouble:-INFINITY];

    testassert(ninfinity == ninfinity2);
    testassert([ninfinity isKindOfClass:[NSNumber class]]);

    return YES;
}

test(NumberWithBool)
{
    // boolValue is guaranteed to return YES or NO since OS X 10.3

    testassert([[NSNumber numberWithBool:YES] boolValue] == YES);
    testassert([[NSNumber numberWithBool:YES] charValue] == YES);
    testassert([[NSNumber numberWithBool:YES] unsignedCharValue] == YES);
    testassert([[NSNumber numberWithBool:YES] shortValue] == YES);
    testassert([[NSNumber numberWithBool:YES] unsignedShortValue] == YES);
    testassert([[NSNumber numberWithBool:YES] intValue] == YES);
    testassert([[NSNumber numberWithBool:YES] unsignedIntValue] == YES);
    testassert([[NSNumber numberWithBool:YES] longValue] == YES);
    testassert([[NSNumber numberWithBool:YES] unsignedLongValue] == YES);
    testassert([[NSNumber numberWithBool:YES] longLongValue] == YES);
    testassert([[NSNumber numberWithBool:YES] unsignedLongLongValue] == YES);

    testassert([[NSNumber numberWithBool:NO] boolValue] == NO);
    testassert([[NSNumber numberWithBool:NO] charValue] == NO);
    testassert([[NSNumber numberWithBool:NO] unsignedCharValue] == NO);
    testassert([[NSNumber numberWithBool:NO] shortValue] == NO);
    testassert([[NSNumber numberWithBool:NO] unsignedShortValue] == NO);
    testassert([[NSNumber numberWithBool:NO] intValue] == NO);
    testassert([[NSNumber numberWithBool:NO] unsignedIntValue] == NO);
    testassert([[NSNumber numberWithBool:NO] longValue] == NO);
    testassert([[NSNumber numberWithBool:NO] unsignedLongValue] == NO);
    testassert([[NSNumber numberWithBool:NO] longLongValue] == NO);
    testassert([[NSNumber numberWithBool:NO] unsignedLongLongValue] == NO);

    return YES;
}

test(NumberWithChar1)
{
    testassert([[NSNumber numberWithChar:0] boolValue] == NO);
    testassert([[NSNumber numberWithChar:-23] boolValue] == YES);
    testassert([[NSNumber numberWithChar:42] boolValue] == YES);
    testassert([[NSNumber numberWithChar:CHAR_MAX] boolValue] == YES);
    testassert([[NSNumber numberWithChar:CHAR_MIN] boolValue] == YES);

    testassert([[NSNumber numberWithChar:0] charValue] == (char)0);
    testassert([[NSNumber numberWithChar:-23] charValue] == (char)-23);
    testassert([[NSNumber numberWithChar:42] charValue] == (char)42);
    testassert([[NSNumber numberWithChar:CHAR_MAX] charValue] == (char)CHAR_MAX);
    testassert([[NSNumber numberWithChar:CHAR_MIN] charValue] == (char)CHAR_MIN);

    testassert([[NSNumber numberWithChar:0] unsignedCharValue] == (unsigned char)0);
    testassert([[NSNumber numberWithChar:-23] unsignedCharValue] == (unsigned char)-23);
    testassert([[NSNumber numberWithChar:42] unsignedCharValue] == (unsigned char)42);
    testassert([[NSNumber numberWithChar:CHAR_MAX] unsignedCharValue] == (unsigned char)CHAR_MAX);
    testassert([[NSNumber numberWithChar:CHAR_MIN] unsignedCharValue] == (unsigned char)CHAR_MIN);

    testassert([[NSNumber numberWithChar:0] shortValue] == (short)0);
    testassert([[NSNumber numberWithChar:-23] shortValue] == (short)-23);
    testassert([[NSNumber numberWithChar:42] shortValue] == (short)42);
    testassert([[NSNumber numberWithChar:CHAR_MAX] shortValue] == (short)CHAR_MAX);
    testassert([[NSNumber numberWithChar:CHAR_MIN] shortValue] == (short)CHAR_MIN);

    testassert([[NSNumber numberWithChar:0] unsignedShortValue] == (unsigned short)0);
    testassert([[NSNumber numberWithChar:-23] unsignedShortValue] == (unsigned short)-23);
    testassert([[NSNumber numberWithChar:42] unsignedShortValue] == (unsigned short)42);
    testassert([[NSNumber numberWithChar:CHAR_MAX] unsignedShortValue] == (unsigned short)CHAR_MAX);
    testassert([[NSNumber numberWithChar:CHAR_MIN] unsignedShortValue] == (unsigned short)CHAR_MIN);

    testassert([[NSNumber numberWithChar:0] intValue] == (int)0);
    testassert([[NSNumber numberWithChar:-23] intValue] == (int)-23);
    testassert([[NSNumber numberWithChar:42] intValue] == (int)42);
    testassert([[NSNumber numberWithChar:CHAR_MAX] intValue] == (int)CHAR_MAX);
    testassert([[NSNumber numberWithChar:CHAR_MIN] intValue] == (int)CHAR_MIN);

    testassert([[NSNumber numberWithChar:0] unsignedIntValue] == (unsigned int)0);
    testassert([[NSNumber numberWithChar:-23] unsignedIntValue] == (unsigned int)-23);
    testassert([[NSNumber numberWithChar:42] unsignedIntValue] == (unsigned int)42);
    testassert([[NSNumber numberWithChar:CHAR_MAX] unsignedIntValue] == (unsigned int)CHAR_MAX);
    testassert([[NSNumber numberWithChar:CHAR_MIN] unsignedIntValue] == (unsigned int)CHAR_MIN);

    return YES;
}

test(NumberWithChar2)
{
    testassert([[NSNumber numberWithChar:0] integerValue] == (NSInteger)0);
    testassert([[NSNumber numberWithChar:-23] integerValue] == (NSInteger)-23);
    testassert([[NSNumber numberWithChar:42] integerValue] == (NSInteger)42);
    testassert([[NSNumber numberWithChar:CHAR_MAX] integerValue] == (NSInteger)CHAR_MAX);
    testassert([[NSNumber numberWithChar:CHAR_MIN] integerValue] == (NSInteger)CHAR_MIN);

    testassert([[NSNumber numberWithChar:0] unsignedIntegerValue] == (NSUInteger)0);
    testassert([[NSNumber numberWithChar:-23] unsignedIntegerValue] == (NSUInteger)-23);
    testassert([[NSNumber numberWithChar:42] unsignedIntegerValue] == (NSUInteger)42);
    testassert([[NSNumber numberWithChar:CHAR_MAX] unsignedIntegerValue] == (NSUInteger)CHAR_MAX);
    testassert([[NSNumber numberWithChar:CHAR_MIN] unsignedIntegerValue] == (NSUInteger)CHAR_MIN);

    testassert([[NSNumber numberWithChar:0] longValue] == (long)0);
    testassert([[NSNumber numberWithChar:-23] longValue] == (long)-23);
    testassert([[NSNumber numberWithChar:42] longValue] == (long)42);
    testassert([[NSNumber numberWithChar:CHAR_MAX] longValue] == (long)CHAR_MAX);
    testassert([[NSNumber numberWithChar:CHAR_MIN] longValue] == (long)CHAR_MIN);

    testassert([[NSNumber numberWithChar:0] unsignedLongValue] == (unsigned long)0);
    testassert([[NSNumber numberWithChar:-23] unsignedLongValue] == (unsigned long)-23);
    testassert([[NSNumber numberWithChar:42] unsignedLongValue] == (unsigned long)42);
    testassert([[NSNumber numberWithChar:CHAR_MAX] unsignedLongValue] == (unsigned long)CHAR_MAX);
    testassert([[NSNumber numberWithChar:CHAR_MIN] unsignedLongValue] == (unsigned long)CHAR_MIN);

    testassert([[NSNumber numberWithChar:0] longLongValue] == (long long)0);
    testassert([[NSNumber numberWithChar:-23] longLongValue] == (long long)-23);
    testassert([[NSNumber numberWithChar:42] longLongValue] == (long long)42);
    testassert([[NSNumber numberWithChar:CHAR_MAX] longLongValue] == (long long)CHAR_MAX);
    testassert([[NSNumber numberWithChar:CHAR_MIN] longLongValue] == (long long)CHAR_MIN);

    testassert([[NSNumber numberWithChar:0] unsignedLongLongValue] == (unsigned long long)0);
    testassert([[NSNumber numberWithChar:-23] unsignedLongLongValue] == (unsigned long long)-23);
    testassert([[NSNumber numberWithChar:42] unsignedLongLongValue] == (unsigned long long)42);
    testassert([[NSNumber numberWithChar:CHAR_MAX] unsignedLongLongValue] == (unsigned long long)CHAR_MAX);
    testassert([[NSNumber numberWithChar:CHAR_MIN] unsignedLongLongValue] == (unsigned long long)CHAR_MIN);

    return YES;
}

test(NumberWithUnsignedChar1)
{
    testassert([[NSNumber numberWithUnsignedChar:0] boolValue] == NO);
    testassert([[NSNumber numberWithUnsignedChar:42] boolValue] == YES);
    testassert([[NSNumber numberWithUnsignedChar:UCHAR_MAX] boolValue] == YES);

    testassert([[NSNumber numberWithUnsignedChar:0] charValue] == (char)0);
    testassert([[NSNumber numberWithUnsignedChar:42] charValue] == (char)42);
    testassert([[NSNumber numberWithUnsignedChar:UCHAR_MAX] charValue] == (char)UCHAR_MAX);

    testassert([[NSNumber numberWithUnsignedChar:0] unsignedCharValue] == (unsigned char)0);
    testassert([[NSNumber numberWithUnsignedChar:42] unsignedCharValue] == (unsigned char)42);
    testassert([[NSNumber numberWithUnsignedChar:UCHAR_MAX] unsignedCharValue] == (unsigned char)UCHAR_MAX);

    testassert([[NSNumber numberWithUnsignedChar:0] shortValue] == (short)0);
    testassert([[NSNumber numberWithUnsignedChar:42] shortValue] == (short)42);
    testassert([[NSNumber numberWithUnsignedChar:UCHAR_MAX] shortValue] == (short)UCHAR_MAX);

    testassert([[NSNumber numberWithUnsignedChar:0] unsignedShortValue] == (unsigned short)0);
    testassert([[NSNumber numberWithUnsignedChar:42] unsignedShortValue] == (unsigned short)42);
    testassert([[NSNumber numberWithUnsignedChar:UCHAR_MAX] unsignedShortValue] == (unsigned short)UCHAR_MAX);

    testassert([[NSNumber numberWithUnsignedChar:0] intValue] == (int)0);
    testassert([[NSNumber numberWithUnsignedChar:42] intValue] == (int)42);
    testassert([[NSNumber numberWithUnsignedChar:UCHAR_MAX] intValue] == (int)UCHAR_MAX);

    testassert([[NSNumber numberWithUnsignedChar:0] unsignedIntValue] == (unsigned int)0);
    testassert([[NSNumber numberWithUnsignedChar:42] unsignedIntValue] == (unsigned int)42);
    testassert([[NSNumber numberWithUnsignedChar:UCHAR_MAX] unsignedIntValue] == (unsigned int)UCHAR_MAX);
    return YES;
}

test(NumberWithUnsignedChar2)
{

    testassert([[NSNumber numberWithUnsignedChar:0] integerValue] == (NSInteger)0);
    testassert([[NSNumber numberWithUnsignedChar:42] integerValue] == (NSInteger)42);
    testassert([[NSNumber numberWithUnsignedChar:UCHAR_MAX] integerValue] == (NSInteger)UCHAR_MAX);

    testassert([[NSNumber numberWithUnsignedChar:0] unsignedIntegerValue] == (NSUInteger)0);
    testassert([[NSNumber numberWithUnsignedChar:42] unsignedIntegerValue] == (NSUInteger)42);
    testassert([[NSNumber numberWithUnsignedChar:UCHAR_MAX] unsignedIntegerValue] == (NSUInteger)UCHAR_MAX);

    testassert([[NSNumber numberWithUnsignedChar:0] longValue] == (long)0);
    testassert([[NSNumber numberWithUnsignedChar:42] longValue] == (long)42);
    testassert([[NSNumber numberWithUnsignedChar:UCHAR_MAX] longValue] == (long)UCHAR_MAX);

    testassert([[NSNumber numberWithUnsignedChar:0] unsignedLongValue] == (unsigned long)0);
    testassert([[NSNumber numberWithUnsignedChar:42] unsignedLongValue] == (unsigned long)42);
    testassert([[NSNumber numberWithUnsignedChar:UCHAR_MAX] unsignedLongValue] == (unsigned long)UCHAR_MAX);

    testassert([[NSNumber numberWithUnsignedChar:0] longLongValue] == (long long)0);
    testassert([[NSNumber numberWithUnsignedChar:42] longLongValue] == (long long)42);
    testassert([[NSNumber numberWithUnsignedChar:UCHAR_MAX] longLongValue] == (long long)UCHAR_MAX);

    testassert([[NSNumber numberWithUnsignedChar:0] unsignedLongLongValue] == (unsigned long long)0);
    testassert([[NSNumber numberWithUnsignedChar:42] unsignedLongLongValue] == (unsigned long long)42);
    testassert([[NSNumber numberWithUnsignedChar:UCHAR_MAX] unsignedLongLongValue] == (unsigned long long)UCHAR_MAX);

    return YES;
}

test(NumberWithShort1)
{
    testassert([[NSNumber numberWithShort:0] boolValue] == NO);
    testassert([[NSNumber numberWithShort:-23] boolValue] == YES);
    testassert([[NSNumber numberWithShort:42] boolValue] == YES);
    testassert([[NSNumber numberWithShort:SHRT_MAX] boolValue] == YES);
    testassert([[NSNumber numberWithShort:SHRT_MIN] boolValue] == YES);

    testassert([[NSNumber numberWithShort:0] charValue] == (char)0);
    testassert([[NSNumber numberWithShort:-23] charValue] == (char)-23);
    testassert([[NSNumber numberWithShort:42] charValue] == (char)42);
    testassert([[NSNumber numberWithShort:SHRT_MAX] charValue] == (char)SHRT_MAX);
    testassert([[NSNumber numberWithShort:SHRT_MIN] charValue] == (char)SHRT_MIN);

    testassert([[NSNumber numberWithShort:0] unsignedCharValue] == (unsigned char)0);
    testassert([[NSNumber numberWithShort:-23] unsignedCharValue] == (unsigned char)-23);
    testassert([[NSNumber numberWithShort:42] unsignedCharValue] == (unsigned char)42);
    testassert([[NSNumber numberWithShort:SHRT_MAX] unsignedCharValue] == (unsigned char)SHRT_MAX);
    testassert([[NSNumber numberWithShort:SHRT_MIN] unsignedCharValue] == (unsigned char)SHRT_MIN);

    testassert([[NSNumber numberWithShort:0] shortValue] == (short)0);
    testassert([[NSNumber numberWithShort:-23] shortValue] == (short)-23);
    testassert([[NSNumber numberWithShort:42] shortValue] == (short)42);
    testassert([[NSNumber numberWithShort:SHRT_MAX] shortValue] == (short)SHRT_MAX);
    testassert([[NSNumber numberWithShort:SHRT_MIN] shortValue] == (short)SHRT_MIN);

    testassert([[NSNumber numberWithShort:0] unsignedShortValue] == (unsigned short)0);
    testassert([[NSNumber numberWithShort:-23] unsignedShortValue] == (unsigned short)-23);
    testassert([[NSNumber numberWithShort:42] unsignedShortValue] == (unsigned short)42);
    testassert([[NSNumber numberWithShort:SHRT_MAX] unsignedShortValue] == (unsigned short)SHRT_MAX);
    testassert([[NSNumber numberWithShort:SHRT_MIN] unsignedShortValue] == (unsigned short)SHRT_MIN);

    testassert([[NSNumber numberWithShort:0] intValue] == (int)0);
    testassert([[NSNumber numberWithShort:-23] intValue] == (int)-23);
    testassert([[NSNumber numberWithShort:42] intValue] == (int)42);
    testassert([[NSNumber numberWithShort:SHRT_MAX] intValue] == (int)SHRT_MAX);
    testassert([[NSNumber numberWithShort:SHRT_MIN] intValue] == (int)SHRT_MIN);

    testassert([[NSNumber numberWithShort:0] unsignedIntValue] == (unsigned int)0);
    testassert([[NSNumber numberWithShort:-23] unsignedIntValue] == (unsigned int)-23);
    testassert([[NSNumber numberWithShort:42] unsignedIntValue] == (unsigned int)42);
    testassert([[NSNumber numberWithShort:SHRT_MAX] unsignedIntValue] == (unsigned int)SHRT_MAX);
    testassert([[NSNumber numberWithShort:SHRT_MIN] unsignedIntValue] == (unsigned int)SHRT_MIN);

    return YES;
}

test(NumberWithShort2)
{
    testassert([[NSNumber numberWithShort:0] integerValue] == (NSInteger)0);
    testassert([[NSNumber numberWithShort:-23] integerValue] == (NSInteger)-23);
    testassert([[NSNumber numberWithShort:42] integerValue] == (NSInteger)42);
    testassert([[NSNumber numberWithShort:SHRT_MAX] integerValue] == (NSInteger)SHRT_MAX);
    testassert([[NSNumber numberWithShort:SHRT_MIN] integerValue] == (NSInteger)SHRT_MIN);

    testassert([[NSNumber numberWithShort:0] unsignedIntegerValue] == (NSUInteger)0);
    testassert([[NSNumber numberWithShort:-23] unsignedIntegerValue] == (NSUInteger)-23);
    testassert([[NSNumber numberWithShort:42] unsignedIntegerValue] == (NSUInteger)42);
    testassert([[NSNumber numberWithShort:SHRT_MAX] unsignedIntegerValue] == (NSUInteger)SHRT_MAX);
    testassert([[NSNumber numberWithShort:SHRT_MIN] unsignedIntegerValue] == (NSUInteger)SHRT_MIN);

    testassert([[NSNumber numberWithShort:0] longValue] == (long)0);
    testassert([[NSNumber numberWithShort:-23] longValue] == (long)-23);
    testassert([[NSNumber numberWithShort:42] longValue] == (long)42);
    testassert([[NSNumber numberWithShort:SHRT_MAX] longValue] == (long)SHRT_MAX);
    testassert([[NSNumber numberWithShort:SHRT_MIN] longValue] == (long)SHRT_MIN);

    testassert([[NSNumber numberWithShort:0] unsignedLongValue] == (unsigned long)0);
    testassert([[NSNumber numberWithShort:-23] unsignedLongValue] == (unsigned long)-23);
    testassert([[NSNumber numberWithShort:42] unsignedLongValue] == (unsigned long)42);
    testassert([[NSNumber numberWithShort:SHRT_MAX] unsignedLongValue] == (unsigned long)SHRT_MAX);
    testassert([[NSNumber numberWithShort:SHRT_MIN] unsignedLongValue] == (unsigned long)SHRT_MIN);

    testassert([[NSNumber numberWithShort:0] longLongValue] == (long long)0);
    testassert([[NSNumber numberWithShort:-23] longLongValue] == (long long)-23);
    testassert([[NSNumber numberWithShort:42] longLongValue] == (long long)42);
    testassert([[NSNumber numberWithShort:SHRT_MAX] longLongValue] == (long long)SHRT_MAX);
    testassert([[NSNumber numberWithShort:SHRT_MIN] longLongValue] == (long long)SHRT_MIN);

    testassert([[NSNumber numberWithShort:0] unsignedLongLongValue] == (unsigned long long)0);
    testassert([[NSNumber numberWithShort:-23] unsignedLongLongValue] == (unsigned long long)-23);
    testassert([[NSNumber numberWithShort:42] unsignedLongLongValue] == (unsigned long long)42);
    testassert([[NSNumber numberWithShort:SHRT_MAX] unsignedLongLongValue] == (unsigned long long)SHRT_MAX);
    testassert([[NSNumber numberWithShort:SHRT_MIN] unsignedLongLongValue] == (unsigned long long)SHRT_MIN);

    return YES;
}

test(NumberWithUnsignedShort1)
{
    testassert([[NSNumber numberWithUnsignedShort:0] boolValue] == NO);
    testassert([[NSNumber numberWithUnsignedShort:42] boolValue] == YES);
    testassert([[NSNumber numberWithUnsignedShort:USHRT_MAX] boolValue] == YES);

    testassert([[NSNumber numberWithUnsignedShort:0] charValue] == (char)0);
    testassert([[NSNumber numberWithUnsignedShort:42] charValue] == (char)42);
    testassert([[NSNumber numberWithUnsignedShort:USHRT_MAX] charValue] == (char)USHRT_MAX);

    testassert([[NSNumber numberWithUnsignedShort:0] unsignedCharValue] == (unsigned char)0);
    testassert([[NSNumber numberWithUnsignedShort:42] unsignedCharValue] == (unsigned char)42);
    testassert([[NSNumber numberWithUnsignedShort:USHRT_MAX] unsignedCharValue] == (unsigned char)USHRT_MAX);

    testassert([[NSNumber numberWithUnsignedShort:0] shortValue] == (short)0);
    testassert([[NSNumber numberWithUnsignedShort:42] shortValue] == (short)42);
    testassert([[NSNumber numberWithUnsignedShort:USHRT_MAX] shortValue] == (short)USHRT_MAX);

    testassert([[NSNumber numberWithUnsignedShort:0] unsignedShortValue] == (unsigned short)0);
    testassert([[NSNumber numberWithUnsignedShort:42] unsignedShortValue] == (unsigned short)42);
    testassert([[NSNumber numberWithUnsignedShort:USHRT_MAX] unsignedShortValue] == (unsigned short)USHRT_MAX);

    testassert([[NSNumber numberWithUnsignedShort:0] intValue] == (int)0);
    testassert([[NSNumber numberWithUnsignedShort:42] intValue] == (int)42);
    testassert([[NSNumber numberWithUnsignedShort:USHRT_MAX] intValue] == (int)USHRT_MAX);

    testassert([[NSNumber numberWithUnsignedShort:0] unsignedIntValue] == (unsigned int)0);
    testassert([[NSNumber numberWithUnsignedShort:42] unsignedIntValue] == (unsigned int)42);
    testassert([[NSNumber numberWithUnsignedShort:USHRT_MAX] unsignedIntValue] == (unsigned int)USHRT_MAX);

    return YES;
}

test(NumberWithUnsignedShort2)
{
    testassert([[NSNumber numberWithUnsignedShort:0] integerValue] == (NSInteger)0);
    testassert([[NSNumber numberWithUnsignedShort:42] integerValue] == (NSInteger)42);
    testassert([[NSNumber numberWithUnsignedShort:USHRT_MAX] integerValue] == (NSInteger)USHRT_MAX);

    testassert([[NSNumber numberWithUnsignedShort:0] unsignedIntegerValue] == (NSUInteger)0);
    testassert([[NSNumber numberWithUnsignedShort:42] unsignedIntegerValue] == (NSUInteger)42);
    testassert([[NSNumber numberWithUnsignedShort:USHRT_MAX] unsignedIntegerValue] == (NSUInteger)USHRT_MAX);

    testassert([[NSNumber numberWithUnsignedShort:0] longValue] == (long)0);
    testassert([[NSNumber numberWithUnsignedShort:42] longValue] == (long)42);
    testassert([[NSNumber numberWithUnsignedShort:USHRT_MAX] longValue] == (long)USHRT_MAX);

    testassert([[NSNumber numberWithUnsignedShort:0] unsignedLongValue] == (unsigned long)0);
    testassert([[NSNumber numberWithUnsignedShort:42] unsignedLongValue] == (unsigned long)42);
    testassert([[NSNumber numberWithUnsignedShort:USHRT_MAX] unsignedLongValue] == (unsigned long)USHRT_MAX);

    testassert([[NSNumber numberWithUnsignedShort:0] longLongValue] == (long long)0);
    testassert([[NSNumber numberWithUnsignedShort:42] longLongValue] == (long long)42);
    testassert([[NSNumber numberWithUnsignedShort:USHRT_MAX] longLongValue] == (long long)USHRT_MAX);

    testassert([[NSNumber numberWithUnsignedShort:0] unsignedLongLongValue] == (unsigned long long)0);
    testassert([[NSNumber numberWithUnsignedShort:42] unsignedLongLongValue] == (unsigned long long)42);
    testassert([[NSNumber numberWithUnsignedShort:USHRT_MAX] unsignedLongLongValue] == (unsigned long long)USHRT_MAX);

    return YES;
}

test(NumberWithInt1)
{
    testassert([[NSNumber numberWithInt:0] boolValue] == NO);
    testassert([[NSNumber numberWithInt:-23] boolValue] == YES);
    testassert([[NSNumber numberWithInt:42] boolValue] == YES);
    testassert([[NSNumber numberWithInt:INT_MAX] boolValue] == YES);
    testassert([[NSNumber numberWithInt:INT_MIN] boolValue] == YES);

    testassert([[NSNumber numberWithInt:0] charValue] == (char)0);
    testassert([[NSNumber numberWithInt:-23] charValue] == (char)-23);
    testassert([[NSNumber numberWithInt:42] charValue] == (char)42);
    testassert([[NSNumber numberWithInt:INT_MAX] charValue] == (char)INT_MAX);
    testassert([[NSNumber numberWithInt:INT_MIN] charValue] == (char)INT_MIN);

    testassert([[NSNumber numberWithInt:0] unsignedCharValue] == (unsigned char)0);
    testassert([[NSNumber numberWithInt:-23] unsignedCharValue] == (unsigned char)-23);
    testassert([[NSNumber numberWithInt:42] unsignedCharValue] == (unsigned char)42);
    testassert([[NSNumber numberWithInt:INT_MAX] unsignedCharValue] == (unsigned char)INT_MAX);
    testassert([[NSNumber numberWithInt:INT_MIN] unsignedCharValue] == (unsigned char)INT_MIN);

    testassert([[NSNumber numberWithInt:0] shortValue] == (short)0);
    testassert([[NSNumber numberWithInt:-23] shortValue] == (short)-23);
    testassert([[NSNumber numberWithInt:42] shortValue] == (short)42);
    testassert([[NSNumber numberWithInt:INT_MAX] shortValue] == (short)INT_MAX);
    testassert([[NSNumber numberWithInt:INT_MIN] shortValue] == (short)INT_MIN);

    testassert([[NSNumber numberWithInt:0] unsignedShortValue] == (unsigned short)0);
    testassert([[NSNumber numberWithInt:-23] unsignedShortValue] == (unsigned short)-23);
    testassert([[NSNumber numberWithInt:42] unsignedShortValue] == (unsigned short)42);
    testassert([[NSNumber numberWithInt:INT_MAX] unsignedShortValue] == (unsigned short)INT_MAX);
    testassert([[NSNumber numberWithInt:INT_MIN] unsignedShortValue] == (unsigned short)INT_MIN);

    testassert([[NSNumber numberWithInt:0] intValue] == (int)0);
    testassert([[NSNumber numberWithInt:-23] intValue] == (int)-23);
    testassert([[NSNumber numberWithInt:42] intValue] == (int)42);
    testassert([[NSNumber numberWithInt:INT_MAX] intValue] == (int)INT_MAX);
    testassert([[NSNumber numberWithInt:INT_MIN] intValue] == (int)INT_MIN);

    return YES;
}

test(NumberWithInt2)
{
    testassert([[NSNumber numberWithInt:0] unsignedIntValue] == (unsigned int)0);
    testassert([[NSNumber numberWithInt:-23] unsignedIntValue] == (unsigned int)-23);
    testassert([[NSNumber numberWithInt:42] unsignedIntValue] == (unsigned int)42);
    testassert([[NSNumber numberWithInt:INT_MAX] unsignedIntValue] == (unsigned int)INT_MAX);
    testassert([[NSNumber numberWithInt:INT_MIN] unsignedIntValue] == (unsigned int)INT_MIN);

    testassert([[NSNumber numberWithInt:0] integerValue] == (NSInteger)0);
    testassert([[NSNumber numberWithInt:-23] integerValue] == (NSInteger)-23);
    testassert([[NSNumber numberWithInt:42] integerValue] == (NSInteger)42);
    testassert([[NSNumber numberWithInt:INT_MAX] integerValue] == (NSInteger)INT_MAX);
    testassert([[NSNumber numberWithInt:INT_MIN] integerValue] == (NSInteger)INT_MIN);

    testassert([[NSNumber numberWithInt:0] unsignedIntegerValue] == (NSUInteger)0);
    testassert([[NSNumber numberWithInt:-23] unsignedIntegerValue] == (NSUInteger)-23);
    testassert([[NSNumber numberWithInt:42] unsignedIntegerValue] == (NSUInteger)42);
    testassert([[NSNumber numberWithInt:INT_MAX] unsignedIntegerValue] == (NSUInteger)INT_MAX);
    testassert([[NSNumber numberWithInt:INT_MIN] unsignedIntegerValue] == (NSUInteger)INT_MIN);

    testassert([[NSNumber numberWithInt:0] longValue] == (long)0);
    testassert([[NSNumber numberWithInt:-23] longValue] == (long)-23);
    testassert([[NSNumber numberWithInt:42] longValue] == (long)42);
    testassert([[NSNumber numberWithInt:INT_MAX] longValue] == (long)INT_MAX);
    testassert([[NSNumber numberWithInt:INT_MIN] longValue] == (long)INT_MIN);

    testassert([[NSNumber numberWithInt:0] unsignedLongValue] == (unsigned long)0);
    testassert([[NSNumber numberWithInt:-23] unsignedLongValue] == (unsigned long)-23);
    testassert([[NSNumber numberWithInt:42] unsignedLongValue] == (unsigned long)42);
    testassert([[NSNumber numberWithInt:INT_MAX] unsignedLongValue] == (unsigned long)INT_MAX);
    testassert([[NSNumber numberWithInt:INT_MIN] unsignedLongValue] == (unsigned long)INT_MIN);

    testassert([[NSNumber numberWithInt:0] longLongValue] == (long long)0);
    testassert([[NSNumber numberWithInt:-23] longLongValue] == (long long)-23);
    testassert([[NSNumber numberWithInt:42] longLongValue] == (long long)42);
    testassert([[NSNumber numberWithInt:INT_MAX] longLongValue] == (long long)INT_MAX);
    testassert([[NSNumber numberWithInt:INT_MIN] longLongValue] == (long long)INT_MIN);

    testassert([[NSNumber numberWithInt:0] unsignedLongLongValue] == (unsigned long long)0);
    testassert([[NSNumber numberWithInt:-23] unsignedLongLongValue] == (unsigned long long)-23);
    testassert([[NSNumber numberWithInt:42] unsignedLongLongValue] == (unsigned long long)42);
    testassert([[NSNumber numberWithInt:INT_MAX] unsignedLongLongValue] == (unsigned long long)INT_MAX);
    testassert([[NSNumber numberWithInt:INT_MIN] unsignedLongLongValue] == (unsigned long long)INT_MIN);

    return YES;
}

test(NumberWithUnsignedInt1)
{
    testassert([[NSNumber numberWithUnsignedInt:0] boolValue] == NO);
    testassert([[NSNumber numberWithUnsignedInt:42] boolValue] == YES);
    testassert([[NSNumber numberWithUnsignedInt:UINT_MAX] boolValue] == YES);

    testassert([[NSNumber numberWithUnsignedInt:0] charValue] == (char)0);
    testassert([[NSNumber numberWithUnsignedInt:42] charValue] == (char)42);
    testassert([[NSNumber numberWithUnsignedInt:UINT_MAX] charValue] == (char)UINT_MAX);

    testassert([[NSNumber numberWithUnsignedInt:0] unsignedCharValue] == (unsigned char)0);
    testassert([[NSNumber numberWithUnsignedInt:42] unsignedCharValue] == (unsigned char)42);
    testassert([[NSNumber numberWithUnsignedInt:UINT_MAX] unsignedCharValue] == (unsigned char)UINT_MAX);

    testassert([[NSNumber numberWithUnsignedInt:0] shortValue] == (short)0);
    testassert([[NSNumber numberWithUnsignedInt:42] shortValue] == (short)42);
    testassert([[NSNumber numberWithUnsignedInt:UINT_MAX] shortValue] == (short)UINT_MAX);

    testassert([[NSNumber numberWithUnsignedInt:0] unsignedShortValue] == (unsigned short)0);
    testassert([[NSNumber numberWithUnsignedInt:42] unsignedShortValue] == (unsigned short)42);
    testassert([[NSNumber numberWithUnsignedInt:UINT_MAX] unsignedShortValue] == (unsigned short)UINT_MAX);

    testassert([[NSNumber numberWithUnsignedInt:0] intValue] == (int)0);
    testassert([[NSNumber numberWithUnsignedInt:42] intValue] == (int)42);
    testassert([[NSNumber numberWithUnsignedInt:UINT_MAX] intValue] == (int)UINT_MAX);

    testassert([[NSNumber numberWithUnsignedInt:0] unsignedIntValue] == (unsigned int)0);
    testassert([[NSNumber numberWithUnsignedInt:42] unsignedIntValue] == (unsigned int)42);
    testassert([[NSNumber numberWithUnsignedInt:UINT_MAX] unsignedIntValue] == (unsigned int)UINT_MAX);

    return YES;
}

test(NumberWithUnsignedInt2)
{
    testassert([[NSNumber numberWithUnsignedInt:0] integerValue] == (NSInteger)0);
    testassert([[NSNumber numberWithUnsignedInt:42] integerValue] == (NSInteger)42);
    testassert([[NSNumber numberWithUnsignedInt:UINT_MAX] integerValue] == (NSInteger)UINT_MAX);

    testassert([[NSNumber numberWithUnsignedInt:0] unsignedIntegerValue] == (NSUInteger)0);
    testassert([[NSNumber numberWithUnsignedInt:42] unsignedIntegerValue] == (NSUInteger)42);
    testassert([[NSNumber numberWithUnsignedInt:UINT_MAX] unsignedIntegerValue] == (NSUInteger)UINT_MAX);

    testassert([[NSNumber numberWithUnsignedInt:0] longValue] == (long)0);
    testassert([[NSNumber numberWithUnsignedInt:42] longValue] == (long)42);
    testassert([[NSNumber numberWithUnsignedInt:UINT_MAX] longValue] == (long)UINT_MAX);

    testassert([[NSNumber numberWithUnsignedInt:0] unsignedLongValue] == (unsigned long)0);
    testassert([[NSNumber numberWithUnsignedInt:42] unsignedLongValue] == (unsigned long)42);
    testassert([[NSNumber numberWithUnsignedInt:UINT_MAX] unsignedLongValue] == (unsigned long)UINT_MAX);

    testassert([[NSNumber numberWithUnsignedInt:0] longLongValue] == (long long)0);
    testassert([[NSNumber numberWithUnsignedInt:42] longLongValue] == (long long)42);
    testassert([[NSNumber numberWithUnsignedInt:UINT_MAX] longLongValue] == (long long)UINT_MAX);

    testassert([[NSNumber numberWithUnsignedInt:0] unsignedLongLongValue] == (unsigned long long)0);
    testassert([[NSNumber numberWithUnsignedInt:42] unsignedLongLongValue] == (unsigned long long)42);
    testassert([[NSNumber numberWithUnsignedInt:UINT_MAX] unsignedLongLongValue] == (unsigned long long)UINT_MAX);

    return YES;
}

test(NumberWithLong1)
{
    testassert([[NSNumber numberWithLong:0] boolValue] == NO);
    testassert([[NSNumber numberWithLong:-23] boolValue] == YES);
    testassert([[NSNumber numberWithLong:42] boolValue] == YES);
    testassert([[NSNumber numberWithLong:LONG_MAX] boolValue] == YES);
#ifdef __LP64__
    testassert([[NSNumber numberWithLong:LONG_MIN] boolValue] == NO);
#else
    testassert([[NSNumber numberWithLong:LONG_MIN] boolValue] == YES);
#endif

    testassert([[NSNumber numberWithLong:0] charValue] == (char)0);
    testassert([[NSNumber numberWithLong:-23] charValue] == (char)-23);
    testassert([[NSNumber numberWithLong:42] charValue] == (char)42);
    testassert([[NSNumber numberWithLong:LONG_MAX] charValue] == (char)LONG_MAX);
    testassert([[NSNumber numberWithLong:LONG_MIN] charValue] == (char)LONG_MIN);

    testassert([[NSNumber numberWithLong:0] unsignedCharValue] == (unsigned char)0);
    testassert([[NSNumber numberWithLong:-23] unsignedCharValue] == (unsigned char)-23);
    testassert([[NSNumber numberWithLong:42] unsignedCharValue] == (unsigned char)42);
    testassert([[NSNumber numberWithLong:LONG_MAX] unsignedCharValue] == (unsigned char)LONG_MAX);
    testassert([[NSNumber numberWithLong:LONG_MIN] unsignedCharValue] == (unsigned char)LONG_MIN);

    testassert([[NSNumber numberWithLong:0] shortValue] == (short)0);
    testassert([[NSNumber numberWithLong:-23] shortValue] == (short)-23);
    testassert([[NSNumber numberWithLong:42] shortValue] == (short)42);
    testassert([[NSNumber numberWithLong:LONG_MAX] shortValue] == (short)LONG_MAX);
    testassert([[NSNumber numberWithLong:LONG_MIN] shortValue] == (short)LONG_MIN);

    testassert([[NSNumber numberWithLong:0] unsignedShortValue] == (unsigned short)0);
    testassert([[NSNumber numberWithLong:-23] unsignedShortValue] == (unsigned short)-23);
    testassert([[NSNumber numberWithLong:42] unsignedShortValue] == (unsigned short)42);
    testassert([[NSNumber numberWithLong:LONG_MAX] unsignedShortValue] == (unsigned short)LONG_MAX);
    testassert([[NSNumber numberWithLong:LONG_MIN] unsignedShortValue] == (unsigned short)LONG_MIN);

    testassert([[NSNumber numberWithLong:0] intValue] == (int)0);
    testassert([[NSNumber numberWithLong:-23] intValue] == (int)-23);
    testassert([[NSNumber numberWithLong:42] intValue] == (int)42);
    testassert([[NSNumber numberWithLong:LONG_MAX] intValue] == (int)LONG_MAX);
    testassert([[NSNumber numberWithLong:LONG_MIN] intValue] == (int)LONG_MIN);

    testassert([[NSNumber numberWithLong:0] unsignedIntValue] == (unsigned int)0);
    testassert([[NSNumber numberWithLong:-23] unsignedIntValue] == (unsigned int)-23);
    testassert([[NSNumber numberWithLong:42] unsignedIntValue] == (unsigned int)42);
    testassert([[NSNumber numberWithLong:LONG_MAX] unsignedIntValue] == (unsigned int)LONG_MAX);
    testassert([[NSNumber numberWithLong:LONG_MIN] unsignedIntValue] == (unsigned int)LONG_MIN);

    return YES;
}

test(NumberWithLong2)
{
    testassert([[NSNumber numberWithLong:0] integerValue] == (NSInteger)0);
    testassert([[NSNumber numberWithLong:-23] integerValue] == (NSInteger)-23);
    testassert([[NSNumber numberWithLong:42] integerValue] == (NSInteger)42);
    testassert([[NSNumber numberWithLong:LONG_MAX] integerValue] == (NSInteger)LONG_MAX);
    testassert([[NSNumber numberWithLong:LONG_MIN] integerValue] == (NSInteger)LONG_MIN);

    testassert([[NSNumber numberWithLong:0] unsignedIntegerValue] == (NSUInteger)0);
    testassert([[NSNumber numberWithLong:-23] unsignedIntegerValue] == (NSUInteger)-23);
    testassert([[NSNumber numberWithLong:42] unsignedIntegerValue] == (NSUInteger)42);
    testassert([[NSNumber numberWithLong:LONG_MAX] unsignedIntegerValue] == (NSUInteger)LONG_MAX);
    testassert([[NSNumber numberWithLong:LONG_MIN] unsignedIntegerValue] == (NSUInteger)LONG_MIN);

    testassert([[NSNumber numberWithLong:0] longValue] == (long)0);
    testassert([[NSNumber numberWithLong:-23] longValue] == (long)-23);
    testassert([[NSNumber numberWithLong:42] longValue] == (long)42);
    testassert([[NSNumber numberWithLong:LONG_MAX] longValue] == (long)LONG_MAX);
    testassert([[NSNumber numberWithLong:LONG_MIN] longValue] == (long)LONG_MIN);

    testassert([[NSNumber numberWithLong:0] unsignedLongValue] == (unsigned long)0);
    testassert([[NSNumber numberWithLong:-23] unsignedLongValue] == (unsigned long)-23);
    testassert([[NSNumber numberWithLong:42] unsignedLongValue] == (unsigned long)42);
    testassert([[NSNumber numberWithLong:LONG_MAX] unsignedLongValue] == (unsigned long)LONG_MAX);
    testassert([[NSNumber numberWithLong:LONG_MIN] unsignedLongValue] == (unsigned long)LONG_MIN);

    testassert([[NSNumber numberWithLong:0] longLongValue] == (long long)0);
    testassert([[NSNumber numberWithLong:-23] longLongValue] == (long long)-23);
    testassert([[NSNumber numberWithLong:42] longLongValue] == (long long)42);
    testassert([[NSNumber numberWithLong:LONG_MAX] longLongValue] == (long long)LONG_MAX);
    testassert([[NSNumber numberWithLong:LONG_MIN] longLongValue] == (long long)LONG_MIN);

    testassert([[NSNumber numberWithLong:0] unsignedLongLongValue] == (unsigned long long)0);
    testassert([[NSNumber numberWithLong:-23] unsignedLongLongValue] == (unsigned long long)-23);
    testassert([[NSNumber numberWithLong:42] unsignedLongLongValue] == (unsigned long long)42);
    testassert([[NSNumber numberWithLong:LONG_MAX] unsignedLongLongValue] == (unsigned long long)LONG_MAX);
    testassert([[NSNumber numberWithLong:LONG_MIN] unsignedLongLongValue] == (unsigned long long)LONG_MIN);

    return YES;
}

test(NumberWithUnsignedLong1)
{
    testassert([[NSNumber numberWithUnsignedLong:0] boolValue] == NO);
    testassert([[NSNumber numberWithUnsignedLong:42] boolValue] == YES);
    testassert([[NSNumber numberWithUnsignedLong:ULONG_MAX] boolValue] == YES);

    testassert([[NSNumber numberWithUnsignedLong:0] charValue] == (char)0);
    testassert([[NSNumber numberWithUnsignedLong:42] charValue] == (char)42);
    testassert([[NSNumber numberWithUnsignedLong:ULONG_MAX] charValue] == (char)ULONG_MAX);

    testassert([[NSNumber numberWithUnsignedLong:0] unsignedCharValue] == (unsigned char)0);
    testassert([[NSNumber numberWithUnsignedLong:42] unsignedCharValue] == (unsigned char)42);
    testassert([[NSNumber numberWithUnsignedLong:ULONG_MAX] unsignedCharValue] == (unsigned char)ULONG_MAX);

    testassert([[NSNumber numberWithUnsignedLong:0] shortValue] == (short)0);
    testassert([[NSNumber numberWithUnsignedLong:42] shortValue] == (short)42);
    testassert([[NSNumber numberWithUnsignedLong:ULONG_MAX] shortValue] == (short)ULONG_MAX);

    testassert([[NSNumber numberWithUnsignedLong:0] unsignedShortValue] == (unsigned short)0);
    testassert([[NSNumber numberWithUnsignedLong:42] unsignedShortValue] == (unsigned short)42);
    testassert([[NSNumber numberWithUnsignedLong:ULONG_MAX] unsignedShortValue] == (unsigned short)ULONG_MAX);

    testassert([[NSNumber numberWithUnsignedLong:0] intValue] == (int)0);
    testassert([[NSNumber numberWithUnsignedLong:42] intValue] == (int)42);
    testassert([[NSNumber numberWithUnsignedLong:ULONG_MAX] intValue] == (int)ULONG_MAX);

    testassert([[NSNumber numberWithUnsignedLong:0] unsignedIntValue] == (unsigned int)0);
    testassert([[NSNumber numberWithUnsignedLong:42] unsignedIntValue] == (unsigned int)42);
    testassert([[NSNumber numberWithUnsignedLong:ULONG_MAX] unsignedIntValue] == (unsigned int)ULONG_MAX);

    return YES;
}

test(NumberWithUnsignedLong2)
{
    testassert([[NSNumber numberWithUnsignedLong:0] integerValue] == (NSInteger)0);
    testassert([[NSNumber numberWithUnsignedLong:42] integerValue] == (NSInteger)42);
    testassert([[NSNumber numberWithUnsignedLong:ULONG_MAX] integerValue] == (NSInteger)ULONG_MAX);

    testassert([[NSNumber numberWithUnsignedLong:0] unsignedIntegerValue] == (NSUInteger)0);
    testassert([[NSNumber numberWithUnsignedLong:42] unsignedIntegerValue] == (NSUInteger)42);
    testassert([[NSNumber numberWithUnsignedLong:ULONG_MAX] unsignedIntegerValue] == (NSUInteger)ULONG_MAX);

    testassert([[NSNumber numberWithUnsignedLong:0] longValue] == (long)0);
    testassert([[NSNumber numberWithUnsignedLong:42] longValue] == (long)42);
    testassert([[NSNumber numberWithUnsignedLong:ULONG_MAX] longValue] == (long)ULONG_MAX);

    testassert([[NSNumber numberWithUnsignedLong:0] unsignedLongValue] == (unsigned long)0);
    testassert([[NSNumber numberWithUnsignedLong:42] unsignedLongValue] == (unsigned long)42);
    testassert([[NSNumber numberWithUnsignedLong:ULONG_MAX] unsignedLongValue] == (unsigned long)ULONG_MAX);

    testassert([[NSNumber numberWithUnsignedLong:0] longLongValue] == (long long)0);
    testassert([[NSNumber numberWithUnsignedLong:42] longLongValue] == (long long)42);
    testassert([[NSNumber numberWithUnsignedLong:ULONG_MAX] longLongValue] == (long long)ULONG_MAX);

    testassert([[NSNumber numberWithUnsignedLong:0] unsignedLongLongValue] == (unsigned long long)0);
    testassert([[NSNumber numberWithUnsignedLong:42] unsignedLongLongValue] == (unsigned long long)42);
    testassert([[NSNumber numberWithUnsignedLong:ULONG_MAX] unsignedLongLongValue] == (unsigned long long)ULONG_MAX);

    return YES;
}

/*!
 * @note the behavior of boolValue for long longs
 */

test(NumberWithLongLong1)
{
    testassert([[NSNumber numberWithLongLong:0] boolValue] == NO);
    testassert([[NSNumber numberWithLongLong:-23] boolValue] == YES);
    testassert([[NSNumber numberWithLongLong:42] boolValue] == YES);
    testassert([[NSNumber numberWithLongLong:LLONG_MAX] boolValue] == YES);

    testassert([[NSNumber numberWithLongLong:0] charValue] == (char)0);
    testassert([[NSNumber numberWithLongLong:-23] charValue] == (char)-23);
    testassert([[NSNumber numberWithLongLong:42] charValue] == (char)42);
    testassert([[NSNumber numberWithLongLong:LLONG_MAX] charValue] == (char)LLONG_MAX);
    testassert([[NSNumber numberWithLongLong:LLONG_MIN] charValue] == (char)LLONG_MIN);

    testassert([[NSNumber numberWithLongLong:0] unsignedCharValue] == (unsigned char)0);
    testassert([[NSNumber numberWithLongLong:-23] unsignedCharValue] == (unsigned char)-23);
    testassert([[NSNumber numberWithLongLong:42] unsignedCharValue] == (unsigned char)42);
    testassert([[NSNumber numberWithLongLong:LLONG_MAX] unsignedCharValue] == (unsigned char)LLONG_MAX);
    testassert([[NSNumber numberWithLongLong:LLONG_MIN] unsignedCharValue] == (unsigned char)LLONG_MIN);

    testassert([[NSNumber numberWithLongLong:0] shortValue] == (short)0);
    testassert([[NSNumber numberWithLongLong:-23] shortValue] == (short)-23);
    testassert([[NSNumber numberWithLongLong:42] shortValue] == (short)42);
    testassert([[NSNumber numberWithLongLong:LLONG_MAX] shortValue] == (short)LLONG_MAX);
    testassert([[NSNumber numberWithLongLong:LLONG_MIN] shortValue] == (short)LLONG_MIN);

    testassert([[NSNumber numberWithLongLong:0] unsignedShortValue] == (unsigned short)0);
    testassert([[NSNumber numberWithLongLong:-23] unsignedShortValue] == (unsigned short)-23);
    testassert([[NSNumber numberWithLongLong:42] unsignedShortValue] == (unsigned short)42);
    testassert([[NSNumber numberWithLongLong:LLONG_MAX] unsignedShortValue] == (unsigned short)LLONG_MAX);
    testassert([[NSNumber numberWithLongLong:LLONG_MIN] unsignedShortValue] == (unsigned short)LLONG_MIN);

    testassert([[NSNumber numberWithLongLong:0] intValue] == (int)0);
    testassert([[NSNumber numberWithLongLong:-23] intValue] == (int)-23);
    testassert([[NSNumber numberWithLongLong:42] intValue] == (int)42);
    testassert([[NSNumber numberWithLongLong:LLONG_MAX] intValue] == (int)LLONG_MAX);
    testassert([[NSNumber numberWithLongLong:LLONG_MIN] intValue] == (int)LLONG_MIN);

    testassert([[NSNumber numberWithLongLong:0] unsignedIntValue] == (unsigned int)0);
    testassert([[NSNumber numberWithLongLong:-23] unsignedIntValue] == (unsigned int)-23);
    testassert([[NSNumber numberWithLongLong:42] unsignedIntValue] == (unsigned int)42);
    testassert([[NSNumber numberWithLongLong:LLONG_MAX] unsignedIntValue] == (unsigned int)LLONG_MAX);
    testassert([[NSNumber numberWithLongLong:LLONG_MIN] unsignedIntValue] == (unsigned int)LLONG_MIN);

    testassert([[NSNumber numberWithLongLong:LLONG_MIN] boolValue] == NO); // iOS bug!

    return YES;
}

test(NumberWithLongLong2)
{
    testassert([[NSNumber numberWithLongLong:0] integerValue] == (NSInteger)0);
    testassert([[NSNumber numberWithLongLong:-23] integerValue] == (NSInteger)-23);
    testassert([[NSNumber numberWithLongLong:42] integerValue] == (NSInteger)42);
    testassert([[NSNumber numberWithLongLong:LLONG_MAX] integerValue] == (NSInteger)LLONG_MAX);
    testassert([[NSNumber numberWithLongLong:LLONG_MIN] integerValue] == (NSInteger)LLONG_MIN);

    testassert([[NSNumber numberWithLongLong:0] unsignedIntegerValue] == (NSUInteger)0);
    testassert([[NSNumber numberWithLongLong:-23] unsignedIntegerValue] == (NSUInteger)-23);
    testassert([[NSNumber numberWithLongLong:42] unsignedIntegerValue] == (NSUInteger)42);
    testassert([[NSNumber numberWithLongLong:LLONG_MAX] unsignedIntegerValue] == (NSUInteger)LLONG_MAX);
    testassert([[NSNumber numberWithLongLong:LLONG_MIN] unsignedIntegerValue] == (NSUInteger)LLONG_MIN);

    testassert([[NSNumber numberWithLongLong:0] longValue] == (long)0);
    testassert([[NSNumber numberWithLongLong:-23] longValue] == (long)-23);
    testassert([[NSNumber numberWithLongLong:42] longValue] == (long)42);
    testassert([[NSNumber numberWithLongLong:LLONG_MAX] longValue] == (long)LLONG_MAX);
    testassert([[NSNumber numberWithLongLong:LLONG_MIN] longValue] == (long)LLONG_MIN);

    testassert([[NSNumber numberWithLongLong:0] unsignedLongValue] == (unsigned long)0);
    testassert([[NSNumber numberWithLongLong:-23] unsignedLongValue] == (unsigned long)-23);
    testassert([[NSNumber numberWithLongLong:42] unsignedLongValue] == (unsigned long)42);
    testassert([[NSNumber numberWithLongLong:LLONG_MAX] unsignedLongValue] == (unsigned long)LLONG_MAX);
    testassert([[NSNumber numberWithLongLong:LLONG_MIN] unsignedLongValue] == (unsigned long)LLONG_MIN);

    testassert([[NSNumber numberWithLongLong:0] longLongValue] == (long long)0);
    testassert([[NSNumber numberWithLongLong:-23] longLongValue] == (long long)-23);
    testassert([[NSNumber numberWithLongLong:42] longLongValue] == (long long)42);
    testassert([[NSNumber numberWithLongLong:LLONG_MAX] longLongValue] == (long long)LLONG_MAX);
    testassert([[NSNumber numberWithLongLong:LLONG_MIN] longLongValue] == (long long)LLONG_MIN);

    testassert([[NSNumber numberWithLongLong:0] unsignedLongLongValue] == (unsigned long long)0);
    testassert([[NSNumber numberWithLongLong:-23] unsignedLongLongValue] == (unsigned long long)-23);
    testassert([[NSNumber numberWithLongLong:42] unsignedLongLongValue] == (unsigned long long)42);
    testassert([[NSNumber numberWithLongLong:LLONG_MAX] unsignedLongLongValue] == (unsigned long long)LLONG_MAX);
    testassert([[NSNumber numberWithLongLong:LLONG_MIN] unsignedLongLongValue] == (unsigned long long)LLONG_MIN);

    return YES;
}

test(NumberWithUnsignedLongLong1)
{
    testassert([[NSNumber numberWithUnsignedLongLong:0] boolValue] == NO);
    testassert([[NSNumber numberWithUnsignedLongLong:42] boolValue] == YES);
    testassert([[NSNumber numberWithUnsignedLongLong:ULLONG_MAX] boolValue] == YES);

    testassert([[NSNumber numberWithUnsignedLongLong:0] charValue] == (char)0);
    testassert([[NSNumber numberWithUnsignedLongLong:42] charValue] == (char)42);
    testassert([[NSNumber numberWithUnsignedLongLong:ULLONG_MAX] charValue] == (char)ULLONG_MAX);

    testassert([[NSNumber numberWithUnsignedLongLong:0] unsignedCharValue] == (unsigned char)0);
    testassert([[NSNumber numberWithUnsignedLongLong:42] unsignedCharValue] == (unsigned char)42);
    testassert([[NSNumber numberWithUnsignedLongLong:ULLONG_MAX] unsignedCharValue] == (unsigned char)ULLONG_MAX);

    testassert([[NSNumber numberWithUnsignedLongLong:0] shortValue] == (short)0);
    testassert([[NSNumber numberWithUnsignedLongLong:42] shortValue] == (short)42);
    testassert([[NSNumber numberWithUnsignedLongLong:ULLONG_MAX] shortValue] == (short)ULLONG_MAX);

    testassert([[NSNumber numberWithUnsignedLongLong:0] unsignedShortValue] == (unsigned short)0);
    testassert([[NSNumber numberWithUnsignedLongLong:42] unsignedShortValue] == (unsigned short)42);
    testassert([[NSNumber numberWithUnsignedLongLong:ULLONG_MAX] unsignedShortValue] == (unsigned short)ULLONG_MAX);

    testassert([[NSNumber numberWithUnsignedLongLong:0] intValue] == (int)0);
    testassert([[NSNumber numberWithUnsignedLongLong:42] intValue] == (int)42);
    testassert([[NSNumber numberWithUnsignedLongLong:ULLONG_MAX] intValue] == (int)ULLONG_MAX);

    testassert([[NSNumber numberWithUnsignedLongLong:0] unsignedIntValue] == (unsigned int)0);
    testassert([[NSNumber numberWithUnsignedLongLong:42] unsignedIntValue] == (unsigned int)42);
    testassert([[NSNumber numberWithUnsignedLongLong:ULLONG_MAX] unsignedIntValue] == (unsigned int)ULLONG_MAX);

    return YES;
}

test(NumberWithUnsignedLongLong2)
{
    testassert([[NSNumber numberWithUnsignedLongLong:0] integerValue] == (NSInteger)0);
    testassert([[NSNumber numberWithUnsignedLongLong:42] integerValue] == (NSInteger)42);
    testassert([[NSNumber numberWithUnsignedLongLong:ULLONG_MAX] integerValue] == (NSInteger)ULLONG_MAX);

    testassert([[NSNumber numberWithUnsignedLongLong:0] unsignedIntegerValue] == (NSUInteger)0);
    testassert([[NSNumber numberWithUnsignedLongLong:42] unsignedIntegerValue] == (NSUInteger)42);
    testassert([[NSNumber numberWithUnsignedLongLong:ULLONG_MAX] unsignedIntegerValue] == (NSUInteger)ULLONG_MAX);

    testassert([[NSNumber numberWithUnsignedLongLong:0] longValue] == (long)0);
    testassert([[NSNumber numberWithUnsignedLongLong:42] longValue] == (long)42);
    testassert([[NSNumber numberWithUnsignedLongLong:ULLONG_MAX] longValue] == (long)ULLONG_MAX);

    testassert([[NSNumber numberWithUnsignedLongLong:0] unsignedLongValue] == (unsigned long)0);
    testassert([[NSNumber numberWithUnsignedLongLong:42] unsignedLongValue] == (unsigned long)42);
    testassert([[NSNumber numberWithUnsignedLongLong:ULLONG_MAX] unsignedLongValue] == (unsigned long)ULLONG_MAX);

    testassert([[NSNumber numberWithUnsignedLongLong:0] longLongValue] == (long long)0);
    testassert([[NSNumber numberWithUnsignedLongLong:42] longLongValue] == (long long)42);
    testassert([[NSNumber numberWithUnsignedLongLong:ULLONG_MAX] longLongValue] == (long long)ULLONG_MAX);

    testassert([[NSNumber numberWithUnsignedLongLong:0] unsignedLongLongValue] == (unsigned long long)0);
    testassert([[NSNumber numberWithUnsignedLongLong:42] unsignedLongLongValue] == (unsigned long long)42);
    testassert([[NSNumber numberWithUnsignedLongLong:ULLONG_MAX] unsignedLongLongValue] == (unsigned long long)ULLONG_MAX);

    return YES;
}

test(NumberWithInteger1)
{
    testassert([[NSNumber numberWithInteger:0] boolValue] == NO);
    testassert([[NSNumber numberWithInteger:-23] boolValue] == YES);
    testassert([[NSNumber numberWithInteger:42] boolValue] == YES);
    testassert([[NSNumber numberWithInteger:NSIntegerMax] boolValue] == YES);
#ifdef __LP64__
    testassert([[NSNumber numberWithInteger:NSIntegerMin] boolValue] == NO); // mac bug
#else
    testassert([[NSNumber numberWithInteger:NSIntegerMin] boolValue] == YES);
#endif

    testassert([[NSNumber numberWithInteger:0] charValue] == (char)0);
    testassert([[NSNumber numberWithInteger:-23] charValue] == (char)-23);
    testassert([[NSNumber numberWithInteger:42] charValue] == (char)42);
    testassert([[NSNumber numberWithInteger:NSIntegerMax] charValue] == (char)NSIntegerMax);
    testassert([[NSNumber numberWithInteger:NSIntegerMin] charValue] == (char)NSIntegerMin);

    testassert([[NSNumber numberWithInteger:0] unsignedCharValue] == (unsigned char)0);
    testassert([[NSNumber numberWithInteger:-23] unsignedCharValue] == (unsigned char)-23);
    testassert([[NSNumber numberWithInteger:42] unsignedCharValue] == (unsigned char)42);
    testassert([[NSNumber numberWithInteger:NSIntegerMax] unsignedCharValue] == (unsigned char)NSIntegerMax);
    testassert([[NSNumber numberWithInteger:NSIntegerMin] unsignedCharValue] == (unsigned char)NSIntegerMin);

    testassert([[NSNumber numberWithInteger:0] shortValue] == (short)0);
    testassert([[NSNumber numberWithInteger:-23] shortValue] == (short)-23);
    testassert([[NSNumber numberWithInteger:42] shortValue] == (short)42);
    testassert([[NSNumber numberWithInteger:NSIntegerMax] shortValue] == (short)NSIntegerMax);
    testassert([[NSNumber numberWithInteger:NSIntegerMin] shortValue] == (short)NSIntegerMin);

    testassert([[NSNumber numberWithInteger:0] unsignedShortValue] == (unsigned short)0);
    testassert([[NSNumber numberWithInteger:-23] unsignedShortValue] == (unsigned short)-23);
    testassert([[NSNumber numberWithInteger:42] unsignedShortValue] == (unsigned short)42);
    testassert([[NSNumber numberWithInteger:NSIntegerMax] unsignedShortValue] == (unsigned short)NSIntegerMax);
    testassert([[NSNumber numberWithInteger:NSIntegerMin] unsignedShortValue] == (unsigned short)NSIntegerMin);

    testassert([[NSNumber numberWithInteger:0] intValue] == (int)0);
    testassert([[NSNumber numberWithInteger:-23] intValue] == (int)-23);
    testassert([[NSNumber numberWithInteger:42] intValue] == (int)42);
    testassert([[NSNumber numberWithInteger:NSIntegerMax] intValue] == (int)NSIntegerMax);
    testassert([[NSNumber numberWithInteger:NSIntegerMin] intValue] == (int)NSIntegerMin);

    testassert([[NSNumber numberWithInteger:0] unsignedIntValue] == (unsigned int)0);
    testassert([[NSNumber numberWithInteger:-23] unsignedIntValue] == (unsigned int)-23);
    testassert([[NSNumber numberWithInteger:42] unsignedIntValue] == (unsigned int)42);
    testassert([[NSNumber numberWithInteger:NSIntegerMax] unsignedIntValue] == (unsigned int)NSIntegerMax);
    testassert([[NSNumber numberWithInteger:NSIntegerMin] unsignedIntValue] == (unsigned int)NSIntegerMin);

    return YES;
}

test(NumberWithInteger2)
{
    testassert([[NSNumber numberWithInteger:0] integerValue] == (NSInteger)0);
    testassert([[NSNumber numberWithInteger:-23] integerValue] == (NSInteger)-23);
    testassert([[NSNumber numberWithInteger:42] integerValue] == (NSInteger)42);
    testassert([[NSNumber numberWithInteger:NSIntegerMax] integerValue] == (NSInteger)NSIntegerMax);
    testassert([[NSNumber numberWithInteger:NSIntegerMin] integerValue] == (NSInteger)NSIntegerMin);

    testassert([[NSNumber numberWithInteger:0] unsignedIntegerValue] == (NSUInteger)0);
    testassert([[NSNumber numberWithInteger:-23] unsignedIntegerValue] == (NSUInteger)-23);
    testassert([[NSNumber numberWithInteger:42] unsignedIntegerValue] == (NSUInteger)42);
    testassert([[NSNumber numberWithInteger:NSIntegerMax] unsignedIntegerValue] == (NSUInteger)NSIntegerMax);
    testassert([[NSNumber numberWithInteger:NSIntegerMin] unsignedIntegerValue] == (NSUInteger)NSIntegerMin);

    testassert([[NSNumber numberWithInteger:0] longValue] == (long)0);
    testassert([[NSNumber numberWithInteger:-23] longValue] == (long)-23);
    testassert([[NSNumber numberWithInteger:42] longValue] == (long)42);
    testassert([[NSNumber numberWithInteger:NSIntegerMax] longValue] == (long)NSIntegerMax);
    testassert([[NSNumber numberWithInteger:NSIntegerMin] longValue] == (long)NSIntegerMin);

    testassert([[NSNumber numberWithInteger:0] unsignedLongValue] == (unsigned long)0);
    testassert([[NSNumber numberWithInteger:-23] unsignedLongValue] == (unsigned long)-23);
    testassert([[NSNumber numberWithInteger:42] unsignedLongValue] == (unsigned long)42);
    testassert([[NSNumber numberWithInteger:NSIntegerMax] unsignedLongValue] == (unsigned long)NSIntegerMax);
    testassert([[NSNumber numberWithInteger:NSIntegerMin] unsignedLongValue] == (unsigned long)NSIntegerMin);

    testassert([[NSNumber numberWithInteger:0] longLongValue] == (long long)0);
    testassert([[NSNumber numberWithInteger:-23] longLongValue] == (long long)-23);
    testassert([[NSNumber numberWithInteger:42] longLongValue] == (long long)42);
    testassert([[NSNumber numberWithInteger:NSIntegerMax] longLongValue] == (long long)NSIntegerMax);
    testassert([[NSNumber numberWithInteger:NSIntegerMin] longLongValue] == (long long)NSIntegerMin);

    testassert([[NSNumber numberWithInteger:0] unsignedLongLongValue] == (unsigned long long)0);
    testassert([[NSNumber numberWithInteger:-23] unsignedLongLongValue] == (unsigned long long)-23);
    testassert([[NSNumber numberWithInteger:42] unsignedLongLongValue] == (unsigned long long)42);
    testassert([[NSNumber numberWithInteger:NSIntegerMax] unsignedLongLongValue] == (unsigned long long)NSIntegerMax);
    testassert([[NSNumber numberWithInteger:NSIntegerMin] unsignedLongLongValue] == (unsigned long long)NSIntegerMin);

    return YES;
}

test(NumberWithUnsignedInteger1)
{
    testassert([[NSNumber numberWithUnsignedInteger:0] boolValue] == NO);
    testassert([[NSNumber numberWithUnsignedInteger:42] boolValue] == YES);
    testassert([[NSNumber numberWithUnsignedInteger:NSUIntegerMax] boolValue] == YES);

    testassert([[NSNumber numberWithUnsignedInteger:0] charValue] == (char)0);
    testassert([[NSNumber numberWithUnsignedInteger:42] charValue] == (char)42);
    testassert([[NSNumber numberWithUnsignedInteger:NSUIntegerMax] charValue] == (char)NSUIntegerMax);

    testassert([[NSNumber numberWithUnsignedInteger:0] unsignedCharValue] == (unsigned char)0);
    testassert([[NSNumber numberWithUnsignedInteger:42] unsignedCharValue] == (unsigned char)42);
    testassert([[NSNumber numberWithUnsignedInteger:NSUIntegerMax] unsignedCharValue] == (unsigned char)NSUIntegerMax);

    testassert([[NSNumber numberWithUnsignedInteger:0] shortValue] == (short)0);
    testassert([[NSNumber numberWithUnsignedInteger:42] shortValue] == (short)42);
    testassert([[NSNumber numberWithUnsignedInteger:NSUIntegerMax] shortValue] == (short)NSUIntegerMax);

    testassert([[NSNumber numberWithUnsignedInteger:0] unsignedShortValue] == (unsigned short)0);
    testassert([[NSNumber numberWithUnsignedInteger:42] unsignedShortValue] == (unsigned short)42);
    testassert([[NSNumber numberWithUnsignedInteger:NSUIntegerMax] unsignedShortValue] == (unsigned short)NSUIntegerMax);

    testassert([[NSNumber numberWithUnsignedInteger:0] intValue] == (int)0);
    testassert([[NSNumber numberWithUnsignedInteger:42] intValue] == (int)42);
    testassert([[NSNumber numberWithUnsignedInteger:NSUIntegerMax] intValue] == (int)NSUIntegerMax);

    return YES;
}

test(NumberWithUnsignedInteger2)
{
    testassert([[NSNumber numberWithUnsignedInteger:0] unsignedIntValue] == (unsigned int)0);
    testassert([[NSNumber numberWithUnsignedInteger:42] unsignedIntValue] == (unsigned int)42);
    testassert([[NSNumber numberWithUnsignedInteger:NSUIntegerMax] unsignedIntValue] == (unsigned int)NSUIntegerMax);

    testassert([[NSNumber numberWithUnsignedInteger:0] integerValue] == (NSInteger)0);
    testassert([[NSNumber numberWithUnsignedInteger:42] integerValue] == (NSInteger)42);
    testassert([[NSNumber numberWithUnsignedInteger:NSUIntegerMax] integerValue] == (NSInteger)NSUIntegerMax);

    testassert([[NSNumber numberWithUnsignedInteger:0] unsignedIntegerValue] == (NSUInteger)0);
    testassert([[NSNumber numberWithUnsignedInteger:42] unsignedIntegerValue] == (NSUInteger)42);
    testassert([[NSNumber numberWithUnsignedInteger:NSUIntegerMax] unsignedIntegerValue] == (NSUInteger)NSUIntegerMax);

    testassert([[NSNumber numberWithUnsignedInteger:0] longValue] == (long)0);
    testassert([[NSNumber numberWithUnsignedInteger:42] longValue] == (long)42);
    testassert([[NSNumber numberWithUnsignedInteger:NSUIntegerMax] longValue] == (long)NSUIntegerMax);

    testassert([[NSNumber numberWithUnsignedInteger:0] unsignedLongValue] == (unsigned long)0);
    testassert([[NSNumber numberWithUnsignedInteger:42] unsignedLongValue] == (unsigned long)42);
    testassert([[NSNumber numberWithUnsignedInteger:NSUIntegerMax] unsignedLongValue] == (unsigned long)NSUIntegerMax);

    testassert([[NSNumber numberWithUnsignedInteger:0] longLongValue] == (long long)0);
    testassert([[NSNumber numberWithUnsignedInteger:42] longLongValue] == (long long)42);
    testassert([[NSNumber numberWithUnsignedInteger:NSUIntegerMax] longLongValue] == (long long)NSUIntegerMax);

    testassert([[NSNumber numberWithUnsignedInteger:0] unsignedLongLongValue] == (unsigned long long)0);
    testassert([[NSNumber numberWithUnsignedInteger:42] unsignedLongLongValue] == (unsigned long long)42);
    testassert([[NSNumber numberWithUnsignedInteger:NSUIntegerMax] unsignedIntegerValue] == (unsigned long long)NSUIntegerMax);

    return YES;
}


test(IsNumber)
{
    NSNumber *n = [NSNumber numberWithBool:YES];
    testassert([n isNSNumber__]);
    testassert([@"abc" isNSNumber__] == NO);

    return YES;
}

test(Strtod)
{
    double d = strtod("1.99", NULL);
    testassert(d == 1.99);
    return YES;
}

#warning TODO strtod_l implementation
//test(Strtod_l)
//{
//    double d = strtod_l("1.99", NULL, NULL);
//    testassert(d == 1.99);
//    return YES;
//}

test(NumberComparisons)
{
    BOOL exception = NO;
    @try {
        exception = NO;
        [[NSNumber numberWithInt:42] compare:nil];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([e.name isEqualToString:NSInvalidArgumentException]);
    }
    testassert(exception);

#warning TODO : more comparisons ...
    return YES;
}

#warning TODO: floating point types, stringValue

@end
