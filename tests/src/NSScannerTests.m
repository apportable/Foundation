//
//  NSScannerTests.m
//  FoundationTests
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "FoundationTests.h"

#include "objc/runtime.h"

@testcase(NSScanner)

test(ScannerWithStringNil)
{
    NSScanner* scanner = [NSScanner scannerWithString:nil];

    testassert([scanner.string isEqualToString:@""]);

    testassert(scanner.isAtEnd);

    return YES;
}

test(ScannerWithStringEmpty)
{
    NSScanner* scanner = [NSScanner scannerWithString:@""];

    testassert([scanner.string isEqualToString:@""]);

    int value = -1;
    testassert(![scanner scanInt:&value]);
    testassert(value == -1);

    return YES;
}

test(ScannerWithStringSpaces)
{
    NSScanner* scanner = [NSScanner scannerWithString:@"    "];

    int value = -1;
    testassert(![scanner scanInt:&value]);
    testassert(value == -1);
    testassert([scanner scanLocation] == 0);

    return YES;
}

test(ScannerIsAtEnd)
{
    NSScanner* scanner = [NSScanner scannerWithString:@"ABC"];
    testassert(![scanner isAtEnd]);
    scanner.scanLocation = 3;
    testassert([scanner isAtEnd]);

    scanner = [NSScanner scannerWithString:@"ABC  \n\t"];
    scanner.scanLocation = 3;
    testassert(scanner.isAtEnd);
    testassert(scanner.scanLocation == 3);

    return YES;
}

test(ScannerWithStringNotEmpty)
{
    NSScanner* scanner = [NSScanner scannerWithString:@"123"];

    testassert([scanner.string isEqualToString:@"123"]);

    int value = -1;
    testassert([scanner scanInt:&value]);
    testassert(value == 123);
    testassert([scanner scanLocation] == 3);
    return YES;
}

test(ScannerWithStringLeadingSpaces)
{
    NSScanner* scanner = [NSScanner scannerWithString:@"  123"];

    testassert([scanner.string isEqualToString:@"  123"]);

    int value = -1;
    testassert([scanner scanInt:&value]);
    testassert(value == 123);
    testassert([scanner scanLocation] == 5);
    return YES;
}

test(ScannerWithStringNegative)
{
    NSScanner* scanner = [NSScanner scannerWithString:@"   -123 14"];

    testassert([scanner.string isEqualToString:@"   -123 14"]);

    int value = -1;
    testassert([scanner scanInt:&value]);
    testassert(value == -123);
    testassert([scanner scanLocation] == 7);
    return YES;
}

test(ScannerWithStringOverflow)
{
    NSScanner* scanner = [NSScanner scannerWithString:@"12345678901"];

    int value = -1;
    testassert([scanner scanInt:&value]);
    testassert(value == INT_MAX);
    testassert([scanner scanLocation] == 11);
    return YES;
}

test(ScanInteger)
{
    NSScanner* scanner = [NSScanner scannerWithString:@"123"];
    NSInteger value = -1;
    testassert([scanner scanInteger:&value]);
    testassert(value == 123);
    testassert([scanner scanLocation] == 3);
    return YES;
}

test(ScanInt_Empty)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@""];
    int value = 0;
    testassert(![scanner scanInt:&value]);
    testassert(value == 0);
    testassert([scanner scanLocation] == 0);

    return YES;
}

test(ScanInt_Nil)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"0"];
    testassert([scanner scanInt:nil]);
    testassert([scanner scanLocation] == 1);

    return YES;
}

test(ScanInt_Uninitialized)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"feefiefofum"];
    int value = 0xDEADC0DE;
    testassert(![scanner scanInt:&value]);
    testassert(value == 0xDEADC0DE);
    testassert([scanner scanLocation] == 0);

    return YES;
}

test(ScanInt_Dot)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"."];
    int value = 0;

    testassert(![scanner scanInt:&value]);
    testassert(value == 0);
    testassert([scanner scanLocation] == 0);

    return YES;
}

test(ScanInt_ZeroDot)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"0."];
    int value = 0;

    testassert([scanner scanInt:&value]);
    testassert(value == 0);
    testassert([scanner scanLocation] == 1);

    return YES;
}

test(ScanInt_Zero)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"0"];
    int value = 0;

    testassert([scanner scanInt:&value]);
    testassert(value == 0);
    testassert([scanner scanLocation] == 1);

    return YES;
}

test(ScanInt_Zeroes)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"000000000000"];
    int value = 0;

    testassert([scanner scanInt:&value]);
    testassert(value == 0);
    testassert([scanner scanLocation] == 12);

    return YES;
}

test(ScanInt_Dots)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"............"];
    int value = 0;

    testassert(![scanner scanInt:&value]);
    testassert(value == 0);
    testassert([scanner scanLocation] == 0);

    return YES;
}

test(ScanInt_DotsAndStuff)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"1.0."];
    int value = 0;

    testassert([scanner scanInt:&value]);
    testassert(value == 1.0);
    testassert([scanner scanLocation] == 1);

    return YES;
}

test(ScanInt_Minus)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"-"];
    int value = 0;

    testassert(![scanner scanInt:&value]);
    testassert(value == 0);
    testassert([scanner scanLocation] == 0);

    return YES;
}

test(ScanInt_Minuses)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"-------"];
    int value = 0;

    testassert(![scanner scanInt:&value]);
    testassert(value == 0);
    testassert([scanner scanLocation] == 0);

    return YES;
}

test(ScanInt_Pluses)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"+++++++++"];
    int value = 0;

    testassert(![scanner scanInt:&value]);
    testassert(value == 0);
    testassert([scanner scanLocation] == 0);

    return YES;
}

