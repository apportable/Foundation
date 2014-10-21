//
//  NSOrderedSetTests.m
//  FoundationTests
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "FoundationTests.h"

@testcase(NSOrderedSet)

test(BlankCreation)
{
    NSOrderedSet *os = [[NSOrderedSet alloc] init];

    // Blank initialization should return an ordered set
    testassert(os != nil);

    [os release];

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

    NSOrderedSet *os = [[NSOrderedSet alloc] initWithObjects:members count:2*count];

    // Default initializer with <count> objects should return an ordered set
    testassert(os != nil);

    [os release];

    free(members);

    return YES;
}

test(DefaultCreationWithArray)
{
    NSOrderedSet *os = [[NSOrderedSet alloc] initWithArray:@[@1, @2]];

    // Default initializer with <count> should return a countable ordered set
    testassert(os != nil);
    testassert([os count] == 2);

    [os release];

    return YES;
}

test(OrderedSetCreation)
{
    NSOrderedSet *s = [[NSOrderedSet alloc] initWithObjects:
                [[[NSObject alloc] init] autorelease],
                [[[NSObject alloc] init] autorelease],
                [[[NSObject alloc] init] autorelease],
                nil];
    NSOrderedSet *os = [[NSOrderedSet alloc] initWithOrderedSet:s];

    // OrderedSet initializer should return a countable ordered set
    testassert(os != nil);

    [s release];
    [os release];

    return YES;
}

test(OrderedSetWithCopyCreation)
{
    // Ideally we would use just NSObjects for this test, but they are not copyable.
    NSOrderedSet *s = [[NSOrderedSet alloc] initWithObjects:
                @"",
                @"",
                @"",
                nil];
    NSOrderedSet *os = [[NSOrderedSet alloc] initWithOrderedSet:s copyItems:YES];

    // OrderedSet initializer should return an ordered set
    testassert([os count] == 1);
    testassert(os != nil);

    [s release];
    [os release];

    return YES;
}

test(OrderedSetWithoutCopyCreation)
{
    NSOrderedSet *s = [[NSOrderedSet alloc] initWithObjects:
                [[[NSObject alloc] init] autorelease],
                [[[NSObject alloc] init] autorelease],
                [[[NSObject alloc] init] autorelease],
                nil];
    NSOrderedSet *os = [[NSOrderedSet alloc] initWithOrderedSet:s copyItems:NO];

    // OrderedSet initializer should return a countable ordered set
    testassert(os != nil);

    [s release];
    [os release];

    return YES;
}

test(VarArgsCreation)
{
    NSOrderedSet *os = [[NSOrderedSet alloc] initWithObjects:
                        [[[NSObject alloc] init] autorelease],
                        [[[NSObject alloc] init] autorelease],
                        [[[NSObject alloc] init] autorelease],
                        nil];

    // Var args initializer should return a countable ordered set
    testassert(os != nil);

    [os release];

    return YES;
}

test(ArrayCreation)
{
    NSOrderedSet *os = [[NSOrderedSet alloc] initWithArray:@[
                        [[[NSObject alloc] init] autorelease],
                        [[[NSObject alloc] init] autorelease],
                        [[[NSObject alloc] init] autorelease],
                        ]];

    // Array initializer should return a countable ordered set
    testassert(os != nil);

    [os release];

    return YES;
}

