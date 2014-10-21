//
//  NSVariableAssignmentExpression.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "NSExpressionInternal.h"

#import "_NSPredicateUtilities.h"

#import <Foundation/NSDictionary.h>
#import <Foundation/NSKeyedArchiver.h>

static NSString * const NSAssignmentVariableKey = @"NSAssignmentVariable";
static NSString * const NSSubexpressionKey = @"NSSubexpression";

@implementation NSVariableAssignmentExpression
{
    NSVariableExpression *_assignmentVariable;
    NSExpression *_subexpression;
}

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (void)dealloc
{
    [_assignmentVariable release];
    [_subexpression release];
    [super dealloc];
}

- (id)initWithAssignmentExpression:(NSVariableExpression *)assignmentExpression expression:(NSExpression *)expression
{
    self = [super initWithExpressionType:NSVariableExpressionType];
    if (self != nil)
    {
        _assignmentVariable = [assignmentExpression retain];
        _subexpression = [expression retain];
    }
    return self;
}

- (id)initWithAssignmentVariable:(NSString *)variableName expression:(NSExpression *)expression
{
    NSVariableExpression *assignmentExpression = [[[NSVariableExpression alloc] initWithObject:variableName] autorelease];
    return [self initWithAssignmentExpression:assignmentExpression expression:expression];
}

- (id)copyWithZone:(NSZone *)zone
{
    NSVariableExpression *assignmentVariable = [_assignmentVariable copy];
    NSExpression *subexpression = [_subexpression copy];

    NSVariableAssignmentExpression *copy = [[[self class] alloc] initWithAssignmentExpression:assignmentVariable expression:subexpression];

    [assignmentVariable release];
    [subexpression release];

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
        NSSet *predicateAllowedClasses = [_NSPredicateUtilities _expressionClassesForSecureCoding];
        NSSet *allowedClasses = _NSPredicateAllowedClasses(decoder, predicateAllowedClasses);

        NSString *variable = [decoder decodeObjectOfClass:[NSString self] forKey:NSAssignmentVariableKey];
        if (variable == nil)
        {
            [self release];
            [NSException raise:NSInvalidUnarchiveOperationException format:@"Could not decode variable name"];
            return nil;
        }
        _assignmentVariable = [[NSVariableExpression alloc] initWithObject:variable];
        _assignmentVariable->_expressionFlags |= NSPredicateVisitorVisitExpressions;

        _subexpression = [[decoder decodeObjectOfClasses:allowedClasses forKey:NSSubexpressionKey] retain];

        if (![_subexpression isKindOfClass:[NSExpression self]])
        {
            [self release];
            [NSException raise:NSInvalidUnarchiveOperationException format:@"Bad decoded expression %@", _subexpression];
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

    [coder encodeObject:[self variable] forKey:NSAssignmentVariableKey];
    [coder encodeObject:[self subexpression] forKey:NSSubexpressionKey];
}

- (NSUInteger)hash
{
    NSUInteger variableHash = [[self variable] hash];
    NSUInteger subexpressionHash = [_subexpression hash];

    return variableHash ^ subexpressionHash;
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
    if (![_assignmentVariable isEqual:[other variable]])
    {
        return NO;
    }
    if (![_subexpression isEqual:[other subexpression]])
    {
        return NO;
    }
    return YES;
}

- (NSExpression *)subexpression
{
    return _subexpression;
}

- (NSString *)variable
{
    return [_assignmentVariable variable];
}

- (id)assignmentVariable
{
    return _assignmentVariable;
}

- (NSString *)predicateFormat
{
    NSExpression *subexpression = [self subexpression];

    NSString *expDescription = [subexpression predicateFormat];
    NSString *varDescription = [[self assignmentVariable] predicateFormat];

    if ([subexpression _shouldUseParensWithDescription])
    {
        return [NSString stringWithFormat:@"%@ := (%@)", varDescription, expDescription];
    }
    else
    {
        return [NSString stringWithFormat:@"%@ := %@", varDescription, expDescription];
    }
}

- (void)allowEvaluation
{
    [_assignmentVariable allowEvaluation];
    [_subexpression allowEvaluation];

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

    [[self assignmentVariable] acceptVisitor:visitor flags:flags];
    [[self subexpression] acceptVisitor:visitor flags:flags];

    if ((flags & NSPredicateVisitorVisitInternalNodes) != 0)
    {
        [visitor visitPredicateExpression:self];
    }
}

- (NSExpression *)_expressionWithSubstitutionVariables:(NSDictionary *)variables
{
    if (!_NSPredicateSubstitutionCheck(variables))
    {
        return nil;
    }

    NSVariableExpression *newAssignmentVariable = (NSVariableExpression *)[[self assignmentVariable] _expressionWithSubstitutionVariables:variables];
    NSExpression *newSubexpression = [[self subexpression] _expressionWithSubstitutionVariables:variables];

    return [[[[self class] alloc] initWithAssignmentExpression:newAssignmentVariable expression:newSubexpression] autorelease];
}

- (id)expressionValueWithObject:(id)object context:(NSMutableDictionary *)context
{
    if (!_NSExpressionEvaluationCheck(self))
    {
        return nil;
    }

    if (context == nil)
    {
        [NSException raise:NSInternalInconsistencyException format:@"Cannot evaluate variable assignment with nil bindings"];
        return nil;
    }

    id value = [[self subexpression] expressionValueWithObject:object context:context];
    [context setObject:value forKey:[self variable]];
    return value;
}

@end
