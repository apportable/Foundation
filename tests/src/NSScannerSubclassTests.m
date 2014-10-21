//
//  NSScannerSubclassTests.m
//  FoundationTests
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "FoundationTests.h"

#include "objc/runtime.h"

@interface MyScanner : NSScanner
@end

@implementation MyScanner

@end

@interface SimpleScanner : NSScanner
@end

@implementation SimpleScanner

- (NSString *)string
{
    return @"123";
}

- (NSUInteger)scanLocation
{
    return 0;
}

- (void)setScanLocation:(NSUInteger)pos
{
}

@end

@testcase(NSScannerSubclass)

test(AllocClass)
{
    MyScanner* scanner = [MyScanner alloc];

    testassert(scanner.class == objc_getClass("MyScanner"));

    NSString *s = @"abc";
    [[scanner initWithString:s] autorelease];

    return YES;
}

test(ScannerWithStringClass)
{
    NSScanner* scanner = [MyScanner scannerWithString:@""];

    testassert(scanner.class == objc_getClass("NSConcreteScanner"));

    return YES;
}

test(LocalizedScannerWithStringClass)
{
    NSScanner* scanner = [MyScanner localizedScannerWithString:@""];

    testassert(scanner.class == objc_getClass("NSConcreteScanner"));

    return YES;
}

static BOOL InvokeRequiredMethod(NSScanner* scanner, int index)
{
    // This kludgy switch statement could be avoided in various ways
    // (such as using a list of selectors & NSInvocation)
    // but I think this approach has the advantage of simplicity!
    switch (index) {
        case 0:
            (void)[scanner string];
            return YES;
        case 1:
            (void)[scanner scanLocation];
            return YES;
        case 2:
            [scanner setScanLocation:0];
            return YES;
        case 3:
            [scanner setCharactersToBeSkipped:nil];
            return YES;
        case 4:
            [scanner setCaseSensitive:NO];
            return YES;
        case 5:
            [scanner setLocale:nil];
            return YES;
    }
    return NO;
}

test(ScannerRequired)
{
    MyScanner* scanner = [[MyScanner alloc] init];

    for (int i=0;i<1000;++i) {
        BOOL raised = NO;
        @try {
            if (!InvokeRequiredMethod(scanner, i))
                break;
        }
        @catch (NSException *e) {
            raised = [[e name] isEqualToString:NSInvalidArgumentException];
        }
        testassert(raised);
    }

    [scanner release];
    return YES;
}

static BOOL InvokeOptionalMethod(NSScanner* scanner, int index)
{
    switch (index) {
        case 0:
            [scanner charactersToBeSkipped];
            return YES;
        case 1:
            [scanner caseSensitive];
            return YES;
        case 2:
            [scanner locale];
            return YES;
        case 3:
            [scanner scanInt:NULL];
            return YES;
        case 4:
            [scanner scanInteger:NULL];
            return YES;
        case 5:
            [scanner scanHexLongLong:NULL];
            return YES;
        case 6:
            [scanner scanHexFloat:NULL];
            return YES;
        case 7:
            [scanner scanHexDouble:NULL];
            return YES;
        case 8:
            [scanner scanHexInt:NULL];
            return YES;
        case 9:
            [scanner scanLongLong:NULL];
            return YES;
        case 10:
            [scanner scanFloat:NULL];
            return YES;
        case 11:
            [scanner scanDouble:NULL];
            return YES;
        case 12:
            [scanner scanString:@"ABC" intoString:NULL];
            return YES;
        case 13:
            [scanner scanCharactersFromSet:[NSCharacterSet letterCharacterSet] intoString:NULL];
            return YES;
        case 14:
            [scanner scanUpToString:@"ABC" intoString:NULL];
            return YES;
        case 15:
            [scanner scanUpToCharactersFromSet:[NSCharacterSet letterCharacterSet] intoString:NULL];
            return YES;
        case 16:
            [scanner isAtEnd];
            return YES;
    }
    return NO;
}

test(ScannerOptional)
{
    SimpleScanner* scanner = [[SimpleScanner alloc] initWithString:@""];

    for (int i=0;i<1000;++i) {
        if (!InvokeOptionalMethod(scanner, i))
            break;
    }

    [scanner release];
    return YES;
}

@end
