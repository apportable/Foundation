//
//  NSKeyValueCoding.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "NSKeyValueCodingInternal.h"
#import "NSKeyValueCollectionProxies.h"
#import <Foundation/NSException.h>
#import "NSKeyValueAccessor.h"
#import <Foundation/NSSet.h>
#import <Foundation/NSString.h>
#import <libkern/OSAtomic.h>
#import <objc/runtime.h>

static int32_t NSKVOLock;

NSString *const NSUnknownKeyException = @"NSUnknownKeyException";
NSString *const NSUndefinedKeyException = @"NSUnknownKeyException";
NSString *const NSAverageKeyValueOperator = @"avg";
NSString *const NSCountKeyValueOperator = @"count";
NSString *const NSDistinctUnionOfArraysKeyValueOperator = @"distinctUnionOfArrays";
NSString *const NSDistinctUnionOfObjectsKeyValueOperator = @"distinctUnionOfObjects";
NSString *const NSDistinctUnionOfSetsKeyValueOperator = @"distinctUnionOfSets";
NSString *const NSMaximumKeyValueOperator = @"max";
NSString *const NSMinimumKeyValueOperator = @"min";
NSString *const NSSumKeyValueOperator = @"sum";
NSString *const NSUnionOfArraysKeyValueOperator = @"unionOfArrays";
NSString *const NSUnionOfObjectsKeyValueOperator = @"unionOfObjects";
NSString *const NSUnionOfSetsKeyValueOperator = @"unionOfSets";
static NSString *const NSTargetObjectUserInfoKey = @"NSTargetObjectUserInfoKey";
static NSString *const NSUnknownUserInfoKey = @"NSUnknownUserInfoKey";

@implementation NSObject (NSKeyValueCoding)

+ (BOOL)accessInstanceVariablesDirectly
{
    return YES;
}

- (void)setValue:(id)value forKey:(NSString *)key
{
    Class cls = object_getClass(self);
    OSSpinLockLock(&NSKVOLock);
    NSKeyValueSetter *setter = [NSObject _createValueSetterWithContainerClassID:cls key:key];
    OSSpinLockUnlock(&NSKVOLock);
    _NSSetUsingKeyValueSetter(self, setter, value);
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    [NSException raise:NSUnknownKeyException format:@"%@ is not key value coding compliant for the key %@", self, key];
}

- (id)valueForKey:(id)key
{
    Class cls = object_getClass(self);
    OSSpinLockLock(&NSKVOLock);
    NSKeyValueGetter *getter = [NSObject _createValueGetterWithContainerClassID:cls key:key];
    OSSpinLockUnlock(&NSKVOLock);
    return _NSGetUsingKeyValueGetter(self, getter);
}

// - (BOOL)validateValue:(inout id *)ioValue forKey:(NSString *)inKey error:(out NSError **)outError;

- (NSMutableArray *)mutableArrayValueForKey:(NSString *)key
{
    Class cls = object_getClass(self);
    OSSpinLockLock(&NSKVOLock);
    NSKeyValueProxyGetter *getter = [NSObject _createMutableArrayValueGetterWithContainerClassID:cls key:key];
    OSSpinLockUnlock(&NSKVOLock);
    return _NSGetUsingKeyValueGetter(self, getter);
}

- (NSMutableOrderedSet *)mutableOrderedSetValueForKey:(NSString *)key
{
    Class cls = object_getClass(self);
    OSSpinLockLock(&NSKVOLock);
    NSKeyValueGetter *getter = [NSObject _createMutableOrderedSetValueGetterWithContainerClassID:cls key:key];
    OSSpinLockUnlock(&NSKVOLock);
    return _NSGetUsingKeyValueGetter(self, getter);
}

- (NSMutableSet *)mutableSetValueForKey:(NSString *)key
{
    Class cls = object_getClass(self);
    OSSpinLockLock(&NSKVOLock);
    NSKeyValueGetter *getter = [NSObject _createMutableSetValueGetterWithContainerClassID:cls key:key];
    OSSpinLockUnlock(&NSKVOLock);
    return _NSGetUsingKeyValueGetter(self, getter);
}

