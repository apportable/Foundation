//
//  NSCountedSetTests.m
//  FoundationTests
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "FoundationTests.h"

@testcase(NSCountedSet)

test(Allocate)
{
    NSCountedSet *s1 = [NSCountedSet alloc];
    NSCountedSet *s2 = [NSCountedSet alloc];

    testassert(s1 != s2);

    [s1 release];
    [s2 release];

    return YES;
}

test(BlankCreation)
{
    NSCountedSet *cs = [[NSCountedSet alloc] init];

    // Blank initialization should return a counted set
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

    NSCountedSet *cs = [[NSCountedSet alloc] initWithObjects:members count:2*count];

    // Default initializer with <count> objects should return a countable set
    testassert(cs != nil);

    [cs release];

    free(members);

    return YES;
}

test(DefaultCreationWithCapacity)
{
    int count = 10;
    NSCountedSet *cs = [[NSCountedSet alloc] initWithCapacity:count];

    // Default initializer with <count> should return a countable set
    testassert(cs != nil);

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
    NSCountedSet *cs = [[NSCountedSet alloc] initWithSet:s];

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
    NSCountedSet *cs = [[NSCountedSet alloc] initWithSet:s copyItems:YES];

    // Set initializer should return a countable set
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
    NSCountedSet *cs = [[NSCountedSet alloc] initWithSet:s copyItems:NO];

    // Set initializer should return a countable set
    testassert(cs != nil);

    [s release];
    [cs release];

    return YES;
}

