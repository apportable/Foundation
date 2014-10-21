//
//  NSKeyValueCodingMutableContainerTests.m
//  FoundationTests
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "FoundationTests.h"

#include <stdio.h>
#import <objc/runtime.h>

@interface ArrayCodingMutationTest : NSObject
{
    // Not naming instance variable _foo to ensure accessors used.
    NSMutableArray *_boo;
}
@end

@implementation ArrayCodingMutationTest

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        _boo = [[NSMutableArray alloc] initWithObjects:@(42), nil];
    }
    return self;
}

- (void)dealloc
{
    [_boo release];
    [super dealloc];
}

- (NSMutableArray*)foo
{
    return _boo;
}

- (void)insertObject:(id)object inFooAtIndex:(NSUInteger)index
{
    [_boo insertObject:object atIndex:index];
}

- (void)removeObjectFromFooAtIndex:(NSUInteger)index
{
    [_boo removeObjectAtIndex:index];
}

@end

@interface ArrayCodingAccessorTest : NSObject
{
    NSMutableArray *_boo;
}
@end

@implementation ArrayCodingAccessorTest

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        _boo = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [_boo release];
    [super dealloc];
}

- (NSMutableArray*)foo
{
    return _boo;
}

- (void)setFoo:(NSMutableArray*)array
{
    array = [array retain];
    [_boo release];
    _boo = array;
}

@end

@interface ArrayCodingInstanceVariableTest : NSObject
{
@public
    NSMutableArray *_foo;
}
@end

@implementation ArrayCodingInstanceVariableTest

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        _foo = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [_foo release];
    [super dealloc];
}

@end

@interface ArrayCodingUndefinedKeyTest : NSObject
{
@public
    NSMutableArray *_boo;
}
@end

@implementation ArrayCodingUndefinedKeyTest

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        _boo = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [_boo release];
    [super dealloc];
}

- (id)valueForUndefinedKey:(NSString *)key
{
    if ([key isEqualToString:@"foo"]) {
        return _boo;
    }
    else {
        return [super valueForUndefinedKey:key];
    }
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    if ([key isEqualToString:@"foo"]) {
        value = [value retain];
        [_boo release];
        _boo = value;
    }
    else {
        [super setValue:value forUndefinedKey:key];
    }
}

@end

@interface OrderedSetCodingMutationTest : NSObject
{
    NSMutableOrderedSet *_boo;
}
@end

@implementation OrderedSetCodingMutationTest

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        _boo = [[NSMutableOrderedSet alloc] initWithObjects:@(42), nil];
    }
    return self;
}

- (void)dealloc
{
    [_boo release];
    [super dealloc];
}

- (NSMutableOrderedSet*)foo
{
    return _boo;
}

- (void)insertObject:(id)object inFooAtIndex:(NSUInteger)index
{
    [_boo insertObject:object atIndex:index];
}

- (void)removeObjectFromFooAtIndex:(NSUInteger)index
{
    [_boo removeObjectAtIndex:index];
}

@end

@interface OrderedSetCodingAccessorTest : NSObject
{
    NSMutableOrderedSet *_boo;
}
@end

