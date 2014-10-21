//
//  NSExpression.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "NSExpressionInternal.h"

#import <Foundation/NSArray.h>
#import <Foundation/NSComparisonPredicate.h>
#import <Foundation/NSDictionary.h>
#import "NSObjectInternal.h"
#import <Foundation/NSString.h>
#import "_NSPredicateUtilities.h"

static NSString * const NSExpressionTypeKey = @"NSExpressionType";

@implementation NSExpression

+ (NSExpression *)expressionWithFormat:(NSString *)format argumentArray:(NSArray *)arguments
{
    NSString *predicateFormat = [NSString stringWithFormat:@"%@ == 1", format];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFormat argumentArray:arguments];
    return [(NSComparisonPredicate *)predicate leftExpression];
}

+ (NSExpression *)expressionWithFormat:(NSString *)format, ...
{
    va_list args;
    va_start(args, format);

    NSExpression *expression = [self expressionWithFormat:format arguments:args];

    va_end(args);

    return expression;
}

+ (NSExpression *)expressionWithFormat:(NSString *)format arguments:(va_list)args
{
    NSString *predicateFormat = [NSString stringWithFormat:@"%@ == 1", format];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFormat arguments:args];
    return [(NSComparisonPredicate *)predicate leftExpression];
}

+ (NSExpression *)expressionForConstantValue:(id)obj
{
    return [[[NSConstantValueExpression alloc] initWithObject:obj] autorelease];
}

+ (NSExpression *)expressionForEvaluatedObject
{
    return [[[NSSelfExpression alloc] init] autorelease];
}

+ (NSExpression *)expressionForVariable:(NSString *)variable
{
    return [[[NSVariableExpression alloc] initWithObject:variable] autorelease];
}

+ (NSExpression *)expressionForKeyPath:(NSString *)keyPath
{
    NSExpression *keyPathSpecifierExpression = [NSExpression _newKeyPathExpressionForString:keyPath];
    NSExpression *keyPathExpression = [[[NSKeyPathExpression alloc] initWithKeyPath:keyPathSpecifierExpression] autorelease];
    [keyPathSpecifierExpression release];
    return keyPathExpression;
}

+ (NSExpression *)expressionForFunction:(NSExpression *)target selectorName:(NSString *)name arguments:(NSArray *)parameters
{
    return [[[NSFunctionExpression alloc] initWithTarget:target selectorName:name arguments:parameters] autorelease];
}

+ (NSExpression *)expressionForFunction:(NSString *)name arguments:(NSArray *)parameters
{
    SEL selector = NSSelectorFromString(name);

    if (![_NSPredicateUtilities respondsToSelector:selector])
    {
        [NSException raise:NSInternalInconsistencyException format:@"Function %@ is not supported", name];
        return nil;
    }

    return [[[NSFunctionExpression alloc] initWithSelector:selector argumentArray:parameters] autorelease];
}

+ (NSExpression *)expressionForAggregate:(NSArray *)subexpressions
{
    return [[[NSAggregateExpression alloc] initWithCollection:subexpressions] autorelease];
}

+ (NSExpression *)expressionForUnionSet:(NSExpression *)left with:(NSExpression *)right
{
    return [[[NSSetExpression alloc] initWithType:NSUnionSetExpressionType leftExpression:left rightExpression:right] autorelease];
}

+ (NSExpression *)expressionForIntersectSet:(NSExpression *)left with:(NSExpression *)right
{
    return [[[NSSetExpression alloc] initWithType:NSIntersectSetExpressionType leftExpression:left rightExpression:right] autorelease];
}

+ (NSExpression *)expressionForMinusSet:(NSExpression *)left with:(NSExpression *)right
{
    return [[[NSSetExpression alloc] initWithType:NSMinusSetExpressionType leftExpression:left rightExpression:right] autorelease];
}

+ (NSExpression *)expressionForSubquery:(NSExpression *)expression usingIteratorVariable:(NSString *)variable predicate:(id)predicate
{
    return [[[NSSubqueryExpression alloc] initWithExpression:expression usingIteratorVariable:variable predicate:predicate] autorelease];
}

+ (NSExpression *)expressionForBlock:(id (^)(id evaluatedObject, NSArray *expressions, NSMutableDictionary *context))block arguments:(NSArray *)arguments
{
    return [[[NSBlockExpression alloc] initWithType:NSBlockExpressionType block:block arguments:arguments] autorelease];
}

