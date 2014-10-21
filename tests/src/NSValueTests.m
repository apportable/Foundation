//
//  NSValueTests.m
//  FoundationTests
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "FoundationTests.h"

#include <stdio.h>
#import <objc/runtime.h>

@interface NSValue (Internal)
- (CGRect)rectValue;
- (CGSize)sizeValue;
- (CGPoint)pointValue;
@end

@testcase(NSValue)


test(NSValueDocs1)
{
    char *myCString = "This is a string.";
    char *out;
    NSValue *theValue = [NSValue valueWithBytes:(const void *)&myCString objCType:@encode(char *)];
    [theValue getValue:&out];
    testassert(out == myCString);
    return YES;
}

test(NSValueChar)
{
    char myChar = 9;
    NSValue *myNSValueObj = [[NSValue alloc] initWithBytes:&myChar objCType:@encode(char)];
    char myNewChar;
    [myNSValueObj getValue:&myNewChar];
    testassert(myNewChar == 9);
    testassert([[myNSValueObj description] isEqualToString:@"<09>"]);
    testassert(strcmp([myNSValueObj objCType],"c") == 0);
    testassert([myNSValueObj isEqualToValue:[[NSValue alloc] initWithBytes:&myChar objCType:@encode(char)]]);
    [myNSValueObj release];
    
    return YES;
}

test(NSValueInt)
{
    int myInt = 42;
    NSValue *myNSValueObj = [[NSValue alloc] initWithBytes:&myInt objCType:@encode(int)];
    int myNewint;
    [myNSValueObj getValue:&myNewint];
    testassert(myNewint == 42);
    testassert([[myNSValueObj description] isEqualToString:@"<2a000000>"]);
    testassert(strcmp([myNSValueObj objCType],"i") == 0);
    testassert([myNSValueObj isEqualToValue:[[NSValue alloc] initWithBytes:&myInt objCType:@encode(int)]]);
    [myNSValueObj release];
    
    return YES;
}

test(NSValueFloat)
{
    float myFloat = 42.0f;
    NSValue *myNSValueObj = [[NSValue alloc] initWithBytes:&myFloat objCType:@encode(float)];
    float myNewFloat;
    [myNSValueObj getValue:&myNewFloat];
    testassert(myNewFloat == 42.0f);
    testassert([[myNSValueObj description] isEqualToString:@"<00002842>"]);
    testassert(strcmp([myNSValueObj objCType],"f") == 0);
    testassert([myNSValueObj isEqualToValue:[[NSValue alloc] initWithBytes:&myFloat objCType:@encode(float)]]);
    [myNSValueObj release];
    
    return YES;
}

test(NSValueDouble)
{
    double myDouble = 1234.5678;
    NSValue *myNSValueObj = [[NSValue alloc]
                             initWithBytes:&myDouble
                             objCType:@encode(double)];
    double myNewDouble;
    [myNSValueObj getValue:&myNewDouble];
    testassert(myNewDouble == 1234.5678);
    testassert([[myNSValueObj description] isEqualToString:@"<adfa5c6d 454a9340>"]);
    testassert(strcmp([myNSValueObj objCType],"d") == 0);
    testassert([myNSValueObj isEqualToValue:[[NSValue alloc] initWithBytes:&myDouble objCType:@encode(double)]]);
    [myNSValueObj release];
    
    return YES;
}

test(NSValueLongLong)
{
    long long myLongLong = 123456789;
    NSValue *myNSValueObj = [[NSValue alloc] initWithBytes:&myLongLong objCType:@encode(long long)];
    long long myNewLongLong;
    [myNSValueObj getValue:&myNewLongLong];
    testassert(myNewLongLong == 123456789);
    testassert([[myNSValueObj description] isEqualToString:@"<15cd5b07 00000000>"]);
    testassert(strcmp([myNSValueObj objCType],"q") == 0);
    testassert([myNSValueObj isEqualToValue:[[NSValue alloc] initWithBytes:&myLongLong objCType:@encode(long long)]]);
    [myNSValueObj release];
    
    return YES;
}