@implementation OrderedSetCodingAccessorTest

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        _boo = [[NSMutableOrderedSet alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [_boo release];
    [super dealloc];
}

- (NSMutableOrderedSet*)foo
{
    return _boo;
}

- (void)setFoo:(NSMutableOrderedSet*)array
{
    array = [array retain];
    [_boo release];
    _boo = array;
}

@end

@interface OrderedSetCodingInstanceVariableTest : NSObject
{
@public
    NSMutableOrderedSet *_foo;
}
@end

@implementation OrderedSetCodingInstanceVariableTest

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        _foo = [[NSMutableOrderedSet alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [_foo release];
    [super dealloc];
}

@end

@interface OrderedSetCodingUndefinedKeyTest : NSObject
{
@public
    NSMutableOrderedSet *_boo;
}
@end

@implementation OrderedSetCodingUndefinedKeyTest

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        _boo = [[NSMutableOrderedSet alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [_boo release];
    [super dealloc];
}

- (id)valueForUndefinedKey:(NSString *)key
{
    if ([key isEqualToString:@"foo"]) {
        return _boo;
    }
    else {
        return [super valueForUndefinedKey:key];
    }
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    if ([key isEqualToString:@"foo"]) {
        value = [value retain];
        [_boo release];
        _boo = value;
    }
    else {
        [super setValue:value forUndefinedKey:key];
    }
}

@end

@interface SetCodingMutationTest : NSObject
{
    NSMutableSet *_boo;
}
@end

@implementation SetCodingMutationTest

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        _boo = [[NSMutableSet alloc] initWithObjects:@(42), nil];
    }
    return self;
}

- (void)dealloc
{
    [_boo release];
    [super dealloc];
}

- (NSMutableSet*)foo
{
    return _boo;
}

- (void)addFooObject:(id)object
{
    [_boo addObject:object];
}

- (void)removeFooObject:(id)object
{
    [_boo removeObject:object];
}

@end

@interface SetCodingCodingAccessorTest : NSObject
{
    NSMutableSet *_boo;
}
@end

@implementation SetCodingCodingAccessorTest

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        _boo = [[NSMutableSet alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [_boo release];
    [super dealloc];
}

- (NSMutableSet*)foo
{
    return _boo;
}

- (void)setFoo:(NSMutableSet*)array
{
    array = [array retain];
    [_boo release];
    _boo = array;
}

@end

@interface SetCodingCodingInstanceVariableTest : NSObject
{
@public
    NSMutableSet *_foo;
}
@end

@implementation SetCodingCodingInstanceVariableTest

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        _foo = [[NSMutableSet alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [_foo release];
    [super dealloc];
}

@end

@interface SetCodingCodingUndefinedKeyTest : NSObject
{
@public
    NSMutableSet *_boo;
}
@end

@implementation SetCodingCodingUndefinedKeyTest

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        _boo = [[NSMutableSet alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [_boo release];
    [super dealloc];
}

- (id)valueForUndefinedKey:(NSString *)key
{
    if ([key isEqualToString:@"foo"]) {
        return _boo;
    }
    else {
        return [super valueForUndefinedKey:key];
    }
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    if ([key isEqualToString:@"foo"]) {
        value = [value retain];
        [_boo release];
        _boo = value;
    }
    else {
        [super setValue:value forUndefinedKey:key];
    }
}

@end

@interface AccessorObserver : NSObject
{
@public
    NSObject *_observable;
    NSString *_keyPath;
    NSMutableArray *_observedValues;
}
@end

@implementation AccessorObserver

- (id)initWithObservable:(NSObject *)observable forKeyPath:(NSString*)keyPath
{
    if ((self = [self init]))
    {
        _observable = [observable retain];
        _keyPath = [keyPath copy];
        _observedValues = [NSMutableArray new];
        
        [_observable addObserver:self forKeyPath:keyPath options:0 context:NULL];
    }
    return self;
}

- (void)dealloc
{
    [_observable removeObserver:self forKeyPath:_keyPath context:NULL];
    
    [_observable release];
    [_keyPath release];
    [_observedValues release];
    
    [super dealloc];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:_keyPath])
        [_observedValues addObject:[[object valueForKey:keyPath] copy]];
}

@end

@testcase(NSKeyValueCodingMutableContainer)

test(mutableArrayValueForKey_basicMutationMethodAccess)
{
    ArrayCodingMutationTest *arrayCoding = [[[ArrayCodingMutationTest alloc] init] autorelease];
    
    NSMutableArray *mutableArrayValues = [arrayCoding mutableArrayValueForKey:@"foo"];
    testassert([mutableArrayValues isEqualToArray:@[@(42)]]);

    [mutableArrayValues insertObject:@(23) atIndex:1];
    testassert([arrayCoding.foo isEqualToArray:@[@(42), @(23)]]);

    [mutableArrayValues insertObject:@(23) atIndex:2];
    testassert([mutableArrayValues isEqualToArray:@[@(42), @(23), @(23)]]);

    [mutableArrayValues removeObjectAtIndex:0];
    testassert([arrayCoding.foo isEqualToArray:@[@(23), @(23)]]);

    [mutableArrayValues removeObjectAtIndex:0];
    testassert([mutableArrayValues isEqualToArray:@[@(23)]]);

    [mutableArrayValues removeObjectAtIndex:0];
    testassert([arrayCoding.foo isEqualToArray:@[]]);

    return YES;
}

test(mutableArrayValueForKey_basicAccessorMethodAccess)
{
    ArrayCodingAccessorTest *arrayCoding = [[[ArrayCodingAccessorTest alloc] init] autorelease];
    
    NSMutableArray *mutableArrayValues = [arrayCoding mutableArrayValueForKey:@"foo"];
    testassert(mutableArrayValues != arrayCoding.foo);
    
    [mutableArrayValues addObject:@"bar"];
    testassert([mutableArrayValues isEqualToArray:@[@"bar"]]);
    
    [mutableArrayValues insertObject:@"baz" atIndex:0];
    testassert([mutableArrayValues isEqualToArray:arrayCoding.foo]);
    
    [mutableArrayValues removeLastObject];
    testassert([arrayCoding.foo isEqualToArray:@[@"baz"]]);
    
    [mutableArrayValues replaceObjectAtIndex:0 withObject:@"qux"];
    testassert([mutableArrayValues isEqualToArray:arrayCoding.foo]);
    
    [mutableArrayValues removeObjectAtIndex:0];
    testassert([mutableArrayValues isEqualToArray:@[]]);
    
    [mutableArrayValues insertObjects:@[@(1), @(2), @(3)] atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 3)]];
    testassert([mutableArrayValues isEqualToArray:@[@(1), @(2), @(3)]]);
    
    [mutableArrayValues removeAllObjects];
    testassert([mutableArrayValues isEqualToArray:@[]]);
    
    return YES;
}

