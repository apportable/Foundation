//
//  NSArray.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/NSArray.h>
#import <Foundation/NSString.h>
#import "NSCoderInternal.h"
#import <Foundation/NSException.h>
#import <Foundation/NSData.h>
#import "NSKeyValueCodingInternal.h"
#import "NSObjectInternal.h"
#import <stdlib.h>
#import <Foundation/NSKeyedArchiver.h>

CF_EXPORT CFTypeRef _CFPropertyListCreateFromXMLData(CFAllocatorRef allocator, CFDataRef xmlData, CFOptionFlags option, CFStringRef *errorString, Boolean allNewTypes, CFPropertyListFormat *format);

@implementation NSArray (NSArray)

+ (id)newWithContentsOf:(id)pathOrURL immutable:(BOOL)immutable
{
    NSData *xmlData = nil;
    if ([pathOrURL isNSString__])
    {
        xmlData = [[NSData alloc] initWithContentsOfFile:pathOrURL];
    }
    else // it doesnt seem to test if it is a url, just if it is a string
    {
        xmlData = [[NSData alloc] initWithContentsOfURL:pathOrURL];
    }
    CFPropertyListFormat format;
    CFStringRef errorString = NULL;
    id array = (id)_CFPropertyListCreateFromXMLData(kCFAllocatorDefault, (CFDataRef)xmlData, immutable ? kCFPropertyListImmutable : kCFPropertyListMutableContainers, &errorString, true, &format);
    if (errorString != NULL)
    {
        CFRelease(errorString);
    }
    [xmlData release];
    if (![array isNSArray__])
    {
        [array release];
        return nil;
    }
    return array;
}

OBJC_PROTOCOL_IMPL_PUSH
- (id)initWithCoder:(NSCoder *)coder
{
#warning TODO: Fix fault cases to replicate behavior
    NSUInteger count = 0;
    id *objects = NULL;
    if ([coder allowsKeyedCoding])
    {
        if (![coder isKindOfClass:[NSXPCCoder class]])
        {
            // note: self could be mutable
            return [self initWithArray:[coder _decodeArrayOfObjectsForKey:NS_objects]];
        }
        else
        {
            NSUInteger capacity = 31;
            NSUInteger index = 0;
            id object = nil;
            objects = malloc(capacity * sizeof(id));
            if (objects == NULL)
            {
                [self release];
                [NSException raise:NSMallocException format:@"Could not allocate buffer"];
                return nil;
            }
            do {
                if (count > capacity)
                {
                    capacity *= 2;
                    id *newObjects = realloc(objects, capacity * sizeof(id));
                    if (newObjects == NULL)
                    {
                        free(objects);
                        [self release];
                        [NSException raise:NSMallocException format:@"Could not allocate buffer"];
                        return nil;
                    }
                    objects = newObjects;
                }
                object = [coder decodeObjectForKey:[NSString stringWithFormat:@"NS.object.%d", index]];
                // NS.object.# being nil signifies the end of the list
                if (object != nil)
                {
                    objects[index] = object;
                    index++;
                }
                count = index;
            } while (object != nil);
        }
    }
    else
    {
        [coder decodeValueOfObjCType:@encode(int) at:&count];

        objects = malloc(count * sizeof(id));
        if (objects == NULL)
        {
            [self release];
            [NSException raise:NSMallocException format:@"Could not allocate buffer"];
            return nil;
        }
        for (NSUInteger idx = 0; idx < count; idx++)
        {
            id object = nil;
            [coder decodeValueOfObjCType:@encode(id) at:&object];
            if (object != nil)
            {
                objects[idx] = object;
            }
            else
            {
                // fault?
            }
        }
    }
    NSArray *array = nil;
    if (objects != NULL)
    {
        array = [self initWithObjects:objects count:count];
        free(objects);
    }
    return array;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    NSUInteger count = [self count];
    if ([coder allowsKeyedCoding])
    {
        if ([coder class] == [NSKeyedArchiver class])
        {
            [coder _encodeArrayOfObjects:self forKey:NS_objects];
        }
        else
        {
            for (id object in self)
            {
                [object encodeWithCoder:coder];
            }
        }
    }
    else if ([coder isKindOfClass:[NSXPCCoder class]])
    {
        NSUInteger idx = 0;
        for (id object in self)
        {
            [coder encodeObject:object forKey:[NSString stringWithFormat:@"NS.object.%d", idx]];
        }
    }
    else
    {
        [coder encodeValueOfObjCType:@encode(int) at:&count];
        NSEnumerator *enumerator = [self objectEnumerator];
        id object = [enumerator nextObject];
        while (object != nil)
        {
            [coder encodeBycopyObject:object];
            object = [enumerator nextObject];
        }
    }
}
OBJC_PROTOCOL_IMPL_POP

- (Class)classForCoder
{
    return [NSArray self];
}

@end


@implementation NSArray (NSKeyValueCoding)

- (id)_minForKeyPath:(id)keyPath
{
    return __NSMinOrMaxForKeyPath(keyPath, NSOrderedDescending, [self objectEnumerator]);
}

- (id)_maxForKeyPath:(id)keyPath
{
    return __NSMinOrMaxForKeyPath(keyPath, NSOrderedAscending, [self objectEnumerator]);
}

