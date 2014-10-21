//
//  NSValueTransformer.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/NSValueTransformer.h>

#import <Foundation/NSArray.h>
#import <Foundation/NSData.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSException.h>
#import <Foundation/NSKeyedArchiver.h>
#import <Foundation/NSValue.h>

#import <dispatch/dispatch.h>
#import <libkern/OSAtomic.h>

#import "NSArchiver.h"

@interface _NSSharedValueTransformer : NSValueTransformer
@end

CF_PRIVATE
@interface _NSNegateBooleanTransformer : _NSSharedValueTransformer
@end

CF_PRIVATE
@interface _NSIsNilTransformer : _NSNegateBooleanTransformer
@end

CF_PRIVATE
@interface _NSIsNotNilTransformer : _NSNegateBooleanTransformer
@end

CF_PRIVATE
@interface _NSKeyedUnarchiveFromDataTransformer : _NSSharedValueTransformer
@end

CF_PRIVATE
@interface _NSUnarchiveFromDataTransformer : _NSSharedValueTransformer
@end

NSString *const NSNegateBooleanTransformerName = @"NSNegateBoolean";
NSString *const NSIsNilTransformerName = @"NSIsNil";
NSString *const NSIsNotNilTransformerName = @"NSIsNotNil";
NSString *const NSUnarchiveFromDataTransformerName = @"NSUnarchiveFromData";
NSString *const NSKeyedUnarchiveFromDataTransformerName = @"NSKeyedUnarchiveFromData";

@implementation NSValueTransformer

static OSSpinLock registryLock = OS_SPINLOCK_INIT;

+ (NSMutableDictionary *)_transformerRegistry
{
    static NSMutableDictionary *transformerRegistry = nil;
    static dispatch_once_t once = 0L;
    dispatch_once(&once, ^{
        transformerRegistry = [[NSMutableDictionary alloc] init];
        [transformerRegistry setObject:[_NSNegateBooleanTransformer new] forKey:NSNegateBooleanTransformerName];
        [transformerRegistry setObject:[_NSIsNilTransformer new] forKey:NSIsNilTransformerName];
        [transformerRegistry setObject:[_NSIsNotNilTransformer new] forKey:NSIsNotNilTransformerName];
        [transformerRegistry setObject:[_NSUnarchiveFromDataTransformer new] forKey:NSUnarchiveFromDataTransformerName];
        [transformerRegistry setObject:[_NSKeyedUnarchiveFromDataTransformer new] forKey:NSKeyedUnarchiveFromDataTransformerName];
    });
    return transformerRegistry;
}

+ (void)setValueTransformer:(NSValueTransformer *)transformer forName:(NSString *)name
{
    if (name == nil)
    {
        [NSException raise:NSInvalidArgumentException format:@"transformer name cannot be nil"];
        return;
    }
    OSSpinLockLock(&registryLock);
    [[self _transformerRegistry] setObject:transformer forKey:name];
    OSSpinLockUnlock(&registryLock);
}

+ (NSValueTransformer *)valueTransformerForName:(NSString *)name
{
    if (name == nil)
    {
        return nil;
    }

    OSSpinLockLock(&registryLock);
    NSMutableDictionary *registry = [self _transformerRegistry];
    NSValueTransformer *transformer = [[registry objectForKey:name] retain];
    if (transformer == nil)
    {
        Class cls = NSClassFromString(name);
        if (cls != nil)
        {
            transformer = (NSValueTransformer *)[[cls alloc] init];
            [registry setObject:transformer forKey:name];
        }
    }
    OSSpinLockUnlock(&registryLock);
    return [transformer autorelease];
}

+ (NSArray *)valueTransformerNames
{
    NSArray *keys = nil;
    OSSpinLockLock(&registryLock);
    keys = [[[self _transformerRegistry] allKeys] retain];
    OSSpinLockUnlock(&registryLock);
    return [keys autorelease];
}

+ (Class)transformedValueClass
{
    return Nil;
}

+ (BOOL)allowsReverseTransformation
{
    return YES;
}

- (id)transformedValue:(id)value
{
    return value;
}

- (id)reverseTransformedValue:(id)value
{
    return value;
}

@end

@implementation _NSSharedValueTransformer

- (BOOL)_isBooleanTransformer
{
    return NO;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)copy
{
    return self;
}

- (BOOL)_tryRetain
{
    return YES;
}

- (BOOL)_isDeallocating
{
    return NO;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-missing-super-calls"
- (oneway void)release
{

}
#pragma clang diagnostic pop

- (id)autorelease
{
    return self;
}

- (id)retain
{
    return self;
}

@end

@implementation _NSNegateBooleanTransformer

+ (Class)transformedValueClass
{
    return [NSNumber class];
}

- (BOOL)_isBooleanTransformer
{
    return YES;
}

- (id)description
{
    return @"<shared NSNegateBoolean transformer>";
}

- (id)transformedValue:(id)value
{
    BOOL val = [(NSNumber *)value boolValue];
    return [NSNumber numberWithBool:!val];
}

@end

@implementation _NSIsNilTransformer

+ (BOOL)supportsReverseTransformation
{
    return NO;
}

- (id)description
{
    return @"<shared NSIsNil transformer>";
}

- (id)transformedValue:(id)value
{
    return [NSNumber numberWithBool:value == nil];
}

@end

@implementation _NSIsNotNilTransformer

+ (BOOL)supportsReverseTransformation
{
    return NO;
}

- (id)description
{
    return @"<shared NSIsNotNil transformer>";
}

- (id)transformedValue:(id)value
{
    return [NSNumber numberWithBool:value != nil];
}

@end

@implementation _NSKeyedUnarchiveFromDataTransformer

- (id)description
{
    return @"<shared NSKeyedUnarchiveFromData transformer>";
}

- (id)reverseTransformedValue:(id)value
{
    return [NSKeyedArchiver archivedDataWithRootObject:value];
}

- (id)transformedValue:(id)value
{
    if (value == nil)
    {
        return nil;
    }

    return [NSKeyedUnarchiver unarchiveObjectWithData:value];
}

@end

@implementation _NSUnarchiveFromDataTransformer

- (id)description
{
    return @"<shared NSUnarchiveFromData transformer>";
}

- (id)reverseTransformedValue:(id)value
{
    return [NSArchiver archivedDataWithRootObject:value];
}

- (id)transformedValue:(id)value
{
    if (value == nil)
    {
        return nil;
    }

    return [NSUnarchiver unarchiveObjectWithData:value];
}

@end
