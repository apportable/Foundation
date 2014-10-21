//
//  NSThreadTests.m
//  FoundationTests
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "FoundationTests.h"

@testcase(NSThread, {
    BOOL _thread1Passed;
    BOOL _thread2Passed;
})

test(ThreadCreation)
{
    NSThread *thread = [[NSThread alloc] init];
    testassert(thread != nil);
    [thread release];

    return YES;
}

- (BOOL)thread1
{
    _thread1Passed = YES;

    return YES;
}

test(ThreadSpawning1)
{
    _thread1Passed = NO;
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(thread1) object:nil];
    [thread start];
    sleep(1);
    testassert(_thread1Passed);
    [thread release];

    return YES;
}

- (BOOL)thread2:(NSObject *)obj
{
    _thread2Passed = [obj retain] != NULL;

    return YES;
}

test(ThreadSpawning2)
{
    _thread2Passed = NO;
    NSObject *obj = [[NSObject alloc] init];
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(thread2:) object:obj];
    [obj release];
    [thread start];
    sleep(1);
    testassert(_thread2Passed);
    [thread release];

    return YES;
}

@end
