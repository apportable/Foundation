//
//  NSNullTests.m
//  FoundationTests
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "FoundationTests.h"

@testcase(NSNull)

test(NullSingleton)
{
    testassert([NSNull null] == [NSNull null]);
    return YES;
}

test(CFNull)
{
    testassert([NSNull null] == (id)kCFNull);
    return YES;
}

test(CFNullClass)
{
    testassert([(id)kCFNull class] == [NSNull class]);
    return YES;
}

@end
