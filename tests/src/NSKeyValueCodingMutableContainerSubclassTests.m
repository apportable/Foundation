//
//  NSKeyValueCodingMutableContainerSubclassTests.m
//  FoundationTests
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "FoundationTests.h"

@interface KVCNSMutableArray : NSMutableArray
{
@public
    NSMutableArray *_backing;
}
@end

@implementation KVCNSMutableArray

-(id)init
{
    self = [super init];
    if (self)
    {
        _backing = [NSMutableArray new];
    }
    return self;
}

-(void)dealloc
{
    [_backing release];
    [super dealloc];
}

- (NSUInteger)count
{
#warning "Disable tracking of calls to count (and member:)
    //return track([_backing count]);
    return [_backing count];
}

- (id)objectAtIndex:(NSUInteger)index
{
    return track([_backing objectAtIndex:index]);
}

- (void)addObject:(id)anObject
{
    track([_backing addObject:anObject]);
}

- (void)insertObject:(id)anObject atIndex:(NSUInteger)index
{
    track([_backing insertObject:anObject atIndex:index]);
}

- (void)removeLastObject
{
    track([_backing removeLastObject]);
}

- (void)removeObjectAtIndex:(NSUInteger)index
{
    track([_backing removeObjectAtIndex:index]);
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject
{
    track([_backing replaceObjectAtIndex:index withObject:anObject]);
}

@end

@interface ArrayCodingMutationSubclassTest : KVCNSMutableArray
@end

@implementation ArrayCodingMutationSubclassTest

- (NSMutableArray*)foo
{
    // Use this object as both as the KVC target and the array which is proxied.
    // This allows us to track both calls to the target's accessors and the calls
    // to the proxied array, and see how they're interleaved.
    return track(self);
}

- (void)insertObject:(id)object inFooAtIndex:(NSUInteger)index
{
    track([self insertObject:object atIndex:index]);
}

- (void)removeObjectFromFooAtIndex:(NSUInteger)index
{
    track([self removeObjectAtIndex:index]);
}

@end

@interface ArrayCodingMutationIndexesSubclassTest : ArrayCodingMutationSubclassTest
@end

@implementation ArrayCodingMutationIndexesSubclassTest

- (void)insertFoo:(NSArray *)objects atIndexes:(NSIndexSet *)indexes
{
    track([self insertObjects:objects atIndexes:indexes]);
}

- (void)removeFooAtIndexes:(NSIndexSet *)indexes
{
    track([self removeObjectsAtIndexes:indexes]);
}

@end

@interface ArrayCodingMutationReplaceSubclassTest : ArrayCodingMutationSubclassTest
@end

@implementation ArrayCodingMutationReplaceSubclassTest

-(void)replaceObjectInFooAtIndex:(NSUInteger)index withObject:(id)anObject
{
    track([self replaceObjectAtIndex:index withObject:anObject]);
}

-(void)replaceFooAtIndexes:(NSIndexSet *)indexes withFoo:(NSArray *)objects
{
    track([self replaceObjectsAtIndexes:indexes withObjects:objects]);
}

@end

@interface ArrayCodingAccessorSubclassTest : KVCNSMutableArray
@end

@implementation ArrayCodingAccessorSubclassTest

- (NSMutableArray*)foo
{
    return track(self);
}

- (void)setFoo:(NSMutableArray*)array
{
    track(array);
    if (array != self) {
        array = [array retain];
        [_backing release];
        _backing = array;
    }
}

@end

@interface KVCNSMutableOrderedSet : NSMutableOrderedSet
{
@public
    NSMutableOrderedSet *_backing;
}
@end

@implementation KVCNSMutableOrderedSet

-(id)init
{
    self = [super init];
    if (self)
    {
        _backing = [NSMutableOrderedSet new];
    }
    return self;
}

-(void)dealloc
{
    [_backing release];
    [super dealloc];
}

- (NSUInteger)count
{
    //return track([_backing count]);
    return [_backing count];
}

- (id)objectAtIndex:(NSUInteger)idx
{
    return track([_backing objectAtIndex:idx]);
}

- (NSUInteger)indexOfObject:(id)object
{
    return track([_backing indexOfObject:object]);
}

- (void)insertObject:(id)object atIndex:(NSUInteger)idx
{
    track([_backing insertObject:object atIndex:idx]);
}

- (void)removeObjectAtIndex:(NSUInteger)idx
{
    track([_backing removeObjectAtIndex:idx]);
}

- (void)replaceObjectAtIndex:(NSUInteger)idx withObject:(id)object
{
    track([_backing replaceObjectAtIndex:idx withObject:object]);
}

@end

@interface OrderedSetCodingMutationSubclassTest : KVCNSMutableOrderedSet
@end

@implementation OrderedSetCodingMutationSubclassTest

- (NSMutableOrderedSet*)foo
{
    return track(self);
}

-(void)insertObject:(id)anObject inFooAtIndex:(NSUInteger)index
{
    return track([self insertObject:anObject atIndex:index]);
}

-(void)removeObjectFromFooAtIndex:(NSUInteger)index
{
    return track([self removeObjectAtIndex:index]);
}

@end

@interface OrderedSetCodingMutationIndexesSubclassTest : OrderedSetCodingMutationSubclassTest
@end

@implementation OrderedSetCodingMutationIndexesSubclassTest

- (void)insertFoo:(NSArray *)objects atIndexes:(NSIndexSet *)indexes
{
    track([self insertObjects:objects atIndexes:indexes]);
}

- (void)removeFooAtIndexes:(NSIndexSet *)indexes
{
    track([self removeObjectsAtIndexes:indexes]);
}

@end

@interface OrderedSetCodingMutationReplaceSubclassTest : OrderedSetCodingMutationSubclassTest
@end

@implementation OrderedSetCodingMutationReplaceSubclassTest

- (void)replaceObjectInFooAtIndex:(NSUInteger)idx withObject:(id)object
{
    track([self replaceObjectAtIndex:idx withObject:object]);
}

- (void)replaceFooAtIndexes:(NSIndexSet *)indexes withFoo:(NSArray *)objects
{
    track([self replaceObjectsAtIndexes:indexes withObjects:objects]);
}

@end

@interface OrderedSetCodingAccessorSubclassTest : KVCNSMutableOrderedSet
@end

@implementation OrderedSetCodingAccessorSubclassTest

- (NSMutableOrderedSet*)foo
{
    return track(self);
}

- (void)setFoo:(NSMutableOrderedSet*)orderedSet
{
    track(orderedSet);
    if (orderedSet != self) {
        orderedSet = [orderedSet retain];
        [_backing release];
        _backing = orderedSet;
    }
}

@end

@interface KVCNSMutableSet : NSMutableSet
{
@public
    NSMutableSet *_backing;
}
@end

@implementation KVCNSMutableSet

-(id)init
{
    self = [super init];
    if (self)
    {
        _backing = [NSMutableSet new];
    }
    return self;
}

-(void)dealloc
{
    [_backing release];
    [super dealloc];
}

- (NSUInteger)count
{
    //return track([_backing count]);
    return [_backing count];
}

- (id)member:(id)object
{
    return [_backing member:object];
    //return track([_backing member:object]);
}

- (NSEnumerator *)objectEnumerator
{
    return track([_backing objectEnumerator]);
}

- (void)addObject:(id)object
{
    return track([_backing addObject:object]);
}

- (void)removeObject:(id)object
{
    return track([_backing removeObject:object]);
}

@end

@interface SetCodingMutationSubclassTest : KVCNSMutableSet
@end

@implementation SetCodingMutationSubclassTest

- (NSMutableSet*)foo
{
    return track(self);
}

- (void)addFooObject:(id)object
{
    return track([self addObject:object]);
}

- (void)removeFooObject:(id)object
{
    return track([self removeObject:object]);
}

@end

@interface SetCodingMutationModifierSubclassTest : SetCodingMutationSubclassTest
@end

@implementation SetCodingMutationModifierSubclassTest

- (void)addFoo:(NSSet *)otherSet
{
    track([self unionSet:otherSet]);
}

- (void)removeFoo:(NSSet*)otherSet
{
    track([self minusSet:otherSet]);
}

@end

@interface SetCodingMutationOperationSubclassTest : SetCodingMutationSubclassTest
@end

@implementation SetCodingMutationOperationSubclassTest

- (void)intersectFoo:(NSSet *)otherSet
{
    track([self intersectSet:otherSet]);
}

- (void)setFoo:(NSSet *)otherSet
{
    [self setSet:otherSet];
}

@end

@interface SetCodingAccessorSubclassTest : KVCNSMutableSet
@end

@implementation SetCodingAccessorSubclassTest

- (NSMutableSet*)foo
{
    return track(self);
}

- (void)setFoo:(NSMutableSet*)set
{
    track(set);
    if (set != self) {
        set = [set retain];
        [_backing release];
        _backing = set;
    }
}

@end

@testcase(NSKeyValueCodingMutableContainerSubclass)

test(ArrayMutation_insertObject_atIndex_CallPattern)
{
    ArrayCodingMutationSubclassTest *target = [[[ArrayCodingMutationSubclassTest alloc] init] autorelease];
    
    NSMutableArray* foo = [target mutableArrayValueForKey:@"foo"];
    [foo addObject:@"Zero"];
    
//    [SubclassTracker dumpVerification:target];
    BOOL verified = [SubclassTracker verify:target commands:@selector(foo), @selector(insertObject:inFooAtIndex:), @selector(insertObject:atIndex:), nil];
    testassert(verified);
    
    return YES;
}

test(ArrayMutation_removeObjectAtIndex_CallPattern)
{
    ArrayCodingMutationSubclassTest *target = [[[ArrayCodingMutationSubclassTest alloc] init] autorelease];
    [target->_backing addObject:@"Remove"];
    
    NSMutableArray* foo = [target mutableArrayValueForKey:@"foo"];
    [foo removeObjectAtIndex:0];
    
//    [SubclassTracker dumpVerification:target];
    BOOL verified = [SubclassTracker verify:target commands:@selector(removeObjectFromFooAtIndex:), @selector(removeObjectAtIndex:), nil];
    testassert(verified);
    
    return YES;
}

test(ArrayMutation_insertObjects_atIndexes_CallPattern)
{
    ArrayCodingMutationIndexesSubclassTest *target = [[[ArrayCodingMutationIndexesSubclassTest alloc] init] autorelease];
    [target->_backing addObject:@"One"];
    
    NSMutableArray* foo = [target mutableArrayValueForKey:@"foo"];
    NSArray *objects = @[@"Zero", @"Two"];
    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSetWithIndex:0];
    [indexes addIndex:2];
    [foo insertObjects:objects atIndexes:indexes];
    
//    [SubclassTracker dumpVerification:target];
    BOOL verified = [SubclassTracker verify:target commands:@selector(insertFoo:atIndexes:), @selector(insertObject:atIndex:), @selector(insertObject:atIndex:), nil];
    testassert(verified);
    
    return YES;
}