- (id)_avgForKeyPath:(id)keyPath
{
    NSUInteger count=0;
    NSNumber *val = __NSSumForKeyPath(keyPath, &count, [self objectEnumerator]);
    if (!count)
    {
        return nil;
    }
    return [NSNumber numberWithDouble:[val doubleValue]/count];
}

- (id)_sumForKeyPath:(id)keyPath
{
    return __NSSumForKeyPath(keyPath, nil, [self objectEnumerator]);
}

- (id)_countForKeyPath:(id)keyPath
{
    return [NSNumber numberWithUnsignedInteger:[self count]];
}

- (id)valueForKey:(id)key
{
    NSMutableArray *resultArray = [NSMutableArray array];
    NSEnumerator *enumerator = [self objectEnumerator];
    id anObj = nil;
    while ((anObj = [enumerator nextObject]))
    {
        [resultArray addObject:[anObj valueForKey:key]];
    }
    return resultArray;
}

- (id)_distinctUnionOfObjectsForKeyPath:(id)keyPath
{
    NSMutableSet *resultSet=[NSMutableSet set];

    id anObj = nil;
    NSEnumerator *enumerator = [self objectEnumerator];
    while ((anObj = [enumerator nextObject]) != NULL)
    {
#warning TODO: valueForKey or valueForKeyPath ?
        id aValue = [anObj valueForKey:keyPath];
        if (aValue)
        {
            [resultSet addObject:aValue];
        }
    }
    return [NSArray arrayWithArray:[resultSet allObjects]];
}

- (id)_distinctUnionOfSetsForKeyPath:(id)keyPath
{
    NSMutableSet *resultSet=[NSMutableSet set];
    NSEnumerator *enumerator = [self objectEnumerator];
    id anObj = nil;
    while ((anObj = [enumerator nextObject]) != NULL)
    {
        if (![anObj isKindOfClass:[NSSet class]])
        {
#warning TODO FIXME what should userInfo be?
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"argument is not an NSSet" userInfo:nil];
            return nil;
        }
        NSSet *aSet = [anObj _distinctUnionOfObjectsForKeyPath:keyPath];
        for (id aValue in aSet)
        {
            [resultSet addObject:aValue];
        }
    }
    return [NSArray arrayWithArray:[resultSet allObjects]];
}

- (id)_distinctUnionOfArraysForKeyPath:(id)keyPath
{
    NSMutableSet *resultSet = [NSMutableSet set];
    NSEnumerator *enumerator = [self objectEnumerator];
    id anObj = nil;
    while ((anObj = [enumerator nextObject]))
    {
        if (! ([anObj isKindOfClass:[NSArray class]] || [anObj isKindOfClass:[NSSet class]]) )
        {
#warning TODO FIXME what should userInfo be?
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"argument is not an NSArray or NSSet" userInfo:nil];
            return nil;
        }
        NSSet *aSet = [anObj _distinctUnionOfObjectsForKeyPath:keyPath];
        for (id aValue in aSet)
        {
            [resultSet addObject:aValue];
        }
    }
    return [NSArray arrayWithArray:[resultSet allObjects]];
}

- (id)valueForKeyPath:(id)aKeyPath
{
#warning KVO/KVC locking? ...
    if ([aKeyPath length] == 0 ||
        [aKeyPath characterAtIndex:0] != '@')
    {
        return [super valueForKeyPath:aKeyPath];
    }

    __NSKeyPathComponents components = __NSGetComponentsFromKeyPath(aKeyPath);
    NSString *key = components.key;
    NSString *remainderPath = components.remainderPath;

    // handle @operators

    __NSKVCOperatorType op = __NSKVCOperatorTypeFromKey(key);
    if ((op != NSCountKeyValueOperatorType) && !remainderPath)
    {
#warning TODO FIXME it seems that sometimes userInfo is != self ...
        @throw [NSException exceptionWithName:@"NSUnknownKeyException" reason:[NSString stringWithFormat:@"this class is not key value coding-compliant for the key '%@'", key] userInfo:nil];
        return nil;
    }

    switch (op)
    {
        case NSCountKeyValueOperatorType:
            return [self _countForKeyPath:key];
        case NSMinimumKeyValueOperatorType:
            return [self _minForKeyPath:remainderPath];
        case NSMaximumKeyValueOperatorType:
            return [self _maxForKeyPath:remainderPath];
        case NSAverageKeyValueOperatorType:
            return [self _avgForKeyPath:remainderPath];
        case NSSumKeyValueOperatorType:
            return [self _sumForKeyPath:remainderPath];
        case NSDistinctUnionOfObjectsKeyValueOperatorType:
            return [self _distinctUnionOfObjectsForKeyPath:remainderPath];
        case NSDistinctUnionOfArraysKeyValueOperatorType:
            return [self _distinctUnionOfArraysForKeyPath:remainderPath];
        case NSDistinctUnionOfSetsKeyValueOperatorType:
            return [self _distinctUnionOfSetsForKeyPath:remainderPath];
        case NSUnionOfObjectsKeyValueOperatorType:
            return [self _unionOfObjectsForKeyPath:remainderPath];
        case NSUnionOfArraysKeyValueOperatorType:
            return [self _unionOfArraysForKeyPath:remainderPath];
        default:
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"this class does not implement the '%@' operation", key] userInfo:nil];
            return nil;
    }
}

@end

@implementation NSMutableArray (NSMutableArray)

- (Class)classForCoder
{
    return [NSMutableArray self];
}

@end
