//
//  NSMapTable.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/NSMapTable.h>
#import <Foundation/NSDictionary.h>
#import "NSPointerFunctionsInternal.h"

CF_PRIVATE
@interface NSConcreteMapTable : NSMapTable
@end

@implementation NSMapTable

+ (id)allocWithZone:(NSZone *)zone
{
    if (self == [NSMapTable class])
    {
        return [NSConcreteMapTable allocWithZone:zone];
    }
    else
    {
        return [super allocWithZone:zone];
    }
}

+ (id)mapTableWithKeyOptions:(NSPointerFunctionsOptions)keyOptions valueOptions:(NSPointerFunctionsOptions)valueOptions
{
    return [[[self alloc] initWithKeyOptions:keyOptions valueOptions:valueOptions capacity:0] autorelease];
}

+ (id)strongToStrongObjectsMapTable
{

    return [[[self alloc] initWithKeyOptions:NSPointerFunctionsStrongMemory | NSPointerFunctionsObjectPersonality
                                valueOptions:NSPointerFunctionsStrongMemory | NSPointerFunctionsObjectPersonality
                                    capacity:0] autorelease];
}

+ (id)weakToStrongObjectsMapTable
{

    return [[[self alloc] initWithKeyOptions:NSPointerFunctionsWeakMemory | NSPointerFunctionsObjectPersonality
                                valueOptions:NSPointerFunctionsStrongMemory | NSPointerFunctionsObjectPersonality
                                    capacity:0] autorelease];
}

+ (id)strongToWeakObjectsMapTable
{
    return [[[self alloc] initWithKeyOptions:NSPointerFunctionsStrongMemory | NSPointerFunctionsObjectPersonality
                                valueOptions:NSPointerFunctionsWeakMemory | NSPointerFunctionsObjectPersonality
                                    capacity:0] autorelease];
}

+ (id)weakToWeakObjectsMapTable
{
    return [[[self alloc] initWithKeyOptions:NSPointerFunctionsWeakMemory | NSPointerFunctionsObjectPersonality
                                valueOptions:NSPointerFunctionsWeakMemory | NSPointerFunctionsObjectPersonality
                                    capacity:0] autorelease];
}

- (id)initWithKeyOptions:(NSPointerFunctionsOptions)keyOptions valueOptions:(NSPointerFunctionsOptions)valueOptions capacity:(NSUInteger)initialCapacity
{
    NSRequestConcreteImplementation();
    [self release];
    return nil;
}

- (id)initWithKeyPointerFunctions:(NSPointerFunctions *)keyFunctions valuePointerFunctions:(NSPointerFunctions *)valueFunctions capacity:(NSUInteger)initialCapacity
{
    NSRequestConcreteImplementation();
    [self release];
    return nil;
}

- (NSPointerFunctions *)keyPointerFunctions
{
    NSRequestConcreteImplementation();
    return nil;
}

- (NSPointerFunctions *)valuePointerFunctions
{
    NSRequestConcreteImplementation();
    return nil;
}

- (id)objectForKey:(id)aKey
{
    NSRequestConcreteImplementation();
    return nil;
}

- (void)removeObjectForKey:(id)aKey
{
    NSRequestConcreteImplementation();
}

- (void)setObject:(id)anObject forKey:(id)aKey
{
    NSRequestConcreteImplementation();
}

- (NSUInteger)count
{
    NSRequestConcreteImplementation();
    return 0;
}

- (NSEnumerator *)keyEnumerator
{
    NSRequestConcreteImplementation();
    return nil;
}

- (NSEnumerator *)objectEnumerator
{
    NSRequestConcreteImplementation();
    return nil;
}

- (void)removeAllObjects
{
    NSRequestConcreteImplementation();
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])buffer count:(NSUInteger)len
{
    NSRequestConcreteImplementation();
    return 0;
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    for (id key in self)
    {
        [dictionary setObject:[self objectForKey:key] forKey:key];
    }
    return [dictionary autorelease];
}

/*!
@bug    This is backwards on iOS...
*/
- (id)copyWithZone:(NSZone *)zone
{
    return [self copy];
}

@end

@implementation NSConcreteMapTable
{
    struct NSSlice keys;
    struct NSSlice values;
    NSUInteger count;
    NSUInteger capacity;
    NSPointerFunctionsOptions keyOptions;
    NSPointerFunctionsOptions valueOptions;
    NSUInteger mutations;
    int32_t growLock;
    BOOL shouldRehash;
}

- (id)initWithKeyOptions:(NSPointerFunctionsOptions)keyOpts valueOptions:(NSPointerFunctionsOptions)valOpts capacity:(NSUInteger)initialCapacity
{
    self = [super init];
    if (self)
    {
        if (initialCapacity == 0)
        {
            capacity = 31;
        }
        else
        {
            capacity = initialCapacity;
        }

        count = 0;

        keyOptions = keyOpts;
        valueOptions = valOpts;

        mutations = 0;

        [NSConcretePointerFunctions initializeSlice:&keys withOptions:keyOpts];
        [NSConcretePointerFunctions initializeSlice:&values withOptions:valOpts];

        keys.items = keys.allocateFunction(keys.sizeFunction(NULL) * capacity);
        if (keys.items == NULL)
        {
            // [NSException raise:]
            [self release];
            return nil;
        }
        values.items = values.allocateFunction(values.sizeFunction(NULL) * capacity);
    }
    return self;
}
@end