test(ScanInt_Plus)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"+"];
    int value = 0;

    testassert(![scanner scanInt:&value]);
    testassert(value == 0);
    testassert([scanner scanLocation] == 0);

    return YES;
}

test(ScanInt_NegativeZero)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"-0.000"];
    int value = 0;

    testassert([scanner scanInt:&value]);
    testassert(value == 0);
    testassert([scanner scanLocation] == 2);

    return YES;
}

test(ScanInt_PlusZero)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"+0.000"];
    int value = 0;

    testassert([scanner scanInt:&value]);
    testassert(value == 0);
    testassert([scanner scanLocation] == 2);

    return YES;
}

test(ScannerWithLongLong)
{
    NSScanner* scanner = [NSScanner scannerWithString:@"12345678901"];

    long long value = -1;
    testassert([scanner scanLongLong:&value]);
    testassert(value == 12345678901);
    testassert([scanner scanLocation] == 11);
    return YES;
}

test(ScannerWithNegativeLongLong)
{
    NSScanner* scanner = [NSScanner scannerWithString:@"-98712345678901"];

    long long value = -1;
    testassert([scanner scanLongLong:&value]);
    testassert(value == -98712345678901);
    testassert([scanner scanLocation] == 15);
    return YES;
}

test(ScanLongLong_Empty)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@""];
    long long value = 0LL;
    testassert(![scanner scanLongLong:&value]);
    testassert(value == 0LL);
    testassert([scanner scanLocation] == 0);

    return YES;
}

test(ScanLongLong_Nil)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"0"];
    testassert([scanner scanLongLong:nil]);
    testassert([scanner scanLocation] == 1);

    return YES;
}

test(ScanLongLong_Uninitialized)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"feefiefofum"];
    long long value = 0xDEADCAFEBEEFC0DE;
    testassert(![scanner scanLongLong:&value]);
    testassert(value == 0xDEADCAFEBEEFC0DE);
    testassert([scanner scanLocation] == 0);

    return YES;
}

test(ScanLongLong_Dot)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"."];
    long long value = 0LL;

    testassert(![scanner scanLongLong:&value]);
    testassert(value == 0LL);
    testassert([scanner scanLocation] == 0);

    return YES;
}

test(ScanLongLong_ZeroDot)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"0."];
    long long value = 0LL;

    testassert([scanner scanLongLong:&value]);
    testassert(value == 0LL);
    testassert([scanner scanLocation] == 1);

    return YES;
}

test(ScanLongLong_Zero)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"0"];
    long long value = 0LL;

    testassert([scanner scanLongLong:&value]);
    testassert(value == 0LL);
    testassert([scanner scanLocation] == 1);

    return YES;
}

test(ScanLongLong_Zeroes)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"000000000000"];
    long long value = 0LL;

    testassert([scanner scanLongLong:&value]);
    testassert(value == 0LL);
    testassert([scanner scanLocation] == 12);

    return YES;
}

test(ScanLongLong_Dots)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"............"];
    long long value = 0LL;

    testassert(![scanner scanLongLong:&value]);
    testassert(value == 0LL);
    testassert([scanner scanLocation] == 0);

    return YES;
}

test(ScanLongLong_DotsAndStuff)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"1.0."];
    long long value = 0LL;

    testassert([scanner scanLongLong:&value]);
    testassert(value == 1.0);
    testassert([scanner scanLocation] == 1);

    return YES;
}

test(ScanLongLong_Minus)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"-"];
    long long value = 0LL;

    testassert(![scanner scanLongLong:&value]);
    testassert(value == 0LL);
    testassert([scanner scanLocation] == 0);

    return YES;
}

test(ScanLongLong_Minuses)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"-------"];
    long long value = 0LL;

    testassert(![scanner scanLongLong:&value]);
    testassert(value == 0LL);
    testassert([scanner scanLocation] == 0);

    return YES;
}

test(ScanLongLong_Pluses)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"+++++++++"];
    long long value = 0LL;

    testassert(![scanner scanLongLong:&value]);
    testassert(value == 0LL);
    testassert([scanner scanLocation] == 0);

    return YES;
}

test(ScanLongLong_Plus)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"+"];
    long long value = 0LL;

    testassert(![scanner scanLongLong:&value]);
    testassert(value == 0LL);
    testassert([scanner scanLocation] == 0);

    return YES;
}

test(ScanLongLong_NegativeZero)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"-0.000"];
    long long value = 0LL;

    testassert([scanner scanLongLong:&value]);
    testassert(value == 0LL);
    testassert([scanner scanLocation] == 2);

    return YES;
}

test(ScanLongLong_PlusZero)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"+0.000"];
    long long value = 0LL;

    testassert([scanner scanLongLong:&value]);
    testassert(value == 0LL);
    testassert([scanner scanLocation] == 2);

    return YES;
}

test(ScanHexInt)
{
    NSScanner* scanner = [NSScanner scannerWithString:@"0x1a3 4444"];
    unsigned value = -1;
    testassert([scanner scanHexInt:&value]);
    testassert(value == 0x1a3);
    testassert([scanner scanLocation] == 5);

    testassert([scanner scanHexInt:&value]);
    testassert(value == 0x4444);
    testassert([scanner scanLocation] == 10);
    return YES;
}

test(ScanHexInt_Empty)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@""];
    unsigned value = 0;
    testassert(![scanner scanHexInt:&value]);
    testassert(value == 0);
    testassert([scanner scanLocation] == 0);

    return YES;
}

test(ScanHexInt_Nil)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"0x0"];
    testassert([scanner scanHexInt:nil]);
    testassert([scanner scanLocation] == 3);

    return YES;
}

