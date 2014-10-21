//
//  NSKeyValueCodingInternal.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "NSKeyValueCodingInternal.h"

#import <objc/runtime.h>
#import <objc/message.h>

#import <Foundation/NSException.h>
#import "NSKeyValueAccessor.h"
#import <Foundation/NSString.h>

const void *NSKVOSetterRetain(CFAllocatorRef allocator, const void *value)
{
    NSKeyValueSetter *setter = (NSKeyValueSetter *)value;
    return [setter retain];
}

void NSKVOSetterRelease(CFAllocatorRef allocator, const void *value)
{
    NSKeyValueSetter *setter = (NSKeyValueSetter *)value;
    [setter release];
}

Boolean NSKVOSetterEqual(const void *value1, const void *value2)
{
    NSKVOSetterStruct *key1 = (NSKVOSetterStruct *)value1;
    NSKVOSetterStruct *key2 = (NSKVOSetterStruct *)value2;
    if (key1 == key2)
    {
        return YES;
    }

    if (key1 == NULL || key2 == NULL)
    {
        return NO;
    }

    if (key1->cls != key2->cls)
    {
        return NO;
    }

    if (![key1->key isEqualToString:key2->key])
    {
        return NO;
    }

    return YES;
}

CFHashCode NSKVOSetterHash(const void *value)
{
    NSKVOSetterStruct *key = (NSKVOSetterStruct *)value;
    return [key->cls hash] ^ [key->key hash];
}

void _NSSetUsingKeyValueSetter(id obj, NSKeyValueSetter *setter, id value)
{
    switch (setter->_extraArgumentCount)
    {
        case 0:
            ((void (*)(id, SEL, id))setter->_implementation)(obj, setter->_selector, value);
            break;
        case 1:
            ((void (*)(id, SEL, id, void*))setter->_implementation)(obj, setter->_selector, value, setter->_extraArgument1);
            break;
        case 2:
            ((void (*)(id, SEL, id, void*, void*))setter->_implementation)(obj, setter->_selector, value, setter->_extraArgument1, setter->_extraArgument2);
            break;
        case 3:
            ((void (*)(id, SEL, id, void*, void*, void*))setter->_implementation)(obj, setter->_selector, value, setter->_extraArgument1, setter->_extraArgument2, setter->_extraArgument3);
            break;
    }
}

id _NSGetUsingKeyValueGetter(id obj, NSKeyValueGetter *getter)
{
    switch(getter->_extraArgumentCount)
    {
        case 0:
            return ((id (*)(id, SEL))getter->_implementation)(obj, getter->_selector);
        case 1:
            return ((id (*)(id, SEL, void*))getter->_implementation)(obj, getter->_selector, getter->_extraArgument1);
        case 2:
            return ((id (*)(id, SEL, void*, void*))getter->_implementation)(obj, getter->_selector, getter->_extraArgument1, getter->_extraArgument2);
        case 3:
            return ((id (*)(id, SEL, void*, void*, void*))getter->_implementation)(obj, getter->_selector, getter->_extraArgument1, getter->_extraArgument2, getter->_extraArgument3);
    }
    return nil;
}

id __NSMinOrMaxForKeyPath(id keyPath, NSComparisonResult order, NSEnumerator *enumerator)
{
    NSNumber *retVal = nil;
    id aValue = nil;
    while ((aValue = [enumerator nextObject]) != nil)
    {
        aValue = [aValue valueForKeyPath:keyPath];
        if (retVal == nil)
        {
            retVal = aValue;
        }
        else if ((aValue != nil) && ([retVal compare:aValue] == order))
        {
            retVal = aValue;
        }
    }
    return retVal;
}

id __NSSumForKeyPath(id keyPath, NSUInteger *countPtr, NSEnumerator *enumerator)
{
    double sum = 0.0;
    id aValue = nil;
    while ((aValue = [enumerator nextObject]) != nil)
    {
        sum += [[aValue valueForKeyPath:keyPath] doubleValue];
        if (countPtr)
        {
            ++(*countPtr);
        }
    }
    return [NSNumber numberWithDouble:sum];
}

