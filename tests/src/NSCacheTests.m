//
//  NSCacheTests.m
//  FoundationTests
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "FoundationTests.h"

#include <stdio.h>
#import <objc/runtime.h>

@interface NSCacheDelegate : NSObject<NSCacheDelegate>
@end

@implementation NSCacheDelegate
{
    BOOL *_success;
    id _object;
}

- (id)initWithSuccessPtr:(BOOL *)success andObjectToBeEvicted:(id)object
{
    self = [super init];
    if (self != nil)
    {
        _success = success;
        _object = object;
    }
    return self;
}

- (void)cache:(NSCache *)cache willEvictObject:(id)object
{
    *_success = object == _object;
}

@end

@interface NSCacheObject : NSObject<NSDiscardableContent>
@end

@implementation NSCacheObject
{
    id _object;
}

- (void)dealloc
{
    [_object release];
    [super dealloc];
}

- (id)initWithObject:(id)object
{
    self = [super init];
    if (self != nil)
    {
        _object = [object retain];
    }
    return self;
}

- (BOOL)beginContentAccess
{
    return _object != nil;
}

- (void)endContentAccess
{
}

- (void)discardContentIfPossible
{
    [_object release];
    _object = nil;
}

- (BOOL)isContentDiscarded
{
    return _object == nil;
}

@end

@interface NSCacheKey : NSObject
@property BOOL wasCopied;
@end

@implementation NSCacheKey

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        _wasCopied = NO;
    }
    return self;
}

- (id)copy
{
    self.wasCopied = YES;
    return [super copy];
}

@end

@testcase(NSCache)

test(Allocate)
{
    NSCache *c1 = [NSCache alloc];
    NSCache *c2 = [NSCache alloc];

    testassert(c1 != c2);

    return YES;
}

test(AllocateDifferential)
{
    NSCache *c1 = [NSCache alloc];
    NSCache *c2 = [NSCache alloc];

    testassert([c1 class] == [c2 class]);

    return YES;
}

test(AllocatedClass)
{
    testassert([[NSCache alloc] isKindOfClass:[NSCache class]]);

    return YES;
}

test(RetainCount)
{
    NSCache *d = [NSCache alloc];

    testassert([d retainCount] == 1);

    return YES;
}

test(BlankCreation)
{
    NSCache *cache = [[NSCache alloc] init];
    testassert(cache != nil);

    [cache release];

    return YES;
}

test(DoubleInit)
{
    [[[NSCache alloc] init] init];
    return YES;
}

test(name_default)
{
    NSCache *cache = [[[NSCache alloc] init] autorelease];
    testassert([[cache name] isEqualToString:@""]);
    return YES;
}

test(setName)
{
    NSCache *cache = [[[NSCache alloc] init] autorelease];
    [cache setName:@"name"];
    testassert([[cache name] isEqualToString:@"name"]);
    return YES;
}

test(setName2)
{
    NSCache *cache = [[[NSCache alloc] init] autorelease];
    [cache setName:@"name"];
    [cache setName:@"name2"];
    testassert([[cache name] isEqualToString:@"name2"]);
    return YES;
}

test(setObject_forKey)
{
    NSCache *cache = [[[NSCache alloc] init] autorelease];

    [cache setObject:@"foo" forKey:@"fooKey"];

    testassert([[cache objectForKey:@"fooKey"] isEqualToString:@"foo"]);

    return YES;
}

test(setObject_forNilKey)
{
    NSCache *cache = [[[NSCache alloc] init] autorelease];
    [cache setObject:@"foo" forKey:nil];

    return YES;
}

test(setNilObject_forKey)
{
    NSCache *cache = [[[NSCache alloc] init] autorelease];

    BOOL exception = NO;
    @try {
        [cache setObject:nil forKey:@"fooKey"];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:NSInvalidArgumentException]);
    }

    testassert([cache objectForKey:@"fooKey"] == nil);
    testassert(exception);

    return YES;
}

test(setNilObject_forNilKey)
{
    NSCache *cache = [[[NSCache alloc] init] autorelease];
    [cache setObject:nil forKey:nil];

    return YES;
}

test(totalCostLimit_default)
{
    NSCache *cache = [[[NSCache alloc] init] autorelease];
    testassert([cache totalCostLimit] == 0);

    return YES;
}

