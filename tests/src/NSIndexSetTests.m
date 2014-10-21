//
//  NSIndexSetTests.m
//  FoundationTests
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "FoundationTests.h"
@interface NSIndexSet(Strings)
+(instancetype)indexSetWithString:(NSString *)indexSetString;
-(NSString *)stringValue;
@end

@implementation NSIndexSet(Strings)

- (NSString *)stringValue {
    NSMutableString *result = [NSMutableString string];
    [self enumerateRangesUsingBlock:^(NSRange range, __unused BOOL *stop) {
        [result appendString:NSStringFromRange(range)];
        [result appendString:@";"];
    }];
    return [result substringToIndex:result.length - 1];
}

+ (instancetype)indexSetWithString:(NSString *)indexSetString {
    NSArray *comp = [indexSetString componentsSeparatedByString:@";"];
    if(comp.count < 1)
        comp = @[indexSetString];
    NSMutableIndexSet *mis = [NSMutableIndexSet indexSet];
    for(NSString *s in comp){
        [mis addIndexesInRange:NSRangeFromString(s)];
    }
    return [[[self alloc] initWithIndexSet:mis] autorelease];
}
@end

@testcase(NSIndexSet)

test(IndexSet)
{
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    [indexSet addIndex:0];
    [indexSet addIndex:2];
    NSArray *a = @[@1, @20, @300, @4000];
    __block int sum = 0;
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        sum += [[a objectAtIndex:idx] intValue];
    }];
    testassert(sum == 301);
    return YES;
}

test(IndexSet2)
{
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    [indexSet addIndex:0];
    [indexSet addIndex:2];
    [indexSet addIndex:4];
    NSArray *a = @[@1, @20, @300, @4000, @50000];
    __block int sum = 0;
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        sum += [[a objectAtIndex:idx] intValue];
    }];
    testassert(sum == 50301);
    return YES;
}

test(IndexSet3)
{
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    [indexSet addIndex:2];
    [indexSet addIndex:4];
    [indexSet addIndex:0];  // insert at beginning
    NSArray *a = @[@1, @20, @300, @4000, @50000];
    __block int sum = 0;
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        sum += [[a objectAtIndex:idx] intValue];
    }];
    testassert(sum == 50301);
    return YES;
}

test(IndexSet4)
{
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    [indexSet addIndex:1];
    [indexSet addIndex:3];
    [indexSet addIndex:2];  // merging to single range
    NSArray *a = @[@1, @20, @300, @4000, @50000];
    __block int sum = 0;
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        sum += [[a objectAtIndex:idx] intValue];
    }];
    testassert(sum == 4320);
    return YES;
}

test(IndexSetWithIndex)
{
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSetWithIndex:2];
    NSArray *a = @[@1, @20, @300, @4000];
    __block int sum = 0;
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        sum += [[a objectAtIndex:idx] intValue];
    }];
    testassert(sum == 300);
    return YES;
}

test(IndexSetWithIndexesInRange)
{
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 3)];
    NSArray *a = @[@1, @20, @300, @4000];
    __block int sum = 0;
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        sum += [[a objectAtIndex:idx] intValue];
    }];
    testassert(sum == 4320);
    return YES;
}


test(ContainsIndex)
{
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    testassert([indexSet containsIndex:2] == NO);
    [indexSet addIndexesInRange:NSMakeRange(1, 3)];
    testassert([indexSet containsIndex:1]);
    testassert([indexSet containsIndex:3]);
    testassert([indexSet containsIndex:0] == NO);
    testassert([indexSet containsIndex:43452342] == NO);
    return YES;
}

test(ContainsIndexes)
{
    NSMutableIndexSet *indexSet0 = [NSMutableIndexSet indexSet];
    testassert([indexSet0 containsIndexes:nil] == YES);
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 5)];
    testassert([indexSet containsIndexes:nil] == YES);
    NSIndexSet *indexSet2 = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 2)];
    NSIndexSet *indexSet3 = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(2, 2)];
    NSIndexSet *indexSet4 = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(3, 4)];
    testassert([indexSet containsIndexes:indexSet]);
    testassert([indexSet containsIndexes:indexSet2]);
    testassert([indexSet containsIndexes:indexSet3]);
    testassert([indexSet0 containsIndexes:indexSet4] == NO);
    testassert([indexSet containsIndexes:indexSet4] == NO);
    testassert([indexSet containsIndexes:nil]);
    NSMutableIndexSet *indexSet5 = [NSMutableIndexSet indexSet];
    [indexSet5 addIndex:1];
    [indexSet5 addIndex:3];
    testassert([indexSet containsIndexes:indexSet5]);
    [indexSet5 addIndex:7];
    testassert([indexSet containsIndexes:indexSet5] == NO);
    return YES;
}

test(ContainsIndexesInRange)
{
    NSIndexSet *indexSet0 = [NSIndexSet indexSet];
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 3)];
    testassert([indexSet containsIndexesInRange:NSMakeRange(1, 3)]);
    testassert([indexSet containsIndexesInRange:NSMakeRange(1, 2)]);
    testassert([indexSet containsIndexesInRange:NSMakeRange(1, 0)] == NO);
    testassert([indexSet containsIndexesInRange:NSMakeRange(9, 0)] == NO);
    testassert([indexSet containsIndexesInRange:NSMakeRange(2, 3)] == NO);
    testassert([indexSet containsIndexesInRange:NSMakeRange(9, 3)] == NO);
    testassert([indexSet0 containsIndexesInRange:NSMakeRange(9, 3)] == NO);
    return YES;
}

test(ContainsIndexesInRange2)
{
    NSMutableIndexSet *indexSet = [[[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 3)] mutableCopy] autorelease];
    [indexSet addIndexesInRange:NSMakeRange(100,4)];
    testassert([indexSet containsIndexesInRange:NSMakeRange(1, 3)]);
    testassert([indexSet containsIndexesInRange:NSMakeRange(1, 2)]);
    testassert([indexSet containsIndexesInRange:NSMakeRange(101, 2)]);
    testassert([indexSet containsIndexesInRange:NSMakeRange(2, 3)] == NO);
    testassert([indexSet containsIndexesInRange:NSMakeRange(9, 3)] == NO);
    return YES;
}


test(Count)
{
    NSIndexSet *indexSet0 = [NSMutableIndexSet indexSet];
    testassert([indexSet0 count] == 0);
    NSMutableIndexSet *indexSet = [[[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 3)] mutableCopy] autorelease];
    testassert([indexSet count] == 3);
    [indexSet addIndexesInRange:NSMakeRange(100,4)];
    testassert([indexSet count] == 7);
    [indexSet addIndex:2];
    testassert([indexSet count] == 7);
    [indexSet addIndex:2000];
    testassert([indexSet count] == 8);
    return YES;
}