test(mutableArrayValueForKey_modifyUnderlyingContainer)
{
    ArrayCodingAccessorTest *arrayCoding = [[[ArrayCodingAccessorTest alloc] init] autorelease];
    
    NSMutableArray* mutableArrayValues = [arrayCoding mutableArrayValueForKey:@"foo"];
    testassert([mutableArrayValues isEqualToArray:@[]]);
    
    [arrayCoding setFoo:[NSMutableArray arrayWithObject:@(42)]];
    testassert([mutableArrayValues isEqualToArray:arrayCoding.foo]);
    
    NSMutableArray* observedFoo = arrayCoding.foo;
    [observedFoo addObject:@(32)];
    testassert([mutableArrayValues isEqualToArray:observedFoo]);
    
    [observedFoo sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        int val1 = [obj1 integerValue];
        int val2 = [obj2 integerValue];
        if (val1 < val2)
            return NSOrderedAscending;
        else if (val2 < val1)
            return NSOrderedDescending;
        else
            return NSOrderedSame;
    }];
    testassert([mutableArrayValues isEqualToArray:@[@(32), @(42)]]);
    
    return YES;
}

test(mutableArrayValueForKey_AccessorMethodKVO)
{
    ArrayCodingAccessorTest *arrayCoding = [[ArrayCodingAccessorTest alloc] init];
    AccessorObserver* arrayObserver = [[AccessorObserver alloc] initWithObservable:arrayCoding forKeyPath:@"foo"];
    
    NSMutableArray *mutableArrayValues = [arrayCoding mutableArrayValueForKey:@"foo"];
    [mutableArrayValues addObject:@(1)];
    [mutableArrayValues addObject:@(2)];
    
    testassert([arrayObserver->_observedValues isEqualToArray:@[@[@(1)],@[@(1),@(2)]]]);
    
    [arrayObserver release];
    [arrayCoding release];
    
    return YES;
}

test(mutableArrayValueForKey_MutationMethodKVO)
{
    ArrayCodingMutationTest *arrayCoding = [[ArrayCodingMutationTest alloc] init];
    AccessorObserver* arrayObserver = [[AccessorObserver alloc] initWithObservable:arrayCoding forKeyPath:@"foo"];
    
    NSMutableArray *mutableArrayValues = [arrayCoding mutableArrayValueForKey:@"foo"];
    [mutableArrayValues insertObject:@(1) atIndex:0];
    [mutableArrayValues replaceObjectAtIndex:1 withObject:@(2)];
    [mutableArrayValues removeObjectsAtIndexes:[NSIndexSet indexSetWithIndex:1]];
    
    testassert([arrayObserver->_observedValues isEqualToArray:@[@[@(1),@(42)], @[@(1),@(2)], @[@(1)]]]);
    
    [arrayObserver release];
    [arrayCoding release];
    
    return YES;
}

