//
//  NSComparisonPredicate.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/NSComparisonPredicate.h>

#import "NSExpressionInternal.h"
#import "NSNestedDictionary.h"
#import "NSPredicateOperator.h"
#import "NSPredicateInternal.h"
#import "_NSPredicateUtilities.h"

#import <Foundation/NSException.h>
#import <Foundation/NSKeyedArchiver.h>

static NSString * const NSLeftExpressionKey = @"NSLeftExpression";
static NSString * const NSRightExpressionKey = @"NSRightExpression";
static NSString * const NSPredicateOperatorKey = @"NSPredicateOperator";

@implementation NSComparisonPredicate
{
    void *_reserved2;
    NSPredicateOperator *_predicateOperator;
    NSExpression *_lhs;
    NSExpression *_rhs;
}

+ (BOOL)supportsSecureCoding
{
    return YES;
}

+ (NSPredicate *)predicateWithPredicateOperator:(NSPredicateOperator *)predicateOperator leftExpression:(NSExpression *)lhs rightExpression:(NSExpression *)rhs
{
    return [[[self alloc] initWithPredicateOperator:predicateOperator leftExpression:lhs rightExpression:rhs] autorelease];
}

+ (NSPredicate *)predicateWithPredicateOperator:(NSPredicateOperator *)predicateOperator leftKeyPath:(NSExpression *)lhs rightKeyPath:(NSExpression *)rhs
{
    return [[[self alloc] initWithPredicateOperator:predicateOperator leftKeyPath:lhs rightKeyPath:rhs] autorelease];
}

+ (NSPredicate *)predicateWithPredicateOperator:(NSPredicateOperator *)predicateOperator leftKeyPath:(NSExpression *)lhs rightValue:(NSExpression *)rhs
{
    return [[[self alloc] initWithPredicateOperator:predicateOperator leftKeyPath:lhs rightValue:rhs] autorelease];}

+ (NSPredicate *)predicateWithLeftExpression:(NSExpression *)lhs rightExpression:(NSExpression *)rhs modifier:(NSComparisonPredicateModifier)modifier type:(NSPredicateOperatorType)type options:(NSComparisonPredicateOptions)options
{
    return [[[self alloc] initWithLeftExpression:lhs rightExpression:rhs modifier:modifier type:type options:options] autorelease];
}

+ (NSPredicate *)predicateWithLeftExpression:(NSExpression *)lhs rightExpression:(NSExpression *)rhs customSelector:(SEL)selector
{
    return [[[self alloc] initWithLeftExpression:lhs rightExpression:rhs customSelector:selector] autorelease];
}

- (id)initWithPredicateOperator:(NSPredicateOperator *)predicateOperator leftExpression:(NSExpression *)lhs rightExpression:(NSExpression *)rhs
{
    if (predicateOperator == nil || lhs == nil || rhs == nil)
    {
        [NSException raise:NSInvalidArgumentException format:@"Cannot initialize predicate with nil operator or expressions"];
        [self release];
        return nil;
    }

    self = [super init];
    if (self != nil)
    {
        _predicateOperator = [predicateOperator retain];
        _lhs = [lhs retain];
        _rhs = [rhs retain];
    }
    return self;
}

- (id)initWithPredicateOperator:(NSPredicateOperator *)predicateOperator leftKeyPath:(NSExpression *)lhs rightValue:(NSExpression *)rhs
{
    NSKeyPathExpression *left = [[[NSKeyPathExpression alloc] initWithKeyPath:lhs] autorelease];
    NSConstantValueExpression *right = [[[NSConstantValueExpression alloc] initWithObject:lhs] autorelease];

    return [self initWithPredicateOperator:predicateOperator leftExpression:left rightExpression:right];
}

- (id)initWithPredicateOperator:(NSPredicateOperator *)predicateOperator leftKeyPath:(NSExpression *)lhs rightKeyPath:(NSExpression *)rhs
{
    NSKeyPathExpression *left = [[[NSKeyPathExpression alloc] initWithKeyPath:lhs] autorelease];
    NSKeyPathExpression *right = [[[NSKeyPathExpression alloc] initWithKeyPath:rhs] autorelease];

    return [self initWithPredicateOperator:predicateOperator leftExpression:left rightExpression:right];
}

- (id)initWithLeftExpression:(NSExpression *)lhs rightExpression:(NSExpression *)rhs modifier:(NSComparisonPredicateModifier)modifier type:(NSPredicateOperatorType)type options:(NSComparisonPredicateOptions)options
{
    NSPredicateOperator *predicateOperator = [[NSPredicateOperator _newOperatorWithType:type modifier:modifier options:options] autorelease];
    return [self initWithPredicateOperator:predicateOperator leftExpression:lhs rightExpression:rhs];
}

