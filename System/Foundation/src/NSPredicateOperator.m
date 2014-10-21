//
//  NSPredicateOperator.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "NSPredicateOperator.h"

#import "NSBetweenPredicateOperator.h"
#import "NSComparisonPredicateOperator.h"
#import "NSCustomPredicateOperator.h"
#import "NSEqualityPredicateOperator.h"
#import "NSInPredicateOperator.h"
#import "NSLikePredicateOperator.h"
#import "NSMatchingPredicateOperator.h"
#import "NSObjectInternal.h"
#import "NSPredicateInternal.h"
#import "NSSubstringPredicateOperator.h"
#import "NSTokenMatchingPredicateOperator.h"

#import <Foundation/NSNull.h>

@implementation NSPredicateOperator
{
    NSPredicateOperatorType _operatorType;
    NSComparisonPredicateModifier _modifier;
}

static NSString * const NSOperatorTypeKey = @"NSOperatorType";
static NSString * const NSModifierKey = @"NSModifier";

static NSString * const NSGreaterThanSymbol = @">";
static NSString * const NSGreaterThanOrEqualSymbol = @">=";
static NSString * const NSLessThanSymbol = @"<";
static NSString * const NSLessThanOrEqualSymbol = @"<=";
static NSString * const NSEqualSymbol = @"==";
static NSString * const NSNotEqualSymbol = @"!=";
static NSString * const NSInSymbol = @"IN";
static NSString * const NSBetweenSymbol = @"BETWEEN";
static NSString * const NSContainsSymbol = @"CONTAINS";

+ (BOOL)supportsSecureCoding
{
    return YES;
}

+ (id)operatorWithCustomSelector:(SEL)customSelector modifier:(NSComparisonPredicateModifier)modifier
{
    return [[[NSCustomPredicateOperator alloc] initWithCustomSelector:customSelector modifier:modifier] autorelease];
}

+ (id)_newOperatorWithType:(NSPredicateOperatorType)type modifier:(NSComparisonPredicateModifier)modifier options:(NSComparisonPredicateOptions)options
{
    switch ((NSUInteger)type)
    {
        case NSLessThanPredicateOperatorType:
        case NSLessThanOrEqualToPredicateOperatorType:
        case NSGreaterThanPredicateOperatorType:
        case NSGreaterThanOrEqualToPredicateOperatorType:
            return [[NSComparisonPredicateOperator alloc] initWithOperatorType:type modifier:modifier variant:type options:options];
        case NSEqualToPredicateOperatorType:
            return [[NSEqualityPredicateOperator alloc] initWithOperatorType:type modifier:modifier negate:NO options:options];
        case NSNotEqualToPredicateOperatorType:
            return [[NSEqualityPredicateOperator alloc] initWithOperatorType:type modifier:modifier negate:YES options:options];
        case NSMatchesPredicateOperatorType:
            return [[NSMatchingPredicateOperator alloc] initWithOperatorType:type modifier:modifier variant:options];
        case NSLikePredicateOperatorType:
            return [[NSLikePredicateOperator alloc] initWithOperatorType:type modifier:modifier variant:options];
        case NSBeginsWithPredicateOperatorType:
            return [[NSSubstringPredicateOperator alloc] initWithOperatorType:type modifier:modifier variant:options position:NSSubstringBeginsWith];
        case NSEndsWithPredicateOperatorType:
            return [[NSSubstringPredicateOperator alloc] initWithOperatorType:type modifier:modifier variant:options position:NSSubstringEndsWith];
        case NSInPredicateOperatorType:
            return [[NSInPredicateOperator alloc] initWithOperatorType:type modifier:modifier options:options];
        case NSContainsPredicateOperatorType:
            return [[NSInPredicateOperator alloc] initWithOperatorType:type modifier:modifier options:options];
        case NSBetweenPredicateOperatorType:
            return [[NSBetweenPredicateOperator alloc] initWithOperatorType:type modifier:modifier options:options];
        case NSTokenMatchingPredicateOperatorType:
            return [[NSTokenMatchingPredicateOperator alloc] initWithOperatorType:type modifier:modifier variant:options];
        case NSCustomSelectorPredicateOperatorType:
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Bad predicate operator type: %ld", (long)type];
            return nil;
    }
}

+ (id)operatorWithType:(NSPredicateOperatorType)type modifier:(NSComparisonPredicateModifier)modifier options:(NSComparisonPredicateOptions)options
{
    return [[self _newOperatorWithType:type modifier:modifier options:options] autorelease];
}

+ (SEL)_getSelectorForType:(NSPredicateOperatorType)type
{
    switch (type)
    {
        case NSEqualToPredicateOperatorType:
        case NSNotEqualToPredicateOperatorType:
            return @selector(isEqual:);
        case NSInPredicateOperatorType:
        case NSContainsPredicateOperatorType:
            return @selector(containsObject:);
        case NSLessThanPredicateOperatorType:
        case NSLessThanOrEqualToPredicateOperatorType:
        case NSGreaterThanPredicateOperatorType:
        case NSGreaterThanOrEqualToPredicateOperatorType:
        case NSBetweenPredicateOperatorType:
            return @selector(compare:);
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Bad predicate operator type: %ld", (long)type];
            return NULL;
    }
}