+ (NSExpression *)expressionForAnyKey
{
    return [[[NSAnyKeyExpression alloc] init] autorelease];
}

+ (NSExpression *)_newKeyPathExpressionForString:(NSString *)string
{
    return [[NSKeyPathSpecifierExpression alloc] initWithObject:string];
}

+ (NSExpression *)expressionForTernaryWithPredicate:(NSPredicate *)predicate trueExpression:(NSExpression *)trueExpression falseExpression:(NSExpression *)falseExpression
{
    return [[[NSTernaryExpression alloc] initWithPredicate:predicate trueExpression:trueExpression falseExpression:falseExpression] autorelease];
}

+ (NSExpression *)expressionForVariableNameAssignment:(NSString *)name expression:(NSExpression *)expression
{
    return [[[NSVariableAssignmentExpression alloc] initWithAssignmentVariable:name expression:expression] autorelease];
}

+ (NSExpression *)expressionForSymbolicString:(NSString *)string
{
    return [[[NSSymbolicExpression alloc] initWithString:string] autorelease];
}

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (id)initWithExpressionType:(NSExpressionType)type
{
    self = [super init];
    if (self != nil)
    {
        _expressionType = type;
    }
    return self;
}

- (NSExpressionType)expressionType
{
    return _expressionType;
}

- (id)constantValue
{
    NSRequestConcreteImplementation();
    return nil;
}

- (NSString *)keyPath
{
    NSRequestConcreteImplementation();
    return nil;
}

- (NSString *)function
{
    NSRequestConcreteImplementation();
    return nil;
}

- (NSString *)variable
{
    NSRequestConcreteImplementation();
    return nil;
}

- (NSExpression *)operand
{
    NSRequestConcreteImplementation();
    return nil;
}

- (NSArray *)arguments
{
    NSRequestConcreteImplementation();
    return nil;
}

- (id)collection
{
    NSRequestConcreteImplementation();
    return nil;
}

- (NSPredicate *)predicate
{
    NSRequestConcreteImplementation();
    return nil;
}

- (NSExpression *)leftExpression
{
    NSRequestConcreteImplementation();
    return nil;
}

- (NSExpression *)rightExpression
{
    NSRequestConcreteImplementation();
    return nil;
}

- (id (^)(id, NSArray *, NSMutableDictionary *))expressionBlock
{
    NSRequestConcreteImplementation();
    return nil;
}

- (id)expressionValueWithObject:(id)object context:(NSMutableDictionary *)context
{
    NSRequestConcreteImplementation();
    return nil;
}

- (NSExpression *)_expressionWithSubstitutionVariables:(NSDictionary *)substitution
{
    if (substitution == nil)
    {
        [NSException raise:NSInvalidArgumentException format:@"Cannot substitute nil bindings"];
        return nil;
    }

    return self;
}

- (void)acceptVisitor:(id)visitor flags:(NSPredicateVisitorFlags)flags
{
    if ((flags & NSPredicateVisitorVisitExpressions) != 0)
    {
        [visitor visitPredicateExpression:self];
    }
}

- (BOOL)_shouldUseParensWithDescription
{
    return NO;
}

- (NSExpression *)falseExpression
{
    NSRequestConcreteImplementation();
    return nil;
}

- (NSExpression *)trueExpression
{
    NSRequestConcreteImplementation();
    return nil;
}

- (NSExpression *)subexpression
{
    NSRequestConcreteImplementation();
    return nil;
}

- (SEL)selector
{
    NSRequestConcreteImplementation();
    return NULL;
}

- (NSString *)predicateFormat
{
    NSRequestConcreteImplementation();
    return nil;
}

- (NSString *)description
{
    return [self predicateFormat];
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

    NSExpressionType type = [decoder decodeIntegerForKey:NSExpressionTypeKey];
    self = [self initWithExpressionType:type];
    if (self != nil && [decoder requiresSecureCoding])
    {
        _expressionFlags |= NSPredicateEvaluationBlocked;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    if (!_NSPredicateKeyedArchiverCheck(coder))
    {
        return;
    }

    [coder encodeInteger:[self expressionType] forKey:NSExpressionTypeKey];
}

- (void)allowEvaluation
{
    _expressionFlags &= ~NSPredicateEvaluationBlocked;
}

- (BOOL)_allowsEvaluation
{
    return !((_expressionFlags & NSPredicateEvaluationBlocked) != 0);
}

@end
