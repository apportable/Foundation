//
//  NSExceptionTests.m
//  FoundationTests
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "FoundationTests.h"

@testcase(NSException)

typedef void (^dummyBlock)(void);

static int func(NSException *e)
{
    [e raise];
    return 99;
}

test(RaiseWithCall)
{
    NSException *e = [NSException exceptionWithName:nil reason:nil userInfo:nil];
    BOOL raised = NO;
    
    @try {
        func(e);
    }
    @catch (NSException *caught) {
        raised = YES;
    }
    
    testassert(raised);
    return YES;
}

static int funcWithBlock(NSException *e)
{
    __block int x = 0;
    
    dummyBlock myBlock = ^(void) {
        x = 9;
    };
    
    [e raise];
    myBlock();
    return x;
}

test(RaiseWithBlockVariablesCall)
{
    NSException *e = [NSException exceptionWithName:nil reason:nil userInfo:nil];
    BOOL raised = NO;
    
    @try {
        funcWithBlock(e);
    }
    @catch (NSException *caught) {
        raised = YES;
    }
    
    testassert(raised);
    
    return YES;
}

test(RaiseWithBlockVariables)
{
    NSException *e = [NSException exceptionWithName:nil reason:nil userInfo:nil];
    BOOL raised = NO;
    __block int x = 0;
    
    dummyBlock myBlock = ^(void) {
        x = 9;
    };
    
    myBlock();
    
    @try {
        [e raise];
    }
    @catch (NSException *caught) {
        raised = YES;
        testassert(x == 9);
    }
    
    testassert(raised);
    
    return YES;
}

test(InitWithNameReasonUserInfo)
{
    NSException *e = [[NSException alloc] initWithName:nil reason:nil userInfo:nil];

    testassert(e != nil);

    [e release];

    return YES;
}

test(ExceptionWithNameReasonUserInfo)
{
    NSException *e = [NSException exceptionWithName:nil reason:nil userInfo:nil];

    testassert(e != nil);

    return YES;
}

test(Copy)
{
    NSException *e1 = [NSException exceptionWithName:nil reason:nil userInfo:nil];
    NSException *e2 = [e1 copy];

    // Exceptions are immutable and copies should be the same pointer.
    testassert(e1 == e2);

    [e2 release];

    return YES;
}

test(Raise)
{
    NSException *e = [NSException exceptionWithName:nil reason:nil userInfo:nil];
    BOOL raised = NO;

    @try {
        [e raise];
    }
    @catch (NSException *caught) {
        raised = YES;
    }

    testassert(raised);

    return YES;
}

test(Catch)
{
    NSException *e = [NSException exceptionWithName:nil reason:nil userInfo:nil];

    @try {
        [e raise];
    }
    @catch (NSException *caught) {
        testassert(caught == e);
    }

    return YES;
}

@end
