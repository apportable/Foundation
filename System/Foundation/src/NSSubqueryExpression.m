//
//  NSSubqueryExpression.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "NSExpressionInternal.h"

#import "_NSPredicateUtilities.h"

#import <Foundation/NSDictionary.h>
#import <Foundation/NSKeyedArchiver.h>
#import <Foundation/NSKeyValueCoding.h>

static NSString * const NSExpressionKey = @"NSExpression";
static NSString * const NSSubpredicateKey = @"NSSubpredicate";
static NSString * const NSVariableKey = @"NSVariable";

@implementation NSSubqueryExpression
{
    NSExpression *_collection;
    NSExpression *_variableExpression;
    NSPredicate *_subpredicate;
}

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (void)dealloc
{
    [_collection release];
    [_variableExpression release];
    [_subpredicate release];
    [super dealloc];
}

- (id)initWithExpression:(NSExpression *)expression usingIteratorExpression:(NSExpression *)iteratorExpression predicate:(NSPredicate *)predicate
{
    if (iteratorExpression == nil)
    {
        [self release];
        [NSException raise:NSInvalidArgumentException format:@"Cannot initialize subquery expression with nil iterator"];
        return nil;
    }

    if (predicate == nil)
    {
        [self release];
        [NSException raise:NSInvalidArgumentException format:@"Cannot initialize subquery expression with nil predicate"];
        return nil;
    }

    self = [super initWithExpressionType:NSSubqueryExpressionType];
    if (self != nil)
    {
        _collection = [expression retain];
        _variableExpression = [iteratorExpression retain];
        _subpredicate = [predicate retain];
    }
    return self;
}

- (id)initWithExpression:(NSExpression *)expression usingIteratorVariable:(NSString *)variable predicate:(NSPredicate *)predicate
{
    if (variable == nil)
    {
        [self release];
        [NSException raise:NSInvalidArgumentException format:@"Cannot initialize subquery expression with nil variable"];
        return nil;
    }

    if (predicate == nil)
    {
        [self release];
        [NSException raise:NSInvalidArgumentException format:@"Cannot initialize subquery expression with nil predicate"];
        return nil;
    }

    NSExpression *iteratorExpression = [[[NSVariableExpression alloc] initWithObject:variable] autorelease];
    return [self initWithExpression:expression usingIteratorExpression:iteratorExpression predicate:predicate];
}