test(mutableArrayValueForKey_basicInstanceVariableAccess)
{
    ArrayCodingInstanceVariableTest *arrayCoding = [[[ArrayCodingInstanceVariableTest alloc] init] autorelease];
    
    NSMutableArray* mutableArrayValues = [arrayCoding mutableArrayValueForKey:@"foo"];
    testassert(mutableArrayValues != arrayCoding->_foo);
    
    [mutableArrayValues addObject:@"One"];
    testassert([arrayCoding->_foo isEqualToArray:@[@"One"]]);
    
    [arrayCoding->_foo addObject:@"Two"];
    testassert([mutableArrayValues isEqualToArray:@[@"One", @"Two"]]);
    
    [mutableArrayValues addObject:@"Three"];
    testassert([mutableArrayValues isEqualToArray:arrayCoding->_foo]);
    
    return YES;
}

test(mutableArrayValueForKey_basicUndefinedKeyAccess)
{
    ArrayCodingUndefinedKeyTest *arrayCoding = [[[ArrayCodingUndefinedKeyTest alloc] init] autorelease];
    
    NSMutableArray* mutableArrayValues = [arrayCoding mutableArrayValueForKey:@"foo"];
    [mutableArrayValues addObjectsFromArray:@[@"A", @"B", @"C"]];
    [arrayCoding->_boo isEqualToArray:@[@"A", @"B", @"C"]];
    
    NSMutableArray* bar = [arrayCoding mutableArrayValueForKey:@"bar"];
    BOOL thrown = NO;
    @try {
        [bar addObject:@"Oops"];
    } @catch(NSException *e) {
        thrown = [[e name] isEqualToString:NSUndefinedKeyException];
    }
    testassert(thrown);
    
    return YES;
}

test(mutableOrderedSetValueForKey_basicMutationMethodAccess)
{
    OrderedSetCodingMutationTest *orderedSetCoding = [[[OrderedSetCodingMutationTest alloc] init] autorelease];
    
    NSMutableOrderedSet *mutableOrderedSetValues = [orderedSetCoding mutableOrderedSetValueForKey:@"foo"];
    testassert([mutableOrderedSetValues isEqualToOrderedSet:[NSOrderedSet orderedSetWithArray:@[@(42)]]]);

    [mutableOrderedSetValues insertObject:@(23) atIndex:1];
    testassert([orderedSetCoding.foo isEqualToOrderedSet:[NSOrderedSet orderedSetWithArray:@[@(42), @(23)]]]);
    
    [mutableOrderedSetValues insertObject:@(23) atIndex:2];
    testassert([mutableOrderedSetValues isEqualToOrderedSet:[NSOrderedSet orderedSetWithArray:@[@(42), @(23)]]]);
    
    [mutableOrderedSetValues removeObjectAtIndex:0];
    testassert([orderedSetCoding.foo isEqualToOrderedSet:[NSOrderedSet orderedSetWithArray:@[@(23)]]]);
    
    [mutableOrderedSetValues removeObjectAtIndex:0];
    testassert([mutableOrderedSetValues isEqualToOrderedSet:[NSOrderedSet orderedSetWithArray:@[]]]);
    testassert([orderedSetCoding.foo isEqualToOrderedSet:[NSOrderedSet orderedSetWithArray:@[]]]);

    return YES;
}

test(mutableOrderedSetValueForKey_basicAccessorMethodAccess)
{
    OrderedSetCodingAccessorTest *orderedSetCoding = [[[OrderedSetCodingAccessorTest alloc] init] autorelease];
    
    NSMutableOrderedSet* mutableOrderedSetValues = [orderedSetCoding mutableOrderedSetValueForKey:@"foo"];
    testassert(mutableOrderedSetValues != orderedSetCoding.foo);
    
    [mutableOrderedSetValues addObject:@"bar"];
    testassert([mutableOrderedSetValues isEqualToOrderedSet:[NSOrderedSet orderedSetWithArray:@[@"bar"]]]);
    
    [mutableOrderedSetValues insertObject:@"baz" atIndex:0];
    testassert([mutableOrderedSetValues isEqualToOrderedSet:orderedSetCoding.foo]);
    
    [mutableOrderedSetValues removeObjectAtIndex:1];
    testassert([orderedSetCoding.foo isEqualToOrderedSet:[NSOrderedSet orderedSetWithArray:@[@"baz"]]]);
    
    [mutableOrderedSetValues replaceObjectAtIndex:0 withObject:@"qux"];
    testassert([mutableOrderedSetValues isEqualToOrderedSet:orderedSetCoding.foo]);
    
    [mutableOrderedSetValues removeObjectAtIndex:0];
    testassert([mutableOrderedSetValues isEqualToOrderedSet:[NSOrderedSet orderedSetWithArray:@[]]]);
    
    [mutableOrderedSetValues insertObjects:@[@(1), @(2), @(3)] atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 3)]];
    testassert([mutableOrderedSetValues isEqualToOrderedSet:[NSOrderedSet orderedSetWithArray:@[@(1), @(2), @(3)]]]);
    
    [mutableOrderedSetValues removeAllObjects];
    testassert([mutableOrderedSetValues isEqualToOrderedSet:[NSOrderedSet orderedSetWithArray:@[]]]);
    
    return YES;
}

