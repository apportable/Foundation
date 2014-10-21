//
//  NSTernaryExpression.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "NSExpressionInternal.h"

#import "_NSPredicateUtilities.h"

#import <Foundation/NSDictionary.h>
#import <Foundation/NSKeyedArchiver.h>

@implementation NSTernaryExpression
{
    NSPredicate *_predicate;
    NSExpression *_trueExpression;
    NSExpression *_falseExpression;
}

static NSString * const NSPredicateKey = @"NSPredicate";
static NSString * const NSTrueExpressionKey = @"NSTrueExpression";
static NSString * const NSFalseExpressionKey = @"NSFalseExpression";

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (void)dealloc
{
    [_predicate release];
    [_trueExpression release];
    [_falseExpression release];
    [super dealloc];
}

- (id)initWithPredicate:(NSPredicate *)predicate trueExpression:(NSExpression *)trueExpression falseExpression:(NSExpression *)falseExpression
{
    self = [super initWithExpressionType:NSTernaryExpressionType];
    if (self != nil)
    {
        _predicate = predicate;
        _trueExpression = trueExpression;
        _falseExpression = falseExpression;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    NSPredicate *predicate = [_predicate copy];
    NSExpression *trueExpression = [_trueExpression copy];
    NSExpression *falseExpression = [_falseExpression copy];

    NSTernaryExpression *copy = [[[self class] alloc] initWithPredicate:predicate trueExpression:trueExpression falseExpression:falseExpression];

    [predicate release];
    [trueExpression release];
    [falseExpression release];

    return copy;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if (_NSPredicateKeyedArchiverCheck(decoder))
    {
        [self release];
        return nil;
    }

    self = [super initWithCoder:decoder];
    if (self != nil)
    {
        NSSet *predicateAllowedExpressionClasses = [_NSPredicateUtilities _expressionClassesForSecureCoding];
        NSSet *predicateAllowedPredicateClasses = [_NSPredicateUtilities _predicateClassesForSecureCoding];

        NSSet *allowedExpressionClasses = _NSPredicateAllowedClasses(decoder, predicateAllowedExpressionClasses);
        NSSet *allowedPredicateClasses = _NSPredicateAllowedClasses(decoder, predicateAllowedPredicateClasses);

        _predicate = [decoder decodeObjectOfClasses:allowedPredicateClasses forKey:NSPredicateKey];
        _trueExpression = [decoder decodeObjectOfClasses:allowedExpressionClasses forKey:NSTrueExpressionKey];
        _falseExpression = [decoder decodeObjectOfClasses:allowedExpressionClasses forKey:NSFalseExpressionKey];

        if (![_predicate isKindOfClass:[NSPredicate self]])
        {
            [self release];
            [NSException raise:NSInvalidUnarchiveOperationException format:@"Bad decoded predicate %@", _predicate];
            return nil;
        }
        if (![_trueExpression isKindOfClass:[NSExpression self]])
        {
            [self release];
            [NSException raise:NSInvalidUnarchiveOperationException format:@"Bad decoded expression %@", _trueExpression];
            return nil;
        }
        if (![_falseExpression isKindOfClass:[NSExpression self]])
        {
            [self release];
            [NSException raise:NSInvalidUnarchiveOperationException format:@"Bad decoded expression %@", _falseExpression];
            return nil;
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    if (_NSPredicateKeyedArchiverCheck(coder))
    {
        return;
    }

    [super encodeWithCoder:coder];

    [coder encodeObject:_predicate forKey:NSPredicateKey];
    [coder encodeObject:_trueExpression forKey:NSTrueExpressionKey];
    [coder encodeObject:_falseExpression forKey:NSFalseExpressionKey];
}

- (BOOL)isEqual:(id)other
{
    if (self == other)
    {
        return YES;
    }
    if (![other isKindOfClass:[NSTernaryExpression self]])
    {
        return NO;
    }
    if ([self expressionType] != [other expressionType])
    {
        return NO;
    }
    if (![_predicate isEqual:[other predicate]])
    {
        return NO;
    }
    if (![_trueExpression isEqual:[other trueExpression]])
    {
        return NO;
    }
    if (![_falseExpression isEqual:[other falseExpression]])
    {
        return NO;
    }
    return YES;
}

- (NSExpression *)falseExpression
{
    return _falseExpression;
}

- (NSExpression *)trueExpression
{
    return _trueExpression;
}

- (NSPredicate *)predicate
{
    return _predicate;
}

- (NSString *)predicateFormat
{
    NSString *predicateString = [_predicate predicateFormat];
    NSString *trueString = [_trueExpression predicateFormat];
    NSString *falseString = [_falseExpression predicateFormat];

    return [NSString stringWithFormat:@"TERNARY(%@, %@, %@)", predicateString, trueString, falseString];
}

- (void)allowEvaluation
{
    [_predicate allowEvaluation];
    [_trueExpression allowEvaluation];
    [_falseExpression allowEvaluation];

    [super allowEvaluation];
}

- (void)acceptVisitor:(id)visitor flags:(NSPredicateVisitorFlags)flags
{
    if ((flags & NSPredicateVisitorVisitExpressions) == 0)
    {
        return;
    }

    if ((flags & NSPredicateVisitorVisitInternalNodes) != 0)
    {
        [visitor visitPredicateExpression:self];
    }

    [[self predicate] acceptVisitor:visitor flags:flags];
    [[self trueExpression] acceptVisitor:visitor flags:flags];
    [[self falseExpression] acceptVisitor:visitor flags:flags];

    if ((flags & NSPredicateVisitorVisitInternalNodes) != 0)
    {
        [visitor visitPredicateExpression:self];
    }
}

- (id)expressionValueWithObject:(id)object context:(NSMutableDictionary *)context
{
    if (!_NSExpressionEvaluationCheck(self))
    {
        return nil;
    }

    if ([_predicate evaluateWithObject:object substitutionVariables:context])
    {
        return [_trueExpression expressionValueWithObject:object context:context];
    }
    else
    {
        return [_falseExpression expressionValueWithObject:object context:context];
    }
}

- (NSExpression *)_expressionWithSubstitutionVariables:(NSDictionary *)variables
{
    if (_NSPredicateSubstitutionCheck(variables))
    {
        return nil;
    }

    NSPredicate *predicate = [_predicate predicateWithSubstitutionVariables:variables];
    NSExpression *trueExpression = [_trueExpression _expressionWithSubstitutionVariables:variables];
    NSExpression *falseExpression = [_falseExpression _expressionWithSubstitutionVariables:variables];

    return [[[NSTernaryExpression alloc] initWithPredicate:predicate trueExpression:trueExpression falseExpression:falseExpression] autorelease];
}

@end
