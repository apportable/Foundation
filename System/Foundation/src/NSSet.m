//
//  NSSet.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/NSSet.h>

#import <Foundation/NSArray.h>
#import <Foundation/NSException.h>
#import <Foundation/NSKeyedArchiver.h>
#import <Foundation/NSString.h>

#import <CoreFoundation/CFBag.h>

#import "NSCoderInternal.h"
#import "NSFastEnumerationEnumerator.h"
#import "NSKeyValueCodingInternal.h"
#import "NSObjectInternal.h"

@interface NSSet ()
- (NSUInteger)countForObject:(id)obj;
@end

CF_EXPORT NSUInteger _CFBagFastEnumeration(CFBagRef hc, NSFastEnumerationState *state, id __unsafe_unretained stackbuffer[], NSUInteger count);


@implementation NSSet (NSSet)

OBJC_PROTOCOL_IMPL_PUSH
- (id)initWithCoder:(NSCoder *)coder
{
    NSUInteger count = 0;
    id *objects = NULL;
    if ([coder allowsKeyedCoding])
    {
        if (![coder isKindOfClass:[NSXPCCoder class]])
        {
            return [self initWithArray:[coder _decodeArrayOfObjectsForKey:NS_objects]];
        }
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
            }
            object = [coder decodeObjectForKey:[NSString stringWithFormat:@"NS.object.%d", index]];
            if (object != nil)
            {
                objects[index] = object;
                index++;
            }
            count = index;
        } while (object != nil);
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
            [coder decodeValueOfObjCType:@encode(id) at:&objects[idx]];
        }
    }

    NSSet *set = nil;
    if (objects != NULL)
    {
        set = [self initWithObjects:objects count:count];
        free(objects);
    }
    return set;

}

- (void)encodeWithCoder:(NSCoder *)coder
{
    NSUInteger count = [self count];
    if ([coder allowsKeyedCoding])
    {
        if ([coder class] == [NSKeyedArchiver class])
        {
            [coder _encodeArrayOfObjects:[self allObjects] forKey:NS_objects];
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

@end


@implementation NSSet(NSKeyValueCoding)

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
#warning TODO https://code.google.com/p/apportable/issues/detail?id=267
    NSUInteger count = 0;
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

- (id)_distinctUnionOfObjectsForKeyPath:(id)keyPath
{
    NSMutableSet *resultSet=[NSMutableSet set];

    id anObj = nil;
    NSEnumerator *enumerator = [self objectEnumerator];
    while ((anObj = [enumerator nextObject]) != NULL)
    {
#warning TODO https://code.google.com/p/apportable/issues/detail?id=268
        id aValue = [anObj valueForKey:keyPath];
        if (aValue)
        {
            [resultSet addObject:aValue];
        }
    }
    return resultSet;
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
#warning TODO https://code.google.com/p/apportable/issues/detail?id=265
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"argument is not an NSSet" userInfo:nil];
            return nil;
        }
        NSSet *aSet = [anObj _distinctUnionOfObjectsForKeyPath:keyPath];
        for (id aValue in aSet)
        {
            [resultSet addObject:aValue];
        }
    }
    return resultSet;
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
#warning TODO https://code.google.com/p/apportable/issues/detail?id=265
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"argument is not an NSArray or NSSet" userInfo:nil];
            return nil;
        }
        NSSet *aSet = [anObj _distinctUnionOfObjectsForKeyPath:keyPath];
        for (id aValue in aSet)
        {
            [resultSet addObject:aValue];
        }
    }
    return resultSet;
}

- (id)valueForKey:(id)key
{
    NSMutableSet *resultSet = [NSMutableSet set];
    NSEnumerator *enumerator = [self objectEnumerator];
    id anObj = nil;
    while ((anObj = [enumerator nextObject]))
    {
        [resultSet addObject:[anObj valueForKey:key]];
    }
    return resultSet;
}

- (id)valueForKeyPath:(id)aKeyPath
{
#warning TODO https://code.google.com/p/apportable/issues/detail?id=265
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
#warning TODO https://code.google.com/p/apportable/issues/detail?id=265
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
        case NSUnionOfArraysKeyValueOperatorType:
        case NSUnionOfSetsKeyValueOperatorType:
        default:
        {
            // fall through
        }
    }