test(ScanHexInt_Uninitialized)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"NOfeefiefofum"];
    unsigned value = 0xDEADCAFE;
    testassert(![scanner scanHexInt:&value]);
    testassert(value == 0xDEADCAFE);
    testassert([scanner scanLocation] == 0);

    return YES;
}

test(ScanHexInt_Dot)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"."];
    unsigned value = 0;

    testassert(![scanner scanHexInt:&value]);
    testassert(value == 0);
    testassert([scanner scanLocation] == 0);

    return YES;
}

test(ScanHexInt_ZeroDot)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"0."];
    unsigned value = 0;

    testassert([scanner scanHexInt:&value]);
    testassert(value == 0);
    testassert([scanner scanLocation] == 1);

    return YES;
}

test(ScanHexInt_Zero)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"0"];
    unsigned value = 0;

    testassert([scanner scanHexInt:&value]);
    testassert(value == 0);
    testassert([scanner scanLocation] == 1);

    return YES;
}

test(ScanHexInt_Zeroes)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"000000000000"];
    unsigned value = 0;

    testassert([scanner scanHexInt:&value]);
    testassert(value == 0);
    testassert([scanner scanLocation] == 12);

    return YES;
}

test(ScanHexInt_Dots)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"............"];
    unsigned value = 0;

    testassert(![scanner scanHexInt:&value]);
    testassert(value == 0);
    testassert([scanner scanLocation] == 0);

    return YES;
}

test(ScanHexInt_DotsAndStuff)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"1.0."];
    unsigned value = 0;

    testassert([scanner scanHexInt:&value]);
    testassert(value == 1.0);
    testassert([scanner scanLocation] == 1);

    return YES;
}

test(ScanHexInt_Minus)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"-"];
    unsigned value = 0;

    testassert(![scanner scanHexInt:&value]);
    testassert(value == 0);
    testassert([scanner scanLocation] == 0);

    return YES;
}

test(ScanHexInt_Minuses)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"-------"];
    unsigned value = 0;

    testassert(![scanner scanHexInt:&value]);
    testassert(value == 0);
    testassert([scanner scanLocation] == 0);

    return YES;
}

test(ScanHexInt_Pluses)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"+++++++++"];
    unsigned value = 0;

    testassert(![scanner scanHexInt:&value]);
    testassert(value == 0);
    testassert([scanner scanLocation] == 0);

    return YES;
}

test(ScanHexInt_Plus)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"+"];
    unsigned value = 0;

    testassert(![scanner scanHexInt:&value]);
    testassert(value == 0);
    testassert([scanner scanLocation] == 0);

    return YES;
}

test(ScanHexInt_NegativeZero)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"-0.000"];
    unsigned value = 0;

    testassert(![scanner scanHexInt:&value]);
    testassert(value == 0);
    testassert([scanner scanLocation] == 0);

    return YES;
}

test(ScanHexInt_PlusZero)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"+0.000"];
    unsigned value = 0;

    testassert(![scanner scanHexInt:&value]);
    testassert(value == 0);
    testassert([scanner scanLocation] == 0);

    return YES;
}

test(ScannerHexLongLong)
{
    NSScanner* scanner = [NSScanner scannerWithString:@"f7 0x1234abCDe01"];

    unsigned long long value = -1;
    testassert([scanner scanHexLongLong:&value]);
    testassert(value == 0xf7);
    testassert([scanner scanLocation] == 2);

    testassert([scanner scanHexLongLong:&value]);
    testassert(value == 0x1234abCDe01);
    testassert([scanner scanLocation] == 16);
    return YES;
}

test(ScanHexLongLong_Empty)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@""];
    unsigned long long value = 0LL;
    testassert(![scanner scanHexLongLong:&value]);
    testassert(value == 0LL);
    testassert([scanner scanLocation] == 0);

    return YES;
}

test(ScanHexLongLong_Nil)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"0x0"];
    testassert([scanner scanHexLongLong:nil]);
    testassert([scanner scanLocation] == 3);

    return YES;
}

test(ScanHexLongLong_Uninitialized)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"NOfeefiefofum"];
    unsigned long long value = 0xDEADCAFEBEEFC0DE;
    testassert(![scanner scanHexLongLong:&value]);
    testassert(value == 0xDEADCAFEBEEFC0DE);
    testassert([scanner scanLocation] == 0);

    return YES;
}

test(ScanHexLongLong_Dot)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"."];
    unsigned long long value = 0LL;

    testassert(![scanner scanHexLongLong:&value]);
    testassert(value == 0LL);
    testassert([scanner scanLocation] == 0);

    return YES;
}

test(ScanHexLongLong_ZeroDot)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"0."];
    unsigned long long value = 0LL;

    testassert([scanner scanHexLongLong:&value]);
    testassert(value == 0LL);
    testassert([scanner scanLocation] == 1);

    return YES;
}

test(ScanHexLongLong_Zero)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"0"];
    unsigned long long value = 0LL;

    testassert([scanner scanHexLongLong:&value]);
    testassert(value == 0LL);
    testassert([scanner scanLocation] == 1);

    return YES;
}

test(ScanHexLongLong_Zeroes)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"000000000000"];
    unsigned long long value = 0LL;

    testassert([scanner scanHexLongLong:&value]);
    testassert(value == 0LL);
    testassert([scanner scanLocation] == 12);

    return YES;
}

test(ScanHexLongLong_Dots)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"............"];
    unsigned long long value = 0LL;

    testassert(![scanner scanHexLongLong:&value]);
    testassert(value == 0LL);
    testassert([scanner scanLocation] == 0);

    return YES;
}

