//
//  NSArrayTests.m
//  FoundationTests
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "FoundationTests.h"

#include <stdio.h>
#import <objc/runtime.h>

@implementation InequalObject

- (BOOL)isEqual:(id)object
{
    return NO;
}

@end

@interface DescriptionObject : NSString
@property (nonatomic, copy) NSString *description;
@end

@implementation DescriptionObject

+(DescriptionObject*)withDescription:(NSString*)description
{
    DescriptionObject *object = [DescriptionObject new];
    object.description = description;
    return object;
}

-(void)dealloc
{
    self.description = nil;
    [super dealloc];
}

@end

@interface NoDescriptionObject : NSObject
@end

@implementation NoDescriptionObject
@end

@interface NSArraySubclass : NSArray {
    NSArray *inner;
}
@property (nonatomic, readonly) BOOL didInit;
@end

@implementation NSArraySubclass

- (id)init
{
    self = [super init];
    if (self)
    {
        inner = [@[ @1, @2] retain];
        _didInit = YES;
    }
    return self;
}

- (void)dealloc
{
    [inner release];
    [super dealloc];
}

@end

@interface NSArrayHashTest : NSArray
@end

@implementation NSArrayHashTest

-(NSUInteger)count
{
    return 42;
}

@end

@interface NSMutableArraySubclass : NSMutableArray {
    NSMutableArray *inner;
}
@property (nonatomic, readonly) BOOL didInit;
@property (nonatomic, readwrite) int cnt;
@end

@interface ArrayFastEnumeration : NSArray
@end

@implementation ArrayFastEnumeration
{
    NSUInteger _count;
    id *_things;
}

- (NSUInteger)count
{
    return _count;
}

- (id)objectAtIndex:(NSUInteger)index
{
    return _things[index];
}

- (id)initWithObjects:(const id [])objects count:(NSUInteger)cnt
{
    self = [super init];
    if (self != nil)
    {
        _count = cnt;
        _things = malloc(cnt * sizeof(id));
        memcpy(_things, objects, cnt * sizeof(id));
    }
    return self;
}

@end

@implementation NSMutableArraySubclass

- (id)init
{
    self = [super init];
    if (self)
    {
        _didInit = YES;
        inner = [@[ @1, @2] mutableCopy];
    }
    return self;
}

- (void)dealloc
{
    [inner release];
    [super dealloc];
}

- (void)insertObject:(id)anObject atIndex:(NSUInteger)index
{
    [inner insertObject:anObject atIndex:index];
}

- (void)removeObjectAtIndex:(NSUInteger)index
{
    [inner removeObjectAtIndex:index];
}

- (void)addObject:(id)anObject
{
    [inner addObject:anObject];
}