test(CountOfIndexesInRange)
{
    NSMutableIndexSet *indexSet0 = [NSMutableIndexSet indexSet];
    testassert([indexSet0 countOfIndexesInRange:NSMakeRange(1,3)] == 0);
    NSMutableIndexSet *indexSet = [[[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 3)] mutableCopy] autorelease];
    testassert([indexSet countOfIndexesInRange:NSMakeRange(1,3)] == 3);
    testassert([indexSet countOfIndexesInRange:NSMakeRange(1,2)] == 2);
    testassert([indexSet countOfIndexesInRange:NSMakeRange(3,7)] == 1);
    [indexSet addIndexesInRange:NSMakeRange(100,4)];
    testassert([indexSet countOfIndexesInRange:NSMakeRange(1,3)] == 3);
    testassert([indexSet countOfIndexesInRange:NSMakeRange(1,2)] == 2);
    testassert([indexSet countOfIndexesInRange:NSMakeRange(3,7)] == 1);
    testassert([indexSet countOfIndexesInRange:NSMakeRange(99,3)] == 2);
    testassert([indexSet count] == 7);
    [indexSet addIndex:2];
    testassert([indexSet count] == 7);
    [indexSet addIndex:2000];
    testassert([indexSet count] == 8);
    return YES;
}


test(FirstIndex)
{
    NSMutableIndexSet *indexSet0 = [NSMutableIndexSet indexSet];
    testassert([indexSet0 firstIndex] == NSNotFound);
    NSMutableIndexSet *indexSet = [[[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 3)] mutableCopy] autorelease];
    testassert([indexSet firstIndex] == 1);
    [indexSet addIndexesInRange:NSMakeRange(100,4)];
    testassert([indexSet firstIndex] == 1);
    return YES;
}

test(IndexPassingTest)
{
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 3)];
    
    NSUInteger passedTest = [indexSet indexPassingTest:^BOOL(NSUInteger idx, BOOL *stop) {
        return idx == 2;
    }];
    testassert(passedTest == 2);
    return YES;
}

test(IndexPassingTest2)
{
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 3)];
    
    NSUInteger passedTest = [indexSet indexPassingTest:^BOOL(NSUInteger idx, BOOL *stop) {
        return idx == 20;
    }];
    testassert(passedTest == NSNotFound);
    return YES;
}

test(IndexPassingTestReverse)
{
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 3)];
    
    NSUInteger passedTest = [indexSet indexWithOptions:(NSEnumerationReverse) passingTest:^BOOL(NSUInteger idx, BOOL *stop) {
        return idx == 2;
    }];
    testassert(passedTest == 2);
    return YES;
}

test(IndexPassingTestReverse2)
{
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 3)];
    
    NSUInteger passedTest = [indexSet indexWithOptions:(NSEnumerationReverse) passingTest:^BOOL(NSUInteger idx, BOOL *stop) {
        *stop = YES;
        return idx == 2;
    }];
    testassert(passedTest == NSNotFound);
    return YES;
}

test(IndexPassingTestConcurrent)
{
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 3)];
    
    NSUInteger passedTest = [indexSet indexWithOptions:(NSEnumerationConcurrent) passingTest:^BOOL(NSUInteger idx, BOOL *stop) {
        return idx == 2;
    }];
    testassert(passedTest == 2);
    return YES;
}

test(IndexPassingTestConcurrent2)
{
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 3)];
    
    NSUInteger passedTest = [indexSet indexWithOptions:(NSEnumerationConcurrent) passingTest:^BOOL(NSUInteger idx, BOOL *stop) {
        *stop = YES;
        return idx == 20;
    }];
    testassert(passedTest == NSNotFound);
    return YES;
}


test(IndexPassingTestMultiple)
{
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    [indexSet addIndex:1];
    [indexSet addIndex:4];
    
    NSUInteger passedTest = [indexSet indexPassingTest:^BOOL(NSUInteger idx, BOOL *stop) {
        return idx == 4;
    }];
    testassert(passedTest == 4);
    return YES;
}

test(IndexPassingTest2Multiple)
{
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    [indexSet addIndex:1];
    [indexSet addIndex:4];
    
    NSUInteger passedTest = [indexSet indexPassingTest:^BOOL(NSUInteger idx, BOOL *stop) {
        return idx == 20;
    }];
    testassert(passedTest == NSNotFound);
    return YES;
}

test(IndexPassingTestReverseMultiple)
{
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    [indexSet addIndex:1];
    [indexSet addIndex:2];
    [indexSet addIndex:4];
    
    NSUInteger passedTest = [indexSet indexWithOptions:(NSEnumerationReverse) passingTest:^BOOL(NSUInteger idx, BOOL *stop) {
        return idx;
    }];
    testassert(passedTest == 4);
    return YES;
}

test(IndexPassingTestReverse2Multiple)
{
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    [indexSet addIndex:1];
    [indexSet addIndex:4];
    [indexSet addIndex:5];
    
    NSUInteger passedTest = [indexSet indexWithOptions:(NSEnumerationReverse) passingTest:^BOOL(NSUInteger idx, BOOL *stop) {
        *stop = YES;
        return idx == 2;
    }];
    testassert(passedTest == NSNotFound);
    return YES;
}

test(IndexPassingTestConcurrentMultiple)
{
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    [indexSet addIndex:1];
    [indexSet addIndex:2];
    [indexSet addIndex:4];
    
    NSUInteger passedTest = [indexSet indexWithOptions:(NSEnumerationConcurrent) passingTest:^BOOL(NSUInteger idx, BOOL *stop) {
        return idx == 2;
    }];
    testassert(passedTest == 2);
    return YES;
}

test(IndexPassingTestConcurrent2Multiple)
{
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    [indexSet addIndex:1];
    [indexSet addIndex:1947328574];
    
    NSUInteger passedTest = [indexSet indexWithOptions:(NSEnumerationConcurrent) passingTest:^BOOL(NSUInteger idx, BOOL *stop) {
        *stop = YES;
        return idx == 20;
    }];
    testassert(passedTest == NSNotFound);
    return YES;
}

test(IndexPassingTestRange)
{
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 3)];
    
    NSUInteger passedTest = [indexSet indexInRange:NSMakeRange(1, 2) options:0 passingTest:^BOOL(NSUInteger idx, BOOL *stop) {
        return idx == 2;
    }];
    testassert(passedTest == 2);
    return YES;
}

test(IndexPassingTest2Range)
{
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 3)];
    
    NSUInteger passedTest = [indexSet indexInRange:NSMakeRange(1, 2) options:0 passingTest:^BOOL(NSUInteger idx, BOOL *stop) {
        return idx == 20;
    }];
    testassert(passedTest == NSNotFound);
    return YES;
}

test(IndexPassingTestReverseRange)
{
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 3)];
    
    NSUInteger passedTest = [indexSet indexInRange:NSMakeRange(1, 2) options:NSEnumerationReverse passingTest:^BOOL(NSUInteger idx, BOOL *stop) {
        return idx == 2;
    }];
    testassert(passedTest == 2);
    return YES;
}

test(IndexPassingTestReverse2Range)
{
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 3)];
    
    NSUInteger passedTest = [indexSet indexInRange:NSMakeRange(1, 2) options:NSEnumerationReverse passingTest:^BOOL(NSUInteger idx, BOOL *stop) {
        *stop = YES;
        return idx == 2;
    }];
    testassert(passedTest == 2);
    return YES;
}

test(IndexPassingTestReverse2Range2)
{
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 3)];
    
    NSUInteger passedTest = [indexSet indexInRange:NSMakeRange(2, 2) options:NSEnumerationReverse passingTest:^BOOL(NSUInteger idx, BOOL *stop) {
        *stop = YES;
        return idx == 2;
    }];
    testassert(passedTest == NSNotFound);
    return YES;
}