test(ScanHexLongLong_DotsAndStuff)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"1.0."];
    unsigned long long value = 0LL;

    testassert([scanner scanHexLongLong:&value]);
    testassert(value == 1.0);
    testassert([scanner scanLocation] == 1);

    return YES;
}

test(ScanHexLongLong_Minus)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"-"];
    unsigned long long value = 0LL;

    testassert(![scanner scanHexLongLong:&value]);
    testassert(value == 0LL);
    testassert([scanner scanLocation] == 0);

    return YES;
}

test(ScanHexLongLong_Minuses)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"-------"];
    unsigned long long value = 0LL;

    testassert(![scanner scanHexLongLong:&value]);
    testassert(value == 0LL);
    testassert([scanner scanLocation] == 0);

    return YES;
}

test(ScanHexLongLong_Pluses)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"+++++++++"];
    unsigned long long value = 0LL;

    testassert(![scanner scanHexLongLong:&value]);
    testassert(value == 0LL);
    testassert([scanner scanLocation] == 0);

    return YES;
}

test(ScanHexLongLong_Plus)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"+"];
    unsigned long long value = 0LL;

    testassert(![scanner scanHexLongLong:&value]);
    testassert(value == 0LL);
    testassert([scanner scanLocation] == 0);

    return YES;
}

test(ScanHexLongLong_NegativeZero)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"-0.000"];
    unsigned long long value = 0LL;

    testassert(![scanner scanHexLongLong:&value]);
    testassert(value == 0LL);
    testassert([scanner scanLocation] == 0);

    return YES;
}

test(ScanHexLongLong_PlusZero)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"+0.000"];
    unsigned long long value = 0LL;

    testassert(![scanner scanHexLongLong:&value]);
    testassert(value == 0LL);
    testassert([scanner scanLocation] == 0);

    return YES;
}

test(ScannerWithSLongLongOverflow)
{
    NSScanner* scanner = [NSScanner scannerWithString:@"  -9223372036854775809 "];

    long long value = -1;
    testassert([scanner scanLongLong:&value]);
    testassert(value == LONG_LONG_MIN);
    testassert([scanner scanLocation] == 22);
    return YES;
}

test(ScanFloat)
{
    NSScanner* scanner = [NSScanner scannerWithString:@"123"];
    float value = -1.f;
    testassert([scanner scanFloat:&value]);
    testassert(value == 123.f);
    testassert([scanner scanLocation] == 3);
    return YES;
}

test(ScanFloat2)
{
    NSScanner* scanner = [NSScanner scannerWithString:@" 123.5000 "];  // terminating binary for equality test
    float value = -1.f;
    testassert([scanner scanFloat:&value]);
    testassert(value == 123.5f);
    testassert([scanner scanLocation] == 9);
    return YES;
}

test(ScanFloat_Empty)
{
    NSScanner* scanner = [NSScanner scannerWithString:@""];
    float value = -1.f;
    testassert(![scanner scanFloat:&value]);
    testassert(value == -1.f);
    testassert([scanner scanLocation] == 0);
    return YES;
}

test(ScanFloat_Nil)
{
    NSScanner* scanner = [NSScanner scannerWithString:@"0.0"];
    testassert([scanner scanFloat:nil]);
    testassert([scanner scanLocation] == 3);
    return YES;
}

test(ScanFloat_Uninitialized)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"feefiefofum"];
    float value = -111.1f;
    testassert(![scanner scanFloat:&value]);
    testassert(value == -111.1f);
    testassert([scanner scanLocation] == 0);

    return YES;
}

test(ScanFloat_Minus)
{
    NSScanner* scanner = [NSScanner scannerWithString:@"-"];
    float value = -1.f;
    testassert(![scanner scanFloat:&value]);
    testassert(value == -1.f);
    testassert([scanner scanLocation] == 0);
    return YES;
}

test(ScanFloat_Plus)
{
    NSScanner* scanner = [NSScanner scannerWithString:@"+"];
    float value = -1.f;
    testassert(![scanner scanFloat:&value]);
    testassert(value == -1.f);
    testassert([scanner scanLocation] == 0);
    return YES;
}

test(ScanFloat_Negative1)
{
    NSScanner* scanner = [NSScanner scannerWithString:@"-42"];
    float value = -1.f;
    testassert([scanner scanFloat:&value]);
    testassert(value == -42.f);
    testassert([scanner scanLocation] == 3);
    return YES;
}

test(ScanFloat_Positive)
{
    NSScanner* scanner = [NSScanner scannerWithString:@"+42.1818"];
    float value = -1.f;
    testassert([scanner scanFloat:&value]);
    testassert(value == 42.1818f);
    testassert([scanner scanLocation] == 8);
    return YES;
}

test(ScanFloat_Exponent1)
{
    NSScanner* scanner = [NSScanner scannerWithString:@".1e7"];
    float value = -1.f;
    testassert([scanner scanFloat:&value]);
    testassert(value == 1000000.f);
    testassert([scanner scanLocation] == 4);
    return YES;
}

test(ScanFloat_Exponent2)
{
    NSScanner* scanner = [NSScanner scannerWithString:@"0.1e7"];
    float value = -1.f;
    testassert([scanner scanFloat:&value]);
    testassert(value == 1000000.f);
    testassert([scanner scanLocation] == 5);
    return YES;
}

test(ScanFloat_Exponent3)
{
    NSScanner* scanner = [NSScanner scannerWithString:@"1.1e+7"];
    float value = -1.f;
    testassert([scanner scanFloat:&value]);
    testassert(value == 11000000.f);
    testassert([scanner scanLocation] == 6);
    return YES;
}