test(setTotalCostLimit)
{
    NSCache *cache = [[[NSCache alloc] init] autorelease];
    [cache setTotalCostLimit:42];
    testassert([cache totalCostLimit] == 42);

    return YES;
}

test(setObject_forKey_cost)
{
    NSCache *cache = [[[NSCache alloc] init] autorelease];

    [cache setObject:@"foo" forKey:@"fooKey" cost:42];

    testassert([[cache objectForKey:@"fooKey"] isEqualToString:@"foo"]);

    return YES;
}

test(setObject_forNilKey_cost)
{
    NSCache *cache = [[[NSCache alloc] init] autorelease];
    [cache setObject:@"foo" forKey:nil cost:42];

    return YES;
}

test(setNilObject_forKey_cost)
{
    NSCache *cache = [[[NSCache alloc] init] autorelease];

    BOOL exception = NO;
    @try {
        [cache setObject:nil forKey:@"fooKey" cost:42];
    }
    @catch (NSException *e) {
        exception = YES;
        testassert([[e name] isEqualToString:NSInvalidArgumentException]);
    }

    testassert([cache objectForKey:@"fooKey"] == nil);
    testassert(exception);

    return YES;
}

test(setNilObject_forNilKey_cost)
{
    NSCache *cache = [[[NSCache alloc] init] autorelease];
    [cache setObject:nil forKey:nil cost:42];

    return YES;
}

test(setObject_insufficientCost)
{
    NSCache *cache = [[[NSCache alloc] init] autorelease];
    [cache setTotalCostLimit:23];
    [cache setObject:@"foo" forKey:@"fooKey" cost:42];

    testassert([cache objectForKey:@"fooKey"] == nil);

    return YES;
}

test(removeObjectForKey)
{
    NSCache *cache = [[[NSCache alloc] init] autorelease];
    [cache setObject:@"foo" forKey:@"fooKey"];
    [cache removeObjectForKey:@"fooKey"];

    testassert([cache objectForKey:@"fooKey"] == nil);

    return YES;
}

test(removeObjectForNilKey)
{
    NSCache *cache = [[[NSCache alloc] init] autorelease];
    [cache setObject:@"foo" forKey:@"fooKey"];
    [cache removeObjectForKey:nil];

    testassert([[cache objectForKey:@"fooKey"] isEqual:@"foo"]);

    return YES;
}

test(retrieveObjectForNilKey)
{
    NSCache *cache = [[[NSCache alloc] init] autorelease];
    [cache setObject:@"foo" forKey:@"fooKey"];

    id ret = [cache objectForKey: nil];
    testassert(ret == nil);

    return YES;
}

test(removeAllObjects)
{
    NSCache *cache = [[[NSCache alloc] init] autorelease];
    [cache setObject:@"foo0" forKey:@"fooKey0"];
    [cache setObject:@"foo1" forKey:@"fooKey1"];
    [cache setObject:@"foo2" forKey:@"fooKey2"];
    [cache setObject:@"foo3" forKey:@"fooKey3"];
    [cache setObject:@"foo4" forKey:@"fooKey4"];

    [cache removeAllObjects];
    testassert([cache objectForKey:@"fooKey0"] == nil);
    testassert([cache objectForKey:@"fooKey1"] == nil);
    testassert([cache objectForKey:@"fooKey2"] == nil);
    testassert([cache objectForKey:@"fooKey3"] == nil);
    testassert([cache objectForKey:@"fooKey4"] == nil);

    return YES;
}

test(evicts_default)
{
    NSCache *cache = [[[NSCache alloc] init] autorelease];
    testassert([cache evictsObjectsWithDiscardedContent]);

    return YES;
}

test(setEvicts)
{
    NSCache *cache = [[[NSCache alloc] init] autorelease];
    [cache setEvictsObjectsWithDiscardedContent:NO];
    testassert(![cache evictsObjectsWithDiscardedContent]);

    return YES;
}

test(EvictionSettingsRespected_Yes)
{
    NSCache *cache = [[[NSCache alloc] init] autorelease];
    NSCacheObject *object = [[NSCacheObject alloc] initWithObject:[@"bar" mutableCopy]];
    [cache setObject:object forKey:@"key"];

    [object discardContentIfPossible];

    testassert([cache objectForKey:@"key"] == nil);

    return YES;
}

