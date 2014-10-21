//
//  NSSortDescriptorTests.m
//  FoundationTests
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "FoundationTests.h"

@testcase(NSSortDescriptor)

test(Creation)
{
    NSSortDescriptor *desc = nil;
    desc = [[NSSortDescriptor alloc] initWithKey:nil ascending:NO];
    testassert(desc != nil);
    [desc release];

    desc = [[NSSortDescriptor alloc] initWithKey:nil ascending:YES];
    testassert(desc != nil);
    [desc release];

    desc = [[NSSortDescriptor alloc] initWithKey:@"test" ascending:NO];
    testassert(desc != nil);
    [desc release];

    desc = [[NSSortDescriptor alloc] initWithKey:@"test" ascending:YES];
    testassert(desc != nil);
    [desc release];

    desc = [[NSSortDescriptor alloc] initWithKey:nil ascending:NO selector:NULL];
    testassert(desc != nil);
    [desc release];

    desc = [[NSSortDescriptor alloc] initWithKey:nil ascending:NO selector:@selector(test)];
    testassert(desc != nil);
    [desc release];

    desc = [[NSSortDescriptor alloc] initWithKey:nil ascending:YES selector:NULL];
    testassert(desc != nil);
    [desc release];

    desc = [[NSSortDescriptor alloc] initWithKey:nil ascending:YES selector:@selector(test)];
    testassert(desc != nil);
    [desc release];

    desc = [[NSSortDescriptor alloc] initWithKey:@"test" ascending:NO selector:NULL];
    testassert(desc != nil);
    [desc release];

    desc = [[NSSortDescriptor alloc] initWithKey:@"test" ascending:NO selector:@selector(test)];
    testassert(desc != nil);
    [desc release];

    desc = [[NSSortDescriptor alloc] initWithKey:@"test" ascending:YES selector:NULL];
    testassert(desc != nil);
    [desc release];

    desc = [[NSSortDescriptor alloc] initWithKey:@"test" ascending:YES selector:@selector(test)];
    testassert(desc != nil);
    [desc release];

    desc = [[NSSortDescriptor alloc] initWithKey:nil ascending:NO comparator:NULL];
    testassert(desc != nil);
    [desc release];

    desc = [[NSSortDescriptor alloc] initWithKey:nil ascending:NO comparator:^NSComparisonResult(id obj1, id obj2) {
        return NSOrderedSame;
    }];
    testassert(desc != nil);
    [desc release];

    desc = [[NSSortDescriptor alloc] initWithKey:nil ascending:YES comparator:NULL];
    testassert(desc != nil);
    [desc release];

    desc = [[NSSortDescriptor alloc] initWithKey:nil ascending:YES comparator:^NSComparisonResult(id obj1, id obj2) {
        return NSOrderedSame;
    }];
    testassert(desc != nil);
    [desc release];

    desc = [[NSSortDescriptor alloc] initWithKey:@"test" ascending:NO comparator:NULL];
    testassert(desc != nil);
    [desc release];

    desc = [[NSSortDescriptor alloc] initWithKey:@"test" ascending:NO comparator:^NSComparisonResult(id obj1, id obj2) {
        return NSOrderedSame;
    }];
    testassert(desc != nil);
    [desc release];

    desc = [[NSSortDescriptor alloc] initWithKey:@"test" ascending:YES comparator:NULL];
    testassert(desc != nil);
    [desc release];

    desc = [[NSSortDescriptor alloc] initWithKey:@"test" ascending:YES comparator:^NSComparisonResult(id obj1, id obj2) {
        return NSOrderedSame;
    }];
    testassert(desc != nil);
    [desc release];

    return YES;
}

test(Comparisons)
{
    NSSortDescriptor *desc = [[NSSortDescriptor alloc] initWithKey:nil ascending:YES comparator:^NSComparisonResult(id obj1, id obj2) {
        int i1 = [obj1 intValue];
        int i2 = [obj2 intValue];
        if (i1 < i2)
        {
            return NSOrderedAscending;
        }
        else if (i1 > i2)
        {
            return NSOrderedDescending;
        }
        else
        {
            return NSOrderedSame;
        }
    }];

    NSComparisonResult result;
    result = [desc compareObject:@(1) toObject:@(2)];
    testassert(result == NSOrderedAscending);
    result = [desc compareObject:@(2) toObject:@(1)];
    testassert(result == NSOrderedDescending);
    result = [desc compareObject:@(2) toObject:@(2)];
    testassert(result == NSOrderedSame);
    [desc release];

    return YES;
}

test(Sorting)
{
    NSSortDescriptor *desc = [[NSSortDescriptor alloc] initWithKey:nil ascending:YES comparator:^NSComparisonResult(id obj1, id obj2) {
        int i1 = [obj1 intValue];
        int i2 = [obj2 intValue];
        if (i1 < i2)
        {
            return NSOrderedAscending;
        }
        else if (i1 > i2)
        {
            return NSOrderedDescending;
        }
        else
        {
            return NSOrderedSame;
        }
    }];

    NSArray *sorted = [@[@(5), @(4), @(2), @(6), @(1), @(3)] sortedArrayUsingDescriptors:@[desc]];
    BOOL isSorted = [sorted isEqualToArray:@[@(1), @(2), @(3), @(4), @(5), @(6)]];
    testassert(isSorted);

    [desc release];
    
    return YES;
}

@end