test(ArrayMutation_removeObjectsAtIndexes_CallPattern)
{
    ArrayCodingMutationIndexesSubclassTest *target = [[[ArrayCodingMutationIndexesSubclassTest alloc] init] autorelease];
    [target->_backing addObjectsFromArray:@[@(0), @(1), @(2)]];
    
    NSMutableArray* foo = [target mutableArrayValueForKey:@"foo"];
    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSetWithIndex:0];
    [indexes addIndex:2];
    [foo removeObjectsAtIndexes:indexes];
    
//    [SubclassTracker dumpVerification:target];
    BOOL verified = [SubclassTracker verify:target commands:@selector(removeFooAtIndexes:), @selector(removeObjectAtIndex:), @selector(removeObjectAtIndex:), nil];
    testassert(verified);
    
    return YES;
}

test(ArrayMutation_replaceObjectAtIndex_withObject_CallPattern)
{
    ArrayCodingMutationReplaceSubclassTest *target = [[[ArrayCodingMutationReplaceSubclassTest alloc] init] autorelease];
    [target->_backing addObjectsFromArray:@[@"Zero", @"Three", @"Two"]];
    
    NSMutableArray* foo = [target mutableArrayValueForKey:@"foo"];
    [foo replaceObjectAtIndex:1 withObject:@"One"];
    
//    [SubclassTracker dumpVerification:target];
    BOOL verified = [SubclassTracker verify:target commands:@selector(replaceObjectInFooAtIndex:withObject:), @selector(replaceObjectAtIndex:withObject:), nil];
    testassert(verified);
    
    return YES;
}