test(DoubleInit)
{
    void (^block)() = ^{
        NSOrderedSet *s = [[NSOrderedSet alloc] initWithObjects:
                    [[[NSObject alloc] init] autorelease],
                    [[[NSObject alloc] init] autorelease],
                    [[[NSObject alloc] init] autorelease],
                    nil];

        NSOrderedSet *os = [[[NSOrderedSet alloc] initWithOrderedSet:s] initWithOrderedSet:s];

        [s release];
        [os release];
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

    NSOrderedSet *os = [[NSOrderedSet alloc] initWithObjects: o1, o2, o2, nil];

    // Count for object
    testassert(os != nil);

    testassert(![os containsObject:o0]);
    testassert([os containsObject:o1]);
    testassert([os containsObject:o2]);

    testassert(![os containsObject:nil]);

    testassert([os count] == 2);

    [os release];

    return YES;
}

test(AddObject)
{
    NSMutableOrderedSet *os = [[NSMutableOrderedSet alloc] init];
    int count = 10;
    NSObject **members = malloc(sizeof(*members) * count);

    for (int i = 0; i < count; i++)
    {
        members[i] = [[NSObject alloc] init];
        for (int inserts = 0; inserts < i; inserts++)
        {
            [os addObject:members[i]];
        }
    }

    // Count for object
    for (int i = 1; i < count; i++)
    {
        testassert([os containsObject:members[i]]);
    }

    [os release];

    free(members);

    return YES;
}

test(AddObjectNil)
{
    void (^block)() = ^{
        NSMutableOrderedSet *os = [[[NSMutableOrderedSet alloc] init] autorelease];
        [os addObject:nil];
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

    NSMutableOrderedSet *os = [[NSMutableOrderedSet alloc] initWithObjects: o1, o2, o2, nil];

    // Removing an object not in the countable ordered set should not throw
    [os removeObject:o0];
    [os removeObject:o1];
    [os removeObject:o1];

    testassert(![os containsObject:o0]);
    testassert(![os containsObject:o1]);
    testassert([os containsObject:o2]);

    [os release];

    return YES;
}

test(RemoveObjectNil)
{
    // Removing nil should not throw
    NSMutableOrderedSet *os = [[[NSMutableOrderedSet alloc] init] autorelease];
    [os removeObject:nil];

    return YES;
}

test(RemoveUnretainedObject)
{
    NSObject *o0 = [[[NSObject alloc] init] autorelease];
    NSObject *o1 = [[[NSObject alloc] init] autorelease];

    NSMutableOrderedSet *os = [[NSMutableOrderedSet alloc] initWithObjects: o0, o1, nil];
    id obj = [self unretainedObjectInMutableOrderedSet:os];

    /* Should not throw or crash when we remove an object with no other retains */
    [os removeObject:obj];
    [os release];

    return YES;
}

test(NilContainsObject)
{
    NSObject *o1 = [[[NSObject alloc] init] autorelease];
    NSObject *o2 = [[[NSObject alloc] init] autorelease];

    NSOrderedSet *os = [[NSOrderedSet alloc] initWithObjects: o1, o2, o2, nil];

    testassert(![os containsObject:nil]);

    [os release];

    return YES;
}

test(Count)
{
    NSObject *o1 = [[[NSObject alloc] init] autorelease];
    NSObject *o2 = [[[NSObject alloc] init] autorelease];

    NSOrderedSet *os = [[NSOrderedSet alloc] initWithObjects: o1, o2, o2, nil];

    testassert([os count] == 2);

    [os release];

    return YES;
}

test(ObjectEnumerator)
{
    NSMutableOrderedSet *os = [[NSMutableOrderedSet alloc] init];
    int count = 10;
    NSObject **members = malloc(sizeof(*members) * count);
    int *counts = calloc(sizeof(*counts), count);

    for (int i = 0; i < count; i++)
    {
        members[i] = [[NSObject alloc] init];
        for (int inserts = 0; inserts < i; inserts++)
        {
            [os addObject:members[i]];
        }
    }

    // Count for object
    for (int i = 1; i < count; i++)
    {
        testassert([os containsObject:members[i]]);
    }

    id object;
    NSEnumerator *enumerator = [os objectEnumerator];
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
    NSMutableOrderedSet *os = [[NSMutableOrderedSet alloc] init];
    int count = 10;
    NSObject **members = malloc(sizeof(*members) * count);
    int *counts = calloc(sizeof(*counts), count);

    for (int i = 0; i < count; i++)
    {
        members[i] = [[NSObject alloc] init];
        for (int inserts = 0; inserts < i; inserts++)
        {
            [os addObject:members[i]];
        }
    }

    // Count for object
    for (int i = 1; i < count; i++)
    {
        testassert([os containsObject:members[i]]);
    }

    for (id object in os)
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

    // If an object is added multiple times to an NSOrderedSet, it is
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
    NSOrderedSet *os = [[NSOrderedSet alloc] initWithObjects:
                        [[[NSObject alloc] init] autorelease],
                        [[[NSObject alloc] init] autorelease],
                        [[[NSObject alloc] init] autorelease],
                        nil];

    NSOrderedSet *osCopy = [os copyWithZone:nil];

    testassert(osCopy != nil);

    [osCopy release];
    [os release];

    return YES;
}

test(MutableCopyWithZone)
{
    NSOrderedSet *os = [[NSOrderedSet alloc] initWithObjects:
                        [[[NSObject alloc] init] autorelease],
                        [[[NSObject alloc] init] autorelease],
                        [[[NSObject alloc] init] autorelease],
                        nil];

    NSOrderedSet *osCopy = [os mutableCopyWithZone:nil];

    testassert(osCopy != nil);

    [osCopy release];
    [os release];

    return YES;
}

test(AddObjectsFromArray)
{
    NSObject *o0 = [[[NSObject alloc] init] autorelease];
    NSMutableOrderedSet *os = [[NSMutableOrderedSet alloc] initWithObjects: o0, nil];
    NSArray *a = @[@1, @2];
    [os addObjectsFromArray:a];
    testassert([os count] == 3);

    return YES;
}

test(OrderedSetCreationWithVariousObjectsAndDuplicates)
{
    NSMutableOrderedSet *aOrderedSet = [[NSMutableOrderedSet alloc] initWithObjects:[NSNumber numberWithFloat:3.14159f], [NSNumber numberWithChar:0x7f], [NSNumber numberWithDouble:-6.62606957], [NSNumber numberWithBool:YES], @"42", @"42", @"42", @"42", nil];
    testassert([aOrderedSet count] == 5);
    [aOrderedSet release];
    return YES;
}

test(MinusOrderedSet)
{
    NSObject *o0 = [[[NSObject alloc] init] autorelease];
    NSObject *o1 = [[[NSObject alloc] init] autorelease];
    NSObject *o2 = [[[NSObject alloc] init] autorelease];
    NSObject *o3 = [[[NSObject alloc] init] autorelease];

    NSMutableOrderedSet *os = [[NSMutableOrderedSet alloc] initWithObjects: o1, o2, o0, nil];
    NSOrderedSet *s = [[NSOrderedSet alloc] initWithObjects:o0, o3, o2, nil];

    [os minusOrderedSet:s];
    testassert([os count] == 1);
    testassert([os containsObject:o1]);
    testassert(![os containsObject:o2]);
    [os release];
    [s release];
    return YES;
}

test(IntersectOrderedSet)
{
    NSObject *o0 = [[[NSObject alloc] init] autorelease];
    NSObject *o1 = [[[NSObject alloc] init] autorelease];
    NSObject *o2 = [[[NSObject alloc] init] autorelease];
    NSObject *o3 = [[[NSObject alloc] init] autorelease];

    NSMutableOrderedSet *os = [[NSMutableOrderedSet alloc] initWithObjects: o1, o2, o0, nil];
    NSOrderedSet *s = [[NSOrderedSet alloc] initWithObjects:o0, o2, o3, nil];

    [os intersectOrderedSet:s];
    testassert([os count] == 2);
    testassert(![os containsObject:o1]);
    testassert([os containsObject:o2]);
    [os release];
    [s release];
    return YES;
}


test(UnionOrderedSet)
{
    NSObject *o0 = [[[NSObject alloc] init] autorelease];
    NSObject *o1 = [[[NSObject alloc] init] autorelease];
    NSObject *o2 = [[[NSObject alloc] init] autorelease];
    NSObject *o3 = [[[NSObject alloc] init] autorelease];

    NSMutableOrderedSet *os = [[NSMutableOrderedSet alloc] initWithObjects: o1, o2, o0, nil];
    NSOrderedSet *s = [[NSOrderedSet alloc] initWithObjects:o0, o2, o3, nil];

    [os unionOrderedSet:s];
    testassert([os count] == 4);
    testassert([os containsObject:o1]);
    testassert([os containsObject:o2]);
    [os release];
    [s release];
    return YES;
}

test(NSOrderedSetICreate0)
{
    NSOrderedSet *os = [NSOrderedSet new];
    testassert(strcmp(object_getClassName(os), "__NSOrderedSetI") == 0);
    [os release];
    return YES;
}

test(NSOrderedSetICreate1)
{
    NSOrderedSet *os = [NSOrderedSet orderedSetWithObject:@91];
    testassert(strcmp(object_getClassName(os), "__NSOrderedSetI") == 0);
    return YES;
}

test(NSOrderedSetICreate0Unique)
{
    NSOrderedSet *os1 = [NSOrderedSet new];
    NSOrderedSet *os2 = [NSOrderedSet new];
    NSOrderedSet *os3 = [os2 copy];
    testassert(os1 == os2);
    testassert(os1 == os3);
    [os1 release];
    [os2 release];
    [os3 release];
    return YES;
}

test(Allocate)
{
    NSOrderedSet *d1 = [NSOrderedSet alloc];
    NSOrderedSet *d2 = [NSOrderedSet alloc];

    // OrderedSet allocators return singletons
    testassert(d1 == d2);

    return YES;
}

test(AllocateMutable)
{
    NSMutableOrderedSet *d1 = [NSMutableOrderedSet alloc];
    NSMutableOrderedSet *d2 = [NSMutableOrderedSet alloc];

    // Mutable orderedSet allocators return singletons
    testassert(d1 == d2);

    return YES;
}

test(BadCapacity)
{
    __block BOOL raised = NO;
    __block NSMutableOrderedSet *orderedSet = nil;
    void (^block)(void) = ^{
#if __LP64__
        NSInteger capacity = 1ull << 62;
#else
        NSInteger capacity = 1073741824;
#endif
        orderedSet = [[NSMutableOrderedSet alloc] initWithCapacity:capacity];
    };
    @try {
        block();
    }
    @catch (NSException *e) {
        testassert([[e name] isEqualToString:NSInvalidArgumentException]);
        raised = YES;
    }
    testassert(raised);
    [orderedSet release];
    return YES;
}

test(LargeCapacity)
{
    __block BOOL raised = NO;
    __block NSMutableOrderedSet *orderedSet = nil;
    void (^block)(void) = ^{
        orderedSet = [[NSMutableOrderedSet alloc] initWithCapacity:1073741823];
    };
    @try {
        block();
    }
    @catch (NSException *e) {
        raised = YES;
    }
    testassert(!raised);
    [orderedSet release];
    return YES;
}

test(AllocateDifferential)
{
    NSOrderedSet *d1 = [NSOrderedSet alloc];
    NSMutableOrderedSet *d2 = [NSMutableOrderedSet alloc];

    // Mutable and immutable allocators must be from the same class
    testassert([d1 class] == [d2 class]);

    return YES;
}

test(AllocatedRetainCount)
{
    NSOrderedSet *d = [NSOrderedSet alloc];

    // Allocators are singletons and have this retain count
    testassert([d retainCount] == NSUIntegerMax);

    return YES;
}

test(AllocatedClass)
{
    // Allocation must be a NSOrderedSet subclass
    testassert([[NSOrderedSet alloc] isKindOfClass:[NSOrderedSet class]]);

    // Allocation must be a NSOrderedSet subclass
    testassert([[NSMutableOrderedSet alloc] isKindOfClass:[NSOrderedSet class]]);

    // Allocation must be a NSMutableOrderedSet subclass
    testassert([[NSOrderedSet alloc] isKindOfClass:[NSMutableOrderedSet class]]);

    // Allocation must be a NSMutableOrderedSet subclass
    testassert([[NSMutableOrderedSet alloc] isKindOfClass:[NSMutableOrderedSet class]]);

    return YES;
}

test(RetainCount)
{
    NSOrderedSet *d = [NSOrderedSet alloc];

    testassert([d retainCount] == NSUIntegerMax);

    return YES;
}

test(DoubleDeallocAllocate)
{
    NSOrderedSet *d = [NSOrderedSet alloc];

    // Releasing twice should not throw
    [d release];
    [d release];

    return YES;
}

test(BlankMutableCreation)
{
    NSMutableOrderedSet *arr = [[NSMutableOrderedSet alloc] init];

    // Blank initialization should return a OrderedSet
    testassert(arr != nil);

    [arr release];

    return YES;
}

test(DefaultCreation)
{
    id obj1 = [[NSObject alloc] init];
    NSOrderedSet *obj = [NSOrderedSet alloc];
    NSOrderedSet *arr = [obj initWithObjects:&obj1 count:1];

    // Default initializer with one object should return a OrderedSet
    testassert(arr != nil);

    [arr release];

    return YES;
}

test(DefaultMutableCreation)
{
    id obj1 = [[NSObject alloc] init];
    NSMutableOrderedSet *arr = [[NSMutableOrderedSet alloc] initWithObjects:&obj1 count:1];

    // Default initializer with one object should return a OrderedSet
    testassert(arr != nil);

    [arr release];

    return YES;
}

test(VarArgsMutableCreation)
{
    NSMutableOrderedSet *arr = [[NSMutableOrderedSet alloc] initWithObjects:@"foo", @"bar", @"baz", @"bar", nil];

    // Var args initializer should return a OrderedSet
    testassert(arr != nil);
    testassert([arr isKindOfClass:[objc_getClass("NSOrderedSet") class]]);
    testassert([arr isKindOfClass:[objc_getClass("NSMutableOrderedSet") class]]);

    [arr release];

    return YES;
}

test(OtherOrderedSetCreation)
{
    NSOrderedSet *arr = [[NSOrderedSet alloc] initWithOrderedSet:
                         [NSOrderedSet orderedSetWithArray:@[@"bar", @"foo"]]];

    // Other OrderedSet initializer should return a OrderedSet
    testassert(arr != nil);
    testassert([arr isKindOfClass:[objc_getClass("NSOrderedSet") class]]);

    [arr release];

    return YES;
}

test(OtherOrderedSetMutableCreation)
{
    NSMutableOrderedSet *arr = [[NSMutableOrderedSet alloc] initWithOrderedSet:
                                [NSOrderedSet orderedSetWithArray:@[@"bar", @"foo"]]];
    // Other OrderedSet initializer should return a OrderedSet
    testassert(arr != nil);
    testassert([arr isKindOfClass:[objc_getClass("NSOrderedSet") class]]);
    testassert([arr isKindOfClass:[objc_getClass("NSMutableOrderedSet") class]]);

    [arr release];

    return YES;
}

test(OtherOrderedSetCopyCreation)
{
    NSOrderedSet *arr = [[NSOrderedSet alloc] initWithOrderedSet:
                         [NSOrderedSet orderedSetWithArray:@[@"bar", @"foo"]] copyItems:YES];

    // Other OrderedSet initializer should return a OrderedSet
    testassert(arr != nil);
    testassert([arr isKindOfClass:[objc_getClass("NSOrderedSet") class]]);

    [arr release];

    return YES;
}

test(OtherOrderedSetCopyMutableCreation)
{
    NSMutableOrderedSet *arr = [[NSMutableOrderedSet alloc] initWithOrderedSet:
                                [NSOrderedSet orderedSetWithArray:@[@"bar", @"foo"]] copyItems:YES];

    // Other OrderedSet initializer should return a OrderedSet
    testassert(arr != nil);
    testassert([arr isKindOfClass:[objc_getClass("NSOrderedSet") class]]);
    testassert([arr isKindOfClass:[objc_getClass("NSMutableOrderedSet") class]]);

    [arr release];

    return YES;
}

test(OtherOrderedSetNoCopyCreation)
{
    NSOrderedSet *arr = [[NSOrderedSet alloc] initWithOrderedSet:
                         [NSOrderedSet orderedSetWithArray:@[@"bar", @"foo"]] copyItems:NO];

    // Other OrderedSet initializer should return a OrderedSet
    testassert(arr != nil);
    testassert([arr isKindOfClass:[objc_getClass("NSOrderedSet") class]]);

    [arr release];

    return YES;
}

test(OtherOrderedSetNoCopyMutableCreation)
{
    NSMutableOrderedSet *arr = [[NSMutableOrderedSet alloc] initWithOrderedSet:
                                [NSOrderedSet orderedSetWithArray:@[@"bar", @"foo"]]];

    // Other OrderedSet initializer should return a OrderedSet
    testassert(arr != nil);
    testassert([arr isKindOfClass:[objc_getClass("NSOrderedSet") class]]);
    testassert([arr isKindOfClass:[objc_getClass("NSMutableOrderedSet") class]]);

    [arr release];

    return YES;
}

test(OrderedSetMutableCreation)
{
    NSMutableOrderedSet *arr = [[NSMutableOrderedSet alloc] initWithObjects:@"foo", @"bar", @"baz", nil];

    // OrderedSet initializer should return a OrderedSet
    testassert(arr != nil);
    testassert([arr isKindOfClass:[objc_getClass("NSOrderedSet") class]]);
    testassert([arr isKindOfClass:[objc_getClass("NSMutableOrderedSet") class]]);

    [arr release];

    return YES;
}

#warning TODO
#if 0

test(FileCreation)
{
    NSOrderedSet *arr = [[NSOrderedSet alloc] initWithContentsOfFile:@"Info.plist"];

    // File initializer should return a OrderedSet
    testassert(arr != nil);
    testassert([arr isKindOfClass:[objc_getClass("NSOrderedSet") class]]);

    [arr release];

    return YES;
}

test(FileMutableCreation)
{
    NSMutableOrderedSet *arr = [[NSMutableOrderedSet alloc] initWithContentsOfFile:@"Info.plist"];

    // File initializer should return a OrderedSet
    testassert(arr != nil);
    testassert([arr isKindOfClass:[objc_getClass("NSOrderedSet") class]]);
    testassert([arr isKindOfClass:[objc_getClass("NSMutableOrderedSet") class]]);

    [arr release];

    return YES;
}

test(URLCreation)
{
    NSOrderedSet *arr = [[NSOrderedSet alloc] initWithContentsOfURL:[NSURL fileURLWithPath:@"Info.plist"]];

    // File initializer should return a OrderedSet
    testassert(arr != nil);
    testassert([arr isKindOfClass:[objc_getClass("NSOrderedSet") class]]);

    [arr release];

    return YES;
}

test(URLMutableCreation)
{
    NSMutableOrderedSet *arr = [[NSMutableOrderedSet alloc] initWithContentsOfURL:[NSURL fileURLWithPath:@"Info.plist"]];

    // File initializer should return a OrderedSet
    testassert(arr != nil);
    testassert([arr isKindOfClass:[objc_getClass("NSOrderedSet") class]]);
    testassert([arr isKindOfClass:[objc_getClass("NSMutableOrderedSet") class]]);

    [arr release];

    return YES;
}

#endif

test(Description)
{
    NSOrderedSet *arr = [NSOrderedSet orderedSetWithArray:@[ @1, @2, @3 ]];
    NSString *d = @"{(\n    1,\n    2,\n    3\n)}";
    testassert([d isEqualToString:[arr description]]);

    NSOrderedSet *nestedInOrderedSet = [NSOrderedSet orderedSetWithArray:@[ @1, @{ @"k1": @111, @"k2" : @{ @"kk1" : @11, @"kk2" : @22, @"kk3" : @33}, @"k3": @333}, @3 ]];
    d = @"{(\n    1,\n        {\n        k1 = 111;\n        k2 =         {\n            kk1 = 11;\n            kk2 = 22;\n            kk3 = 33;\n        };\n        k3 = 333;\n    },\n    3\n)}";
    testassert([d isEqualToString:[nestedInOrderedSet description]]);

    return YES;
}

test(RemoveAllObjects)
{
    NSMutableOrderedSet *m = [@[@3, @1, @2] mutableCopy];
    testassert([m count] == 3);

    [m removeAllObjects];
    testassert([m count] == 0);

    /* Check on empty orderedSet */
    [m removeAllObjects];
    testassert([m count] == 0);

    [m addObject:@1];
    testassert([m count] == 1);

    return YES;
}

test(ReplaceObjectsInRange1)
{
    NSMutableOrderedSet *m = [@[@1, @2] mutableCopy];
    id ids[2];
    ids[0] = @10; ids[1] = @20;
    [m replaceObjectsInRange:NSMakeRange(0,2) withObjects:ids count:2];
    testassert([m count] == 2);
    testassert([[m objectAtIndex:0] intValue] + [[m objectAtIndex:1] intValue] == 30);
    [m release];

    return YES;
}

test(ReplaceObjectsInRange2)
{
    NSMutableOrderedSet *m = [@[@1, @2] mutableCopy];
    id ids[2];
    ids[0] = @10; ids[1] = @20;
    [m replaceObjectsInRange:NSMakeRange(0,1) withObjects:ids count:2];
    testassert([m count] == 3);
    testassert([[m objectAtIndex:0] intValue] + [[m objectAtIndex:1] intValue]  + [[m objectAtIndex:2] intValue] == 32);
    [m release];

    return YES;
}

test(ReplaceObjectsInRange3)
{
    NSMutableOrderedSet *m = [@[] mutableCopy];
    id ids[2];
    [m replaceObjectsInRange:NSMakeRange(0,0) withObjects:ids count:0];
    testassert([m count] == 0);
    [m release];

    return YES;
}

test(ReplaceObjectsInRange4)
{
    NSMutableOrderedSet *m = [@[@1, @2] mutableCopy];
    id ids[2];
    [m replaceObjectsInRange:NSMakeRange(0,1) withObjects:ids count:0];
    testassert([m count] == 1);
    [m release];

    return YES;
}

test(ReplaceObjectsInRange5)
{
    NSMutableOrderedSet *m = [@[] mutableCopy];
    id ids[2];
    ids[0] = @10; ids[1] = @20;
    [m replaceObjectsInRange:NSMakeRange(0,0) withObjects:ids count:1];
    testassert([m count] == 1);
    testassert([[m objectAtIndex:0] intValue] == 10);
    [m release];

    return YES;
}

test(Enumeration)
{
    NSOrderedSet *os = [NSOrderedSet orderedSetWithArray:@[ @1, @2, @3 ]];
    int sum = 0;
    for (NSNumber *n in os)
    {
        sum += [n intValue];
    }
    testassert(sum == 6);
    return YES;
}

test(Enumeration2)
{
    int sum = 0;
    NSNumber *n;
    NSOrderedSet *os = [NSOrderedSet orderedSetWithArray:@[ @1, @2, @3 ]];
    NSEnumerator *nse = [os objectEnumerator];

    while( (n = [nse nextObject]) )
    {
        sum += [n intValue];
    }
    testassert(sum == 6);
    return YES;
}

test(Enumeration3)
{
    NSString *s = @"a Z b Z c";

    NSOrderedSet *os = [[NSOrderedSet alloc] initWithArray:[s componentsSeparatedByString:@"Z"]];

    int sum = 0;
    NSEnumerator *nse = [os objectEnumerator];

    while([nse nextObject])
    {
        sum ++;
    }
    testassert(sum == 3);
    [os release];
    return YES;
}

test(RemoveRangeExceptions)
{
    NSMutableOrderedSet *os = [@[@9] mutableCopy];
    BOOL raised = NO;
    @try {
        [os removeObjectAtIndex:NSNotFound];
    }
    @catch (NSException *caught) {
        raised = YES;
        testassert([[caught name] isEqualToString:NSRangeException]);
    }
    testassert(raised);

    raised = NO;
    @try {
        [os removeObjectAtIndex:[os count]];
    }
    @catch (NSException *caught) {
        raised = YES;
        testassert([[caught name] isEqualToString:NSRangeException]);
    }
    [os release];
    testassert(raised);

    return YES;
}


test(ContainsValue)
{
    NSValue *bodyPoint = [NSValue valueWithPointer:(int *)0x12345678];
    NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithObject:bodyPoint];
    testassert([orderedSet containsObject:bodyPoint]);

    NSValue *bodyPoint2 = [NSValue valueWithPointer:(int *)0x12345678];
    testassert([orderedSet containsObject:bodyPoint2]);
    return YES;
}


test(IndexesOfObjectsPassingTest)
{
    NSMutableOrderedSet *os = [[@[@1, @2, @3, @4] mutableCopy] autorelease];
    NSIndexSet *is = [os indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return ([obj intValue] & 1) == 0;
    }];
    testassert([is count] == 2);
    return YES;
}