#warning TODO https://code.google.com/p/apportable/issues/detail?id=265
    @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"this class does not implement the '%@' operation", key] userInfo:nil];
    return nil;
}

@end

@implementation NSCountedSet {
    CFMutableBagRef _table;
    void *_reserved;
}

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (id)initWithCapacity:(NSUInteger)numItems
{
    self = [super init];
    if (self)
    {
        _table = CFBagCreateMutable(kCFAllocatorDefault, numItems, &kCFTypeBagCallBacks);
    }
    return self;
}

- (id)initWithArray:(NSArray *)array
{
    return [super initWithArray:array];
}

- (id)initWithSet:(NSSet *)set
{
    return [super initWithSet:set];
}

- (id)initWithSet:(NSSet *)set copyItems:(BOOL)shouldCopy
{
    self = [self initWithCapacity:[set count]];
    if (self)
    {
        NSEnumerator *enumerator = [set objectEnumerator];
        id obj = nil;
        while (obj = [enumerator nextObject])
        {
            NSUInteger count = [set countForObject:obj];
            id objToInsert;
            if (shouldCopy)
            {
                objToInsert = [obj copy];
            }
            else
            {
                objToInsert = [obj retain];
            }
            for (NSUInteger i = 0; i < count; i++)
            {
                [self addObject:objToInsert];
            }
            [objToInsert release];
        }
    }
    return self;
}

- (id)initWithObjects:(const id [])objects count:(NSUInteger)count
{
    self = [self initWithCapacity:count];
    if (self)
    {
        for (NSUInteger idx = 0; idx < count; idx++)
        {
            id obj = objects[idx];
            if (obj == NULL)
            {
                [NSException raise:NSInvalidArgumentException format:@"attempting to insert nil into NSCountedSet"];
                [self release];
                return nil;
            }
            [self addObject:obj];
        }
    }
    return self;
}

- (id)init
{
    return [self initWithCapacity:0];
}

- (Class)classForCoder
{
    return [NSCountedSet class];
}

- (void)dealloc
{
    if (_table != NULL)
    {
        CFRelease(_table);
    }

    [super dealloc];
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    return [[NSCountedSet alloc] initWithSet:self copyItems:NO];
}

- (id)copyWithZone:(NSZone *)zone
{
    // very sneaky ... immutable copy is mutable!
    return [[NSCountedSet alloc] initWithSet:self copyItems:NO];
}

- (NSUInteger)countForObject:(id)object
{
    if (object == nil)
    {
        return 0;
    }
    return CFBagGetCountOfValue(_table, object);
}

- (NSEnumerator *)objectEnumerator
{
    return [[[__NSFastEnumerationEnumerator alloc] initWithObject:self] autorelease];
}

- (void)addObject:(id)object
{
    if (object == nil)
    {
        [NSException raise:NSInvalidArgumentException format:@"attempt to insert nil object into NSCountedSet"];
        return;
    }

    CFBagAddValue(_table, object);
}

- (void)removeObject:(id)object
{
    if (object == nil)
    {
        [NSException raise:NSInvalidArgumentException format:@"attempt to remove nil object into NSCountedSet"];
        return;
    }

    CFBagRemoveValue(_table, object);
}

- (void)getObjects:(id *)objects count:(NSUInteger)count
{
    NSFastEnumerationState state = { 0 };
    [self countByEnumeratingWithState:&state objects:objects count:count];
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])buffer count:(NSUInteger)len
{

    return _CFBagFastEnumeration(_table, state, buffer, len);
}

- (id)member:(id)object
{
    id found =  nil;

    if (object != nil)
    {
        found = CFBagGetValue(_table, object);
    }

    return found;
}

- (NSUInteger)count
{
/*
    you would think this is how it works... but that is not how it is done?
    return CFBagGetCount(_table);
*/
    NSUInteger objectCount = 0;

    for (id object __attribute((unused)) in self)
    {
        objectCount++;
    }

    return objectCount;
}

@end
