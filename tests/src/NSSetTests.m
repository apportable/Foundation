//
//  NSSetTests.m
//  FoundationTests
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "FoundationTests.h"

@testcase(NSSet)

test(Allocate)
{
    NSSet *s1 = [NSSet alloc];
    NSSet *s2 = [NSSet alloc];
    
    testassert(s1 == s2);
    
    return YES;
}

test(BlankCreation)
{
    NSSet *cs = [[NSSet alloc] init];

    // Blank initialization should return a set
    testassert(cs != nil);

    [cs release];

    return YES;
}

test(DefaultCreationMany)
{
    int count = 10;
    NSObject **members = malloc(2 * sizeof(*members) * count);
    for (int i = 0; i < count; i++)
    {
        members[i] = [[NSObject alloc] init];
        members[i + count] = members[i];
    }

    NSSet *cs = [[NSSet alloc] initWithObjects:members count:2*count];

    // Default initializer with <count> objects should return a set
    testassert(cs != nil);

    [cs release];

    free(members);

    return YES;
}

test(DefaultCreationWithArray)
{
    NSSet *cs = [[NSSet alloc] initWithArray:@[@1, @2]];

    // Default initializer with <count> should return a countable set
    testassert(cs != nil);
    testassert([cs count] == 2);

    [cs release];

    return YES;
}

test(SetCreation)
{
    NSSet *s = [[NSSet alloc] initWithObjects:
                [[[NSObject alloc] init] autorelease],
                [[[NSObject alloc] init] autorelease],
                [[[NSObject alloc] init] autorelease],
                nil];
    NSSet *cs = [[NSSet alloc] initWithSet:s];

    // Set initializer should return a countable set
    testassert(cs != nil);

    [s release];
    [cs release];

    return YES;
}

test(SetWithCopyCreation)
{
    // Ideally we would use just NSObjects for this test, but they are not copyable.
    NSSet *s = [[NSSet alloc] initWithObjects:
                @"",
                @"",
                @"",
                nil];
    NSSet *cs = [[NSSet alloc] initWithSet:s copyItems:YES];

    // Set initializer should return a set
    testassert([cs count] == 1);
    testassert(cs != nil);

    [s release];
    [cs release];

    return YES;
}

test(SetWithoutCopyCreation)
{
    NSSet *s = [[NSSet alloc] initWithObjects:
                [[[NSObject alloc] init] autorelease],
                [[[NSObject alloc] init] autorelease],
                [[[NSObject alloc] init] autorelease],
                nil];
    NSSet *cs = [[NSSet alloc] initWithSet:s copyItems:NO];

    // Set initializer should return a countable set
    testassert(cs != nil);

    [s release];
    [cs release];

    return YES;
}

test(VarArgsCreation)
{
    NSSet *cs = [[NSSet alloc] initWithObjects:
                        [[[NSObject alloc] init] autorelease],
                        [[[NSObject alloc] init] autorelease],
                        [[[NSObject alloc] init] autorelease],
                        nil];

    // Var args initializer should return a countable set
    testassert(cs != nil);

    [cs release];

    return YES;
}

test(ArrayCreation)
{
    NSSet *cs = [[NSSet alloc] initWithArray:@[
                        [[[NSObject alloc] init] autorelease],
                        [[[NSObject alloc] init] autorelease],
                        [[[NSObject alloc] init] autorelease],
                        ]];

    // Array initializer should return a countable set
    testassert(cs != nil);

    [cs release];

    return YES;
}

test(DoubleInit)
{
    void (^block)() = ^{
        NSSet *s = [[NSSet alloc] initWithObjects:
                    [[[NSObject alloc] init] autorelease],
                    [[[NSObject alloc] init] autorelease],
                    [[[NSObject alloc] init] autorelease],
                    nil];

        NSSet *cs = [[[NSSet alloc] initWithSet:s] initWithSet:s];

        [s release];
        [cs release];
    };

    // Double initialization should throw NSInvalidArgumentException
    BOOL raised = NO;

    @try {
        block();
    }
    @catch (NSException *e) {
        testassert([[e name] isEqualToString:NSInvalidArgumentException]);
        raised = YES;
    }

#warning MINOR: Make double initialization raise an exception
    // testassert(raised);

    return YES;
}