test(IndexPassingTestConcurrentRange)
{
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 3)];
    
    NSUInteger passedTest = [indexSet indexInRange:NSMakeRange(1, 2) options:NSEnumerationConcurrent passingTest:^BOOL(NSUInteger idx, BOOL *stop) {
        return idx == 2;
    }];
    testassert(passedTest == 2);
    return YES;
}

test(IndexPassingTestConcurrent2Range)
{
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 3)];
    
    NSUInteger passedTest = [indexSet indexInRange:NSMakeRange(1, 2) options:NSEnumerationConcurrent passingTest:^BOOL(NSUInteger idx, BOOL *stop) {
        *stop = YES;
        return idx == 20;
    }];
    testassert(passedTest == NSNotFound);
    return YES;
}

test(IndexPassingTestMultipleRange)
{
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    [indexSet addIndex:1];
    [indexSet addIndex:4];
    
    NSUInteger passedTest = [indexSet indexInRange:NSMakeRange(1, 2) options:0 passingTest:^BOOL(NSUInteger idx, BOOL *stop) {
        return idx == 4;
    }];
    testassert(passedTest == NSNotFound);
    return YES;
}

test(IndexPassingTestMultipleRange2)
{
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    [indexSet addIndex:1];
    [indexSet addIndex:4];
    
    NSUInteger passedTest = [indexSet indexInRange:NSMakeRange(1, 2) options:0 passingTest:^BOOL(NSUInteger idx, BOOL *stop) {
        return idx == 1;
    }];
    testassert(passedTest == 1);
    return YES;
}

test(IndexPassingTest2MultipleRange)
{
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    [indexSet addIndex:1];
    [indexSet addIndex:4];
    
    NSUInteger passedTest = [indexSet indexInRange:NSMakeRange(1, 2) options:0 passingTest:^BOOL(NSUInteger idx, BOOL *stop) {
        return idx == 20;
    }];
    testassert(passedTest == NSNotFound);
    return YES;
}

test(IndexPassingTestReverseMultipleRange)
{
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    [indexSet addIndex:1];
    [indexSet addIndex:2];
    [indexSet addIndex:4];
    
    NSUInteger passedTest = [indexSet indexInRange:NSMakeRange(1, 2) options:NSEnumerationReverse passingTest:^BOOL(NSUInteger idx, BOOL *stop) {
        return idx;
    }];
    testassert(passedTest == 2);
    return YES;
}

test(IndexPassingTestReverse2MultipleRange)
{
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    [indexSet addIndex:1];
    [indexSet addIndex:4];
    [indexSet addIndex:5];
    
    NSUInteger passedTest = [indexSet indexInRange:NSMakeRange(1, 2) options:NSEnumerationReverse passingTest:^BOOL(NSUInteger idx, BOOL *stop) {
        *stop = YES;
        return idx == 2;
    }];
    testassert(passedTest == NSNotFound);
    return YES;
}

test(IndexPassingTestConcurrentMultipleRange)
{
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    [indexSet addIndex:1];
    [indexSet addIndex:2];
    [indexSet addIndex:4];
    
    NSUInteger passedTest = [indexSet indexInRange:NSMakeRange(1, 2) options:NSEnumerationConcurrent passingTest:^BOOL(NSUInteger idx, BOOL *stop) {
        return idx == 2;
    }];
    testassert(passedTest == 2);
    return YES;
}

test(IndexPassingTestConcurrent2MultipleRange)
{
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    [indexSet addIndex:1];
    [indexSet addIndex:1947328574];
    
    NSUInteger passedTest = [indexSet indexInRange:NSMakeRange(1, 44444) options:NSEnumerationConcurrent passingTest:^BOOL(NSUInteger idx, BOOL *stop) {
        *stop = YES;
        return idx == 20;
    }];
    testassert(passedTest == NSNotFound);
    return YES;
}

test(IndexesPassingTest)
{
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 3)];
    NSArray *a = @[@1, @20, @300, @4000];
    
    NSIndexSet *passedTest = [indexSet indexesPassingTest:^BOOL(NSUInteger idx, BOOL *stop) {
        return idx & 1;
    }];
    
    __block int sum = 0;
    [passedTest enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        sum += [[a objectAtIndex:idx] intValue];
    }];
    testassert(sum == 4020);
    return YES;
}

test(IndexesPassingTestReverse)
{
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 3)];
    NSArray *a = @[@1, @20, @300, @4000];
    
    NSIndexSet *passedTest = [indexSet indexesWithOptions:NSEnumerationReverse passingTest:^BOOL(NSUInteger idx, BOOL *stop) {
        *stop = YES;
        return idx & 1;
    }];
    
    __block int sum = 0;
    [passedTest enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        sum += [[a objectAtIndex:idx] intValue];
    }];
    testassert(sum == 4000);
    return YES;
}

test(IndexesPassingTestConcurrent)
{
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 3)];
    NSArray *a = @[@1, @20, @300, @4000];
    
    NSIndexSet *passedTest = [indexSet indexesWithOptions:NSEnumerationConcurrent passingTest:^BOOL(NSUInteger idx, BOOL *stop) {
        *stop = YES;
        return idx & 1;
    }];
    
    __block int sum = 0;
    [passedTest enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        sum += [[a objectAtIndex:idx] intValue];
    }];
    testassert(sum == 20);
    return YES;
}


test(IndexesPassingTestMultiple)
{
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    [indexSet addIndex:1];
    [indexSet addIndex:3];
    [indexSet addIndex:4];
    NSArray *a = @[@1, @20, @300, @4000, @50000];
    
    NSIndexSet *passedTest = [indexSet indexesPassingTest:^BOOL(NSUInteger idx, BOOL *stop) {
        return idx & 1;
    }];
    
    __block int sum = 0;
    [passedTest enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        sum += [[a objectAtIndex:idx] intValue];
    }];
    testassert(sum == 4020);
    return YES;
}

test(IndexesPassingTestReverseMultiple)
{
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    [indexSet addIndex:1];
    [indexSet addIndex:4];
    NSArray *a = @[@1, @20, @300, @4000];
    
    NSIndexSet *passedTest = [indexSet indexesWithOptions:NSEnumerationReverse passingTest:^BOOL(NSUInteger idx, BOOL *stop) {
        *stop = YES;
        return idx & 1;
    }];
    
    __block int sum = 0;
    [passedTest enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        sum += [[a objectAtIndex:idx] intValue];
    }];
    testassert(sum == 0);
    return YES;
}

test(IndexesPassingTestConcurrentMultiple)
{
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    [indexSet addIndex:1];
    [indexSet addIndex:4];
    NSArray *a = @[@1, @20, @300, @4000, @50000];
    
    NSIndexSet *passedTest = [indexSet indexesWithOptions:NSEnumerationConcurrent passingTest:^BOOL(NSUInteger idx, BOOL *stop) {
        *stop = YES;
        return idx & 1;
    }];
    
    __block int sum = 0;
    [passedTest enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        sum += [[a objectAtIndex:idx] intValue];
    }];
    testassert(sum == 20);
    return YES;
}

test(IndexesPassingTestRange)
{
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 3)];
    NSArray *a = @[@1, @20, @300, @4000];
    
    NSIndexSet *passedTest = [indexSet indexesInRange:NSMakeRange(1,3) options:0 passingTest:^BOOL(NSUInteger idx, BOOL *stop) {
        return idx & 1;
    }];
    
    __block int sum = 0;
    [passedTest enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        sum += [[a objectAtIndex:idx] intValue];
    }];
    testassert(sum == 4020);
    return YES;
}

