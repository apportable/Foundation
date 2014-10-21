//
//  NSHashTableTests.m
//  FoundationTests
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "FoundationTests.h"

@interface WeakHelper : NSObject
{
    BOOL *_deallocated;
}
@end

@implementation WeakHelper

- (void)dealloc
{
    *_deallocated = YES;
    [super dealloc];
}

- (id)initWithPtr:(BOOL *)ptr
{
    self = [super init];
    if (self != nil)
    {
        _deallocated = ptr;
    }
    return self;
}

@end

@testcase(NSHashTable)

test(Allocate)
{
    NSHashTable *s1 = [NSHashTable alloc];
    NSHashTable *s2 = [NSHashTable alloc];

    testassert(s1 != nil);
    testassert(s2 != nil);
    testassert(s1 != s2);

    return YES;
}

test(BlankCreation)
{
    NSHashTable *cs = [[NSHashTable alloc] init];

    testassert(cs != nil);

    [cs release];

    return YES;
}

test(DoubleInit)
{
    NSHashTable *s = [[[NSHashTable alloc] init] autorelease];
    [s init];

    return YES;
}

test(AddObject)
{
    NSHashTable *cs = [[NSHashTable alloc] init];
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

    for (int i = 1; i < count; i++)
    {
        testassert([cs member:members[i]] == members[i]);
    }

    [cs release];

    free(members);

    return YES;
}

test(ContainsObject)
{
    NSObject *o0 = [[[NSObject alloc] init] autorelease];
    NSObject *o1 = [[[NSObject alloc] init] autorelease];
    NSObject *o2 = [[[NSObject alloc] init] autorelease];

    NSHashTable *cs = [[NSHashTable alloc] init];
    [cs addObject:o1];
    [cs addObject:o2];
    [cs addObject:o2];

    testassert([cs containsObject:o0] == NO);
    testassert([cs containsObject:o1] == YES);
    testassert([cs containsObject:o2] == YES);

    testassert([cs containsObject:nil] == NO);

    testassert([cs count] == 2);

    [cs release];

    return YES;
}

test(AddObjectNil)
{
    NSHashTable *cs = [[[NSHashTable alloc] init] autorelease];
    [cs addObject:nil];

    return YES;
}

test(RemoveObject)
{
    NSObject *o0 = [[[NSObject alloc] init] autorelease];
    NSObject *o1 = [[[NSObject alloc] init] autorelease];
    NSObject *o2 = [[[NSObject alloc] init] autorelease];

    NSHashTable *cs = [[NSHashTable alloc] init];
    [cs addObject:o1];
    [cs addObject:o2];
    [cs addObject:o2];

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

    NSHashTable *cs = [[NSHashTable alloc] init];
    [cs addObject:o0];
    [cs addObject:o1];

    id obj = [self unretainedObjectInHashTable:cs];
    [cs removeObject:obj];

    return YES;
}

test(RemoveObjectNil)
{
    NSHashTable *cs = [[[NSHashTable alloc] init] autorelease];
    [cs removeObject:nil];

    return YES;
}

test(NilMember)
{
    NSObject *o1 = [[[NSObject alloc] init] autorelease];
    NSObject *o2 = [[[NSObject alloc] init] autorelease];

    NSHashTable *cs = [[NSHashTable alloc] init];
    [cs addObject:o1];
    [cs addObject:o2];
    [cs addObject:o2];

    testassert([cs member:nil] == nil);

    [cs release];

    return YES;
}

test(Member)
{
    NSObject *o0 = [[[NSObject alloc] init] autorelease];
    NSObject *o1 = [[[NSObject alloc] init] autorelease];
    NSObject *o2 = [[[NSObject alloc] init] autorelease];

    NSHashTable *cs = [[NSHashTable alloc] init];
    [cs addObject:o1];
    [cs addObject:o2];
    [cs addObject:o2];

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

    NSHashTable *cs = [[NSHashTable alloc] init];
    [cs addObject:o1];
    [cs addObject:o2];
    [cs addObject:o2];

    testassert([cs count] == 2);

    [cs release];

    return YES;
}

test(ObjectEnumerator)
{
    NSHashTable *cs = [[NSHashTable alloc] init];
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
    NSHashTable *cs = [[NSHashTable alloc] init];
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
    NSHashTable *cs = [[NSHashTable alloc] init];
    [cs addObject:[[[NSObject alloc] init] autorelease]];
    [cs addObject:[[[NSObject alloc] init] autorelease]];
    [cs addObject:[[[NSObject alloc] init] autorelease]];

    NSHashTable *csCopy = [cs copyWithZone:nil];

    testassert(csCopy != nil);

    [csCopy release];
    [cs release];

    return YES;
}

