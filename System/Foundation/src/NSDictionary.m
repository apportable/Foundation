//
//  NSDictionary.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/NSDictionary.h>

#import <Foundation/NSArray.h>
#import "NSCoderInternal.h"
#import <Foundation/NSData.h>
#import "NSObjectInternal.h"
#import <Foundation/NSString.h>
#import "NSStringInternal.h"
#import "NSSharedKeySet.h"
#import "NSSharedKeyDictionary.h"
#import <Foundation/NSKeyedArchiver.h>

#import <CoreFoundation/CFData.h>
#import <CoreFoundation/CFBase.h>
#import <CoreFoundation/CFPropertyList.h>

#import <stdio.h>
#import <stdlib.h>

@implementation NSDictionary (NSDictionary)

+ (id)newWithContentsOf:(id)source immutable:(BOOL)immutable
{
    CFDataRef data = NULL;

    if ([source isNSString__])
    {
        data = (CFDataRef)[[NSData alloc] initWithContentsOfFile:source];
    }
    else
    {
        data = (CFDataRef)[[NSData alloc] initWithContentsOfURL:source];
    }

    if (data == nil)
    {
        return nil;
    }
    else
    {
        CFDictionaryRef plist = (CFDictionaryRef)CFPropertyListCreateWithData(kCFAllocatorDefault, data, immutable ? kCFPropertyListImmutable : kCFPropertyListMutableContainers, NULL, NULL);
        CFRelease(data);
        id dict = nil;
        if (immutable)
        {
            dict = [[NSDictionary alloc] initWithDictionary:(NSDictionary *)plist];
        }
        else
        {
            dict = [[NSMutableDictionary alloc] initWithDictionary:(NSMutableDictionary *)plist];
        }
        if (plist != nil)
        {
            CFRelease(plist);
        }
        return dict;
    }
}

OBJC_PROTOCOL_IMPL_PUSH
- (id)initWithCoder:(NSCoder *)coder
{
#warning TODO: Fix fault cases to replicate behavior
    NSUInteger count = 0;
    id *objects = NULL;
    id *keys = NULL;
    if ([coder allowsKeyedCoding])
    {
        if (![coder isKindOfClass:[NSXPCCoder class]])
        {
            NSArray *objectArray = [coder _decodeArrayOfObjectsForKey:NS_objects];
            NSArray *keyArray = [coder _decodeArrayOfObjectsForKey:NS_keys];
            count = [objectArray count];
            if (count != [keyArray count])
            {
                // Let this fault in initWithObjects:forKeys:?
            }
            if (objectArray == NULL || keyArray == NULL)
            {
                [self release];
                return nil;
            }
            else
            {
                return [self initWithObjects:objectArray forKeys:keyArray];
            }
        }
        else
        {
            NSUInteger capacity = 31;
            NSUInteger index = 0;
            objects = malloc(capacity * sizeof(id));
            keys = malloc(capacity * sizeof(id));
            if (objects == NULL || keys == NULL)
            {
                free(objects);
                free(keys);
                [self release];
                [NSException raise:NSMallocException format:@"Could not allocate buffer"];
                return nil;
            }
            id key = nil;
            id object = nil;
            do {

                if (index + 1 > capacity)
                {
                    capacity *= 2;
                    id *newObjects = realloc(objects, capacity * sizeof(id));
                    id *newKeys = realloc(keys, capacity * sizeof(id));
                    if (objects == NULL || keys == NULL)
                    {
                        free(objects);
                        free(keys);
                        free(newObjects);
                        free(newKeys);
                        [self release];
                        [NSException raise:NSMallocException format:@"Could not allocate buffer"];
                        return nil;
                    }
                }

                key = [coder decodeObjectForKey:[NSString stringWithFormat:@"NS.key.%d", index]];
                object = [coder decodeObjectForKey:[NSString stringWithFormat:@"NS.object.%d", index]];
                // NS.key.# and NS.object.# being nil signify the end of the list
                if (key != nil && object == nil)
                {
                    // fault?
                }
                else if (object != nil)
                {
                    objects[index] = object;
                    keys[index] = key;
                    index++;
                }
                count = index;
            } while (key != nil && object != nil);
        }
    }
    else
    {
        [coder decodeValueOfObjCType:@encode(int) at:&count];

        objects = malloc(count * sizeof(id));
        keys = malloc(count *sizeof(id));
        if (objects == NULL || keys == NULL)
        {
            free(objects);
            free(keys);
            [self release];
            [NSException raise:NSMallocException format:@"Could not allocate buffer"];
            return nil;
        }
        for (NSUInteger idx = 0; idx < count; idx++)
        {
            id key = nil;
            id object = nil;
            [coder decodeValueOfObjCType:@encode(id) at:&key];
            [coder decodeValueOfObjCType:@encode(id) at:&object];
            if (key == nil || object == nil)
            {
                // fault?
            }
            keys[idx] = key;
            objects[idx] = object;
        }
    }
    NSDictionary *dict = nil;
    if (objects != NULL && keys != NULL)
    {
        dict = [self initWithObjects:objects forKeys:keys count:count];
    }

    if (objects != NULL)
    {
        free(objects);
    }

    if (keys != NULL)
    {
        free(keys);
    }
    return dict;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
#warning TODO: Fix fault cases to replicate behavior
    NSUInteger count = [self count];
    if ([aCoder allowsKeyedCoding])
    {
        if ([aCoder class] == [NSKeyedArchiver class])
        {
            id *objects = malloc(count * sizeof(id));
            id *keys = malloc(count * sizeof(id));
            if (objects == NULL || keys == NULL)
            {
                free(objects);
                free(keys);
                [NSException raise:NSMallocException format:@"Could not allocate buffer"];
                return;
            }
            [self getObjects:objects andKeys:keys];

            NSArray *keyArray = [[NSArray alloc] initWithObjects:keys count:count];
            [aCoder _encodeArrayOfObjects:keyArray forKey:NS_keys];
            [keyArray release];
            free(keys);

            NSArray *objectArray = [[NSArray alloc] initWithObjects:objects count:count];
            [aCoder _encodeArrayOfObjects:objectArray forKey:NS_objects];
            [objectArray release];
            free(objects);
        }
        else
        {
            for (id object in self)
            {
                [object encodeWithCoder:aCoder];
            }
        }
    }
    else if ([aCoder isKindOfClass:[NSXPCCoder class]])
    {
        NSUInteger idx = 0;
        for (id key in self)
        {
            [aCoder encodeObject:key forKey:[NSString stringWithFormat:@"NS.key.%d", idx]];
            [aCoder encodeObject:[self objectForKey:key] forKey:[NSString stringWithFormat:@"NS.object.%d", idx]];
        }
    }
    else
    {
        [aCoder encodeValueOfObjCType:@encode(int) at:&count];
        NSEnumerator *enumerator = [self keyEnumerator];
        id key = [enumerator nextObject];
        while (key != nil)
        {
            [aCoder encodeBycopyObject:key];
            [aCoder encodeBycopyObject:[self objectForKey:key]];
            key = [enumerator nextObject];
        }
    }
}
OBJC_PROTOCOL_IMPL_POP