test(ArrayMutation_replaceObjectsAtIndexes_withObjects_CallPattern)
{
    ArrayCodingMutationReplaceSubclassTest *target = [[[ArrayCodingMutationReplaceSubclassTest alloc] init] autorelease];
    [target->_backing addObjectsFromArray:@[@(0), @"One", @(2), @"Three"]];
    
    NSMutableArray* foo = [target mutableArrayValueForKey:@"foo"];
    NSArray *objects = @[@(1), @(3)];
    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSetWithIndex:1];
    [indexes addIndex:3];
    [foo replaceObjectsAtIndexes:indexes withObjects:objects];
    
//    [SubclassTracker dumpVerification:target];
    BOOL verified = [SubclassTracker verify:target commands:@selector(replaceFooAtIndexes:withFoo:), @selector(replaceObjectAtIndex:withObject:), @selector(replaceObjectAtIndex:withObject:), nil];
    testassert(verified);
    
    return YES;
}

test(ArrayAccessor_isEqualToArray_CallPattern)
{
    ArrayCodingAccessorSubclassTest *target = [[[ArrayCodingAccessorSubclassTest alloc] init] autorelease];
    [target->_backing addObject:@(42)];
    
    NSMutableArray* foo = [target mutableArrayValueForKey:@"foo"];
    [foo isEqualToArray:@[@(42)]];
    
//    [SubclassTracker dumpVerification:target];
    BOOL verified = [SubclassTracker verify:target commands:@selector(foo), @selector(foo), @selector(objectAtIndex:), nil];
    testassert(verified);
    
    return YES;
}