test(IndexesPassingTestReverseRange)
{
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 3)];
    NSArray *a = @[@1, @20, @300, @4000];
    
    NSIndexSet *passedTest = [indexSet indexesInRange:NSMakeRange(1,3) options:NSEnumerationReverse passingTest:^BOOL(NSUInteger idx, BOOL *stop) {
        *stop = YES;
        return idx & 1;
    }];
    
    __block int sum = 0;
    [passedTest enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        sum += [[a objectAtIndex:idx] intValue];
    }];
    testassert(sum == 4000);
    return YES;
}

test(IndexesPassingTestConcurrentRange)
{
#warning TODO data race makes this test fail intermittently
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(2, 4)];
    NSArray *a = @[@1, @20, @300, @4000, @50000];

    NSIndexSet *passedTest = [indexSet indexesInRange:NSMakeRange(3,3) options:NSEnumerationConcurrent passingTest:^BOOL(NSUInteger idx, BOOL *stop) {
        *stop = idx & 1;
        return *stop;
    }];
    
    __block int sum = 0;
    [passedTest enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        sum += [[a objectAtIndex:idx] intValue];
    }];
    testassert(sum == 4000);
    return YES;
}


// The ShiftIndexesSeries was captured from an app in the wild
// All starting index sets were captured from the implementation at the time
test(ShiftIndexesSeries0) {
    NSMutableIndexSet *mis = [NSMutableIndexSet indexSetWithString:@"{0, 2}"];
    [mis shiftIndexesStartingAtIndex:1 by:1];
    testassert([[NSIndexSet indexSetWithString:@"{0, 1};{2, 1}"] isEqualToIndexSet:mis]);
    return YES;
}

test(ShiftIndexesSeries1) {
    NSMutableIndexSet *mis = [NSMutableIndexSet indexSetWithString:@"{1, 3}"];
    [mis shiftIndexesStartingAtIndex:2 by:1];
    testassert([[NSIndexSet indexSetWithString:@"{1, 1};{3, 2}"] isEqualToIndexSet:mis]);
    return YES;
}

test(ShiftIndexesSeries2) {
    NSMutableIndexSet *mis = [NSMutableIndexSet indexSetWithString:@"{2, 3}"];
    [mis shiftIndexesStartingAtIndex:3 by:1];
    testassert([[NSIndexSet indexSetWithString:@"{2, 1};{4, 2}"] isEqualToIndexSet:mis]);
    return YES;
}

test(ShiftIndexesSeries3) {
    NSMutableIndexSet *mis = [NSMutableIndexSet indexSetWithString:@"{3, 3}"];
    [mis shiftIndexesStartingAtIndex:4 by:1];
    testassert([[NSIndexSet indexSetWithString:@"{3, 1};{5, 2}"] isEqualToIndexSet:mis]);
    return YES;
}

test(ShiftIndexesSeries4) {
    NSMutableIndexSet *mis = [NSMutableIndexSet indexSetWithString:@"{4, 3}"];
    [mis shiftIndexesStartingAtIndex:3 by:1];
    testassert([[NSIndexSet indexSetWithString:@"{5, 3}"] isEqualToIndexSet:mis]);
    return YES;
}

test(ShiftIndexesSeries5) {
    NSMutableIndexSet *mis = [NSMutableIndexSet indexSetWithString:@"{0, 2}"];
    [mis shiftIndexesStartingAtIndex:1 by:1];
    testassert([[NSIndexSet indexSetWithString:@"{0, 1};{2, 1}"] isEqualToIndexSet:mis]);
    return YES;
}

test(ShiftIndexesSeries6) {
    NSMutableIndexSet *mis = [NSMutableIndexSet indexSetWithString:@"{0, 3}"];
    [mis shiftIndexesStartingAtIndex:2 by:1];
    testassert([[NSIndexSet indexSetWithString:@"{0, 2};{3, 1}"] isEqualToIndexSet:mis]);
    return YES;
}

test(ShiftIndexesSeries7) {
    NSMutableIndexSet *mis = [NSMutableIndexSet indexSetWithString:@"{0, 1};{2, 3};{3, 1}"];
    [mis shiftIndexesStartingAtIndex:4 by:1];
    testassert([[NSIndexSet indexSetWithString:@"{0, 1};{2, 2};{5, 1}"] isEqualToIndexSet:mis]);
    return YES;
}

test(ShiftIndexesSeries8) {
    NSMutableIndexSet *mis = [NSMutableIndexSet indexSetWithString:@"{0, 1};{2, 3};{3, 2}"];
    [mis shiftIndexesStartingAtIndex:3 by:1];
    testassert([[NSIndexSet indexSetWithString:@"{0, 1};{2, 1};{4, 2}"] isEqualToIndexSet:mis]);
    return YES;
}

test(ShiftIndexesSeries9) {
    NSMutableIndexSet *mis = [NSMutableIndexSet indexSetWithString:@"{0, 1};{2, 3};{4, 2}"];
    [mis shiftIndexesStartingAtIndex:4 by:1];
    testassert([[NSIndexSet indexSetWithString:@"{0, 1};{2, 2};{5, 2}"] isEqualToIndexSet:mis]);
    return YES;
}

test(IndexesPassingTestMultipleRange)
{
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    [indexSet addIndex:1];
    [indexSet addIndex:4];
    [indexSet addIndex:5];
    NSArray *a = @[@1, @20, @300, @4000, @50000];
    
    NSIndexSet *passedTest = [indexSet indexesInRange:NSMakeRange(3,3) options:0 passingTest:^BOOL(NSUInteger idx, BOOL *stop) {
        return (idx & 1) == 0;
    }];
    
    __block int sum = 0;
    [passedTest enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        sum += [[a objectAtIndex:idx] intValue];
    }];
    testassert(sum == 50000);
    return YES;
}

test(IndexesPassingTestReverseMultipleRange)
{
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    [indexSet addIndex:1];
    [indexSet addIndex:4];
    NSArray *a = @[@1, @20, @300, @4000];
    
    NSIndexSet *passedTest = [indexSet indexesInRange:NSMakeRange(1,3) options:NSEnumerationReverse passingTest:^BOOL(NSUInteger idx, BOOL *stop) {
        *stop = YES;
        return idx & 1;
    }];
    
    __block int sum = 0;
    [passedTest enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        sum += [[a objectAtIndex:idx] intValue];
    }];
    testassert(sum == 20);
    return YES;
}

test(IndexesPassingTestConcurrentMultipleRange)
{
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    [indexSet addIndex:1];
    [indexSet addIndex:4];
    NSArray *a = @[@1, @20, @300, @4000, @50000];
    
    NSIndexSet *passedTest = [indexSet indexesInRange:NSMakeRange(1,3) options:NSEnumerationConcurrent passingTest:^BOOL(NSUInteger idx, BOOL *stop) {
        *stop = idx & 1;
        return *stop;
    }];
    
    __block int sum = 0;
    [passedTest enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        sum += [[a objectAtIndex:idx] intValue];
    }];
    testassert(sum == 20);
    return YES;
}