test(mutableOrderedSetValueForKey_modifyUnderlyingContainer)
{
    OrderedSetCodingAccessorTest *orderedSetCoding = [[[OrderedSetCodingAccessorTest alloc] init] autorelease];
    
    NSMutableOrderedSet* mutableOrderedSetValues = [orderedSetCoding mutableOrderedSetValueForKey:@"foo"];
    testassert([mutableOrderedSetValues isEqualToOrderedSet:[NSOrderedSet orderedSetWithArray:@[]]]);
    
    [orderedSetCoding setFoo:[NSMutableOrderedSet orderedSetWithObject:@(42)]];
    testassert([mutableOrderedSetValues isEqualToOrderedSet:orderedSetCoding.foo]);
    
    NSMutableOrderedSet* observedFoo = orderedSetCoding.foo;
    [observedFoo addObject:@(32)];
    testassert([mutableOrderedSetValues isEqualToOrderedSet:observedFoo]);
    
    [observedFoo sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        int val1 = [obj1 integerValue];
        int val2 = [obj2 integerValue];
        if (val1 < val2)
            return NSOrderedAscending;
        else if (val2 < val1)
            return NSOrderedDescending;
        else
            return NSOrderedSame;
    }];
    testassert([mutableOrderedSetValues isEqualToOrderedSet:[NSOrderedSet orderedSetWithArray:@[@(32), @(42)]]]);
    
    return YES;
}

test(mutableOrderedSetValueForKey_AccessorMethodKVO)
{
    OrderedSetCodingAccessorTest *orderedSetCoding = [[OrderedSetCodingAccessorTest alloc] init];
    AccessorObserver* arrayObserver = [[AccessorObserver alloc] initWithObservable:orderedSetCoding forKeyPath:@"foo"];
    
    NSMutableOrderedSet* mutableOrderedSetValues = [orderedSetCoding mutableOrderedSetValueForKey:@"foo"];
    [mutableOrderedSetValues addObject:@(1)];
    [mutableOrderedSetValues addObject:@(2)];
    
    testassert([arrayObserver->_observedValues isEqualToArray:@[
        [NSOrderedSet orderedSetWithArray:@[@(1)]],
        [NSOrderedSet orderedSetWithArray:@[@(1),@(2)]]
    ]]);
    
    [arrayObserver release];
    [orderedSetCoding release];
    
    return YES;
}

test(mutableOrderedSetValueForKey_MutationMethodKVO)
{
    OrderedSetCodingMutationTest *orderedSetCoding = [[OrderedSetCodingMutationTest alloc] init];
    AccessorObserver* arrayObserver = [[AccessorObserver alloc] initWithObservable:orderedSetCoding forKeyPath:@"foo"];
    
    NSMutableOrderedSet* mutableOrderedSetValues = [orderedSetCoding mutableOrderedSetValueForKey:@"foo"];
    [mutableOrderedSetValues insertObject:@(1) atIndex:0];
    [mutableOrderedSetValues replaceObjectAtIndex:0 withObject:@(2)];
    [mutableOrderedSetValues removeObjectAtIndex:0];
    
    testassert([arrayObserver->_observedValues isEqualToArray:@[
        [NSOrderedSet orderedSetWithArray:@[@(1), @(42)]],
        [NSOrderedSet orderedSetWithArray:@[@(2), @(42)]],
        [NSOrderedSet orderedSetWithObject:@(42)]
    ]]);
    
    [arrayObserver release];
    [orderedSetCoding release];
    
    return YES;
}