test(EnumerateObjects)
{
    NSMutableOrderedSet *os = [[@[@1, @2, @3, @4] mutableCopy] autorelease];
    __block int sum = 0;
    [os enumerateObjectsUsingBlock:^void(id obj, NSUInteger idx, BOOL *stop) {
        sum += [obj intValue];
        *stop = idx == 2;
    }];
    testassert(sum == 6);
    return YES;
}

test(EnumerateObjectsWithOptions)
{
    NSMutableOrderedSet *os = [[@[@1, @2, @3, @4] mutableCopy] autorelease];
    __block int sum = 0;
    [os enumerateObjectsWithOptions:0 usingBlock:^void(id obj, NSUInteger idx, BOOL *stop) {
        sum += [obj intValue];
        *stop = idx == 2;
    }];
    testassert(sum == 6);
    return YES;
}

test(EnumerateObjectsWithOptionsReverse)
{
    NSMutableOrderedSet *os = [[@[@1, @2, @3, @4] mutableCopy] autorelease];
    __block int sum = 0;
    [os enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^void(id obj, NSUInteger idx, BOOL *stop) {
        sum += [obj intValue];
        *stop = idx == 2;
    }];
    testassert(sum == 7);
    return YES;
}

test(EnumerateObjectsWithOptionsConcurrent)
{
    NSMutableOrderedSet *os = [[@[@1, @2, @3, @4] mutableCopy] autorelease];
    __block int sum = 0;
    [os enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^void(id obj, NSUInteger idx, BOOL *stop) {
        @synchronized(self) {
            sum += [obj intValue];
        }
    }];
    testassert(sum == 10);
    return YES;
}