test(IndexGreaterThanIndex)
{
    NSMutableIndexSet *indexSet0 = [NSMutableIndexSet indexSet];
    testassert([indexSet0 indexGreaterThanIndex:2] == NSNotFound);
    NSMutableIndexSet *indexSet = [[[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 3)] mutableCopy] autorelease];
    testassert([indexSet indexGreaterThanIndex:2] == 3);
    testassert([indexSet indexGreaterThanIndex:3] == NSNotFound);
    testassert([indexSet indexGreaterThanIndex:8] == NSNotFound);
    [indexSet addIndexesInRange:NSMakeRange(100,4)];
    testassert([indexSet indexGreaterThanIndex:8] == 100);
    testassert([indexSet indexGreaterThanIndex:101] == 102);
    testassert([indexSet indexGreaterThanIndex:1000] == NSNotFound);
    testassert([indexSet indexGreaterThanIndex:2] == 3);
    return YES;
}

test(IndexGreaterThanOrEqualToIndex)
{
    NSMutableIndexSet *indexSet0 = [NSMutableIndexSet indexSet];
    testassert([indexSet0 indexGreaterThanOrEqualToIndex:2] == NSNotFound);
    NSMutableIndexSet *indexSet = [[[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 3)] mutableCopy] autorelease];
    testassert([indexSet indexGreaterThanOrEqualToIndex:2] == 2);
    testassert([indexSet indexGreaterThanOrEqualToIndex:3] == 3);
    testassert([indexSet indexGreaterThanOrEqualToIndex:8] == NSNotFound);
    [indexSet addIndexesInRange:NSMakeRange(100,4)];
    testassert([indexSet indexGreaterThanOrEqualToIndex:8] == 100);
    testassert([indexSet indexGreaterThanOrEqualToIndex:101] == 101);
    testassert([indexSet indexGreaterThanOrEqualToIndex:1000] == NSNotFound);
    testassert([indexSet indexGreaterThanOrEqualToIndex:2] == 2);
    return YES;
}

test(IndexLessThanIndex)
{
    NSMutableIndexSet *indexSet0 = [NSMutableIndexSet indexSet];
    testassert([indexSet0 indexLessThanIndex:2] == NSNotFound);
    NSMutableIndexSet *indexSet = [[[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 3)] mutableCopy] autorelease];
    testassert([indexSet indexLessThanIndex:2] == 1);
    testassert([indexSet indexLessThanIndex:1] == NSNotFound);
    testassert([indexSet indexLessThanIndex:8] == 3);
    [indexSet addIndexesInRange:NSMakeRange(100,4)];
    testassert([indexSet indexLessThanIndex:8] == 3);
    testassert([indexSet indexLessThanIndex:101] == 100);
    testassert([indexSet indexLessThanIndex:1000] == 103);
    testassert([indexSet indexLessThanIndex:2] == 1);
    return YES;
}

test(IndexLessThanOrEqualToIndex)
{
    NSMutableIndexSet *indexSet0 = [NSMutableIndexSet indexSet];
    testassert([indexSet0 indexLessThanOrEqualToIndex:2] == NSNotFound);
    NSMutableIndexSet *indexSet = [[[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 3)] mutableCopy] autorelease];
    testassert([indexSet indexLessThanOrEqualToIndex:2] == 2);
    testassert([indexSet indexLessThanOrEqualToIndex:3] == 3);
    testassert([indexSet indexLessThanOrEqualToIndex:8] == 3);
    [indexSet addIndexesInRange:NSMakeRange(100,4)];
    testassert([indexSet indexLessThanOrEqualToIndex:8] == 3);
    testassert([indexSet indexLessThanOrEqualToIndex:101] == 101);
    testassert([indexSet indexLessThanOrEqualToIndex:1000] == 103);
    testassert([indexSet indexLessThanOrEqualToIndex:2] == 2);
    return YES;
}

test(InitWithIndex)
{
    NSIndexSet *indexSet = [[NSIndexSet alloc] initWithIndex:2];
    testassert([indexSet indexLessThanOrEqualToIndex:2] == 2);
    [indexSet release];
    return YES;
}

test(InitWithIndexesInRange)
{
    NSIndexSet *indexSet = [[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(2,99)];
    testassert([indexSet indexLessThanOrEqualToIndex:2] == 2);
    [indexSet release];
    return YES;
}

test(InitWithIndexSet)
{
    NSIndexSet *indexSetIniter = [[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(2,99)];
    NSIndexSet *indexSet = [[NSIndexSet alloc] initWithIndexSet:indexSetIniter];
    testassert([indexSet indexLessThanOrEqualToIndex:2] == 2);
    [indexSetIniter release];
    [indexSet release];
    return YES;
}


test(IntersectsIndexesInRange)
{
    NSMutableIndexSet *indexSet0 = [NSMutableIndexSet indexSet];
    testassert([indexSet0 intersectsIndexesInRange:NSMakeRange(4,2)] == NO);
    NSMutableIndexSet *indexSet = [[[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 3)] mutableCopy] autorelease];
    testassert([indexSet intersectsIndexesInRange:NSMakeRange(0,1)] == NO);
    testassert([indexSet intersectsIndexesInRange:NSMakeRange(0,2)] == YES);
    testassert([indexSet intersectsIndexesInRange:NSMakeRange(1,6)] == YES);
    testassert([indexSet intersectsIndexesInRange:NSMakeRange(3,22)] == YES);
    testassert([indexSet intersectsIndexesInRange:NSMakeRange(5,100)] == NO);
    [indexSet addIndexesInRange:NSMakeRange(100,4)];
    testassert([indexSet intersectsIndexesInRange:NSMakeRange(0,1)] == NO);
    testassert([indexSet intersectsIndexesInRange:NSMakeRange(0,2)] == YES);
    testassert([indexSet intersectsIndexesInRange:NSMakeRange(1,6)] == YES);
    testassert([indexSet intersectsIndexesInRange:NSMakeRange(3,22)] == YES);
    testassert([indexSet intersectsIndexesInRange:NSMakeRange(5,100)] == YES);
    testassert([indexSet intersectsIndexesInRange:NSMakeRange(101,100)] == YES);
    testassert([indexSet intersectsIndexesInRange:NSMakeRange(1010,100)] == NO);
    return YES;
}


test(IsEqualToIndexSet)
{
    NSIndexSet *indexSetIniter = [[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(2,99)];
    NSIndexSet *indexSet = [[NSIndexSet alloc] initWithIndexSet:indexSetIniter];
    testassert([indexSet isEqualToIndexSet:indexSetIniter]);
    NSMutableIndexSet *indexSet0 = [NSMutableIndexSet indexSet];
    testassert([indexSet isEqualToIndexSet:indexSet0] == NO);
    testassert([indexSet0 isEqualToIndexSet:indexSet] == NO);
    [indexSetIniter release];
    [indexSet release];
    return YES;
}

test(IsEqualToIndexSet2)
{
    NSMutableIndexSet *i0 = [NSMutableIndexSet indexSetWithIndex:0];
    [i0 addIndexesInRange:NSMakeRange(2, 2)];
    NSMutableIndexSet *i1 = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(2, 2)];
    [i1 addIndex:0];
    testassert([i0 isEqualToIndexSet:i1]);
    testassert([i1 isEqualToIndexSet:i0]);
    
    return YES;
}
test(IndexSetShiftSplitsSingleRange) {
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 3)];
    [indexSet shiftIndexesStartingAtIndex:2 by:1];
    NSMutableIndexSet *solution = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)];
    [solution addIndex:3];
    testassert([solution isEqualToIndexSet:indexSet]);
    return YES;
}
test(IndexSetShiftMultiRangeByImmediatelyAfter) {
    NSMutableIndexSet *i = [NSMutableIndexSet indexSetWithIndex:0];
    [i addIndexesInRange:NSMakeRange(3, 2)];
    NSIndexSet *iCopy = [i copy];
    [i shiftIndexesStartingAtIndex:i.lastIndex + 1 by:1];
    testassert([i isEqualToIndexSet:iCopy]);
    [iCopy release];
    return YES;
}

