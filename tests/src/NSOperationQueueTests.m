//
//  NSOperationQueueTests.m
//  FoundationTests
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "FoundationTests.h"

@testcase(NSOperationQueue)

test(Alloc)
{
    NSOperationQueue *queue = [NSOperationQueue alloc];
    testassert(queue != nil);

    [queue release];

    return YES;
}

test(Init)
{
    NSOperationQueue *queue = [[[NSOperationQueue alloc] init] autorelease];
    testassert(queue != nil);

    return YES;
}

test(Name)
{
    NSOperationQueue *queue = [[[NSOperationQueue alloc] init] autorelease];
    NSString *name = [queue name];
    testassert([name hasPrefix:@"NSOperationQueue "]);

    return YES;
}

test(SetName)
{
    NSString * const name = @"Queue 23";

    NSOperationQueue *queue = [[[NSOperationQueue alloc] init] autorelease];
    [queue setName:name];

    testassert([[queue name] isEqualToString:name]);

    return YES;
}

test(Current)
{
    NSOperationQueue *currentQueue = [NSOperationQueue currentQueue];
    testassert(currentQueue != nil);

    return YES;
}

test(Main)
{
    NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
    testassert(mainQueue != nil);
    testassert([[mainQueue name] rangeOfString:@"main" options:NSCaseInsensitiveSearch].location != NSNotFound);

    return YES;
}

test(CancelAllOperations)
{
    NSOperationQueue *queue = [[[NSOperationQueue alloc] init] autorelease];
    [queue cancelAllOperations];

    return YES;
}

test(AddOperationWithBlock)
{
    NSOperationQueue *queue = [[[NSOperationQueue alloc] init] autorelease];

    [queue addOperationWithBlock:^{ while (YES); }];

    [queue cancelAllOperations];

    return YES;
}

test(AddOperationWithBlockNil)
{
    NSOperationQueue *queue = [[[NSOperationQueue alloc] init] autorelease];

    BOOL raised = NO;
    @try {
        [queue addOperationWithBlock:nil];
    }
    @catch (NSException *e) {
        raised = [[e name] isEqualToString:NSInvalidArgumentException];
    }
    testassert(raised);

    return YES;
}

test(OperationCount)
{
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    testassert([queue operationCount] == 0);
    [queue setSuspended:YES];
    for (NSUInteger i = 1; i < 10; i++)
    {
        [queue addOperationWithBlock:^{ while (YES); }];
        testassert([queue operationCount] == i);
    }

    [queue cancelAllOperations];

    return YES;
}

test(Operations)
{
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    testassert([[queue operations] isEqualToArray:@[]]);

    for (NSUInteger i = 1; i < 10; i++)
    {
        [queue addOperationWithBlock:^{ while (YES); }];
        testassert([[queue operations] count] == i);
    }

    [queue cancelAllOperations];

    return YES;
}

test(AddNilOperation)
{
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    testassert([queue operationCount] == 0);
    [queue addOperation:nil];
    testassert([queue operationCount] == 0);
    return YES;
}

test(BlockOperationSingle)
{
    NSBlockOperation *op = [[NSBlockOperation alloc] init];
    testassert(op != nil);
    NSMutableArray *ops = (NSMutableArray *)[op executionBlocks];
    testassert(ops != nil);
    [ops addObject:^{
        NSLog(@"test");
    }];
    testassert([[op executionBlocks] count] == 0);
    return YES;
}

test(BlockOperationMultiple)
{
    NSBlockOperation *op = [[NSBlockOperation alloc] init];
    [op addExecutionBlock:^{
        NSLog(@"test");
    }];
    testassert([[op executionBlocks] count] == 1);
    return YES;
}

@end