test(ArrayAccessor_addObject_CallPattern)
{
    ArrayCodingAccessorSubclassTest *target = [[[ArrayCodingAccessorSubclassTest alloc] init] autorelease];
    [target->_backing addObject:@"Hello"];
    
    NSMutableArray* foo = [target mutableArrayValueForKey:@"foo"];
    [foo addObject:@" and "];
    [foo addObject:@"welcome!"];
    
//    [SubclassTracker dumpVerification:target];
    BOOL verified = [SubclassTracker verify:target commands:@selector(foo), @selector(objectAtIndex:), @selector(setFoo:), @selector(foo), @selector(objectAtIndex:), @selector(objectAtIndex:), @selector(setFoo:), nil];
    testassert(verified);

    return YES;
}

test(ArrayAccessor_removeObjectAtIndex_CallPattern)
{
    ArrayCodingAccessorSubclassTest *target = [[[ArrayCodingAccessorSubclassTest alloc] init] autorelease];
    [target->_backing addObject:@"Hello, world!"];
    
    NSMutableArray* foo = [target mutableArrayValueForKey:@"foo"];
    [foo removeObjectAtIndex:0];
    
//    [SubclassTracker dumpVerification:target];
    BOOL verified = [SubclassTracker verify:target commands:@selector(foo), @selector(objectAtIndex:), @selector(setFoo:), nil];
    testassert(verified);
    
    return YES;
}

test(OrderedSetMutation_insertObject_atIndex_CallPattern)
{
    OrderedSetCodingMutationSubclassTest *target = [[[OrderedSetCodingMutationSubclassTest alloc] init] autorelease];
    
    NSMutableOrderedSet* foo = [target mutableOrderedSetValueForKey:@"foo"];
    [foo addObject:@"Zero"];
    
//    [SubclassTracker dumpVerification:target];
    BOOL verified = [SubclassTracker verify:target commands:@selector(foo), @selector(insertObject:inFooAtIndex:), @selector(insertObject:atIndex:), nil];
    testassert(verified);
    
    return YES;
}