- (void)removeLastObject
{
    [inner removeLastObject];
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject
{
    [inner replaceObjectAtIndex:index withObject:anObject];
}

- (NSUInteger)count
{
    return [inner count];
}
@end

@testcase(NSArray)

test(NSArrayICreate0)
{
    NSArray *a = [NSArray new];
    testassert(strcmp(object_getClassName(a), "__NSArrayI") == 0);
    [a release];
    return YES;
}

test(NSArrayICreate1)
{
    NSArray *a = [NSArray arrayWithObject:@91];
    testassert(strcmp(object_getClassName(a), "__NSArrayI") == 0);
    return YES;
}

test(NSArrayICreate0Unique)
{
    NSArray *a = [NSArray new];
    NSArray *b = [NSArray new];
    NSArray *c = [b copy];
    testassert(a == b);
    testassert(a == c);
    [a release];
    [b release];
    [c release];
    return YES;
}

test(Allocate)
{
    NSArray *d1 = [NSArray alloc];
    NSArray *d2 = [NSArray alloc];

    // Array allocators return singletons
    testassert(d1 == d2);

    return YES;
}

test(AllocateMutable)
{
    NSMutableArray *d1 = [NSMutableArray alloc];
    NSMutableArray *d2 = [NSMutableArray alloc];

    // Mutable array allocators return singletons
    testassert(d1 == d2);

    return YES;
}

test(BadCapacity)
{
    __block BOOL raised = NO;
    __block NSMutableArray *array = nil;
    void (^block)(void) = ^{
#if __LP64__
        NSUInteger capacity = 1ull << 62;
#else
        NSUInteger capacity = 1073741824;
#endif
        array = [[NSMutableArray alloc] initWithCapacity:capacity];
    };
    @try {
        block();
    }
    @catch (NSException *e) {
        testassert([[e name] isEqualToString:NSInvalidArgumentException]);
        raised = YES;
    }
    testassert(raised);
    [array release];
    return YES;
}

test(LargeCapacity)
{
    __block BOOL raised = NO;
    __block NSMutableArray *array = nil;
    void (^block)(void) = ^{
        array = [[NSMutableArray alloc] initWithCapacity:1073741823];
    };
    @try {
        block();
    }
    @catch (NSException *e) {
        raised = YES;
    }
    testassert(!raised);
    [array release];
    return YES;
}

test(AllocateDifferential)
{
    NSArray *d1 = [NSArray alloc];
    NSMutableArray *d2 = [NSMutableArray alloc];

    // Mutable and immutable allocators must be from the same class
    testassert([d1 class] == [d2 class]);

    return YES;
}

test(AllocatedRetainCount)
{
    NSArray *d = [NSArray alloc];

    // Allocators are singletons and have this retain count
    testassert([d retainCount] == NSUIntegerMax);

    return YES;
}

test(AllocatedClass)
{
    // Allocation must be a NSArray subclass
    testassert([[NSArray alloc] isKindOfClass:[NSArray class]]);

    // Allocation must be a NSArray subclass
    testassert([[NSMutableArray alloc] isKindOfClass:[NSArray class]]);

    // Allocation must be a NSMutableArray subclass
    testassert([[NSArray alloc] isKindOfClass:[NSMutableArray class]]);

    // Allocation must be a NSMutableArray subclass
    testassert([[NSMutableArray alloc] isKindOfClass:[NSMutableArray class]]);

    return YES;
}

test(RetainCount)
{
    NSArray *d = [NSArray alloc];

    testassert([d retainCount] == NSUIntegerMax);

    return YES;
}

test(DoubleDeallocAllocate)
{
    NSArray *d = [NSArray alloc];

    // Releasing twice should not throw
    [d release];
    [d release];

    return YES;
}

test(DoubleInit)
{
    void (^block)() = ^{
        [[NSArray arrayWithObjects:@"foo", @"bar", nil] initWithArray:@[@1, @2]];
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

    testassert(raised);

    return YES;
}

test(BlankCreation)
{
    NSArray *arr = [[NSArray alloc] init];

    // Blank initialization should return a Array
    testassert(arr != nil);

    [arr release];

    return YES;
}

test(BlankMutableCreation)
{
    NSMutableArray *arr = [[NSMutableArray alloc] init];

    // Blank initialization should return a Array
    testassert(arr != nil);

    [arr release];

    return YES;
}

test(DefaultCreation)
{
    id obj1 = [[NSObject alloc] init];
    NSArray *obj = [NSArray alloc];
    NSArray *arr = [obj initWithObjects:&obj1 count:1];

    // Default initializer with one object should return a Array
    testassert(arr != nil);

    [arr release];

    return YES;
}

test(DefaultMutableCreation)
{
    id obj1 = [[NSObject alloc] init];
    NSMutableArray *arr = [[NSMutableArray alloc] initWithObjects:&obj1 count:1];

    // Default initializer with one object should return a Array
    testassert(arr != nil);

    [arr release];

    return YES;
}

test(DefaultCreationMany)
{
    int count = 10;
    id *values = malloc(sizeof(id) * count);
    for (int i = 0; i < count; i++)
    {
        values[i] = [[[NSObject alloc] init] autorelease];
    }

    NSArray *arr = [[NSArray alloc] initWithObjects:values count:count];
    // Default initializer with <count> objects should return a Array
    testassert(arr != nil);

    [arr release];

    free(values);

    return YES;
}

test(VarArgsCreation)
{
    NSArray *arr = [[NSArray alloc] initWithObjects:@"foo", @"bar", @"baz", @"bar", nil];

    // Var args initializer should return a Array
    testassert(arr != nil);
    testassert([arr isKindOfClass:[objc_getClass("NSArray") class]]);

    [arr release];

    return YES;
}

test(VarArgsMutableCreation)
{
    NSMutableArray *arr = [[NSMutableArray alloc] initWithObjects:@"foo", @"bar", @"baz", @"bar", nil];

    // Var args initializer should return a Array
    testassert(arr != nil);
    testassert([arr isKindOfClass:[objc_getClass("NSArray") class]]);
    testassert([arr isKindOfClass:[objc_getClass("NSMutableArray") class]]);

    [arr release];

    return YES;
}

test(OtherArrayCreation)
{
    NSArray *arr = [[NSArray alloc] initWithArray:(NSArray *)@[
                                                                                    @"bar",
                                                                                    @"foo"
                                                                                    ]];

    // Other Array initializer should return a Array
    testassert(arr != nil);
    testassert([arr isKindOfClass:[objc_getClass("NSArray") class]]);

    [arr release];

    return YES;
}

test(OtherArrayMutableCreation)
{
    NSMutableArray *arr = [[NSMutableArray alloc] initWithArray:(NSArray *)@[
                            @"bar",
                            @"foo"
                            ]];
    // Other Array initializer should return a Array
    testassert(arr != nil);
    testassert([arr isKindOfClass:[objc_getClass("NSArray") class]]);
    testassert([arr isKindOfClass:[objc_getClass("NSMutableArray") class]]);

    [arr release];

    return YES;
}

test(OtherArrayCopyCreation)
{
    NSArray *arr = [[NSArray alloc] initWithArray:(NSArray *)@[
                     @"bar",
                     @"foo"
                     ] copyItems:YES];

    // Other Array initializer should return a Array
    testassert(arr != nil);
    testassert([arr isKindOfClass:[objc_getClass("NSArray") class]]);

    [arr release];

    return YES;
}

test(OtherArrayCopyMutableCreation)
{
    NSMutableArray *arr = [[NSMutableArray alloc] initWithArray:(NSArray *)@[
                            @"bar",
                            @"foo"
                            ] copyItems:YES];

    // Other Array initializer should return a Array
    testassert(arr != nil);
    testassert([arr isKindOfClass:[objc_getClass("NSArray") class]]);
    testassert([arr isKindOfClass:[objc_getClass("NSMutableArray") class]]);

    [arr release];

    return YES;
}

test(OtherArrayNoCopyCreation)
{
    NSArray *arr = [[NSArray alloc] initWithArray:(NSArray *)@[
                     @"bar",
                     @"foo"
                     ] copyItems:NO];

    // Other Array initializer should return a Array
    testassert(arr != nil);
    testassert([arr isKindOfClass:[objc_getClass("NSArray") class]]);

    [arr release];

    return YES;
}

test(OtherArrayNoCopyMutableCreation)
{
    NSMutableArray *arr = [[NSMutableArray alloc] initWithArray:(NSArray *)@[
                                                                                                  @"bar",
                                                                                                  @"foo"
                                                                                                  ]];

    // Other Array initializer should return a Array
    testassert(arr != nil);
    testassert([arr isKindOfClass:[objc_getClass("NSArray") class]]);
    testassert([arr isKindOfClass:[objc_getClass("NSMutableArray") class]]);

    [arr release];

    return YES;
}

test(ArrayCreation)
{
    NSArray *arr = [[NSArray alloc] initWithObjects:@"foo", @"bar", @"baz", nil];

    // Array initializer should return a Array
    testassert(arr != nil);
    testassert([arr isKindOfClass:[objc_getClass("NSArray") class]]);

    [arr release];

    return YES;
}

test(ArrayMutableCreation)
{
    NSMutableArray *arr = [[NSMutableArray alloc] initWithObjects:@"foo", @"bar", @"baz", nil];

    // Array initializer should return a Array
    testassert(arr != nil);
    testassert([arr isKindOfClass:[objc_getClass("NSArray") class]]);
    testassert([arr isKindOfClass:[objc_getClass("NSMutableArray") class]]);

    [arr release];

    return YES;
}
test(ArrayInsertBeyondBounds)
{
    NSMutableArray *arr = [[NSMutableArray alloc] initWithObjects:@"Foo",@"Bar", nil];
    BOOL thrown = NO;
    @try {
        [arr insertObject:@"Banana" atIndex:3];
    }
    @catch (NSException *exception) {
        thrown = YES;
        testassert([exception.name isEqualToString:NSRangeException]);
    }
    testassert(thrown);
    return YES;
}

#warning TODO
#if 0

test(FileCreation)
{
    NSArray *arr = [[NSArray alloc] initWithContentsOfFile:@"Info.plist"];

    // File initializer should return a Array
    testassert(arr != nil);
    testassert([arr isKindOfClass:[objc_getClass("NSArray") class]]);

    [arr release];

    return YES;
}

test(FileMutableCreation)
{
    NSMutableArray *arr = [[NSMutableArray alloc] initWithContentsOfFile:@"Info.plist"];

    // File initializer should return a Array
    testassert(arr != nil);
    testassert([arr isKindOfClass:[objc_getClass("NSArray") class]]);
    testassert([arr isKindOfClass:[objc_getClass("NSMutableArray") class]]);

    [arr release];

    return YES;
}

test(URLCreation)
{
    NSArray *arr = [[NSArray alloc] initWithContentsOfURL:[NSURL fileURLWithPath:@"Info.plist"]];

    // File initializer should return a Array
    testassert(arr != nil);
    testassert([arr isKindOfClass:[objc_getClass("NSArray") class]]);

    [arr release];

    return YES;
}

test(URLMutableCreation)
{
    NSMutableArray *arr = [[NSMutableArray alloc] initWithContentsOfURL:[NSURL fileURLWithPath:@"Info.plist"]];

    // File initializer should return a Array
    testassert(arr != nil);
    testassert([arr isKindOfClass:[objc_getClass("NSArray") class]]);
    testassert([arr isKindOfClass:[objc_getClass("NSMutableArray") class]]);

    [arr release];

    return YES;
}

#endif

test(SubclassCreation)
{
    NSArraySubclass *arr = [[NSArraySubclass alloc] init];

    // Created Array should not be nil
    testassert(arr != nil);

    // Array subclasses should funnel creation methods to initWithObjects:count:
    testassert(arr.didInit);

    [arr release];

    return YES;
}

test(SubclassHash)
{
    NSArrayHashTest *arr = [[NSArrayHashTest alloc] init];
    
    testassert([arr hash] == 42);
    
    [arr release];
    
    return YES;
}

test(Description)
{
    // If all keys are same type and type is sortable, description should sort

    NSArray *arr = @[ @1, @2, @3 ];
    NSString *d = @"(\n    1,\n    2,\n    3\n)";
    testassert([d isEqualToString:[arr description]]);

    NSArray *nestedInArray =  @[ @1, @{ @"k1": @111, @"k2" : @{ @"kk1" : @11, @"kk2" : @22, @"kk3" : @33}, @"k3": @333}, @3 ];
    d = @"(\n    1,\n        {\n        k1 = 111;\n        k2 =         {\n            kk1 = 11;\n            kk2 = 22;\n            kk3 = 33;\n        };\n        k3 = 333;\n    },\n    3\n)";
    testassert([d isEqualToString:[nestedInArray description]]);

    return YES;
}

test(SortedArrayUsingSelector)
{
    NSArray *p = @[@3, @1, @2];
    NSArray *p2 = [ p sortedArrayUsingSelector:@selector(compare:)];
    BOOL isEqual = [p2 isEqualToArray:@[@1, @2, @3]];
    testassert(isEqual);

    NSArray *a = @[@"b", @"c", @"a"];
    NSArray *a2 = [ a sortedArrayUsingSelector:@selector(compare:)];
    isEqual = [a2 isEqualToArray:@[@"a", @"b", @"c"]];
    testassert(isEqual);

    return YES;
}

static NSComparisonResult compare(id a, id b, void *context)
{
    return (NSComparisonResult)CFNumberCompare((CFNumberRef)a, (CFNumberRef)b, NULL);
}


test(SortedArrayUsingFunction)
{
    NSArray *p = @[@3, @1, @2];
    NSArray *p2 = [ p sortedArrayUsingFunction:compare context:p];
    BOOL isEqual = [p2 isEqualToArray:@[@1, @2, @3]];
    testassert(isEqual);

    return YES;
}

test(SortedArrayUsingFunction572)
{
    NSMutableArray *array = [@[@3, @1, @2] mutableCopy];
    NSArray* array2 = [array sortedArrayUsingFunction:compare context: nil];
    [array removeAllObjects];
    [array addObjectsFromArray: array2];
    [array sortUsingFunction:compare context:nil];
    testassert([array isEqual:@[@1, @2, @3]] );
    
    return YES;
}

test(SortedArrayUsingFunction572_2)
{
    NSMutableArray *array = [@[@3, @1, @2] mutableCopy];
    [array sortUsingFunction:compare context:nil];
    testassert([array isEqual:@[@1, @2, @3]] );
    
    return YES;
}

test(SortedArrayUsingComparator)
{
    NSArray *p = @[@3, @1, @2];
    NSArray *p2 = [ p sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return (NSComparisonResult)CFNumberCompare((CFNumberRef)obj1, (CFNumberRef)obj2, NULL);
    }];
    BOOL isEqual = [p2 isEqualToArray:@[@1, @2, @3]];
    testassert(isEqual);

    return YES;
}

test(RemoveAllObjects)
{
    NSMutableArray *m = [@[@3, @1, @2] mutableCopy];
    testassert([m count] == 3);

    [m removeAllObjects];
    testassert([m count] == 0);

    /* Check on empty array */
    [m removeAllObjects];
    testassert([m count] == 0);

    [m addObject:@1];
    testassert([m count] == 1);

    return YES;
}

test(RemoveAllWithUnretainedObject)
{
    NSMutableArray* m = [@[@3, @2, @1] mutableCopy];
    [self unretainedObjectInMutableArray:m];

    /* Check that we don't crash after remove (due to releasing the last
     * remaining ref)
     */
    [m removeAllObjects];
    [m release];

    return YES;
}

test(SubclassRemoveAllObjects)
{
    NSMutableArraySubclass *m = [[NSMutableArraySubclass alloc] init];
    testassert([m count] == 2);

    [m removeAllObjects];
    testassert([m count] == 0);

    /* Check on empty array */
    [m removeAllObjects];
    testassert([m count] == 0);

    [m addObject:@1];
    testassert([m count] == 1);

    return YES;
}

test(RemoveObject)
{
    NSMutableArray *m = [@[@3, @1, @2] mutableCopy];
    testassert([m count] == 3);

    [m removeObject:@2];
    testassert([m count] == 2);

    m = [@[@1, @1, @2, @1] mutableCopy];
    [m removeObject:@1];
    testassert([m count] == 1);

    [m removeObject:@2];
    testassert([m count] == 0);

    return YES;
}

test(RemoveUnretainedObject)
{
    NSMutableArray* m = [@[@3, @2, @1] mutableCopy];
    id obj = [self unretainedObjectInMutableArray:m];

    /* Check that we don't crash after remove (due to releasing the last
     * remaining ref)
     */
    [m removeObject:obj];
    [m release];

    return YES;
}

test(RemoveIdenticalUnretainedObject)
{
    NSMutableArray* m = [@[@3, @2, @1] mutableCopy];
    id obj = [self unretainedObjectInMutableArray:m];

    /* Check that we don't crash after remove (due to releasing the last
     * remaining ref)
     */
    [m removeObjectIdenticalTo:obj];
    [m release];

    return YES;
}


test(ReplaceObjectsInRange1)
{
    NSMutableArray *m = [@[@1, @2] mutableCopy];
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
    NSMutableArray *m = [@[@1, @2] mutableCopy];
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
    NSMutableArray *m = [@[] mutableCopy];
    id ids[2];
    [m replaceObjectsInRange:NSMakeRange(0,0) withObjects:ids count:0];
    testassert([m count] == 0);
    [m release];

    return YES;
}

test(ReplaceObjectsInRange4)
{
    NSMutableArray *m = [@[@1, @2] mutableCopy];
    id ids[2];
    [m replaceObjectsInRange:NSMakeRange(0,1) withObjects:ids count:0];
    testassert([m count] == 1);
    [m release];

    return YES;
}

test(ReplaceObjectsInRange5)
{
    NSMutableArray *m = [@[] mutableCopy];
    id ids[2];
    ids[0] = @10; ids[1] = @20;
    [m replaceObjectsInRange:NSMakeRange(0,0) withObjects:ids count:1];
    testassert([m count] == 1);
    testassert([[m objectAtIndex:0] intValue] == 10);
    [m release];

    return YES;
}

test(ReplaceUnretainedObject)
{
    NSMutableArray* m = [@[@3, @2, @1] mutableCopy];
    [self unretainedObjectInMutableArray:m];

    /* Check that we don't crash after replace (due to releasing the last
     * remaining ref)
     */
    [m replaceObjectAtIndex:([m count] - 1) withObject:@4];
    [m release];

    return YES;
}

test(AddObjectsFromArray)
{
    NSMutableArray *cs = [@[@9] mutableCopy];
    NSArray *a = @[@1, @2];
    [cs addObjectsFromArray:a];
    testassert([cs count] == 3);
    [cs release];

    return YES;
}

test(Enumeration)
{
    NSArray *a = @[ @1, @2, @3];
    int sum = 0;
    for (NSNumber *n in a)
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
    NSArray *a = @[ @1, @2, @3];
    NSEnumerator *nse = [a objectEnumerator];

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

    NSArray *a = [[NSArray alloc] initWithArray:[s componentsSeparatedByString:@"Z"]];

    int sum = 0;
    NSEnumerator *nse = [a objectEnumerator];

    while([nse nextObject])
    {
        sum ++;
    }
    testassert(sum == 3);
    [a release];
    return YES;
}

test(RemoveRangeExceptions)
{
    NSMutableArray *cs = [@[@9] mutableCopy];
    BOOL raised = NO;
    @try {
        [cs removeObjectAtIndex:NSNotFound];
    }
    @catch (NSException *caught) {
        raised = YES;
        testassert([[caught name] isEqualToString:NSRangeException]);
    }
    testassert(raised);

    raised = NO;
    @try {
        [cs removeObjectAtIndex:[cs count]];
    }
    @catch (NSException *caught) {
        raised = YES;
        testassert([[caught name] isEqualToString:NSRangeException]);
    }
    [cs release];
    testassert(raised);

    return YES;
}


test(ContainsValue)
{
    NSValue *bodyPoint = [NSValue valueWithPointer:(int *)0x12345678];
    NSArray *array = [NSArray arrayWithObject:bodyPoint];
    testassert([array containsObject:bodyPoint]);

    NSValue *bodyPoint2 = [NSValue valueWithPointer:(int *)0x12345678];
    testassert([array containsObject:bodyPoint2]);
    return YES;
}


test(IndexesOfObjectsPassingTest)
{
    NSMutableArray *cs = [[@[@1, @2, @3, @4] mutableCopy] autorelease];
    NSIndexSet *is = [cs indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return ([obj intValue] & 1) == 0;
    }];
    testassert([is count] == 2);
    return YES;
}