test(AnyObject)
{
    NSHashTable *cs = [[NSHashTable alloc] init];
    testassert([cs anyObject] == nil);

    NSObject *o0 = [[[NSObject alloc] init] autorelease];
    [cs addObject:o0];
    testassert([cs anyObject] == o0);

    [cs release];

    return YES;
}

test(HashTableCreationWithVariousObjectsAndDuplicates)
{
    NSHashTable *aHashTable = [[NSHashTable alloc] init];
    [aHashTable addObject:[NSNumber numberWithFloat:3.14159f]];
    [aHashTable addObject:[NSNumber numberWithChar:0x7f]];
    [aHashTable addObject:[NSNumber numberWithDouble:-6.62606957]];
    [aHashTable addObject:[NSNumber numberWithBool:YES]];
    [aHashTable addObject:@"42"];
    [aHashTable addObject:@"42"];
    [aHashTable addObject:@"42"];
    [aHashTable addObject:@"42"];

    testassert([aHashTable count] == 5);
    [aHashTable release];
    return YES;
}

test(MinusHashTable)
{
    NSObject *o0 = [[[NSObject alloc] init] autorelease];
    NSObject *o1 = [[[NSObject alloc] init] autorelease];
    NSObject *o2 = [[[NSObject alloc] init] autorelease];
    NSObject *o3 = [[[NSObject alloc] init] autorelease];

    NSHashTable *cs = [[NSHashTable alloc] init];
    [cs addObject:o1];
    [cs addObject:o2];
    [cs addObject:o0];
    NSHashTable *s = [[NSHashTable alloc] init];
    [s addObject:o0];
    [s addObject:o3];
    [s addObject:o2];

    [cs minusHashTable:s];
    testassert([cs count] == 1);
    testassert([cs member:o1] == o1);
    testassert([cs member:o2] == nil);
    [cs release];
    [s release];
    return YES;
}

test(IntersectHashTable)
{
    NSObject *o0 = [[[NSObject alloc] init] autorelease];
    NSObject *o1 = [[[NSObject alloc] init] autorelease];
    NSObject *o2 = [[[NSObject alloc] init] autorelease];
    NSObject *o3 = [[[NSObject alloc] init] autorelease];

    NSHashTable *cs = [[NSHashTable alloc] init];
    [cs addObject:o1];
    [cs addObject:o2];
    [cs addObject:o0];
    NSHashTable *s = [[NSHashTable alloc] init];
    [s addObject:o0];
    [s addObject:o3];
    [s addObject:o2];

    [cs intersectHashTable:s];
    testassert([cs count] == 2);
    testassert([cs member:o1] == nil);
    testassert([cs member:o2] == o2);
    [cs release];
    [s release];
    return YES;
}


test(UnionHashTable)
{
    NSObject *o0 = [[[NSObject alloc] init] autorelease];
    NSObject *o1 = [[[NSObject alloc] init] autorelease];
    NSObject *o2 = [[[NSObject alloc] init] autorelease];
    NSObject *o3 = [[[NSObject alloc] init] autorelease];

    NSHashTable *cs = [[NSHashTable alloc] init];
    [cs addObject:o1];
    [cs addObject:o2];
    [cs addObject:o0];
    NSHashTable *s = [[NSHashTable alloc] init];
    [s addObject:o0];
    [s addObject:o3];
    [s addObject:o2];

    [cs unionHashTable:s];
    testassert([cs count] == 4);
    testassert([cs member:o1] == o1);
    testassert([cs member:o2] == o2);
    [cs release];
    [s release];
    return YES;
}

test(WeakHashTable)
{
    NSPointerFunctions *pf = [[[NSPointerFunctions alloc] initWithOptions:NSPointerFunctionsWeakMemory] autorelease];
    NSHashTable *ht = [[NSHashTable alloc] initWithPointerFunctions:pf capacity:0];
    testassert(ht != nil);

    testassert([ht count] == 0);

    BOOL deallocated = NO;
    WeakHelper *w = [[WeakHelper alloc] initWithPtr:&deallocated];
    [ht addObject:w];
    testassert([ht count] == 1);

    [w release];
    testassert(deallocated);

    testassert([ht count] == 1); // !!!

    NSUInteger count = 0;
    for (id obj in ht)
    {
        count++;
    }
    testassert(count == 0);

    [ht release];

    return YES;
}

#pragma mark Helpers

- (id)unretainedObjectInHashTable:(NSHashTable*)m
{
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