test(mutableOrderedSetValueForKey_basicInstanceVariableAccess)
{
    OrderedSetCodingInstanceVariableTest *orderedSetCoding = [[[OrderedSetCodingInstanceVariableTest alloc] init] autorelease];
    
    NSMutableOrderedSet* mutableOrderedSetValues = [orderedSetCoding mutableOrderedSetValueForKey:@"foo"];
    testassert(mutableOrderedSetValues != orderedSetCoding->_foo);
    
    [mutableOrderedSetValues addObject:@"One"];
    testassert([orderedSetCoding->_foo isEqualToOrderedSet:[NSOrderedSet orderedSetWithArray:@[@"One"]]]);
    
    [orderedSetCoding->_foo addObject:@"Two"];
    testassert([mutableOrderedSetValues isEqualToOrderedSet:[NSOrderedSet orderedSetWithArray:@[@"One", @"Two"]]]);
    
    [mutableOrderedSetValues addObject:@"Three"];
    testassert([mutableOrderedSetValues isEqualToOrderedSet:orderedSetCoding->_foo]);
    
    return YES;
}

test(mutableOrderedSetValueForKey_basicUndefinedKeyAccess)
{
    OrderedSetCodingUndefinedKeyTest *orderedSetCoding = [[[OrderedSetCodingUndefinedKeyTest alloc] init] autorelease];
    
    NSMutableOrderedSet* mutableOrderedSetValues = [orderedSetCoding mutableOrderedSetValueForKey:@"foo"];
    [mutableOrderedSetValues addObjectsFromArray:@[@"A", @"B", @"C"]];
    [orderedSetCoding->_boo isEqualToOrderedSet:[NSOrderedSet orderedSetWithArray:@[@"A", @"B", @"C"]]];
    
    NSMutableOrderedSet* bar = [orderedSetCoding mutableOrderedSetValueForKey:@"bar"];
    BOOL thrown = NO;
    @try {
        [bar addObject:@"Oops"];
    } @catch(NSException *e) {
        thrown = [[e name] isEqualToString:NSUndefinedKeyException];
    }
    testassert(thrown);
    
    return YES;
}

test(mutableSetValueForKey_basicMethodAccess)
{
    SetCodingMutationTest *setCoding = [[[SetCodingMutationTest alloc] init] autorelease];
    
    NSMutableSet *mutableSetValues = [setCoding mutableSetValueForKey:@"foo"];
    testassert([mutableSetValues isEqualToSet:[NSSet setWithArray:@[@(42)]]]);
    
    [mutableSetValues addObject:@(23)];
    testassert([setCoding.foo isEqualToSet:[NSSet setWithArray:@[@(42), @(23)]]]);
    
    [mutableSetValues addObject:@(23)];
    testassert([mutableSetValues isEqualToSet:[NSSet setWithArray:@[@(42), @(23)]]]);
    
    [mutableSetValues removeObject:@(42)];
    testassert([setCoding.foo isEqualToSet:[NSSet setWithArray:@[@(23)]]]);
    
    [mutableSetValues removeObject:@(23)];
    testassert([mutableSetValues isEqualToSet:[NSSet setWithArray:@[]]]);
    
    return YES;
}

test(mutableSetValueForKey_basicAccessorMethodAccess)
{
    SetCodingCodingAccessorTest *setCoding = [[[SetCodingCodingAccessorTest alloc] init] autorelease];
    
    NSMutableSet* mutableSetValues = [setCoding mutableSetValueForKey:@"foo"];
    testassert(mutableSetValues != setCoding.foo);
    
    [mutableSetValues addObject:@"bar"];
    testassert([mutableSetValues isEqualToSet:[NSSet setWithArray:@[@"bar"]]]);
    
    [mutableSetValues addObject:@"baz"];
    testassert([mutableSetValues isEqualToSet:setCoding.foo]);
    
    [mutableSetValues removeObject:@"bar"];
    testassert([setCoding.foo isEqualToSet:[NSSet setWithArray:@[@"baz"]]]);
    
    [mutableSetValues unionSet:[NSSet setWithObject:@"qux"]];
    testassert([mutableSetValues isEqualToSet:setCoding.foo]);
    
    [mutableSetValues intersectSet:[NSSet setWithObject:@"bar"]];
    testassert([mutableSetValues isEqualToSet:[NSSet setWithArray:@[]]]);
    
    [mutableSetValues addObjectsFromArray:@[@(1), @(2), @(3)]];
    testassert([mutableSetValues isEqualToSet:[NSSet setWithArray:@[@(1), @(2), @(3)]]]);
    
    [mutableSetValues removeAllObjects];
    testassert([mutableSetValues isEqualToSet:[NSSet setWithArray:@[]]]);
    
    return YES;
}