test(IndexSetShiftOneRangeByImmediatelyAfter) {
    NSMutableIndexSet *i = [NSMutableIndexSet indexSetWithIndex:0];
    [i shiftIndexesStartingAtIndex:1 by:1];
    testassert(i.firstIndex == 0);
    return YES;
}

test(IndexSetMergeAdjacents)
{
    NSMutableIndexSet *i0 = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(4, 2)];
    [i0 addIndexesInRange:NSMakeRange(10, 2)];
    [i0 addIndexesInRange:NSMakeRange(6, 2)];
    __block int numRanges = 0;
    [i0 enumerateRangesUsingBlock:^(NSRange range, BOOL *stop) {
        numRanges++;
    }];
    testassert(numRanges == 2);
    return YES;
}

test(LastIndex)
{
    NSMutableIndexSet *indexSet0 = [NSMutableIndexSet indexSet];
    testassert([indexSet0 lastIndex] == NSNotFound);
    NSMutableIndexSet *indexSet = [[[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 3)] mutableCopy] autorelease];
    testassert([indexSet lastIndex] == 3);
    [indexSet addIndexesInRange:NSMakeRange(100,4)];
    testassert([indexSet lastIndex] == 103);
    return YES;
}

test(RemoveAllIndexes)
{
    NSIndexSet *indexSet0 = [NSIndexSet indexSet];
    NSMutableIndexSet *indexSet0m = [[indexSet0 mutableCopy] autorelease];
    [indexSet0m removeAllIndexes];
    testassert([indexSet0m isEqualToIndexSet:indexSet0]);
    NSMutableIndexSet *indexSet = [[[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 3)] mutableCopy] autorelease];
    [indexSet removeAllIndexes];
    testassert([indexSet isEqualToIndexSet:indexSet0]);
    return YES;
}

test(RemoveIndex)
{
    NSMutableIndexSet *indexSet = [[[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 3)] mutableCopy] autorelease];
    [indexSet removeIndex:2];
    NSArray *a = @[@1, @20, @300, @4000];
    __block int sum = 0;
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        sum += [[a objectAtIndex:idx] intValue];
    }];
    testassert(sum == 4020);
    [indexSet removeIndex:9999];
    testassert([indexSet count] == 2);
    [indexSet removeIndex:2];
    testassert([indexSet count] == 2);
    [indexSet removeIndex:1];
    testassert([indexSet count] == 1);
    [indexSet removeIndex:3];
    testassert([indexSet count] == 0);
    return YES;
}

test(RemoveIndexesInRange)
{
    NSMutableIndexSet *indexSet = [[[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 4)] mutableCopy] autorelease];
    [indexSet removeIndexesInRange:NSMakeRange(2,2)];
    NSArray *a = @[@1, @20, @300, @4000, @50000];
    __block int sum = 0;
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        sum += [[a objectAtIndex:idx] intValue];
    }];
    testassert(sum == 50020);
    [indexSet removeIndexesInRange:NSMakeRange(3,1)];
    testassert([indexSet count] == 2);
    [indexSet removeIndexesInRange:NSMakeRange(4,100)];
    testassert([indexSet count] == 1);
    [indexSet removeIndexesInRange:NSMakeRange(0,7)];
    testassert([indexSet count] == 0);
    return YES;
}

test(RemoveIndexesInRange2)
{
    NSMutableIndexSet *indexSet0 = [[[NSIndexSet indexSet] mutableCopy] autorelease];
    [indexSet0 removeIndexesInRange:NSMakeRange(2,2)];
    NSMutableIndexSet *indexSet = [[[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 4)] mutableCopy] autorelease];
    [indexSet removeIndexesInRange:NSMakeRange(4,2)];
    NSArray *a = @[@1, @20, @300, @4000, @50000];
    __block int sum = 0;
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        sum += [[a objectAtIndex:idx] intValue];
    }];
    testassert(sum == 4320);
    [indexSet removeIndexesInRange:NSMakeRange(4,2)];
    testassert([indexSet count] == 3);
    [indexSet removeIndexesInRange:NSMakeRange(1,1)];
    testassert([indexSet count] == 2);
    [indexSet removeIndexesInRange:NSMakeRange(2,1)];
    testassert([indexSet count] == 1);
    [indexSet removeIndexesInRange:NSMakeRange(1, 1000000)];
    testassert([indexSet count] == 0);
    return YES;
}

test(MutateIndexes)
{
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSetWithString:@"{0, 5};{7, 5};{23, 5}"];

    [indexSet removeIndexesInRange:NSMakeRange(8, 1)];
    testassert([indexSet isEqualToIndexSet:[NSIndexSet indexSetWithString:@"{0, 5};{7, 1};{9, 3};{23, 5}"]]);

    [indexSet addIndexesInRange:NSMakeRange(42, 5)];
    testassert([indexSet isEqualToIndexSet:[NSIndexSet indexSetWithString:@"{0, 5};{7, 1};{9, 3};{23, 5};{42, 5}"]]);

    [indexSet removeIndexesInRange:NSMakeRange(0, 20)];
    testassert([indexSet isEqualToIndexSet:[NSIndexSet indexSetWithString:@"{23, 5};{42, 5}"]]);

    [indexSet removeIndexesInRange:NSMakeRange(20, 20)];
    testassert([indexSet isEqualToIndexSet:[NSIndexSet indexSetWithString:@"{42, 5}"]]);

    testassert([indexSet lastIndex] == 46);

    return YES;
}

test(RemoveIndexesInRangeZero)
{
    NSMutableIndexSet *indexSet0 = [[[NSIndexSet indexSet] mutableCopy] autorelease];
    [indexSet0 removeIndexesInRange:NSMakeRange(2,2)];
    NSMutableIndexSet *indexSet = [[[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 4)] mutableCopy] autorelease];
    [indexSet addIndex:9];
    [indexSet addIndex:11];
    [indexSet addIndex:6];
    
    testassert([indexSet count] == 7);
    
    [indexSet removeIndexesInRange:NSMakeRange(0,2)];
    testassert([indexSet count] == 5);
    NSArray *a = @[@1, @20, @300, @4000, @50000, @2, @30, @400, @5000, @60000, @700000, @80000000];
    __block int sum = 0;
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        sum += [[a objectAtIndex:idx] intValue];
    }];
    testassert(sum == 80064330);
    [indexSet removeIndexesInRange:NSMakeRange(4,2)];
    testassert([indexSet count] == 5);
    [indexSet removeIndexesInRange:NSMakeRange(1,1)];
    testassert([indexSet count] == 5);
    [indexSet removeIndexesInRange:NSMakeRange(11,10)];
    testassert([indexSet count] == 4);
    [indexSet removeIndexesInRange:NSMakeRange(1, 1000000)];
    testassert([indexSet count] == 0);
    return YES;
}