test(ContainsObject)
{
    NSObject *o0 = [[[NSObject alloc] init] autorelease];
    NSObject *o1 = [[[NSObject alloc] init] autorelease];
    NSObject *o2 = [[[NSObject alloc] init] autorelease];

    NSSet *cs = [[NSSet alloc] initWithObjects: o1, o2, o2, nil];

    // Count for object
    testassert(cs != nil);

    testassert([cs containsObject:o0] == NO);
    testassert([cs containsObject:o1] == YES);
    testassert([cs containsObject:o2] == YES);

    testassert([cs containsObject:nil] == NO);

    testassert([cs count] == 2);

    [cs release];

    return YES;
}

test(AddObject)
{
    NSMutableSet *cs = [[NSMutableSet alloc] init];
    int count = 10;
    NSObject **members = malloc(sizeof(*members) * count);

    for (int i = 0; i < count; i++)
    {
        members[i] = [[NSObject alloc] init];
        for (int inserts = 0; inserts < i; inserts++)
        {
            [cs addObject:members[i]];
        }
    }

    // Count for object
    for (int i = 1; i < count; i++)
    {
        testassert([cs member:members[i]] == members[i]);
    }

    [cs release];

    free(members);

    return YES;
}

test(AddObjectNil)
{
    void (^block)() = ^{
        NSMutableSet *cs = [[[NSMutableSet alloc] init] autorelease];
        [cs addObject:nil];
    };

    // Adding nil should throw NSInvalidArgumentException
    BOOL raised = NO;

    @try {
        block();
    }
    @catch (NSException *e) {
        testassert([[e name] isEqualToString:NSInvalidArgumentException]);
        raised = YES;
    }

    testassert(raised);

    return YES;
}

test(RemoveObject)
{
    NSObject *o0 = [[[NSObject alloc] init] autorelease];
    NSObject *o1 = [[[NSObject alloc] init] autorelease];
    NSObject *o2 = [[[NSObject alloc] init] autorelease];

    NSMutableSet *cs = [[NSMutableSet alloc] initWithObjects: o1, o2, o2, nil];

    // Removing an object not in the countable set should not throw
    [cs removeObject:o0];
    [cs removeObject:o1];
    [cs removeObject:o1];

    testassert([cs member:o0] == nil);
    testassert([cs member:o1] == nil);
    testassert([cs member:o2] == o2);

    [cs release];

    return YES;
}

test(RemoveUnretainedObject)
{
    NSObject *o0 = [[[NSObject alloc] init] autorelease];
    NSObject *o1 = [[[NSObject alloc] init] autorelease];
    
    NSMutableSet *cs = [[NSMutableSet alloc] initWithObjects: o0, o1, nil];

    /* Removing an unretained object should not throw */
    id obj = [self unretainedObjectInMutableSet:cs];
    [cs removeObject:obj];

    return YES;
}

test(RemoveObjectNil)
{
    void (^block)() = ^{
        NSMutableSet *cs = [[[NSMutableSet alloc] init] autorelease];
        [cs removeObject:nil];
    };

    // Removing nil should throw NSInvalidArgumentException
    BOOL raised = NO;

    @try {
        block();
    }
    @catch (NSException *e) {
        testassert([[e name] isEqualToString:NSInvalidArgumentException]);
        raised = YES;
    }

    testassert(raised);

    return YES;
}

test(NilMember)
{
    NSObject *o1 = [[[NSObject alloc] init] autorelease];
    NSObject *o2 = [[[NSObject alloc] init] autorelease];

    NSSet *cs = [[NSSet alloc] initWithObjects: o1, o2, o2, nil];

    testassert([cs member:nil] == nil);

    [cs release];

    return YES;
}

test(Member)
{
    NSObject *o0 = [[[NSObject alloc] init] autorelease];
    NSObject *o1 = [[[NSObject alloc] init] autorelease];
    NSObject *o2 = [[[NSObject alloc] init] autorelease];

    NSSet *cs = [[NSSet alloc] initWithObjects: o1, o2, o2, nil];

    testassert([cs member:o0] == nil);
    testassert([cs member:o1] == o1);
    testassert([cs member:o2] == o2);

    testassert([cs member:nil] == nil);

    [cs release];

    return YES;
}