const NSString *__NSKVCKeyFromOperatorType(__NSKVCOperatorType op)
{
    switch (op)
    {
        case NSCountKeyValueOperatorType:
            return NSCountKeyValueOperator;
        case NSMaximumKeyValueOperatorType:
            return NSMaximumKeyValueOperator;
        case NSMinimumKeyValueOperatorType:
            return NSMinimumKeyValueOperator;
        case NSAverageKeyValueOperatorType:
            return NSAverageKeyValueOperator;
        case NSSumKeyValueOperatorType:
            return NSSumKeyValueOperator;
        case NSDistinctUnionOfObjectsKeyValueOperatorType:
            return NSDistinctUnionOfObjectsKeyValueOperator;
        case NSUnionOfObjectsKeyValueOperatorType:
            return NSUnionOfObjectsKeyValueOperator;
        case NSDistinctUnionOfArraysKeyValueOperatorType:
            return NSDistinctUnionOfArraysKeyValueOperator;
        case NSUnionOfArraysKeyValueOperatorType:
            return NSUnionOfArraysKeyValueOperator;
        case NSDistinctUnionOfSetsKeyValueOperatorType:
            return NSDistinctUnionOfSetsKeyValueOperator;
        case NSUnionOfSetsKeyValueOperatorType:
            return NSUnionOfSetsKeyValueOperator;
        default:
            return nil;
    }
}

__NSKVCOperatorType __NSKVCOperatorTypeFromKey(const NSString *key)
{
    if (![key hasPrefix:@"@"])
    {
        return NSKVCNoOperatorType;
    }

    NSString *operatorName = [key substringFromIndex:1];

    if ([operatorName isEqualToString:NSCountKeyValueOperator])
    {
        return NSCountKeyValueOperatorType;
    }
    else if ([operatorName isEqualToString:NSMaximumKeyValueOperator])
    {
        return NSMaximumKeyValueOperatorType;
    }
    else if ([operatorName isEqualToString:NSMinimumKeyValueOperator])
    {
        return NSMinimumKeyValueOperatorType;
    }
    else if ([operatorName isEqualToString:NSAverageKeyValueOperator])
    {
        return NSAverageKeyValueOperatorType;
    }
    else if ([operatorName isEqualToString:NSSumKeyValueOperator])
    {
        return NSSumKeyValueOperatorType;
    }
    else if ([key isEqualToString:NSDistinctUnionOfObjectsKeyValueOperator])
    {
        return NSDistinctUnionOfObjectsKeyValueOperatorType;
    }
    else if ([key isEqualToString:NSUnionOfObjectsKeyValueOperator])
    {
        return NSUnionOfObjectsKeyValueOperatorType;
    }
    else if ([key isEqualToString:NSDistinctUnionOfArraysKeyValueOperator])
    {
        return NSDistinctUnionOfArraysKeyValueOperatorType;
    }
    else if ([key isEqualToString:NSUnionOfArraysKeyValueOperator])
    {
        return NSUnionOfArraysKeyValueOperatorType;
    }
    else if ([key isEqualToString:NSDistinctUnionOfSetsKeyValueOperator])
    {
        return NSDistinctUnionOfSetsKeyValueOperatorType;
    }

    return NSKVCNoOperatorType;
}

__NSKeyPathComponents __NSGetComponentsFromKeyPath(NSString *key)
{
    NSRange remainderRange = [key rangeOfString:@"."];
    NSString *remainderPath = nil;

    if (remainderRange.location != NSNotFound)
    {
        remainderPath = @"";
        NSString *subkey = [key substringWithRange:NSMakeRange(0, remainderRange.location)];
        if (remainderRange.location < [key length]-1)
        {
            remainderPath = [key substringFromIndex:remainderRange.location+1];
        }
        key = subkey;
    }

    return (__NSKeyPathComponents) { .key = key, .remainderPath = remainderPath };
}