test(EnumerateObjectsWithOptionsReverseConcurrent)
{
    NSMutableOrderedSet *os = [[@[@1, @2, @3, @4] mutableCopy] autorelease];
    __block int sum = 0;
    [os enumerateObjectsWithOptions:NSEnumerationReverse | NSEnumerationConcurrent usingBlock:^void(id obj, NSUInteger idx, BOOL *stop) {
        @synchronized(self) {
            sum += [obj intValue];
        }
    }];
    testassert(sum == 10);
    return YES;
}

test(InequalObjects1)
{
    InequalObject *o1 = [InequalObject new];
    InequalObject *o2 = [InequalObject new];

    NSMutableOrderedSet *orderedSet = [NSMutableOrderedSet orderedSet];
    testassert([orderedSet count] == 0);
    [orderedSet addObject:o1];
    testassert([orderedSet count] == 1);
    testassert([orderedSet indexOfObject:o1] == 0);
    testassert([orderedSet indexOfObject:o2] == NSNotFound);
    testassert([orderedSet containsObject:o1]);
    testassert(![orderedSet containsObject:o2]);
    [orderedSet addObject:o2];
    testassert([orderedSet count] == 2);
    [orderedSet removeObject:o1];
    testassert([orderedSet count] == 1);
    [orderedSet removeObject:o2];
    testassert([orderedSet count] == 0);

    return YES;
}