test(OrderedSetMutation_removeObjectAtIndex_CallPattern)
{
    OrderedSetCodingMutationSubclassTest *target = [[[OrderedSetCodingMutationSubclassTest alloc] init] autorelease];
    [target->_backing addObject:@"Remove"];
    
    NSMutableOrderedSet* foo = [target mutableOrderedSetValueForKey:@"foo"];
    [foo removeObjectAtIndex:0];
    
//    [SubclassTracker dumpVerification:target];
    BOOL verified = [SubclassTracker verify:target commands:@selector(removeObjectFromFooAtIndex:), @selector(removeObjectAtIndex:), nil];
    testassert(verified);
    
    return YES;
}

test(OrderedSetMutation_insertObjects_atIndexes_CallPattern)
{
    OrderedSetCodingMutationIndexesSubclassTest *target = [[[OrderedSetCodingMutationIndexesSubclassTest alloc] init] autorelease];
    [target->_backing addObject:@"One"];
    
    NSMutableOrderedSet* foo = [target mutableOrderedSetValueForKey:@"foo"];
    NSArray *objects = @[@"Zero", @"Two"];
    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSetWithIndex:0];
    [indexes addIndex:2];
    [foo insertObjects:objects atIndexes:indexes];
    
//    [SubclassTracker dumpVerification:target];
    BOOL verified = [SubclassTracker verify:target commands:@selector(insertFoo:atIndexes:), @selector(insertObject:atIndex:), @selector(insertObject:atIndex:), nil];
    testassert(verified);
    
    return YES;
}

test(OrderedSetMutation_removeObjectsAtIndexes_CallPattern)
{
    OrderedSetCodingMutationIndexesSubclassTest *target = [[[OrderedSetCodingMutationIndexesSubclassTest alloc] init] autorelease];
    [target->_backing addObjectsFromArray:@[@(0), @(1), @(2)]];
    
    NSMutableOrderedSet* foo = [target mutableOrderedSetValueForKey:@"foo"];
    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSetWithIndex:0];
    [indexes addIndex:2];
    [foo removeObjectsAtIndexes:indexes];
    
//    [SubclassTracker dumpVerification:target];
    BOOL verified = [SubclassTracker verify:target commands:@selector(removeFooAtIndexes:), @selector(removeObjectAtIndex:), @selector(removeObjectAtIndex:), nil];
    testassert(verified);
    
    return YES;
}

test(OrderedSetMutation_replaceObjectAtIndex_withObject_CallPattern)
{
    OrderedSetCodingMutationReplaceSubclassTest *target = [[[OrderedSetCodingMutationReplaceSubclassTest alloc] init] autorelease];
    [target->_backing addObjectsFromArray:@[@"Zero", @"Three", @"Two"]];
    
    NSMutableOrderedSet* foo = [target mutableOrderedSetValueForKey:@"foo"];
    [foo replaceObjectAtIndex:1 withObject:@"One"];
    
//    [SubclassTracker dumpVerification:target];
    BOOL verified = [SubclassTracker verify:target commands:@selector(replaceObjectInFooAtIndex:withObject:), @selector(replaceObjectAtIndex:withObject:), nil];
    testassert(verified);
    
    return YES;
}

test(OrderedSetMutation_replaceObjectsAtIndexes_withObjects_CallPattern)
{
    OrderedSetCodingMutationReplaceSubclassTest *target = [[[OrderedSetCodingMutationReplaceSubclassTest alloc] init] autorelease];
    [target->_backing addObjectsFromArray:@[@(0), @"One", @(2), @"Three"]];
    
    NSMutableOrderedSet* foo = [target mutableOrderedSetValueForKey:@"foo"];
    NSArray *objects = @[@(1), @(3)];
    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSetWithIndex:1];
    [indexes addIndex:3];
    [foo replaceObjectsAtIndexes:indexes withObjects:objects];
    
//    [SubclassTracker dumpVerification:target];
    BOOL verified = [SubclassTracker verify:target commands:@selector(replaceFooAtIndexes:withFoo:), @selector(removeObjectAtIndex:), @selector(removeObjectAtIndex:), @selector(insertObject:atIndex:), @selector(insertObject:atIndex:), nil];
    testassert(verified);
    
    return YES;
}