typedef struct {
    float real;
    float imaginary;
} ImaginaryNumber;

test(NSValueDocs2)
{
    ImaginaryNumber miNumber;
    miNumber.real = 1.1;
    miNumber.imaginary = 1.41;

    NSValue *miValue = [NSValue valueWithBytes: &miNumber objCType:@encode(ImaginaryNumber)];

    ImaginaryNumber miNumber2;
    [miValue getValue:&miNumber2];
    
    testassert(miNumber2.real == miNumber.real && miNumber.imaginary == miNumber.imaginary);

    return YES;
}


typedef struct {
    int t;
    float b;
    struct {
        float b;
        struct {
            float b;
            struct {
                float b;
                struct {
                    float b;
                    struct {
                        float b;
                        struct {
                            float b;
                            struct {
                                float b;
                                struct {
                                    float b;
                                    struct {
                                        float b;
                                        struct {
                                            float b;
                                            struct {
                                                float b;
                                                struct {
                                                    float b;
                                                    struct {
                                                        float b;
                                                        struct {
                                                            float b;
                                                            struct {
                                                                float b;
                                                                struct {
                                                                    float b;
                                                                    struct {
                                                                        float b;
                                                                        struct {
                                                                            float b;
                                                                            struct {
                                                                                float b;
                                                                            } q;
                                                                        } q;
                                                                    } q;
                                                                } q;
                                                            } q;
                                                        } q;
                                                    } q;
                                                } q;
                                            } q;
                                        } q;
                                    } q;
                                } q;
                            } q;
                        } q;
                    } q;
                } q;
            } q;
        } q;
    } q;
} myStruct;

test(NSValueBigStruct)
{
    myStruct t = {0};
    myStruct q = {0};
    myStruct r = {0};
    t.q.q.b = 99.0f;
    q.q.q.b = 99.0f;
    r.q.q.b = 99.9f;
    r.q.q.q.b = 3.4f;
    
    char *e = malloc(1024);
    strcpy(e, @encode(myStruct));
    NSValue *val1 = [[NSValue alloc] initWithBytes:&t objCType:e];
    NSValue *val2 = [[NSValue alloc] initWithBytes:&q objCType:e];
    NSValue *val3 = [[NSValue alloc] initWithBytes:&r objCType:e];
    free(e);
    testassert([val1 isEqualToValue:val2]);
    testassert(![val1 isEqualToValue:val3]);
    
    [val1 release];
    [val2 release];
    [val3 release];
    
    return YES;
}

test(RangeValue)
{
    NSRange r = {55, 44};
    NSValue *val = [NSValue valueWithRange:r];
    testassert([val rangeValue].location == 55);
    testassert([val rangeValue].length == 44);
    return YES;
}

#if 0
// Need UIKit for these

test(RectValue)
{
    CGRect r = {{55.0f, 44.0f}, {22.0f, 77.0f}};
    NSValue *val = [NSValue valueWithCGRect:r];
    testassert([val rectValue].origin.x == 55.0f);
    testassert([val rectValue].origin.y == 44.0f);
    testassert([val rectValue].size.width == 22.0f);
    testassert([val rectValue].size.height == 77.0f);
    return YES;
}

test(SizeValue)
{
    CGSize sz = {22.0f, 77.0f};
    NSValue *val = [NSValue valueWithCGSize:sz];
    testassert([val sizeValue].width == 22.0f);
    testassert([val sizeValue].height == 77.0f);
    return YES;
}

test(PointValue)
{
    CGPoint pt = {55.0f, 44.0f};
    NSValue *val = [NSValue valueWithCGPoint:pt];
    testassert([val pointValue].x == 55.0f);
    testassert([val pointValue].y == 44.0f);
    return YES;
}
#endif

test(HugeStruct)
{
// TODO add huge struct test (like the one in NSInvocationTests.m)
    
    return YES;
}

@end