test(EvictionSettingsRespected_No)
{
    NSCache *cache = [[[NSCache alloc] init] autorelease];
    [cache setEvictsObjectsWithDiscardedContent:NO];
    NSCacheObject *object = [[NSCacheObject alloc] initWithObject:[@"bar" mutableCopy]];
    [cache setObject:object forKey:@"key"];

    [object discardContentIfPossible];

    testassert([cache objectForKey:@"key"] == object);

    return YES;
}

test(TotalCostLimitRespected)
{
    NSCache *cache = [[[NSCache alloc] init] autorelease];
    [cache setTotalCostLimit:42];

    for (int i = 0; i < 20; i++)
    {
        [cache setObject:@(i) forKey:@(i) cost:4];
    }

    int count = 0;
    for (int i = 0; i < 20; i++)
    {
        if ([cache objectForKey:@(i)] != nil)
        {
            count++;
        }
    }

    testassert(count == 10);

    return YES;
}

test(CountLimit_default)
{
    NSCache *cache = [[[NSCache alloc] init] autorelease];
    testassert([cache countLimit] == 0);

    return YES;
}

test(setCountLimit)
{
    NSCache *cache = [[[NSCache alloc] init] autorelease];
    [cache setCountLimit:42];
    testassert([cache countLimit] == 42);

    return YES;
}

test(CountLimitRespected)
{
    NSCache *cache = [[[NSCache alloc] init] autorelease];
    [cache setCountLimit:10];

    for (int i = 0; i < 20; i++)
    {
        [cache setObject:@(i) forKey:@(i)];
    }

    int count = 0;
    for (int i = 0; i < 20; i++)
    {
        if ([cache objectForKey:@(i)] != nil)
        {
            count++;
        }
    }

    testassert(count == 10);

    return YES;
}

test(delegate_default)
{
    NSCache *cache = [[[NSCache alloc] init] autorelease];

    testassert([cache delegate] == nil);

    return YES;
}

test(setDelegate)
{
    NSCache *cache = [[[NSCache alloc] init] autorelease];
    NSCacheDelegate *delegate = [[[NSCacheDelegate alloc] init] autorelease];
    [cache setDelegate:delegate];

    testassert([cache delegate] == delegate);

    return YES;
}

test(DelegateIsInvoked)
{
    NSCache *cache = [[[NSCache alloc] init] autorelease];
    [cache setTotalCostLimit:10];

    BOOL delegateMessaged = NO;
    NSCacheObject *object = [[NSCacheObject alloc] initWithObject:@23];
    NSCacheDelegate *delegate = [[NSCacheDelegate alloc] initWithSuccessPtr:&delegateMessaged andObjectToBeEvicted:object];
    [cache setDelegate:delegate];

    [cache setObject:object forKey:@"key" cost:8];
    testassert([cache objectForKey:@"key"] == object);

    [cache setObject:@42 forKey:@"key2" cost:8];
    testassert([[cache objectForKey:@"key2"] isEqual:@42]);

    testassert([cache objectForKey:@"key"] == nil);
    testassert(delegateMessaged);

    return YES;
}

test(DelegateIsInvoked_insufficientCost)
{
    NSCache *cache = [[[NSCache alloc] init] autorelease];
    [cache setTotalCostLimit:23];

    NSCacheObject *object = [[NSCacheObject alloc] initWithObject:@"foo"];

    BOOL delegateMessaged = NO;
    NSCacheDelegate *delegate = [[NSCacheDelegate alloc] initWithSuccessPtr:&delegateMessaged andObjectToBeEvicted:object];
    [cache setDelegate:delegate];

    [cache setObject:@"foo" forKey:@"fooKey" cost:42];
    testassert(!delegateMessaged);

    testassert([cache objectForKey:@"fooKey"] == nil);

    return YES;
}

test(KeysAreNotCopied)
{
    NSCache *cache = [[[NSCache alloc] init] autorelease];
    NSCacheKey *key = [[[NSCacheKey alloc] init] autorelease];
    [cache setObject:@"foo" forKey:key];

    testassert(!key.wasCopied);

    return YES;
}

@end