- (NSString *)descriptionInStringsFileFormat
{
    NSMutableString *description = [[NSMutableString alloc] init];
    NSEnumerator *enumerator = [self keyEnumerator];
    id key = [enumerator nextObject];
    while (key != nil)
    {
        [description appendFormat:@"%@ = %@;", [key quotedStringRepresentation], [(NSString *)[self objectForKey:key] quotedStringRepresentation]];
        key = [enumerator nextObject];
        if (key == nil)
        {
            [description appendString:@"\n"];
        }
    }
    NSString *desc = [description copy];
    [description release];
    return [desc autorelease];
}

@end

@implementation NSDictionary (NSKeyValueCoding)

- (id)valueForKeyPath:(id)idKeyPath
{
    if (!idKeyPath)
    {
        return nil;
    }

    NSString *key = [idKeyPath description];
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

    if (![key hasPrefix:@"@"])
    {
        id aVal = [self valueForKey:key];
        if (!remainderPath)
        {
            return aVal;
        }
        return [aVal valueForKeyPath:remainderPath];
    }

    // handle @operators

    if ([key isEqualToString:@"@count"])
    {
        if (remainderPath)
        {
            @throw [NSException exceptionWithName:@"NSInvalidArgumentException" reason:@"this class does not implement the count operation." userInfo:nil];
            return nil;
        }
        return [NSNumber numberWithUnsignedInteger:[self count]];
    }

    if (remainderPath)
    {
        @throw [NSException exceptionWithName:@"NSInvalidArgumentException" reason:[NSString stringWithFormat:@"this class does not implement the %@ operation.", key] userInfo:nil];
        return nil;
    }

#warning TODO : FIXME what is userInfo here?
    @throw [NSException exceptionWithName:@"NSUnknownKeyException" reason:[NSString stringWithFormat:@"this class is not key value coding-compliant for the key %@.", key] userInfo:self];
    return nil;
}

- (id)valueForKey:(id)key
{
    return [self objectForKey:key];
}

@end

@implementation NSMutableDictionary (NSKeyValueCoding)

- (void)setValue:(id)value forKey:(NSString *)key
{
    if (value) {
        [self setObject:value forKey:key];
    } else {
        [self removeObjectForKey:key];
    }
}

@end


@implementation NSDictionary (NSSharedKeySetDictionary)

+ (id)sharedKeySetForKeys:(NSArray *)keys
{
    if (keys == nil)
    {
        [NSException raise:NSInvalidArgumentException format:@"keys cannot be nil"];
        return nil;
    }
    if (![keys isNSArray__])
    {
        [NSException raise:NSInvalidArgumentException format:@"keys must be an array"];
        return nil;
    }
    return [NSSharedKeySet keySetWithKeys:keys];
}

@end

@implementation NSMutableDictionary (NSSharedKeySetDictionary)

+ (id)dictionaryWithSharedKeySet:(id)keyset
{
    return [NSSharedKeyDictionary sharedKeyDictionaryWithKeySet:keyset];
}

@end