test(EnumerateObjects)
{
    NSMutableArray *cs = [[@[@1, @2, @3, @4] mutableCopy] autorelease];
    __block int sum = 0;
    [cs enumerateObjectsUsingBlock:^void(id obj, NSUInteger idx, BOOL *stop) {
        sum += [obj intValue];
        *stop = idx == 2;
    }];
    testassert(sum == 6);
    return YES;
}

test(EnumerateObjectsWithOptions)
{
    NSMutableArray *cs = [[@[@1, @2, @3, @4] mutableCopy] autorelease];
    __block int sum = 0;
    [cs enumerateObjectsWithOptions:0 usingBlock:^void(id obj, NSUInteger idx, BOOL *stop) {
        sum += [obj intValue];
        *stop = idx == 2;
    }];
    testassert(sum == 6);
    return YES;
}

test(EnumerateObjectsWithOptionsReverse)
{
    NSMutableArray *cs = [[@[@1, @2, @3, @4] mutableCopy] autorelease];
    __block int sum = 0;
    [cs enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^void(id obj, NSUInteger idx, BOOL *stop) {
        sum += [obj intValue];
        *stop = idx == 2;
    }];
    testassert(sum == 7);
    return YES;
}

test(EnumerateObjectsWithOptionsConcurrent)
{
    NSMutableArray *cs = [[@[@1, @2, @3, @4] mutableCopy] autorelease];
    __block int sum = 0;
    [cs enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^void(id obj, NSUInteger idx, BOOL *stop) {
        @synchronized(self) {
            sum += [obj intValue];
        }
    }];
    testassert(sum == 10);
    return YES;
}