- (id)copyWithZone:(NSZone *)zone
{
    NSExpression *collection = [_collection copy];
    NSExpression *variableExpression = [_variableExpression copy];
    NSPredicate *subpredicate = [_subpredicate copy];

    NSSubqueryExpression *copy = [[[NSSubqueryExpression self] alloc] initWithExpression:collection usingIteratorExpression:variableExpression predicate:subpredicate];

    [collection release];
    [variableExpression release];
    [subpredicate release];

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
        NSSet *predicateAllowedExpressionClasses = [_NSPredicateUtilities _expressionClassesForSecureCoding];
        NSSet *predicateAllowedPredicateClasses = [_NSPredicateUtilities _predicateClassesForSecureCoding];

        NSSet *allowedExpressionClasses = _NSPredicateAllowedClasses(decoder, predicateAllowedExpressionClasses);
        NSSet *allowedPredicateClasses = _NSPredicateAllowedClasses(decoder, predicateAllowedPredicateClasses);

        _collection = [[decoder decodeObjectOfClasses:allowedExpressionClasses forKey:NSExpressionKey] retain];

        NSString *variable = [decoder decodeObjectOfClass:[NSString self] forKey:NSVariableKey];
        if (variable == nil)
        {
            [self release];
            [NSException raise:NSInvalidUnarchiveOperationException format:@"Could not decode variable name"];
            return nil;
        }
        _variableExpression = [[NSVariableExpression alloc] initWithObject:variable];
        _variableExpression->_expressionFlags |= NSPredicateVisitorVisitExpressions;

        _subpredicate = [[decoder decodeObjectOfClasses:allowedPredicateClasses forKey:NSSubpredicateKey] retain];

        if (![_collection isKindOfClass:[NSExpression self]])
        {
            [self release];
            [NSException raise:NSInvalidUnarchiveOperationException format:@"Bad decoded expression %@", _collection];
            return nil;
        }
        if (![_subpredicate isKindOfClass:[NSPredicate self]])
        {
            [self release];
            [NSException raise:NSInvalidUnarchiveOperationException format:@"Bad decoded predicate %@", _subpredicate];
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

    [coder encodeObject:[self collection] forKey:NSExpressionKey];
    [coder encodeObject:[self variable] forKey:NSVariableKey];
    [coder encodeObject:[self predicate] forKey:NSSubpredicateKey];
}

- (NSUInteger)hash
{
    NSUInteger variableHash = [[self variable] hash];
    NSUInteger predicateHash = [_subpredicate hash];

    return variableHash ^ predicateHash;
}

- (BOOL)isEqual:(id)other
{
    if (self == other)
    {
        return YES;
    }
    if (![other isKindOfClass:[NSSubqueryExpression class]])
    {
        return NO;
    }
    if (![[other variable] isEqual:[self variable]])
    {
        return NO;
    }
    return [[other predicate] isEqual:[self predicate]];
}

- (NSPredicate *)predicate
{
    return _subpredicate;
}

- (NSString *)variable
{
    return [_variableExpression variable];
}

- (NSExpression *)variableExpression
{
    return _variableExpression;
}

- (id)collection
{
    return _collection;
}

- (NSString *)predicateFormat
{
    NSString *collectionDescription = [[self collection] predicateFormat];
    NSString *variableDescription = [[self variableExpression] predicateFormat];
    NSString *predicateDescription = [[self predicate] predicateFormat];

    return [NSString stringWithFormat:@"SUBQUERY(%@, %@, %@)", collectionDescription, variableDescription, predicateDescription];
}

- (BOOL)_shouldUseParensWithDescription
{
    return NO;
}

- (NSExpression *)_expressionWithSubstitutionVariables:(NSDictionary *)variables
{
    if (!_NSPredicateSubstitutionCheck(variables))
    {
        return nil;
    }

    NSExpression *newCollection = [[self collection] _expressionWithSubstitutionVariables:variables];
    NSExpression *newVariableExpression = [[self variableExpression] _expressionWithSubstitutionVariables:variables];
    NSPredicate *newPredicate = [[self predicate] predicateWithSubstitutionVariables:variables];

    return [[[[self class] alloc] initWithExpression:newCollection usingIteratorExpression:newVariableExpression predicate:newPredicate] autorelease];
}

- (id)expressionValueWithObject:(id)object context:(NSMutableDictionary *)context
{
    if (!_NSExpressionEvaluationCheck(self))
    {
        return nil;
    }

    id collectionValue = [[self collection] expressionValueWithObject:object context:context];
    if (collectionValue == nil)
    {
        return nil;
    }
    if (![collectionValue isNSArray__] &&
        ![collectionValue isNSSet__] &&
        ![collectionValue isNSOrderedSet__])
    {
        [NSException raise:NSInternalInconsistencyException format:@"Collection value was not a collection class"];
        return nil;
    }

    NSString *variable = [self variable];
    id originalContextBinding = [context valueForKey:variable];
    NSMutableArray *selectedValues = [NSMutableArray array];

    for (id value in collectionValue)
    {
        [context setObject:value forKey:variable];
        if ([[self predicate] evaluateWithObject:object substitutionVariables:context])
        {
            [selectedValues addObject:value];
        }
    }

    if (originalContextBinding == nil)
    {
        [context removeObjectForKey:variable];
    }
    else
    {
        [context setObject:originalContextBinding forKey:variable];
    }

    return selectedValues;
}

- (void)allowEvaluation
{
    [_collection allowEvaluation];
    [_subpredicate allowEvaluation];
    [_variableExpression allowEvaluation];

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

    [[self collection] acceptVisitor:visitor flags:flags];
    [[self variableExpression] acceptVisitor:visitor flags:flags];
    [[self predicate] acceptVisitor:visitor flags:flags];

    if ((flags & NSPredicateVisitorVisitInternalNodes) != 0)
    {
        [visitor visitPredicateExpression:self];
    }
}

@end