test(mutableSetValueForKey_modifyUnderlyingContainer)
{
    SetCodingCodingAccessorTest *setCoding = [[[SetCodingCodingAccessorTest alloc] init] autorelease];
    
    NSMutableSet* mutableSetValues = [setCoding mutableSetValueForKey:@"foo"];
    testassert([mutableSetValues isEqualToSet:[NSSet setWithArray:@[]]]);
    
    [setCoding setFoo:[NSMutableSet setWithObject:@(42)]];
    testassert([mutableSetValues isEqualToSet:setCoding.foo]);
    
    NSMutableSet* observedFoo = setCoding.foo;
    [observedFoo addObject:@(32)];
    testassert([mutableSetValues isEqualToSet:observedFoo]);
    
    [observedFoo minusSet:[NSSet setWithObject:@(42)]];
    testassert([mutableSetValues isEqualToSet:[NSSet setWithObject:@(32)]]);
    
    return YES;
}

test(mutableSetValueForKey_AccessorMethodKVO)
{
    SetCodingCodingAccessorTest *setCoding = [[SetCodingCodingAccessorTest alloc] init];
    AccessorObserver* arrayObserver = [[AccessorObserver alloc] initWithObservable:setCoding forKeyPath:@"foo"];
    
    NSMutableSet* mutableSetValues = [setCoding mutableSetValueForKey:@"foo"];
    [mutableSetValues addObject:@(1)];
    [mutableSetValues addObject:@(2)];
    
    testassert([arrayObserver->_observedValues isEqualToArray:@[
        [NSSet setWithArray:@[@(1)]],
        [NSSet setWithArray:@[@(1),@(2)]]
    ]]);
    
    [arrayObserver release];
    [setCoding release];
    
    return YES;
}

test(mutableSetValueForKey_MutationMethodKVO)
{
    SetCodingMutationTest *setCoding = [[SetCodingMutationTest alloc] init];
    AccessorObserver* arrayObserver = [[AccessorObserver alloc] initWithObservable:setCoding forKeyPath:@"foo"];
    
    NSMutableSet* mutableSetValues = [setCoding mutableSetValueForKey:@"foo"];
    [mutableSetValues unionSet:[NSSet setWithArray:@[@(1), @"Two"]]];
    [mutableSetValues intersectSet:[NSSet setWithObject:@(1)]];
    [mutableSetValues minusSet:[NSSet setWithObject:@(1)]];
    
    testassert([arrayObserver->_observedValues isEqualToArray:@[
        [NSSet setWithArray:@[@(1), @"Two", @(42)]],
        [NSSet setWithObject:@(1)],
        [NSSet set]
    ]]);
    
    [arrayObserver release];
    [setCoding release];
    
    return YES;
}

test(mutableSetyValueForKey_basicInstanceVariableAccess)
{
    SetCodingCodingInstanceVariableTest *setCoding = [[[SetCodingCodingInstanceVariableTest alloc] init] autorelease];
    
    NSMutableSet* mutableSetValues = [setCoding mutableSetValueForKey:@"foo"];
    testassert(mutableSetValues != setCoding->_foo);
    
    [mutableSetValues addObject:@"One"];
    testassert([setCoding->_foo isEqualToSet:[NSSet setWithArray:@[@"One"]]]);
    
    [setCoding->_foo addObject:@"Two"];
    testassert([mutableSetValues isEqualToSet:[NSSet setWithArray:@[@"One", @"Two"]]]);
    
    [mutableSetValues addObject:@"Three"];
    testassert([mutableSetValues isEqualToSet:setCoding->_foo]);
    
    return YES;
}

test(mutableSetValueForKey_basicUndefinedKeyAccess)
{
    SetCodingCodingUndefinedKeyTest *setCoding = [[[SetCodingCodingUndefinedKeyTest alloc] init] autorelease];
    
    NSMutableSet* mutableSetValues = [setCoding mutableSetValueForKey:@"foo"];
    [mutableSetValues addObjectsFromArray:@[@"A", @"B", @"C"]];
    [setCoding->_boo isEqualToSet:[NSSet setWithArray:@[@"A", @"B", @"C"]]];
    
    NSMutableSet* bar = [setCoding mutableSetValueForKey:@"bar"];
    BOOL thrown = NO;
    @try {
        [bar addObject:@"Oops"];
    } @catch(NSException *e) {
        thrown = [[e name] isEqualToString:NSUndefinedKeyException];
    }
    testassert(thrown);
    
    return YES;
}

@end