test(InequalObjects2)
{
    InequalObject *o1 = [InequalObject new];
    InequalObject *o2 = [InequalObject new];

    NSMutableOrderedSet *orderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[NSOrderedSet orderedSet]];
    testassert([orderedSet count] == 0);
    [orderedSet addObject:o1];
    testassert([orderedSet count] == 1);
    testassert([orderedSet indexOfObject:o1] == 0);
    testassert([orderedSet indexOfObject:o2] == NSNotFound);
    testassert([orderedSet containsObject:o1]);
    testassert(![orderedSet containsObject:o2]);
    [orderedSet addObject:o2];
    testassert([orderedSet count] == 2);
    [orderedSet removeObject:o1];
    testassert([orderedSet count] == 1);
    [orderedSet removeObject:o2];
    testassert([orderedSet count] == 0);

    return YES;
}

test(InequalObjects3)
{
    InequalObject *o1 = [InequalObject new];
    InequalObject *o2 = [InequalObject new];

    NSMutableOrderedSet *orderedSet = [NSMutableOrderedSet orderedSet];
    testassert([orderedSet count] == 0);
    [orderedSet addObject:o1];
    testassert([orderedSet count] == 1);
    orderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:orderedSet];
    testassert([orderedSet count] == 1);
    testassert([orderedSet indexOfObject:o1] == 0);
    testassert([orderedSet indexOfObject:o2] == NSNotFound);
    testassert([orderedSet containsObject:o1]);
    testassert(![orderedSet containsObject:o2]);
    [orderedSet addObject:o2];
    testassert([orderedSet count] == 2);
    [orderedSet removeObject:o1];
    testassert([orderedSet count] == 1);
    [orderedSet removeObject:o2];
    testassert([orderedSet count] == 0);

    return YES;
}