test(EnumerateObjectsWithOptionsReverseConcurrent)
{
    NSMutableArray *cs = [[@[@1, @2, @3, @4] mutableCopy] autorelease];
    __block int sum = 0;
    [cs enumerateObjectsWithOptions:NSEnumerationReverse | NSEnumerationConcurrent usingBlock:^void(id obj, NSUInteger idx, BOOL *stop) {
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

    NSMutableArray *array = [NSMutableArray array];
    testassert([array count] == 0);
    [array addObject:o1];
    testassert([array count] == 1);
    testassert([array indexOfObject:o1] == 0);
    testassert([array indexOfObject:o2] == NSNotFound);
    testassert([array containsObject:o1]);
    testassert(![array containsObject:o2]);
    [array addObject:o2];
    testassert([array count] == 2);
    [array removeObject:o1];
    testassert([array count] == 1);
    [array removeObject:o2];
    testassert([array count] == 0);

    return YES;
}

test(InequalObjects2)
{
    InequalObject *o1 = [InequalObject new];
    InequalObject *o2 = [InequalObject new];
    
    NSMutableArray *array = [NSMutableArray arrayWithArray:[NSArray array]];
    testassert([array count] == 0);
    [array addObject:o1];
    testassert([array count] == 1);
    testassert([array indexOfObject:o1] == 0);
    testassert([array indexOfObject:o2] == NSNotFound);
    testassert([array containsObject:o1]);
    testassert(![array containsObject:o2]);
    [array addObject:o2];
    testassert([array count] == 2);
    [array removeObject:o1];
    testassert([array count] == 1);
    [array removeObject:o2];
    testassert([array count] == 0);
    
    return YES;
}

test(InequalObjects3)
{
    InequalObject *o1 = [InequalObject new];
    InequalObject *o2 = [InequalObject new];
    
    NSMutableArray *array = [NSMutableArray array];
    testassert([array count] == 0);
    [array addObject:o1];
    testassert([array count] == 1);
    array = [NSMutableArray arrayWithArray:array];
    testassert([array count] == 1);
    testassert([array indexOfObject:o1] == 0);
    testassert([array indexOfObject:o2] == NSNotFound);
    testassert([array containsObject:o1]);
    testassert(![array containsObject:o2]);
    [array addObject:o2];
    testassert([array count] == 2);
    [array removeObject:o1];
    testassert([array count] == 1);
    [array removeObject:o2];
    testassert([array count] == 0);
    
    return YES;
}

test(EnumerateObjectsAtIndexes)
{
    NSIndexSet *is = [[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(2,2)];
    NSMutableArray *cs = [[@[@1, @2, @3, @4] mutableCopy] autorelease];
    __block int sum = 0;
    [cs enumerateObjectsAtIndexes:is options:0 usingBlock:^void(id obj, NSUInteger idx, BOOL *stop) {
        sum += [obj intValue];
        *stop = idx == 2;
    }];
    testassert(sum == 3);
    return YES;
}

test(EnumerateObjectsAtIndexesException)
{
    NSIndexSet *is = [[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(3,2)];
    NSMutableArray *cs = [[@[@1, @2, @3, @4] mutableCopy] autorelease];
    BOOL raised = NO;
    __block int sum = 0;
    @try {
        [cs enumerateObjectsAtIndexes:is options:0 usingBlock:^void(id obj, NSUInteger idx, BOOL *stop) {
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
        [cs enumerateObjectsAtIndexes:is options:0 usingBlock:nil];
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
    NSMutableArray *cs = [[@[@1, @2, @3, @4] mutableCopy] autorelease];
    __block int sum = 0;
    [cs enumerateObjectsAtIndexes:is options:NSEnumerationReverse usingBlock:^void(id obj, NSUInteger idx, BOOL *stop) {
        sum += [obj intValue];
        *stop = idx == 2;
    }];
    testassert(sum == 7);
    return YES;
}

test(SubclassFastEnumeration)
{
    NSMutableArray *ma = [NSMutableArray array];
    for (NSUInteger i = 0; i < 1000; i++)
    {
        [ma addObject:@(i)];
    }

    ArrayFastEnumeration *ff = [[[ArrayFastEnumeration alloc] initWithArray:ma] autorelease];

    NSUInteger total = 0;
    for (id f in ff)
    {
        total += [f integerValue];
    }

    testassert(total == 499500);

    return YES;
}

test(SortUsingComparator)
{
    NSMutableArray* numbers = [NSMutableArray array];
    [numbers addObject: [NSNumber numberWithInt: 5] ];
    [numbers addObject: [NSNumber numberWithInt: 2] ];
    [numbers addObject: [NSNumber numberWithInt: 4] ];
    [numbers addObject: [NSNumber numberWithInt: 1] ];
    [numbers addObject: [NSNumber numberWithInt: 3] ];
    
    [numbers sortUsingComparator: ^NSComparisonResult( id first, id second ) {
        NSNumber* firstObj = (NSNumber*) first;
        NSNumber* secondObj = (NSNumber*) second;
        return [firstObj compare: secondObj];
    }];
    
    testassert([numbers isEqualToArray:@[@1, @2, @3, @4, @5]]);
    return YES;
}

test(SortUsingException)
{
    NSMutableArray* numbers = [NSMutableArray array];
    [numbers addObject: [NSNumber numberWithInt: 5] ];
    [numbers addObject: [NSNumber numberWithInt: 2] ];
    BOOL foundException = NO;
    
    @try {
        [numbers sortUsingComparator: nil];
    }
    @catch (NSException *e) {
        foundException = YES;
        testassert([[e name] isEqualToString:@"NSInvalidArgumentException"]);
    }
    testassert(foundException);
    return YES;
}

test(SortUsingComparatorOptions)
{
    NSMutableArray* numbers = [NSMutableArray array];
    [numbers addObject: [NSNumber numberWithInt: 5] ];
    [numbers addObject: [NSNumber numberWithInt: 2] ];
    [numbers addObject: [NSNumber numberWithInt: 4] ];
    [numbers addObject: [NSNumber numberWithInt: 1] ];
    [numbers addObject: [NSNumber numberWithInt: 3] ];
    
    [numbers sortWithOptions:NSSortStable usingComparator:^NSComparisonResult( id first, id second ) {
        NSNumber* firstObj = (NSNumber*) first;
        NSNumber* secondObj = (NSNumber*) second;
        return [firstObj compare: secondObj];
    }];
    
    testassert([numbers isEqualToArray:@[@1, @2, @3, @4, @5]]);
    return YES;
}

test(SubscriptAccess)
{
    NSArray *array = @[@0, @1, @2];
    testassert([array[0] isEqualToNumber:@0]);
    testassert([array[1] isEqualToNumber:@1]);
    testassert([array[2] isEqualToNumber:@2]);
    return YES;
}

test(SubscriptBoundsException)
{
    NSArray *array = @[@0, @1, @2];
    BOOL raised = NO;
    @try {
        id val = array[NSNotFound];
        NSLog(@"%@", val);
    }
    @catch (NSException *exception) {
        raised = YES;
        testassert([[exception name] isEqualToString:NSRangeException]);
    }
    testassert(raised);
    return YES;
}

test(SubscriptAppend)
{
    NSMutableArray *array = [NSMutableArray arrayWithObjects:@1, @2, nil];
    array[2] = @3;
    testassert([array count] == 3);
    testassert([[array objectAtIndex:2] isEqualToNumber:@3]);
    return YES;
}

test(SubscriptAppendViaNotFound)
{
    NSMutableArray *array = [NSMutableArray array];
    BOOL raised = NO;
    @try {
        array[NSNotFound] = @1;
    }
    @catch (NSException *exception) {
        raised = YES;
        testassert([[exception name] isEqualToString:NSRangeException]);
    }
    testassert(raised);
    testassert([array count] == 0);
    return YES;
}

test(SubscriptReplace)
{
    NSMutableArray *array = [NSMutableArray arrayWithObjects:@0, @0, @0, nil];
    array[0] = @3;
    array[1] = @2;
    array[2] = @1;
    testassert([array isEqualToArray:@[@3, @2, @1]]);
    return YES;
}

test(StringComponentsJoinedByString)
{
    NSArray *array = @[@"a", @"b", @"c"];
    
    NSString *result = [array componentsJoinedByString:@"-"];
    testassert([result isEqualToString:@"a-b-c"]);
    
    return YES;
}

test(NumberComponentsJoinedByString)
{
    NSArray *array = @[@(0), @(1), @(2)];
    
    NSString *result = [array componentsJoinedByString:@"."];
    testassert([result isEqualToString:@"0.1.2"]);
    
    return YES;
}

#if 0

// TODO - why does this test fail?
test(DescriptionComponentsJoinedByString)
{
    NSArray *array = @[[DescriptionObject withDescription:@"x"],
                       [DescriptionObject withDescription:@"y"],
                       [DescriptionObject withDescription:@"z"]];
    
    NSString *result = [array componentsJoinedByString:@""];
    testassert([result isEqualToString:@"xyz"]);
    
    return YES;
}
#endif

test(NoDescriptionObject)
{
    NoDescriptionObject *obj1 = [NoDescriptionObject new];
    NoDescriptionObject *obj2 = [NoDescriptionObject new];
    NoDescriptionObject *obj3 = [NoDescriptionObject new];
    NSArray *array = @[obj1, obj2, obj3];
    [obj1 release];
    [obj2 release];
    [obj3 release];
    NSString *result = [array componentsJoinedByString:@""];
    testassert(result != nil);
    
    return YES;
}

test(InsertionWithIndexSet_issue683)
{
    
    NSArray *array = @[@"Insert Object 1", @"Insert Object 2", @"Insert Object 3", @"Insert Object 4"];
    
    NSMutableArray *mutableArray = [NSMutableArray arrayWithArray:@[@"Object 1", @"Object 2", @"Object 3", @"Object 4"]];
    
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(2, [array count])];
    [mutableArray insertObjects:array atIndexes:indexSet];
    NSArray *expected = @[@"Object 1", @"Object 2", @"Insert Object 1", @"Insert Object 2", @"Insert Object 3", @"Insert Object 4", @"Object 3", @"Object 4"];
    testassert([mutableArray isEqualToArray:expected]);
    
    return YES;
}

#pragma mark Helpers

- (id)unretainedObjectInMutableArray:(NSMutableArray*)m
{
    /* Array must have previous contents for the test to work */
    testassert([m count] > 0);

    @autoreleasepool {
        id obj = @{@"foo": @"bar"};
        [m addObject:obj];

        testassert([obj retainCount] == 2);
    }

    id obj = [m objectAtIndex:[m count] - 1];
    testassert([obj retainCount] == 1);
    return obj;
}

@end