test(ScanFloat_Exponent4)
{
    NSScanner* scanner = [NSScanner scannerWithString:@"10.1E6"];
    float value = -1.f;
    testassert([scanner scanFloat:&value]);
    testassert(value == 10100000.f);
    testassert([scanner scanLocation] == 6);
    return YES;
}

test(ScanFloat_Exponent5)
{
    NSScanner* scanner = [NSScanner scannerWithString:@"1.0e-6"];
    float value = -1.f;
    testassert([scanner scanFloat:&value]);
    testassert(value == 0.000001f);
    testassert([scanner scanLocation] == 6);
    return YES;
}
test(ScanFloat_Exponent6)
{
    NSScanner* scanner = [NSScanner scannerWithString:@"0.0e0"];
    float value = -1.f;
    testassert([scanner scanFloat:&value]);
    testassert(value == 0.f);
    testassert([scanner scanLocation] == 5);
    return YES;
}

test(ScanFloat_Zero)
{
    NSScanner* scanner = [NSScanner scannerWithString:@"0"];
    float value = -1.f;
    testassert([scanner scanFloat:&value]);
    testassert(value == 0.f);
    testassert([scanner scanLocation] == 1);
    return YES;
}

test(ScanFloat_NegativeZero)
{
    NSScanner* scanner = [NSScanner scannerWithString:@"-0"];
    float value = -1.f;
    testassert([scanner scanFloat:&value]);
    testassert(value == 0.f);
    testassert([scanner scanLocation] == 2);
    return YES;
}

test(ScanFloat_PositiveZero)
{
    NSScanner* scanner = [NSScanner scannerWithString:@"+0"];
    float value = -1.f;
    testassert([scanner scanFloat:&value]);
    testassert(value == 0.f);
    testassert([scanner scanLocation] == 2);
    return YES;
}

test(ScanFloat_ZeroPointZero)
{
    NSScanner* scanner = [NSScanner scannerWithString:@"0.000"];
    float value = -1.f;
    testassert([scanner scanFloat:&value]);
    testassert(value == 0.f);
    testassert([scanner scanLocation] == 5);
    return YES;
}

#warning TODO test NaNs

test(ScanDouble)
{
    NSScanner* scanner = [NSScanner scannerWithString:@"123"];
    double value = -1.0;
    testassert([scanner scanDouble:&value]);
    testassert(value == 123.0);
    testassert([scanner scanLocation] == 3);
    return YES;
}

test(ScanDouble2)
{
    NSScanner* scanner = [NSScanner scannerWithString:@" 123.5000 "]; // terminating binary for equality test
    double value = -1.0;
    testassert([scanner scanDouble:&value]);
    testassert(value == 123.5);
    testassert([scanner scanLocation] == 9);
    return YES;
}

test(ScanDouble3)
{
    NSScanner* scanner = [NSScanner scannerWithString:@"4.99"];
    double value = 0;
    testassert([scanner scanDouble:&value]);
    testassert(value == 4.99);
    testassert([scanner scanLocation] == 4);
    return YES;
}

test(ScanDouble_Empty)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@""];
    double value = 0.0;
    testassert(![scanner scanDouble:&value]);
    testassert(value == 0.0);
    testassert([scanner scanLocation] == 0);

    return YES;
}

test(ScanDouble_Nil)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"0.0"];
    testassert([scanner scanDouble:nil]);
    testassert([scanner scanLocation] == 3);

    return YES;
}

test(ScanDouble_Uninitialized)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"feefiefofum"];
    double value = -111.1;
    testassert(![scanner scanDouble:&value]);
    testassert(value == -111.1);
    testassert([scanner scanLocation] == 0);

    return YES;
}

test(ScanDouble_Negative1)
{
    NSScanner* scanner = [NSScanner scannerWithString:@"-42"];
    double value = -1.0;
    testassert([scanner scanDouble:&value]);
    testassert(value == -42.0);
    testassert([scanner scanLocation] == 3);
    return YES;
}

test(ScanDouble_Positive)
{
    NSScanner* scanner = [NSScanner scannerWithString:@"+42.1818"];
    double value = -1.0;
    testassert([scanner scanDouble:&value]);
    testassert(value == 42.1818);
    testassert([scanner scanLocation] == 8);
    return YES;
}

test(ScanDouble_Exponent1)
{
    NSScanner* scanner = [NSScanner scannerWithString:@".1e7"];
    double value = -1.0;
    testassert([scanner scanDouble:&value]);
    testassert(value == 1000000.0);
    testassert([scanner scanLocation] == 4);
    return YES;
}

test(ScanDouble_Exponent2)
{
    NSScanner* scanner = [NSScanner scannerWithString:@"0.1e7"];
    double value = -1.0;
    testassert([scanner scanDouble:&value]);
    testassert(value == 1000000.0);
    testassert([scanner scanLocation] == 5);
    return YES;
}

test(ScanDouble_Exponent3)
{
    NSScanner* scanner = [NSScanner scannerWithString:@"1.1e+7"];
    double value = -1.0;
    testassert([scanner scanDouble:&value]);
    testassert(value == 11000000.0);
    testassert([scanner scanLocation] == 6);
    return YES;
}

test(ScanDouble_Exponent4)
{
    NSScanner* scanner = [NSScanner scannerWithString:@"10.1E6"];
    double value = -1.0;
    testassert([scanner scanDouble:&value]);
    testassert(value == 10100000.0);
    testassert([scanner scanLocation] == 6);
    return YES;
}