test(EnumerateObjectsAtIndexes)
{
    NSIndexSet *is = [[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(2,2)];
    NSMutableOrderedSet *os = [[@[@1, @2, @3, @4] mutableCopy] autorelease];
    __block int sum = 0;
    [os enumerateObjectsAtIndexes:is options:0 usingBlock:^void(id obj, NSUInteger idx, BOOL *stop) {
        sum += [obj intValue];
        *stop = idx == 2;
    }];
    testassert(sum == 3);
    return YES;
}

test(EnumerateObjectsAtIndexesException)
{
    NSIndexSet *is = [[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(3,2)];
    NSMutableOrderedSet *os = [[@[@1, @2, @3, @4] mutableCopy] autorelease];
    BOOL raised = NO;
    __block int sum = 0;
    @try {
        [os enumerateObjectsAtIndexes:is options:0 usingBlock:^void(id obj, NSUInteger idx, BOOL *stop) {
            sum += [obj intValue];
            *stop = idx == 2;
        }];
    }
    @catch (NSException *caught) {
        raised = YES;
        testassert([[caught name] isEqualToString:NSRangeException]);
    }
    testassert(raised);

    raised = NO;
    @try {
        [os enumerateObjectsAtIndexes:is options:0 usingBlock:nil];
    }
    @catch (NSException *caught) {
        raised = YES;
        testassert([[caught name] isEqualToString:NSInvalidArgumentException]);
    }
    testassert(raised);
    return YES;
}

test(EnumerateObjectsAtIndexesReverse)
{
    NSIndexSet *is = [[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(1,3)];
    NSMutableOrderedSet *os = [[@[@1, @2, @3, @4] mutableCopy] autorelease];
    __block int sum = 0;
    [os enumerateObjectsAtIndexes:is options:NSEnumerationReverse usingBlock:^void(id obj, NSUInteger idx, BOOL *stop) {
        sum += [obj intValue];
        *stop = idx == 2;
    }];
    testassert(sum == 7);
    return YES;
}

#pragma mark Helpers

- (id)unretainedObjectInMutableOrderedSet:(NSMutableOrderedSet*)m
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
