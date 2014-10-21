//
//  ConcurrencyTests.m
//  FoundationTests
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "FoundationTests.h"
#import <pthread.h>

#define YIELD() usleep(40)
#define MAIN_INVOKED @"main_invoked"

@interface TestOperation : NSOperation
@property (nonatomic, readonly) NSString *result;
@end

@implementation TestOperation

@synthesize result = _result;

- (id)init
{
    self = [super init];
    if (self)
    {
        _result = nil;
    }
    return self;
}

- (void)dealloc
{
    _result = nil;
    [super dealloc];
}

- (void)main
{
    _result = MAIN_INVOKED;
}

@end

@testcase(Concurrency)

test(NSOperationQueue_ArbitraryQueue)
{
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    TestOperation *op = [[TestOperation alloc] init];
    [queue addOperation:op];
    
    YIELD();
    
    BOOL success = NO;
    NSTimeInterval theFuture = [NSDate timeIntervalSinceReferenceDate] + 2.0;
    while ([NSDate timeIntervalSinceReferenceDate] < theFuture)
    {
        if ([[op result] isEqualToString:MAIN_INVOKED])
        {
            success = YES;
            break;
        }
        [NSThread sleepForTimeInterval:0.001];
    }
    
    [op release];
    [queue release];
    return success;
}

test(NSOperationQueue_ArbitraryQueue_AFewMoreTimes)
{
    
#define NOT_DETERMINISTIC_BUT_DO_IT_A_FEW_MORE_TIMES 1000
    for (unsigned int i=0; i<NOT_DETERMINISTIC_BUT_DO_IT_A_FEW_MORE_TIMES; i++)
    {
        if (![self NSOperationQueue_ArbitraryQueue])
        {
            return NO;
        }
    }
    return YES;
}

#undef YIELD

@end