test(ScanDouble_Exponent5)
{
    NSScanner* scanner = [NSScanner scannerWithString:@"1.0e-6"];
    double value = -1.0;
    testassert([scanner scanDouble:&value]);
    testassert(value == 0.0000010);
    testassert([scanner scanLocation] == 6);
    return YES;
}
test(ScanDouble_Exponent6)
{
    NSScanner* scanner = [NSScanner scannerWithString:@"0.0e0"];
    double value = -1.0;
    testassert([scanner scanDouble:&value]);
    testassert(value == 0.0);
    testassert([scanner scanLocation] == 5);
    return YES;
}

test(ScanDouble_Dot)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"."];
    double value = 0.0;

    testassert(![scanner scanDouble:&value]);
    testassert(value == 0.0);
    testassert([scanner scanLocation] == 0);

    return YES;
}

test(ScanDouble_ZeroDot)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"0."];
    double value = 0.0;

    testassert([scanner scanDouble:&value]);
    testassert(value == 0.0);
    testassert([scanner scanLocation] == 2);

    return YES;
}

test(ScanDouble_Zero)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"0"];
    double value = 0.0;

    testassert([scanner scanDouble:&value]);
    testassert(value == 0.0);
    testassert([scanner scanLocation] == 1);

    return YES;
}

test(ScanDouble_Zeroes)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"000000000000"];
    double value = 0.0;

    testassert([scanner scanDouble:&value]);
    testassert(value == 0.0);
    testassert([scanner scanLocation] == 12);

    return YES;
}

test(ScanDouble_Dots)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"............"];
    double value = 0.0;

    testassert(![scanner scanDouble:&value]);
    testassert(value == 0.0);
    testassert([scanner scanLocation] == 0);

    return YES;
}

test(ScanDouble_DotsAndStuff)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"1.0.0.0.0.0.0"];
    double value = 0.0;

    testassert([scanner scanDouble:&value]);
    testassert(value == 1.0);
    testassert([scanner scanLocation] == 3);

    return YES;
}

test(ScanDouble_Minus)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"-"];
    double value = 0.0;

    testassert(![scanner scanDouble:&value]);
    testassert(value == 0.0);
    testassert([scanner scanLocation] == 0);

    return YES;
}

test(ScanDouble_Minuses)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"-------"];
    double value = 0.0;

    testassert(![scanner scanDouble:&value]);
    testassert(value == 0.0);
    testassert([scanner scanLocation] == 0);

    return YES;
}

test(ScanDouble_Pluses)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"+++++++++"];
    double value = 0.0;

    testassert(![scanner scanDouble:&value]);
    testassert(value == 0.0);
    testassert([scanner scanLocation] == 0);

    return YES;
}

test(ScanDouble_Plus)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"+"];
    double value = 0.0;

    testassert(![scanner scanDouble:&value]);
    testassert(value == 0.0);
    testassert([scanner scanLocation] == 0);

    return YES;
}

test(ScanDouble_NegativeZero)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"-0.000"];
    double value = 0.0;

    testassert([scanner scanDouble:&value]);
    testassert(value == 0.0);
    testassert([scanner scanLocation] == 6);

    return YES;
}

test(ScanDouble_PlusZero)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"+0.000"];
    double value = 0.0;

    testassert([scanner scanDouble:&value]);
    testassert(value == 0.0);
    testassert([scanner scanLocation] == 6);

    return YES;
}

test(ScannerWithStringDefaultConfiguration)
{
    NSScanner* scanner = [NSScanner scannerWithString:@""];

    testassert(scanner.scanLocation == 0);
    testassert(scanner.caseSensitive == NO);
    testassert([scanner.charactersToBeSkipped isEqual:[NSCharacterSet whitespaceAndNewlineCharacterSet]]);
    testassert(scanner.charactersToBeSkipped == [NSCharacterSet whitespaceAndNewlineCharacterSet]);
    testassert(scanner.locale == nil);
    testassert([scanner scanLocation] == 0);
    return YES;
}

test(LocalizedScannerWithStringConfiguration)
{
    NSScanner* scanner = [NSScanner localizedScannerWithString:@""];

    testassert([scanner.locale isEqual:[NSLocale currentLocale]]);

    return YES;
}

test(AllocClass)
{
    NSScanner* scanner = [NSScanner alloc];

    testassert(scanner.class == objc_getClass("NSConcreteScanner"));

    [[scanner init] release];

    return YES;
}

test(InitWithStringClass)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@""];

    testassert(scanner.class == objc_getClass("NSConcreteScanner"));

    [scanner release];

    return YES;
}

test(ScanCharactersFromSetEmpty)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@""];

    NSString* result = nil;
    testassert(![scanner scanCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@""] intoString:&result]);
    testassert(result == nil);

    [scanner release];

    return YES;
}

test(ScanCharactersFromSetNone)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"ABC"];

    NSString* result = nil;
    testassert(![scanner scanCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"XYZ"] intoString:&result]);
    testassert(result == nil);

    [scanner release];

    return YES;
}

test(CFStringFindCharacterFromSet)
{
    NSCharacterSet *charSet = [NSCharacterSet characterSetWithCharactersInString:@"ABC"];
    NSString *s = @"ABBAXYZA";
    CFRange found;
    testassert(CFStringFindCharacterFromSet((CFStringRef)s, (CFCharacterSetRef)charSet, CFRangeMake(0,8 ), 1, &found));
    testassert(found.location == 0 && found.length == 1);
    return YES;
}

test(NSStringRangeOfCharacterFromSet)
{
    NSCharacterSet *charSet = [NSCharacterSet characterSetWithCharactersInString:@"ABC"];
    NSString *s = @"ABBAXYZA";
    NSRange found = [s rangeOfCharacterFromSet:[charSet invertedSet] options:1 range:NSMakeRange(0, 8)];
    testassert(found.location == 4 && found.length == 1);
    return YES;
}