test(Count)
{
    NSObject *o1 = [[[NSObject alloc] init] autorelease];
    NSObject *o2 = [[[NSObject alloc] init] autorelease];

    NSSet *cs = [[NSSet alloc] initWithObjects: o1, o2, o2, nil];

    testassert([cs count] == 2);

    [cs release];

    return YES;
}

test(ObjectEnumerator)
{
    NSMutableSet *cs = [[NSMutableSet alloc] init];
    int count = 10;
    NSObject **members = malloc(sizeof(*members) * count);
    int *counts = calloc(sizeof(*counts), count);

    for (int i = 0; i < count; i++)
    {
        members[i] = [[NSObject alloc] init];
        for (int inserts = 0; inserts < i; inserts++)
        {
            [cs addObject:members[i]];
        }
    }

    // Count for object
    for (int i = 1; i < count; i++)
    {
        testassert([cs member:members[i]] == members[i]);
    }

    id object;
    NSEnumerator *enumerator = [cs objectEnumerator];
    while ((object = [enumerator nextObject]) != nil)
    {
        BOOL found = NO;
        for (int i = 0; i < count; i++)
        {
            if ([object isEqual:members[i]])
            {
                found = YES;
                counts[i]++;
                break;
            }
        }
        testassert(found);
    }

    // If an object is added multiple times to an NSSet, it is
    // still only enumerated once.
    for (int i = 0; i < count; i++)
    {
        testassert(counts[i] == i > 0 ? 1 : 0);
    }

    free(members);
    free(counts);

    return YES;
}

test(FastEnumeration)
{
    NSMutableSet *cs = [[NSMutableSet alloc] init];
    int count = 10;
    NSObject **members = malloc(sizeof(*members) * count);
    int *counts = calloc(sizeof(*counts), count);

    for (int i = 0; i < count; i++)
    {
        members[i] = [[NSObject alloc] init];
        for (int inserts = 0; inserts < i; inserts++)
        {
            [cs addObject:members[i]];
        }
    }

    // Count for object
    for (int i = 1; i < count; i++)
    {
        testassert([cs member:members[i]] == members[i]);
    }

    for (id object in cs)
    {
        BOOL found = NO;
        for (int i = 0; i < count; i++)
        {
            if ([object isEqual:members[i]])
            {
                found = YES;
                counts[i]++;
                break;
            }
        }
        testassert(found);
    }

    // If an object is added multiple times to an NSSet, it is
    // still only enumerated once.
    for (int i = 0; i < count; i++)
    {
        testassert(counts[i] == i > 0 ? 1 : 0);
    }

    free(members);
    free(counts);

    return YES;
}

test(CopyWithZone)
{
    NSSet *cs = [[NSSet alloc] initWithObjects:
                        [[[NSObject alloc] init] autorelease],
                        [[[NSObject alloc] init] autorelease],
                        [[[NSObject alloc] init] autorelease],
                        nil];

    NSSet *csCopy = [cs copyWithZone:nil];

    testassert(csCopy != nil);

    [csCopy release];
    [cs release];

    return YES;
}

test(MutableCopyWithZone)
{
    NSSet *cs = [[NSSet alloc] initWithObjects:
                        [[[NSObject alloc] init] autorelease],
                        [[[NSObject alloc] init] autorelease],
                        [[[NSObject alloc] init] autorelease],
                        nil];

    NSSet *csCopy = [cs mutableCopyWithZone:nil];

    testassert(csCopy != nil);

    [csCopy release];
    [cs release];

    return YES;
}

test(AnyObject)
{
    NSObject *o0 = [[[NSObject alloc] init] autorelease];
    NSSet *cs = [[NSSet alloc] initWithObjects: o0, nil];
    testassert([cs anyObject] == o0);
    [cs release];

    cs = [[NSSet alloc] init];
    testassert([cs anyObject] == nil);
    [cs release];

    return YES;
}

test(AddObjectsFromArray)
{
    NSObject *o0 = [[[NSObject alloc] init] autorelease];
    NSMutableSet *cs = [[NSMutableSet alloc] initWithObjects: o0, nil];
    NSArray *a = @[@1, @2];
    [cs addObjectsFromArray:a];
    testassert([cs count] == 3);

    return YES;
}

