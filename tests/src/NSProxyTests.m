//
//  NSProxyTests.m
//  FoundationTests
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "FoundationTests.h"
#import <objc/runtime.h>

@testcase(NSProxy)

test(Alloc)
{
    testassert([NSProxy alloc] != nil);
    return YES;
}

test(RetainReleaseAutorelease)
{
    NSProxy *p = [NSProxy alloc];
    [p retain];
    [p release];
    [p autorelease];
    return YES;
}

test(BaseMethods)
{
    NSProxy *p = [NSProxy alloc];
    [p hash];
    [p isEqual:p];
    [p release];
    return YES;
}

test(Class)
{
    NSProxy *p = [NSProxy alloc];
    testassert([p class] == objc_getClass("NSProxy"));
    [p release];
    return YES;
}

test(ForwardingTarget)
{
    NSProxy *p = [NSProxy alloc];
    testassert([p forwardingTargetForSelector:@selector(test)] == nil);
    [p release];
    return YES;
}

test(ImplementsConformsToProtocol)
{
    Class cls = objc_getClass("NSProxy");
    testassert(class_getInstanceMethod(cls, @selector(conformsToProtocol:)) != NULL);
    return YES;
}

test(ImplementsMethodSignatureForSelector)
{
    Class cls = objc_getClass("NSProxy");
    testassert(class_getInstanceMethod(cls, @selector(methodSignatureForSelector:)) != NULL);
    return YES;
}

test(MethodSignatureForSelector)
{
    NSProxy *p = [NSProxy alloc];
    BOOL exceptionCaught = NO;
    @try {
        [p methodSignatureForSelector:@selector(init)];
    } @catch(NSException *e) {
        if ([[e name] isEqualToString:NSInvalidArgumentException])
        {
            exceptionCaught = YES;
        }
    }
    testassert(exceptionCaught == YES);
    [p release];
    return YES;
}

test(ImplementsIsKindOfClass)
{
    Class cls = objc_getClass("NSProxy");
    testassert(class_getInstanceMethod(cls, @selector(isKindOfClass:)) != NULL);
    return YES;
}

test(IsKindOfClass)
{
    NSProxy *p = [NSProxy alloc];
    BOOL exceptionCaught = NO;
    @try {
        [p isKindOfClass:[NSProxy class]];
    } @catch(NSException *e) {
        if ([[e name] isEqualToString:NSInvalidArgumentException])
        {
            exceptionCaught = YES;
        }
    }
    testassert(exceptionCaught == YES);
    [p release];
    return YES;
}

test(ImplementsIsMemberOfClass)
{
    Class cls = objc_getClass("NSProxy");
    testassert(class_getInstanceMethod(cls, @selector(isMemberOfClass:)) != NULL);
    return YES;
}

test(IsMemberOfClass)
{
    NSProxy *p = [NSProxy alloc];
    BOOL exceptionCaught = NO;
    @try {
        [p isMemberOfClass:[NSProxy class]];
    } @catch(NSException *e) {
        if ([[e name] isEqualToString:NSInvalidArgumentException])
        {
            exceptionCaught = YES;
        }
    }
    testassert(exceptionCaught == YES);
    [p release];
    return YES;
}

@end