test(VarArgsCreation)
{
    NSCountedSet *cs = [[NSCountedSet alloc] initWithObjects:
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
    NSCountedSet *cs = [[NSCountedSet alloc] initWithArray:@[
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

        NSCountedSet *cs = [[[NSCountedSet alloc] initWithSet:s] initWithSet:s];

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

test(CountForObject)
{
    NSObject *o0 = [[[NSObject alloc] init] autorelease];
    NSObject *o1 = [[[NSObject alloc] init] autorelease];
    NSObject *o2 = [[[NSObject alloc] init] autorelease];

    NSCountedSet *cs = [[NSCountedSet alloc] initWithObjects: o1, o2, o2, nil];

    // Count for object
    testassert(cs != nil);

    testassert([cs countForObject:o0] == 0);
    testassert([cs countForObject:o1] == 1);
    testassert([cs countForObject:o2] == 2);

    testassert([cs countForObject:nil] == 0);

    [cs release];

    return YES;
}

test(AddObject)
{
    NSCountedSet *cs = [[NSCountedSet alloc] init];
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
    for (int i = 0; i < count; i++)
    {
        testassert([cs countForObject:members[i]] == i);
    }

    [cs release];

    free(members);

    return YES;
}

test(AddObjectNil)
{
    void (^block)() = ^{
        NSCountedSet *cs = [[[NSCountedSet alloc] init] autorelease];
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

    NSCountedSet *cs = [[NSCountedSet alloc] initWithObjects: o1, o2, o2, nil];

    [cs removeObject:o2];

    // Removing an object not in the countable set should not throw
    [cs removeObject:o0];
    [cs removeObject:o1];
    [cs removeObject:o1];

    testassert([cs countForObject:o0] == 0);
    testassert([cs countForObject:o1] == 0);
    testassert([cs countForObject:o2] == 1);

    [cs release];

    return YES;
}

test(RemoveObjectNil)
{
    void (^block)() = ^{
        NSCountedSet *cs = [[[NSCountedSet alloc] init] autorelease];
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

test(Member)
{
    NSObject *o0 = [[[NSObject alloc] init] autorelease];
    NSObject *o1 = [[[NSObject alloc] init] autorelease];
    NSObject *o2 = [[[NSObject alloc] init] autorelease];

    NSCountedSet *cs = [[NSCountedSet alloc] initWithObjects: o1, o2, o2, nil];

    testassert([cs member:o0] == nil);
    testassert([cs member:o1] != nil);
    testassert([cs member:o2] != nil);

    testassert([cs member:nil] == nil);

    [cs release];

    return YES;
}

test(Count)
{
    NSObject *o1 = [[[NSObject alloc] init] autorelease];
    NSObject *o2 = [[[NSObject alloc] init] autorelease];

    NSCountedSet *cs = [[NSCountedSet alloc] initWithObjects: o1, o2, o2, nil];

    testassert([cs count] == 2);

    [cs release];

    return YES;
}

test(ObjectEnumerator)
{
    NSCountedSet *cs = [[NSCountedSet alloc] init];
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
    for (int i = 0; i < count; i++)
    {
        testassert([cs countForObject:members[i]] == i);
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

    // If an object is added multiple times to an NSCountedSet, it is
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
    NSCountedSet *cs = [[NSCountedSet alloc] init];
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
    for (int i = 0; i < count; i++)
    {
        testassert([cs countForObject:members[i]] == i);
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

    // If an object is added multiple times to an NSCountedSet, it is
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
    NSCountedSet *cs = [[NSCountedSet alloc] initWithObjects:
                           [[[NSObject alloc] init] autorelease],
                           [[[NSObject alloc] init] autorelease],
                           [[[NSObject alloc] init] autorelease],
                           nil];

    NSCountedSet *csCopy = [cs copyWithZone:nil];

    testassert(csCopy != nil);

    [csCopy release];
    [cs release];

    return YES;
}

test(CopyWithZone_MultipleCopies)
{
    NSObject *o = [[[NSObject alloc] init] autorelease];
    NSCountedSet *cs = [[NSCountedSet alloc] initWithObjects:o, o, o, nil];

    NSCountedSet *csCopy = [cs copyWithZone:nil];

    testassert(csCopy != nil);
    testassert([csCopy countForObject:o] == 3);

    [csCopy release];
    [cs release];

    return YES;
}

test(MutableCopyWithZone)
{
    NSCountedSet *cs = [[NSCountedSet alloc] initWithObjects:
                           [[[NSObject alloc] init] autorelease],
                           [[[NSObject alloc] init] autorelease],
                           [[[NSObject alloc] init] autorelease],
                           nil];

    NSCountedSet *csCopy = [cs mutableCopyWithZone:nil];

    testassert(csCopy != nil);

    [csCopy release];
    [cs release];

    return YES;
}

test(MutableCopyWithZone_MultipleCopies)
{
    NSObject *o = [[[NSObject alloc] init] autorelease];
    NSCountedSet *cs = [[NSCountedSet alloc] initWithObjects:o, o, o, nil];

    NSCountedSet *csCopy = [cs mutableCopyWithZone:nil];

    testassert(csCopy != nil);
    testassert([csCopy countForObject:o] == 3);

    [csCopy release];
    [cs release];

    return YES;
}

test(InitWithSetWithCountedSet)
{
    NSObject *o = [[[NSObject alloc] init] autorelease];
    NSCountedSet *cs = [[[NSCountedSet alloc] initWithObjects:o, o, o, nil] autorelease];

    testassert([cs countForObject:o] == 3);

    NSCountedSet *cs2 = [[[NSCountedSet alloc] initWithSet:cs] autorelease];

    testassert([cs2 countForObject:o] == 3);

    return YES;
}

test(InitWithSet_CopyItems_Yes_WithCountedSet)
{
    NSObject *o = @"strings can be copied";
    NSCountedSet *cs = [[[NSCountedSet alloc] initWithObjects:o, o, o, nil] autorelease];

    testassert([cs countForObject:o] == 3);

    NSCountedSet *cs2 = [[[NSCountedSet alloc] initWithSet:cs copyItems:YES] autorelease];

    testassert([cs2 countForObject:o] == 3);

    return YES;
}

test(InitWithSet_CopyItems_No_WithCountedSet)
{
    NSObject *o = [[[NSObject alloc] init] autorelease];
    NSCountedSet *cs = [[[NSCountedSet alloc] initWithObjects:o, o, o, nil] autorelease];

    testassert([cs countForObject:o] == 3);

    NSCountedSet *cs2 = [[[NSCountedSet alloc] initWithSet:cs copyItems:NO] autorelease];

    testassert([cs2 countForObject:o] == 3);

    return YES;
}

@end