+ (id)_getSymbolForType:(NSPredicateOperatorType)type
{
    switch (type)
    {
        case NSLessThanPredicateOperatorType:
            return NSLessThanSymbol;
        case NSLessThanOrEqualToPredicateOperatorType:
            return NSLessThanOrEqualSymbol;
        case NSGreaterThanPredicateOperatorType:
            return NSGreaterThanSymbol;
        case NSGreaterThanOrEqualToPredicateOperatorType:
            return NSGreaterThanOrEqualSymbol;
        case NSEqualToPredicateOperatorType:
            return NSEqualSymbol;
        case NSNotEqualToPredicateOperatorType:
            return NSNotEqualSymbol;
        case NSInPredicateOperatorType:
            return NSInSymbol;
        case NSContainsPredicateOperatorType:
            return NSContainsSymbol;
        case NSBetweenPredicateOperatorType:
            return NSBetweenSymbol;
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Bad predicate operator type: %ld", (long)type];
            return nil;
    }
}

- (id)initWithOperatorType:(NSPredicateOperatorType)type modifier:(NSComparisonPredicateModifier)modifier
{
    self = [super init];
    if (self != nil)
    {
        _operatorType = type;
        _modifier = modifier;
    }
    return self;
}

- (id)initWithOperatorType:(NSPredicateOperatorType)type modifier:(NSComparisonPredicateModifier)modifier options:(NSComparisonPredicateOptions)options
{
    return [self initWithOperatorType:type modifier:modifier];
}

- (id)initWithOperatorType:(NSPredicateOperatorType)type
{
    return [self initWithOperatorType:type modifier:NSDirectPredicateModifier];
}

- (void)_setModifier:(NSComparisonPredicateModifier)modifier
{
    _modifier = modifier;
}

- (NSComparisonPredicateOptions)options
{
    return 0;
}

- (void)_setOptions:(NSComparisonPredicateOptions)options
{
    NSRequestConcreteImplementation();
}

- (void)acceptVisitor:(id)visitor flags:(NSPredicateVisitorFlags)flags
{
    if ((flags & NSPredicateVisitorVisitOperators) != 0)
    {
        [visitor visitPredicateOperator:self];
    }
}

- (BOOL)performOperationUsingObject:(id)lhs andObject:(id)rhs
{
    if (lhs == [NSNull null])
    {
        lhs = nil;
    }
    if (rhs == [NSNull null])
    {
        rhs = nil;
    }

    if (_modifier == NSDirectPredicateModifier)
    {
        return [self performPrimitiveOperationUsingObject:lhs andObject:rhs];
    }

    if (lhs == nil)
    {
        switch (_modifier)
        {
        case NSAllPredicateModifier:
            return YES;
        case NSAnyPredicateModifier:
            return NO;
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Bad predicate operator modifier: %ld", (long)_modifier];
            return NO;
        }
    }

    NSArray *leftArray;
    if ([lhs isNSArray__])
    {
        leftArray = lhs;
    }
    else if ([lhs isNSSet__])
    {
        leftArray = [lhs allObjects];
    }
    else if ([lhs isNSOrderedSet__])
    {
        leftArray = [lhs array];
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"left hand expression must be an array, set, or ordered set"];
        return NO;
    }

    switch (_modifier)
    {
        case NSAllPredicateModifier:
            for (id obj in leftArray)
            {
                if (![self performPrimitiveOperationUsingObject:obj andObject:rhs])
                {
                    return NO;
                }
            }
            return YES;
        case NSAnyPredicateModifier:
            for (id obj in leftArray)
            {
                if ([self performPrimitiveOperationUsingObject:obj andObject:rhs])
                {
                    return YES;
                }
            }
            return NO;
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Bad predicate operator modifier: %ld", (long)_modifier];
            return NO;
    }
}

- (BOOL)performPrimitiveOperationUsingObject:(id)lhs andObject:(id)rhs
{
    NSRequestConcreteImplementation();
    return NO;
}

- (NSUInteger)hash
{
    NSUInteger selectorHash = [NSStringFromSelector([self selector]) hash];
    NSUInteger classHash = [[self class] hash];

    return selectorHash ^ classHash;
}

- (BOOL)isEqual:(id)other
{
    if (self == other)
    {
        return YES;
    }
    if (![other isKindOfClass:[NSPredicateOperator self]])
    {
        return NO;
    }
    if (_operatorType != [other operatorType])
    {
        return NO;
    }
    if (_modifier != [other modifier])
    {
        return NO;
    }
    return YES;
}

- (NSComparisonPredicateModifier)modifier
{
    return _modifier;
}

- (NSString *)symbol
{
    return [NSPredicateOperator _getSymbolForType:_operatorType];
}

- (NSPredicateOperatorType)operatorType
{
    return _operatorType;
}

- (SEL)selector
{
    return [NSPredicateOperator _getSelectorForType:_operatorType];
}

- (NSString *)description
{
    return [self predicateFormat];
}

- (NSString *)predicateFormat
{
    return [self symbol];
}

- (id)copyWithZone:(NSZone *)zone
{
    NSRequestConcreteImplementation();
    return nil;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if (!_NSPredicateKeyedArchiverCheck(decoder))
    {
        [self release];
        return nil;
    }

    NSPredicateOperatorType type = [decoder decodeIntegerForKey:NSOperatorTypeKey];
    NSComparisonPredicateModifier modifier = [decoder decodeIntegerForKey:NSModifierKey];

    return [self initWithOperatorType:type modifier:modifier];
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    if (!_NSPredicateKeyedArchiverCheck(coder))
    {
        return;
    }

    [coder encodeInteger:_operatorType forKey:NSOperatorTypeKey];
    [coder encodeInteger:_modifier forKey:NSModifierKey];
}

@end