test(ScanCharactersFromSetSimple)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"ABBABXYZA"];

    NSString* result = nil;
    testassert([scanner scanCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"ABC"] intoString:&result]);
    testassert([result isEqualToString:@"ABBAB"]);
    testassert([scanner scanLocation] == 5);

    [scanner release];

    return YES;
}

test(ScanCharactersFromSetSkipping)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@" \n\tABC"];

    NSString* result = nil;
    testassert([scanner scanCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"ABZ"] intoString:&result]);
    testassert([result isEqualToString:@"AB"]);
    testassert([scanner scanLocation] == 5);
    [scanner release];

    return YES;
}

test(NSStringRangeOfCharacterFromSet2)
{
    NSCharacterSet *charSet = [NSCharacterSet characterSetWithCharactersInString:@"XYZ"];
    NSString *s = @"ABCXYZ";
    NSRange found = [s rangeOfCharacterFromSet:[charSet invertedSet] options:1 range:NSMakeRange(3, 3)];
    testassert(found.location == NSNotFound && found.length == 0);
    return YES;
}

test(ScanCharactersFromSetLocation)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"ABCXYZ"];
    scanner.scanLocation = 3;

    NSString* result = nil;
    testassert([scanner scanCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"XYZ"] intoString:&result]);
    testassert([result isEqualToString:@"XYZ"]);
    testassert([scanner scanLocation] == 6);

    [scanner release];

    return YES;
}

test(SetScanLocationOverflow)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"ABCXYZ"];
    scanner.scanLocation = 6;

    BOOL sawException = NO;
    @try
    {
        scanner.scanLocation = 10;
    }
    @catch(NSException *e)
    {
        sawException = YES;
        testassert([[e name] isEqualToString:@"NSRangeException"]);
    }
    testassert(sawException);
    testassert([scanner scanLocation] == 6);
    [scanner release];

    return YES;
}

test(ScanCharactersScanUpToCharacters)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"ABCXYZ"];

    testassert([scanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"CX"] intoString:nil]);
    testassert([scanner scanLocation] == 2);

    testassert(![scanner scanCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"X"] intoString:nil]);
    testassert([scanner scanCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"C"] intoString:nil]);
    testassert([scanner scanLocation] == 3);

    NSString *newString;
    testassert([scanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"Z"] intoString:&newString]);
    testassert([scanner scanLocation] == 5);
    testassert([newString isEqualToString:@"XY"]);
    testassert(![scanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"Z"] intoString:&newString]);
    testassert(![scanner scanCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"ABC"] intoString:&newString]);
    [scanner release];

    return YES;
}

test(ScanCharactersScanUpToString)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"ABCXYZ"];

    testassert([scanner scanUpToString:@"CX" intoString:nil]);
    testassert([scanner scanLocation] == 2);

    testassert(![scanner scanString:@"X" intoString:nil]);
    testassert([scanner scanString:@"C" intoString:nil]);
    testassert([scanner scanLocation] == 3);

    NSString *newString;
    testassert([scanner scanUpToString:@"Z" intoString:&newString]);
    testassert([scanner scanLocation] == 5);
    testassert([newString isEqualToString:@"XY"]);
    testassert(![scanner scanUpToString:@"Z" intoString:&newString]);
    testassert(![scanner scanString:@"ABC" intoString:&newString]);
    [scanner release];

    return YES;
}

test(ScanCharactersToBeSkipped)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"AAAABCXYZ"];
    testassert(![scanner scanString:@"BCX" intoString:nil]);
    testassert([scanner scanLocation] == 0);
    [scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@"A"]];
    testassert([scanner scanString:@"BCX" intoString:nil]);
    testassert([scanner scanLocation] == 7);
    return YES;
}

test(ScanDecimal)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@" 5.67   0 -0 -12 .981"];
    NSDecimal decimal;
    testassert([scanner scanDecimal:&decimal]);
    testassert(decimal._mantissa[0] == 567);
    testassert(decimal._exponent == -2);
    testassert([scanner scanLocation] == 5);

    testassert([scanner scanDecimal:&decimal]);
    testassert(decimal._mantissa[0] == 0);
    testassert(decimal._exponent == 0);
    testassert(decimal._isNegative == 0);
    testassert([scanner scanLocation] == 9);

    testassert([scanner scanDecimal:&decimal]);
    testassert(decimal._mantissa[0] == 0);
    testassert(decimal._exponent == 0);
    testassert(decimal._isNegative == 0);
    testassert([scanner scanLocation] == 12);

    testassert([scanner scanDecimal:&decimal]);
    testassert(decimal._mantissa[0] == 12);
    testassert(decimal._exponent == 0);
    testassert(decimal._isNegative == 1);
    testassert([scanner scanLocation] == 16);

    testassert([scanner scanDecimal:&decimal]);
    testassert(decimal._mantissa[0] == 981);
    testassert(decimal._exponent == -3);
    testassert(decimal._isNegative == 0);
    testassert([scanner scanLocation] == 21);

    return YES;
}

test(ScanDecimal_Empty)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@""];
    NSDecimal decimal = { 0 };
    testassert(![scanner scanDecimal:&decimal]);
    testassert(decimal._mantissa[0] == 0);
    testassert(decimal._exponent == 0);
    testassert([scanner scanLocation] == 0);

    return YES;
}

test(ScanDecimal_Nil)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"0.0"];
    testassert([scanner scanDecimal:nil]);
    testassert([scanner scanLocation] == 3);

    return YES;
}