test(RemoveIndexes)
{
    NSMutableIndexSet *indexSet = [[[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 4)] mutableCopy] autorelease];
    NSMutableIndexSet *indexSet0 = [NSMutableIndexSet indexSet];
    [indexSet removeIndexes:indexSet0];
    testassert([indexSet count] == 4);
    NSMutableIndexSet *indexSet2 = [[[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 3)] mutableCopy] autorelease];
    [indexSet removeIndexes:indexSet2];
    testassert([indexSet count] == 1);
    return YES;
}

test(IndexSetEnumerateIndexesInRange)
{
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    [indexSet addIndex:0];
    [indexSet addIndex:1];
    [indexSet addIndex:2];
    NSArray *a = @[@1, @20, @300, @4000];
    __block int sum = 0;
    [indexSet enumerateIndexesInRange:NSMakeRange(1, 2) options:0 usingBlock:^(NSUInteger idx, BOOL *stop){
        sum += [[a objectAtIndex:idx] intValue];
    }];
    testassert(sum == 320);
    return YES;
}

test(IndexSetEnumerateIndexesInRangeEarlyExit)
{
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    [indexSet addIndex:0];
    [indexSet addIndex:1];
    [indexSet addIndex:2];
    NSArray *a = @[@1, @20, @300, @4000];
    __block int sum = 0;
    [indexSet enumerateIndexesInRange:NSMakeRange(1, 2) options:0 usingBlock:^(NSUInteger idx, BOOL *stop){
        sum += [[a objectAtIndex:idx] intValue];
        *stop = YES;
    }];
    testassert(sum == 20);
    return YES;
}

test(IndexSetEnumerateIndexesReverse)
{
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    [indexSet addIndex:1];
    [indexSet addIndex:3];
    NSArray *a = @[@1, @20, @300, @4000];
    __block int sum = 0;
    [indexSet enumerateIndexesWithOptions:NSEnumerationReverse usingBlock:^(NSUInteger idx, BOOL *stop){
        sum += [[a objectAtIndex:idx] intValue];
        *stop = YES;
    }];
    testassert(sum == 4000);
    return YES;
}

test(IndexSetEnumerateIndexesInRangeReverse)
{
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    [indexSet addIndex:1];
    [indexSet addIndex:2];
    [indexSet addIndex:3];
    NSArray *a = @[@1, @20, @300, @4000];
    __block int sum = 0;
    [indexSet enumerateIndexesInRange:NSMakeRange(1, 2) options:NSEnumerationReverse usingBlock:^(NSUInteger idx, BOOL *stop){
        sum += [[a objectAtIndex:idx] intValue];
        *stop = YES;
    }];
    testassert(sum == 300);
    return YES;
}

test(IndexSetEnumerateIndexesInRangeReverse2)
{
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    [indexSet addIndex:1];
    [indexSet addIndex:2];
    [indexSet addIndex:3];
    [indexSet addIndex:4];
    NSArray *a = @[@1, @20, @300, @4000, @50000];
    __block int sum = 0;
    [indexSet enumerateIndexesInRange:NSMakeRange(1, 2) options:NSEnumerationReverse usingBlock:^(NSUInteger idx, BOOL *stop){
        sum += [[a objectAtIndex:idx] intValue];
        *stop = YES;
    }];
    testassert(sum == 300);
    return YES;
}

test(IndexSetEnumerateIndexesInRangeConcurrent)
{
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    [indexSet addIndex:0];
    [indexSet addIndex:1];
    [indexSet addIndex:2];
    NSArray *a = @[@1, @20, @300, @4000];
    __block int sum = 0;
    [indexSet enumerateIndexesInRange:NSMakeRange(1, 2) options:NSEnumerationConcurrent usingBlock:^(NSUInteger idx, BOOL *stop){
        sum += [[a objectAtIndex:idx] intValue];
    }];
    testassert(sum == 320);
    return YES;
}

test(IndexSetEnumerateIndexesInRangeConcurrent2)
{
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    [indexSet addIndex:0];
    [indexSet addIndex:2];
    NSArray *a = @[@1, @20, @300, @4000];
    __block int sum = 0;
    [indexSet enumerateIndexesInRange:NSMakeRange(1, 2) options:NSEnumerationConcurrent usingBlock:^(NSUInteger idx, BOOL *stop){
        sum += [[a objectAtIndex:idx] intValue];
    }];
    testassert(sum == 300);
    return YES;
}

test(IndexSetEnumerateNilException)
{
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    
    BOOL foundException = NO;
    @try
    {
        [indexSet enumerateIndexesInRange:NSMakeRange(1, 2) options:NSEnumerationReverse usingBlock:nil];
    }
    @catch(NSException *e)
    {
        foundException = YES;
    }
    testassert(foundException);
    return YES;
}


test(IndexSetEnumerateIndexesInRangeRange)
{
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    [indexSet addIndex:0];
    [indexSet addIndex:2];
    [indexSet addIndex:3];
    NSArray *a = @[@1, @20, @300, @4000];
    __block int sum = 0;
    [indexSet enumerateRangesInRange:NSMakeRange(1, 3) options:0 usingBlock:^(NSRange range, BOOL *stop){
        sum += [[a objectAtIndex:range.location] intValue];
    }];
    testassert(sum == 300);
    return YES;
}

test(IndexSetEnumerateIndexesInRangeEarlyExitRange)
{
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    [indexSet addIndex:0];
    [indexSet addIndex:1];
    [indexSet addIndex:2];
    NSArray *a = @[@1, @20, @300, @4000];
    __block int sum = 0;
    [indexSet enumerateRangesInRange:NSMakeRange(1, 2) options:0 usingBlock:^(NSRange range, BOOL *stop){
        sum += [[a objectAtIndex:range.location + range.length - 1] intValue];
        *stop = YES;
    }];
    testassert(sum == 300);
    return YES;
}

test(IndexSetEnumerateIndexesInRangeReverseRange)
{
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    [indexSet addIndex:1];
    [indexSet addIndex:2];
    [indexSet addIndex:3];
    NSArray *a = @[@1, @20, @300, @4000];
    __block int sum = 0;
    [indexSet enumerateRangesInRange:NSMakeRange(1, 2) options:NSEnumerationReverse usingBlock:^(NSRange range, BOOL *stop){
        sum += [[a objectAtIndex:range.location] intValue];
        *stop = YES;
    }];
    testassert(sum == 20);
    return YES;
}

test(IndexSetEnumerateIndexesInRangeReverseRange2)
{
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    [indexSet addIndex:1];
    [indexSet addIndex:3];
    [indexSet addIndex:4];
    NSArray *a = @[@1, @20, @300, @4000, @5000];
    __block int sum = 0;
    [indexSet enumerateRangesInRange:NSMakeRange(1, 2) options:NSEnumerationReverse usingBlock:^(NSRange range, BOOL *stop){
        sum += [[a objectAtIndex:range.location] intValue];
        *stop = YES;
    }];
    testassert(sum == 20);
    return YES;
}