- (id)valueForKeyPath:(id)keyPath
{
    NSRange remainderRange = [keyPath rangeOfString:@"."];
    if (remainderRange.location != NSNotFound)
    {
        NSString *subkey = [keyPath substringWithRange:NSMakeRange(0, remainderRange.location)];
        id aVal = [self valueForKey:subkey];
        NSString *remainderPath = [keyPath substringFromIndex:remainderRange.location + 1];
        return [aVal valueForKeyPath:remainderPath];
    }
    else
    {
        return [self valueForKey:keyPath];
    }
}

- (void)setValue:(id)value forKeyPath:(NSString *)keyPath
{
    if (keyPath == nil)
    {
        // TODO : ultimate result should be an exception  ...
        [self setValue:value forKey:keyPath];
        return;
    }

    NSUInteger length = [keyPath length];
    NSRange remainderRange = NSMakeRange(0, length);
    remainderRange = [keyPath rangeOfString:@"." options:0 range:remainderRange];
    if (remainderRange.length == 0)
    {
        [self setValue:value forKey:keyPath];
        return;
    }

    // NOTE : We could optimize substring processing with [NSString _newSubstringWithRange:zone:]

    NSString *subkey = [keyPath substringWithRange:NSMakeRange(0, remainderRange.location)];
    NSObject *obj = [self valueForKey:subkey];
    if (obj)
    {
        ++remainderRange.location;
        NSString *remainderPath = [keyPath substringWithRange:NSMakeRange(remainderRange.location, length-remainderRange.location)];
        [obj setValue:value forKeyPath:remainderPath];
    }
}

- (NSMutableArray *)mutableArrayValueForKeyPath:(NSString *)keyPath
{
    NSRange remainderRange = [keyPath rangeOfString:@"."];
    if (remainderRange.location != NSNotFound)
    {
        NSString *subkey = [keyPath substringWithRange:NSMakeRange(0, remainderRange.location)];
        id aVal = [self valueForKey:subkey];
        NSString *remainderPath = [keyPath substringFromIndex:remainderRange.location + 1];
        return [aVal mutableArrayValueForKeyPath:remainderPath];
    }
    else
    {
        return [self mutableArrayValueForKey:keyPath];
    }
}

- (NSMutableOrderedSet *)mutableOrderedSetValueForKeyPath:(NSString *)keyPath
{
    NSRange remainderRange = [keyPath rangeOfString:@"."];
    if (remainderRange.location != NSNotFound)
    {
        NSString *subkey = [keyPath substringWithRange:NSMakeRange(0, remainderRange.location)];
        id aVal = [self valueForKey:subkey];
        NSString *remainderPath = [keyPath substringFromIndex:remainderRange.location + 1];
        return [aVal mutableOrderedSetValueForKeyPath:remainderPath];
    }
    else
    {
        return [self mutableOrderedSetValueForKey:keyPath];
    }
}

- (NSMutableSet *)mutableSetValueForKeyPath:(NSString *)keyPath
{
    NSRange remainderRange = [keyPath rangeOfString:@"."];
    if (remainderRange.location != NSNotFound)
    {
        NSString *subkey = [keyPath substringWithRange:NSMakeRange(0, remainderRange.location)];
        id aVal = [self valueForKey:subkey];
        NSString *remainderPath = [keyPath substringFromIndex:remainderRange.location + 1];
        return [aVal mutableSetValueForKeyPath:remainderPath];
    }
    else
    {
        return [self mutableSetValueForKey:keyPath];
    }
}

- (id)valueForUndefinedKey:(id)key
{
    @throw [NSException exceptionWithName:NSUnknownKeyException reason:[NSString stringWithFormat:@"This class is not key value coding-compliant for the key %@.", key] userInfo:@{
        NSTargetObjectUserInfoKey: [self description],
        NSUnknownUserInfoKey: key ?: @"(null)"
    }];
    return nil;
}

- (NSDictionary *)dictionaryWithValuesForKeys:(NSArray *)keys
{
    NSMutableDictionary *values = [[NSMutableDictionary alloc] init];
    for (NSString *key in keys)
    {
        values[key] = [self valueForKey:key];
    }
    return [values autorelease];
}

- (void)setValuesForKeysWithDictionary:(NSDictionary *)keyedValues
{
    for (NSString *key in keyedValues)
    {
        [self setValue:keyedValues[key] forKey:key];
    }
}

@end