- (id)initWithLeftExpression:(NSExpression *)lhs rightExpression:(NSExpression *)rhs customSelector:(SEL)selector
{
    NSPredicateOperator *predicateOperator = [NSPredicateOperator operatorWithCustomSelector:selector modifier:0];
    return [self initWithPredicateOperator:predicateOperator leftExpression:lhs rightExpression:rhs];
}

- (void)dealloc
{
    [_predicateOperator release];
    [_lhs release];
    [_rhs release];
    [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone
{
    NSPredicateOperator *predicateOperator = [[self predicateOperator] copy];
    NSExpression *lhs = [[self leftExpression] copy];
    NSExpression *rhs = [[self rightExpression] copy];

    NSComparisonPredicate *copy = [[NSComparisonPredicate alloc] initWithPredicateOperator:predicateOperator leftExpression:lhs rightExpression:rhs];

    [predicateOperator release];
    [lhs release];
    [rhs release];

    return copy;
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
        NSSet *predicateAllowedExpressionClasses = [_NSPredicateUtilities _extendedExpressionClassesForSecureCoding];
        NSSet *predicateAllowedOperatorClasses = [_NSPredicateUtilities _expressionClassesForSecureCoding];

        NSSet *allowedExpressionClasses = _NSPredicateAllowedClasses(decoder, predicateAllowedExpressionClasses);
        NSSet *allowedOperatorClasses = _NSPredicateAllowedClasses(decoder, predicateAllowedOperatorClasses);

        _lhs = [[decoder decodeObjectOfClasses:allowedExpressionClasses forKey:NSLeftExpressionKey] retain];
        _rhs = [[decoder decodeObjectOfClasses:allowedExpressionClasses forKey:NSRightExpressionKey] retain];
        _predicateOperator = [[decoder decodeObjectOfClasses:allowedOperatorClasses forKey:NSPredicateOperatorKey] retain];

        if (![_lhs isKindOfClass:[NSExpression self]])
        {
            [self release];
            [NSException raise:NSInvalidUnarchiveOperationException format:@"Bad decoded expression %@", _lhs];
            return nil;
        }
        if (![_rhs isKindOfClass:[NSExpression self]])
        {
            [self release];
            [NSException raise:NSInvalidUnarchiveOperationException format:@"Bad decoded expression %@", _rhs];
            return nil;
        }
        if (![_predicateOperator isKindOfClass:[NSPredicateOperator self]])
        {
            [self release];
            [NSException raise:NSInvalidUnarchiveOperationException format:@"Bad decoded operator %@", _predicateOperator];
            return nil;
        }
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

    [coder encodeObject:[self leftExpression] forKey:NSLeftExpressionKey];
    [coder encodeObject:[self rightExpression] forKey:NSRightExpressionKey];
    [coder encodeObject:[self predicateOperator] forKey:NSPredicateOperatorKey];
}

- (NSComparisonPredicateOptions)options
{
    return [[self predicateOperator] options];
}

- (NSPredicateOperator *)predicateOperator
{
    return _predicateOperator;
}

- (NSExpression *)leftExpression
{
    return _lhs;
}

- (NSExpression *)rightExpression
{
    return _rhs;
}

- (NSPredicate *)predicateWithSubstitutionVariables:(NSDictionary *)variables
{
    if (!_NSPredicateSubstitutionCheck(variables))
    {
        return nil;
    }

    NSExpression *newLeft = [[self leftExpression] _expressionWithSubstitutionVariables:variables];
    NSExpression *newRight = [[self rightExpression] _expressionWithSubstitutionVariables:variables];
    NSPredicateOperator *op = [self predicateOperator];

    return [[[[self class] alloc] initWithPredicateOperator:op leftExpression:newLeft rightExpression:newRight] autorelease];
}

- (void)acceptVisitor:(id)visitor flags:(NSPredicateVisitorFlags)flags
{
    if ((flags & NSPredicateVisitorVisitExpressions) == 0)
    {
        return;
    }

    if ((flags & NSPredicateVisitorVisitInternalNodes) != 0)
    {
        [visitor visitPredicate:self];
    }

    NSPredicateVisitorFlags operatorFlags = NSPredicateVisitorVisitOperators | NSPredicateVisitorVisitOperatorsBefore;
    if ((flags & operatorFlags) == operatorFlags)
    {
        [self _acceptOperator:visitor flags:flags];
    }

    if ((flags & NSPredicateVisitorVisitExpressions) != 0)
    {
        [self _acceptExpressions:visitor flags:flags];
    }

    if ((flags & NSPredicateVisitorVisitOperators) != 0)
    {
        [self _acceptOperator:visitor flags:flags];
    }

    if ((flags & NSPredicateVisitorVisitInternalNodes) != 0)
    {
        [visitor visitPredicate:self];
    }
}

- (void)_acceptExpressions:(id)visitor flags:(NSPredicateVisitorFlags)flags
{
    [_lhs acceptVisitor:visitor flags:flags];
    [_rhs acceptVisitor:visitor flags:flags];
}

- (void)_acceptOperator:(id)visitor flags:(NSPredicateVisitorFlags)flags
{
    [_predicateOperator acceptVisitor:visitor flags:flags];
}

- (BOOL)evaluateWithObject:(id)object substitutionVariables:(NSDictionary *)variables
{
    if (!_NSPredicateEvaluationCheck(self))
    {
        return NO;
    }

    Class nestedDictClass = [_NSNestedDictionary class];
    size_t nestedDictSize = class_getInstanceSize(nestedDictClass);
    char nestedDictBuffer[nestedDictSize];

    _NSNestedDictionary *nestedDict;
    if (variables == nil || [variables isKindOfClass:nestedDictClass])
    {
        nestedDict = (_NSNestedDictionary *)variables;
    }
    else
    {
        memset(nestedDictBuffer, 0, nestedDictSize);
        nestedDict = (_NSNestedDictionary *)nestedDictBuffer;
        object_setClass(nestedDict, nestedDictClass);
        nestedDict->_bindings = variables;
    }

    id leftValue = [[self leftExpression] expressionValueWithObject:object context:nestedDict];
    id rightValue = [[self rightExpression] expressionValueWithObject:object context:nestedDict];
    NSPredicateOperator *op = [self predicateOperator];

    BOOL evaluation = [op performOperationUsingObject:leftValue andObject:rightValue];

    if ((void *)nestedDict == (void *)nestedDictBuffer && nestedDict->_locals != nil)
    {
        [nestedDict->_locals release];
    }

    return evaluation;
}

- (NSUInteger)hash
{
    NSUInteger predicateOperatorHash = [[self predicateOperator] hash];
    NSUInteger leftHash = [[self leftExpression] hash];
    NSUInteger rightHash = [[self rightExpression] hash];

    return predicateOperatorHash ^ leftHash ^ rightHash;
}

- (BOOL)isEqual:(id)other
{
    if (self == other)
    {
        return YES;
    }
    if (![other isKindOfClass:[NSComparisonPredicate self]])
    {
        return NO;
    }
    if (![[other leftExpression] isEqual:[self leftExpression]])
    {
        return NO;
    }
    if (![[other rightExpression] isEqual:[self rightExpression]])
    {
        return NO;
    }
    return [[other predicateOperator] isEqual:[self predicateOperator]];
}

- (void)setPredicateOperator:(NSPredicateOperator *)predicateOperator
{
    NSPredicateOperator *currentPredicateOperator = [self predicateOperator];

    if (predicateOperator != currentPredicateOperator)
    {
        _predicateOperator = [predicateOperator retain];
        [currentPredicateOperator release];
    }
}

- (SEL)customSelector
{
    return [[self predicateOperator] selector];
}

- (NSComparisonPredicateModifier)comparisonPredicateModifier
{
    return [[self predicateOperator] modifier];
}

- (NSPredicateOperatorType)predicateOperatorType
{
    return [[self predicateOperator] operatorType];
}

- (NSString *)predicateFormat
{
    NSString *modifierDescription = nil;
    switch ([self comparisonPredicateModifier])
    {
        case NSDirectPredicateModifier:
            modifierDescription = @"";
            break;
        case NSAllPredicateModifier:
            modifierDescription = @"ALL ";
            break;
        case NSAnyPredicateModifier:
            modifierDescription = @"ANY ";
            break;
    }

    NSString *leftDescription = [[self leftExpression] predicateFormat];
    NSString *rightDescription = [[self rightExpression] predicateFormat];
    NSString *predicateOperatorDescription = [[self predicateOperator] predicateFormat];

    return [NSString stringWithFormat:@"%@%@ %@ %@", modifierDescription, leftDescription, predicateOperatorDescription, rightDescription];
}

- (void)allowEvaluation
{
    [_lhs allowEvaluation];
    [_rhs allowEvaluation];

    [super allowEvaluation];
}

- (id)keyPathExpressionForString:(NSString *)string
{
    return [[NSExpression _newKeyPathExpressionForString:string] autorelease];
}

@end