test(OrderedSetAccessor_isEqualToOrderedSet_CallPattern)
{
    OrderedSetCodingAccessorSubclassTest *target = [[[OrderedSetCodingAccessorSubclassTest alloc] init] autorelease];
    [target->_backing addObject:@(42)];
    
    NSMutableOrderedSet* foo = [target mutableOrderedSetValueForKey:@"foo"];
    [foo isEqualToOrderedSet:[NSOrderedSet orderedSetWithArray:@[@(42)]]];
    
//    [SubclassTracker dumpVerification:target];
    BOOL verified = [SubclassTracker verify:target commands:@selector(foo), @selector(foo), @selector(objectAtIndex:), nil];
    testassert(verified);
    
    return YES;
}

test(OrderedSetAccessor_addObject_CallPattern)
{
    OrderedSetCodingAccessorSubclassTest *target = [[[OrderedSetCodingAccessorSubclassTest alloc] init] autorelease];
    [target->_backing addObject:@"Hello"];
    
    NSMutableOrderedSet* foo = [target mutableOrderedSetValueForKey:@"foo"];
    [foo addObject:@" and "];
    [foo addObject:@"welcome!"];
    
//    [SubclassTracker dumpVerification:target];
    BOOL verified = [SubclassTracker verify:target commands:@selector(foo), @selector(foo), @selector(objectAtIndex:), @selector(setFoo:), @selector(foo), @selector(foo), @selector(objectAtIndex:), @selector(objectAtIndex:), @selector(setFoo:), nil];
    testassert(verified);
    
    return YES;
}

test(OrderedSetAccessor_removeObjectAtIndex_CallPattern)
{
    OrderedSetCodingAccessorSubclassTest *target = [[[OrderedSetCodingAccessorSubclassTest alloc] init] autorelease];
    [target->_backing addObject:@"Hello, world!"];
    
    NSMutableOrderedSet* foo = [target mutableOrderedSetValueForKey:@"foo"];
    [foo removeObjectAtIndex:0];
    
//    [SubclassTracker dumpVerification:target];
    BOOL verified = [SubclassTracker verify:target commands:@selector(foo), @selector(objectAtIndex:), @selector(setFoo:), nil];
    testassert(verified);
    
    return YES;
}

test(SetMutation_addObject_CallPattern)
{
    SetCodingMutationSubclassTest *target = [[[SetCodingMutationSubclassTest alloc] init] autorelease];
    
    NSMutableSet* foo = [target mutableSetValueForKey:@"foo"];
    [foo addObject:@"Zero"];
    
//    [SubclassTracker dumpVerification:target];
    BOOL verified = [SubclassTracker verify:target commands:@selector(addFooObject:), @selector(addObject:), nil];
    testassert(verified);
    
    return YES;
}

test(SetMutation_removeObject_CallPattern)
{
    SetCodingMutationSubclassTest *target = [[[SetCodingMutationSubclassTest alloc] init] autorelease];
    [target->_backing addObject:@"Remove"];
    
    NSMutableSet* foo = [target mutableSetValueForKey:@"foo"];
    [foo removeObject:@"Remove"];
    
//    [SubclassTracker dumpVerification:target];
    BOOL verified = [SubclassTracker verify:target commands:@selector(removeFooObject:), @selector(removeObject:), nil];
    testassert(verified);
    
    return YES;
}

test(SetMutation_unionSet_CallPattern)
{
    SetCodingMutationModifierSubclassTest *target = [[[SetCodingMutationModifierSubclassTest alloc] init] autorelease];
    [target->_backing addObject:@"One"];
    
    NSMutableSet* foo = [target mutableSetValueForKey:@"foo"];
    [foo unionSet:[NSSet setWithArray:@[@"One", @"Two"]]];
    
//    [SubclassTracker dumpVerification:target];
    BOOL verified = [SubclassTracker verify:target commands:@selector(addFoo:), @selector(addObject:), @selector(addObject:), nil];
    testassert(verified);
    
    return YES;
}