test(ScanDecimal_Uninitialized)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"feefiefofum"];

    NSDecimal decimal;
    memset(&decimal, 0xff, sizeof(NSDecimal));
    testassert(![scanner scanDecimal:&decimal]);

    uint8_t *ptr = (void*)&decimal;
    unsigned int i=0;
    for (; i<sizeof(NSDecimal); i++, ptr++)
    {
        testassert(*ptr == 0xff);
    }
    testassert(i == sizeof(NSDecimal));

    return YES;
}

test(ScanDecimal_Dot)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"."];
    NSDecimal decimal = { 0 };

    testassert([scanner scanDecimal:&decimal]);
    testassert(decimal._mantissa[0] == 0);
    testassert(decimal._exponent == 0);
    testassert(decimal._isNegative == 0);
    testassert([scanner scanLocation] == 1);

    return YES;
}

test(ScanDecimal_ZeroDot)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"0."];
    NSDecimal decimal = { 0 };

    testassert([scanner scanDecimal:&decimal]);
    testassert(decimal._mantissa[0] == 0);
    testassert(decimal._exponent == 0);
    testassert(decimal._isNegative == 0);
    testassert([scanner scanLocation] == 2);

    return YES;
}

test(ScanDecimal_Zero)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"0"];
    NSDecimal decimal = { 0 };

    testassert([scanner scanDecimal:&decimal]);
    testassert(decimal._mantissa[0] == 0);
    testassert(decimal._exponent == 0);
    testassert(decimal._isNegative == 0);
    testassert([scanner scanLocation] == 1);

    return YES;
}

test(ScanDecimal_Zeroes)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"000000000000"];
    NSDecimal decimal = { 0 };

    testassert([scanner scanDecimal:&decimal]);
    testassert(decimal._mantissa[0] == 0);
    testassert(decimal._exponent == 0);
    testassert(decimal._isNegative == 0);
    testassert([scanner scanLocation] == 12);

    return YES;
}

test(ScanDecimal_Dots)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"............"];
    NSDecimal decimal = { 0 };

    testassert([scanner scanDecimal:&decimal]);
    testassert(decimal._mantissa[0] == 0);
    testassert(decimal._exponent == 0);
    testassert(decimal._isNegative == 0);
    testassert([scanner scanLocation] == 1);

    return YES;
}

test(ScanDecimal_DotsAndStuff)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"1.0.0.0.0.0.0"];
    NSDecimal decimal = { 0 };

    testassert([scanner scanDecimal:&decimal]);
    testassert(decimal._mantissa[0] == 1);
    testassert(decimal._exponent == 0);
    testassert(decimal._isNegative == 0);
    testassert([scanner scanLocation] == 3);

    return YES;
}

test(ScanDecimal_Minus)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"-"];
    NSDecimal decimal = { 0 };

    testassert([scanner scanDecimal:&decimal]);
    testassert(decimal._mantissa[0] == 0);
    testassert(decimal._exponent == 0);
    testassert(decimal._isNegative == 0);
    testassert([scanner scanLocation] == 1);

    return YES;
}

test(ScanDecimal_Minuses)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"-------"];
    NSDecimal decimal = { 0 };

    testassert([scanner scanDecimal:&decimal]);
    testassert(decimal._mantissa[0] == 0);
    testassert(decimal._exponent == 0);
    testassert(decimal._isNegative == 0);
    testassert([scanner scanLocation] == 1);

    return YES;
}

test(ScanDecimal_Pluses)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"+++++++++"];
    NSDecimal decimal = { 0 };

    testassert([scanner scanDecimal:&decimal]);
    testassert(decimal._mantissa[0] == 0);
    testassert(decimal._exponent == 0);
    testassert(decimal._isNegative == 0);
    testassert([scanner scanLocation] == 1);

    return YES;
}

test(ScanDecimal_Plus)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"+"];
    NSDecimal decimal = { 0 };

    testassert([scanner scanDecimal:&decimal]);
    testassert(decimal._mantissa[0] == 0);
    testassert(decimal._exponent == 0);
    testassert(decimal._isNegative == 0);
    testassert([scanner scanLocation] == 1);

    return YES;
}

test(ScanDecimal_NegativeZero)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"-0.000"];
    NSDecimal decimal = { 0 };

    testassert([scanner scanDecimal:&decimal]);
    testassert(decimal._mantissa[0] == 0);
    testassert(decimal._exponent == -3);
    testassert(decimal._isNegative == 0);
    testassert([scanner scanLocation] == 6);

    return YES;
}

test(ScanDecimal_PlusZero)
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:@"+0.000"];
    NSDecimal decimal = { 0 };

    testassert([scanner scanDecimal:&decimal]);
    testassert(decimal._mantissa[0] == 0);
    testassert(decimal._exponent == -3);
    testassert(decimal._isNegative == 0);
    testassert([scanner scanLocation] == 6);

    return YES;
}

test(SetNilSkipSet)
{
    NSScanner *scanner = [[NSScanner alloc] initWithString:@" 123"];
    [scanner setCharactersToBeSkipped:nil];
    NSCharacterSet *blankSet = [NSCharacterSet characterSetWithCharactersInString:@""];
    testassert(![[scanner charactersToBeSkipped] isEqual:blankSet]);
    testassert([scanner charactersToBeSkipped] == nil);

    // Actually scan something
    NSInteger integer = 0;
    testassert(![scanner scanInteger:&integer]);
    testassert(scanner.scanLocation == 0);
    scanner.scanLocation = 1;
    testassert([scanner scanInteger:&integer]);
    testassert(integer == 123);
    testassert(scanner.scanLocation == 4);
    return YES;
}

@end