test(SetCreationWithVariousObjectsAndDuplicates)
{
    NSMutableSet *aSet = [[NSMutableSet alloc] initWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"42", @"42", nil];
    testassert([aSet count] == 5);
    [aSet release];
    return YES;
}

test(MinusSet)
{
    NSObject *o0 = [[[NSObject alloc] init] autorelease];
    NSObject *o1 = [[[NSObject alloc] init] autorelease];
    NSObject *o2 = [[[NSObject alloc] init] autorelease];
    NSObject *o3 = [[[NSObject alloc] init] autorelease];

    NSMutableSet *cs = [[NSMutableSet alloc] initWithObjects: o1, o2, o0, nil];
    NSSet *s = [[NSSet alloc] initWithObjects:o0, o3, o2, nil];

    [cs minusSet:s];
    testassert([cs count] == 1);
    testassert([cs member:o1] == o1);
    testassert([cs member:o2] == nil);
    [cs release];
    [s release];
    return YES;
}

test(IntersectSet)
{
    NSObject *o0 = [[[NSObject alloc] init] autorelease];
    NSObject *o1 = [[[NSObject alloc] init] autorelease];
    NSObject *o2 = [[[NSObject alloc] init] autorelease];
    NSObject *o3 = [[[NSObject alloc] init] autorelease];

    NSMutableSet *cs = [[NSMutableSet alloc] initWithObjects: o1, o2, o0, nil];
    NSSet *s = [[NSSet alloc] initWithObjects:o0, o2, o3, nil];

    [cs intersectSet:s];
    testassert([cs count] == 2);
    testassert([cs member:o1] == nil);
    testassert([cs member:o2] == o2);
    [cs release];
    [s release];
    return YES;
}


test(UnionSet)
{
    NSObject *o0 = [[[NSObject alloc] init] autorelease];
    NSObject *o1 = [[[NSObject alloc] init] autorelease];
    NSObject *o2 = [[[NSObject alloc] init] autorelease];
    NSObject *o3 = [[[NSObject alloc] init] autorelease];

    NSMutableSet *cs = [[NSMutableSet alloc] initWithObjects: o1, o2, o0, nil];
    NSSet *s = [[NSSet alloc] initWithObjects:o0, o2, o3, nil];

    [cs unionSet:s];
    testassert([cs count] == 4);
    testassert([cs member:o1] == o1);
    testassert([cs member:o2] == o2);
    [cs release];
    [s release];
    return YES;
}

test(BadCapacity)
{
    __block BOOL raised = NO;
    __block NSMutableSet *set = nil;
    void (^block)(void) = ^{
#if __LP64__
        NSInteger capacity = 1ull << 62;
#else
        NSInteger capacity = 1073741824;
#endif
        set = [[NSMutableSet alloc] initWithCapacity:capacity];
    };
    @try {
        block();
    }
    @catch (NSException *e) {
        testassert([[e name] isEqualToString:NSInvalidArgumentException]);
        raised = YES;
    }
    testassert(raised);
    [set release];
    return YES;
}

test(LargeCapacity)
{
    __block BOOL raised = NO;
    __block NSMutableSet *set = nil;
    void (^block)(void) = ^{
        set = [[NSMutableSet alloc] initWithCapacity:1073741823];
    };
    @try {
        block();
    }
    @catch (NSException *e) {
        raised = YES;
    }
    testassert(!raised);
    [set release];
    return YES;
}

test(SetArrayNumbers)
{
    NSSet *s1 = [NSSet setWithObjects:@[@7, @9], nil];
    NSSet *s2 = [NSSet setWithObjects:@[@7, @9], nil];
    testassert([s1 isEqual:s2]);
    return YES;
}

#pragma mark Helpers

- (id)unretainedObjectInMutableSet:(NSMutableSet*)m
{
    /* Set must have previous contents for the test to work */
    testassert([m count] > 0);

    id obj = nil;
    @autoreleasepool {
        obj = @{@"foo": @"bar"};
        [m addObject:obj];

        testassert([obj retainCount] == 2);
    }

    testassert([obj retainCount] == 1);
    return obj;
}

@end
