//
//  NSInPredicateOperator.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "NSInPredicateOperator.h"

#import "NSSubstringPredicateOperator.h"

#import <Foundation/NSNull.h>
#import <pthread.h>

static NSString * NSFlagsKey = @"NSFlags";

@implementation NSInPredicateOperator
{
    NSComparisonPredicateOptions _flags;
    NSSubstringPredicateOperator * _stringVersion;
    pthread_mutex_t _mutex;
}

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (id)initWithOperatorType:(NSPredicateOperatorType)type modifier:(NSComparisonPredicateModifier)modifier options:(NSComparisonPredicateOptions)options
{
    self = [super initWithOperatorType:type modifier:modifier];
    if (self != nil)
    {
        pthread_mutex_init(&_mutex, NULL);
        [self _setOptions:options];
    }
    return self;
}

- (void)dealloc
{
    pthread_mutex_destroy(&_mutex);
    if (_stringVersion != nil)
    {
        [_stringVersion release];
    }
    [super dealloc];
}

- (NSComparisonPredicateOptions)options
{
    return _flags;
}

- (void)_setOptions:(NSComparisonPredicateOptions)options
{
    _flags = options & 0x1f;
}

- (BOOL)performPrimitiveOperationUsingObject:(id)lhs andObject:(id)rhs
{
    id container = nil;
    id object = nil;

    switch ([self operatorType])
    {
        case NSInPredicateOperatorType:
            object = lhs;
            container = rhs;
            break;
        case NSContainsPredicateOperatorType:
            object = rhs;
            container = lhs;
            break;
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Bad operator type for in predicate operator"];
            return NO;
    }

    if (object == nil || container == nil || container == [NSNull null])
    {
        return NO;
    }

    if ([container isNSString__])
    {
        if ([object isNSString__])
        {
            return [[self stringVersion] performPrimitiveOperationUsingObject:container andObject:object];
        }
        else
        {
            [NSException raise:NSInvalidArgumentException format:@"Cannot search for non-string %@ in string %@", object, container];
            return NO;
        }
    }

    if ([container isNSArray__] ||
        [container isNSOrderedSet__] ||
        [container isNSSet__])
    {
        return [container containsObject:object];
    }
    else if ([container isNSDictionary__])
    {
        return [[container allKeysForObject:object] count] != 0;
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Container %@ was not a valid container class", container];
        return NO;
    }
}

- (id)copyWithZone:(NSZone *)zone
{
    return [[self class] _newOperatorWithType:[self operatorType] modifier:[self modifier] options:_flags];
}

- (BOOL)isEqual:(id)other
{
    if (other == self)
    {
        return YES;
    }
    if (![other isKindOfClass:[NSInPredicateOperator self]])
    {
        return NO;
    }
    if ([other operatorType] != [self operatorType])
    {
        return NO;
    }
    if ([other modifier] != [self modifier])
    {
        return NO;
    }
    return [other flags] == [self flags];
}

- (NSComparisonPredicateOptions)flags
{
    return _flags;
}

- (NSString *)symbol
{
    NSString *desc;

    switch ((NSUInteger)[self operatorType])
    {
        case NSInPredicateOperatorType:
            desc = @"IN";
            break;
        case NSContainsPredicateOperatorType:
            desc = @"CONTAINS";
            break;
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Bad operator type in in predicate operator"];
            return nil;
    }

    return [NSString stringWithFormat:@"%@%@", desc, comparisonPredicateOptionDescription(_flags)];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self != nil)
    {
        _flags = [decoder decodeIntegerForKey:NSFlagsKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    [coder encodeInteger:_flags forKey:NSFlagsKey];
}

- (NSSubstringPredicateOperator *)stringVersion
{
    pthread_mutex_lock(&_mutex);
    if (_stringVersion == nil)
    {
        NSPredicateOperatorType type = [self operatorType];
        NSComparisonPredicateModifier modifier = [self modifier];
        _stringVersion = [[NSSubstringPredicateOperator alloc] initWithOperatorType:type modifier:modifier variant:_flags position:NSSubstringContains];
    };
    pthread_mutex_unlock(&_mutex);

    return _stringVersion;
}

@end