test(IndexSetEnumerateIndexesInRangeConcurrentRange)
{
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    [indexSet addIndex:0];
    [indexSet addIndex:1];
    [indexSet addIndex:2];
    NSArray *a = @[@1, @20, @300, @4000];
    __block int sum = 0;
    [indexSet enumerateRangesInRange:NSMakeRange(1, 2) options:NSEnumerationConcurrent usingBlock:^(NSRange range, BOOL *stop){
        sum += [[a objectAtIndex:range.location] intValue];
    }];
    testassert(sum == 20);
    return YES;
}

test(IndexSetEnumerateIndexesInRangeConcurrentRange2)
{
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    [indexSet addIndex:0];
    [indexSet addIndex:2];
    NSArray *a = @[@1, @20, @300, @4000];
    __block int sum = 0;
    [indexSet enumerateRangesInRange:NSMakeRange(0, 4) options:NSEnumerationConcurrent usingBlock:^(NSRange range, BOOL *stop){
        sum += [[a objectAtIndex:range.location] intValue];
    }];
    testassert(sum == 301);
    return YES;
}

test(IndexSetMultipleRanges)
{
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    [indexSet addIndex:0];
    [indexSet addIndex:2];
    [indexSet addIndex:3];
    [indexSet addIndex:4];
    testassert(indexSet.count == 4);
    testassert([indexSet countOfIndexesInRange:NSMakeRange(0,1)] == 1);
    testassert([indexSet countOfIndexesInRange:NSMakeRange(2,3)] == 3);
    return YES;
}

test(OrderedContiguousAdditions)
{
    NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] init];
    [indexSet addIndex:0];
    testassert(indexSet.count == 1);
    testassert([indexSet containsIndex:0]);
    testassert(![indexSet containsIndex:1]);
    testassert(![indexSet containsIndex:2]);
    [indexSet addIndex:1];
    testassert(indexSet.count == 2);
    testassert([indexSet containsIndex:0]);
    testassert([indexSet containsIndex:1]);
    testassert(![indexSet containsIndex:2]);
    [indexSet addIndex:2];
    testassert(indexSet.count == 3);
    testassert([indexSet containsIndex:0]);
    testassert([indexSet containsIndex:1]);
    testassert([indexSet containsIndex:2]);
    return YES;
}

test(OrderedNonContiguousAdditions)
{
    NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] init];
    [indexSet addIndex:0];
    testassert(indexSet.count == 1);
    testassert([indexSet containsIndex:0]);
    testassert(![indexSet containsIndex:2]);
    testassert(![indexSet containsIndex:4]);
    [indexSet addIndex:2];
    testassert(indexSet.count == 2);
    testassert([indexSet containsIndex:0]);
    testassert([indexSet containsIndex:2]);
    testassert(![indexSet containsIndex:4]);
    [indexSet addIndex:4];
    testassert(indexSet.count == 3);
    testassert([indexSet containsIndex:0]);
    testassert([indexSet containsIndex:2]);
    testassert([indexSet containsIndex:4]);
    return YES;
}

test(OutOfOrderAdditions)
{
    NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] init];
    [indexSet addIndex:3];
    testassert(indexSet.count == 1);
    testassert([indexSet containsIndex:3]);
    testassert(![indexSet containsIndex:0]);
    testassert(![indexSet containsIndex:1]);
    [indexSet addIndex:0];
    testassert(indexSet.count == 2);
    testassert([indexSet containsIndex:3]);
    testassert([indexSet containsIndex:0]);
    testassert(![indexSet containsIndex:1]);
    [indexSet addIndex:1];
    testassert(indexSet.count == 3);
    testassert([indexSet containsIndex:3]);
    testassert([indexSet containsIndex:0]);
    testassert([indexSet containsIndex:1]);
    return YES;
}

test(OutOfOrderAdditions2)
{
    NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] init];
    [indexSet addIndex:3];
    testassert(indexSet.count == 1);
    testassert([indexSet containsIndex:3]);
    testassert(![indexSet containsIndex:5]);
    testassert(![indexSet containsIndex:1]);
    [indexSet addIndex:5];
    testassert(indexSet.count == 2);
    testassert([indexSet containsIndex:3]);
    testassert([indexSet containsIndex:5]);
    testassert(![indexSet containsIndex:1]);
    [indexSet addIndex:1];
    testassert(indexSet.count == 3);
    testassert([indexSet containsIndex:3]);
    testassert([indexSet containsIndex:5]);
    testassert([indexSet containsIndex:1]);
    return YES;
}

test(IndexSetShiftIndexesStartingAtIndexByRollunder)
{
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    [indexSet addIndexesInRange: NSMakeRange(0, 2)];
    [indexSet shiftIndexesStartingAtIndex: 0 by: -1];
    testassert([indexSet containsIndex: 0]);
    testassert([indexSet containsIndex: 2] == NO);
    return YES;
}

test(IndexSetShiftIndexesStartingAtIndexBy)
{
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    [indexSet addIndex:2];
    [indexSet addIndexesInRange: NSMakeRange(5, 2)];
    [indexSet shiftIndexesStartingAtIndex: 2 by: 2];
    testassert([indexSet containsIndex: 4]);
    testassert([indexSet containsIndex: 5] == NO);
    testassert([indexSet containsIndex: 8]);
    return YES;
}


test(IndexSetShiftIndexesStartingAtIndexBy2)
{
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    [indexSet addIndex:2];
    [indexSet addIndexesInRange: NSMakeRange(5, 2)];
    [indexSet shiftIndexesStartingAtIndex: 6 by: 2];
    testassert([indexSet containsIndex: 2]);
    testassert([indexSet containsIndex: 5]);
    testassert([indexSet containsIndex: 6] == NO);
    testassert([indexSet containsIndex: 8]);
    return YES;
}

test(IndexSetShiftIndexesStartingAtIndexByRollover)
{
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    [indexSet addIndexesInRange: NSMakeRange(NSNotFound - 2, 1)];
    BOOL foundException = NO;
    @try
    {
        [indexSet shiftIndexesStartingAtIndex: NSNotFound - 2 by: 2];
    }
    @catch(NSException *e)
    {
        foundException = YES;
    }
    testassert(foundException);
    return YES;
}

test(IndexSetShiftIndexesCompleteRollunder)
{
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    [indexSet addIndexesInRange:NSMakeRange(5, 5)];
    [indexSet shiftIndexesStartingAtIndex:0 by:-100];
    testassert([indexSet count] == 0);
    return YES;
}

test(IndexSetBug625)
{
    NSMutableIndexSet *indexSet;
    indexSet = [NSMutableIndexSet indexSet];
    [indexSet addIndexesInRange:NSMakeRange(0, 3)];
    [indexSet addIndexesInRange:NSMakeRange(10, 3)];
    testassert([indexSet count] == 6);
    
    [indexSet removeIndex:0];
    [indexSet removeIndex:10];
    testassert([indexSet count] == 4);
    
    indexSet = [NSMutableIndexSet indexSet];
    [indexSet addIndexesInRange:NSMakeRange(0, 3)];
    [indexSet addIndexesInRange:NSMakeRange(10, 3)];
    testassert([indexSet count] == 6);
    
    [indexSet removeIndexesInRange:NSMakeRange(0, 3)];
    [indexSet removeIndexesInRange:NSMakeRange(10, 3)];
    testassert([indexSet count] == 0);
    return YES;
}

@end
