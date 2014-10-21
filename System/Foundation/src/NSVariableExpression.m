//
//  NSVariableExpression.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "NSExpressionInternal.h"

#import "_NSPredicateUtilities.h"
#import <Foundation/NSDictionary.h>
#import <Foundation/NSNull.h>
#import <Foundation/NSString.h>

static NSString * const NSVariableKey = @"NSVariable";

@implementation NSVariableExpression
{
    NSString *_variable;
}

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (void)dealloc
{
    [_variable release];
    [super dealloc];
}

- (id)initWithObject:(id)object
{
    self = [super initWithExpressionType:NSVariableExpressionType];
    if (self != nil)
    {
        _variable = [(NSString *)object retain];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    return [[[self class] alloc] initWithObject:_variable];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if (!_NSPredicateKeyedArchiverCheck(decoder))
    {
        [self release];
        return nil;
    }

    self = [super initWithCoder:decoder];
    if (self != nil)
    {
        _variable = [[decoder decodeObjectForKey:NSVariableKey] retain];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    if (!_NSPredicateKeyedArchiverCheck(coder))
    {
        return;
    }

    [super encodeWithCoder:coder];
    [coder encodeObject:[self variable] forKey:NSVariableKey];
}

- (NSUInteger)hash
{
    return [_variable hash];
}

- (BOOL)isEqual:(id)other
{
    if (self == other)
    {
        return YES;
    }
    if (![other isKindOfClass:[NSVariableExpression self]])
    {
        return NO;
    }
    return [_variable isEqualToString:[other variable]];
}

- (NSString *)variable
{
    return _variable;
}

- (NSString *)predicateFormat
{
    NSString *variable = [self variable];

    if ([_NSPredicateUtilities _isReservedWordInParser:variable])
    {
        return [NSString stringWithFormat:@"$#%@", variable];
    }
    else
    {
        return [NSString stringWithFormat:@"$%@", variable];
    }
}

- (NSExpression *)_expressionWithSubstitutionVariables:(NSDictionary *)variables
{
    if (!_NSPredicateSubstitutionCheck(variables))
    {
        return nil;
    }

    id value = [variables objectForKey:[self variable]];

    if (value == nil)
    {
        return nil;
    }

    if (value == [NSNull null] || ![value isKindOfClass:[NSExpression class]])
    {
        return [NSExpression expressionForConstantValue:nil];
    }

    return value;
}

- (id)expressionValueWithObject:(id)object context:(NSMutableDictionary *)context
{
    if (!_NSExpressionEvaluationCheck(self))
    {
        return nil;
    }

    id value = [context objectForKey:[self variable]];

    if (value == nil)
    {
        [NSException raise:NSInvalidArgumentException format:@"Cannot evaluate unbound variable %@", [self variable]];
        return nil;
    }

    if (value == [NSNull null])
    {
        return nil;
    }

    if ([value isKindOfClass:[NSExpression class]])
    {
        return [value expressionValueWithObject:object context:context];
    }

    return value;
}

@end