test(SetMutation_minusSet_CallPattern)
{
    SetCodingMutationModifierSubclassTest *target = [[[SetCodingMutationModifierSubclassTest alloc] init] autorelease];
    [target->_backing addObjectsFromArray:@[@(0), @(1), @(2)]];
    
    NSMutableSet* foo = [target mutableSetValueForKey:@"foo"];
    [foo minusSet:[NSSet setWithArray:@[@(2)]]];
    
//    [SubclassTracker dumpVerification:target];
    BOOL verified = [SubclassTracker verify:target commands:@selector(removeFoo:), @selector(removeObject:), nil];
    testassert(verified);
    
    return YES;
}

test(SetMutation_intersectSet_CallPattern)
{
    SetCodingMutationOperationSubclassTest *target = [[[SetCodingMutationOperationSubclassTest alloc] init] autorelease];
    [target->_backing addObjectsFromArray:@[@"Zero", @"Half", @"One"]];
    
    NSMutableSet* foo = [target mutableSetValueForKey:@"foo"];
    [foo intersectSet:[NSSet setWithArray:@[@"Zero", @"One"]]];
    
//    [SubclassTracker dumpVerification:target];
    BOOL verified = [SubclassTracker verify:target commands:@selector(intersectFoo:), @selector(objectEnumerator), @selector(objectEnumerator), @selector(removeObject:), nil];
    testassert(verified);
    
    return YES;
}

test(SetMutation_setSet_CallPattern)
{
    SetCodingMutationOperationSubclassTest *target = [[[SetCodingMutationOperationSubclassTest alloc] init] autorelease];
    
    NSMutableSet* foo = [target mutableSetValueForKey:@"foo"];
    [foo setSet:[NSSet setWithArray:@[@"A", @"B", @"C"]]];
    
//    [SubclassTracker dumpVerification:target];
    BOOL verified = [SubclassTracker verify:target commands:@selector(objectEnumerator), @selector(addObject:), @selector(addObject:), @selector(addObject:), nil];
    testassert(verified);
    
    return YES;
}

test(SetAccessor_isEqualToSet_CallPattern)
{
    SetCodingAccessorSubclassTest *target = [[[SetCodingAccessorSubclassTest alloc] init] autorelease];
    [target->_backing addObject:@(42)];
    
    NSMutableSet* foo = [target mutableSetValueForKey:@"foo"];
    [foo isEqualToSet:[NSSet setWithObject:@(42)]];
    
//    [SubclassTracker dumpVerification:target];
    BOOL verified = [SubclassTracker verify:target commands:@selector(foo), @selector(foo), @selector(foo), @selector(objectEnumerator), @selector(foo), nil];
    testassert(verified);
    
    return YES;
}

test(SetAccessor_addObject_CallPattern)
{
    SetCodingAccessorSubclassTest *target = [[[SetCodingAccessorSubclassTest alloc] init] autorelease];
    [target->_backing addObject:@"Hello"];
    
    NSMutableSet* foo = [target mutableSetValueForKey:@"foo"];
    [foo addObject:@" and "];
    [foo addObject:@"welcome!"];
    
//    [SubclassTracker dumpVerification:target];
    BOOL verified = [SubclassTracker verify:target commands:@selector(foo), @selector(objectEnumerator), @selector(setFoo:), @selector(foo), @selector(objectEnumerator), @selector(setFoo:), nil];
    testassert(verified);
    
    return YES;
}

test(SetAccessor_removeObjectAtIndex_CallPattern)
{
    SetCodingAccessorSubclassTest *target = [[[SetCodingAccessorSubclassTest alloc] init] autorelease];
    [target->_backing addObject:@"A brief hello!"];
    
    NSMutableSet* foo = [target mutableSetValueForKey:@"foo"];
    [foo removeObject:@"A brief hello!"];
    
//    [SubclassTracker dumpVerification:target];
    BOOL verified = [SubclassTracker verify:target commands:@selector(foo), @selector(objectEnumerator), @selector(setFoo:), nil];
    testassert(verified);
    
    return YES;
}

@end
