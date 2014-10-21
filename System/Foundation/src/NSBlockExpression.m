//
//  NSBlockExpression.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "NSExpressionInternal.h"

#import <Foundation/NSDictionary.h>

@implementation NSBlockExpression
{
    id (^_block)(id, NSArray *, NSMutableDictionary *);
    NSArray *_arguments;
}

- (id)initWithType:(NSExpressionType)type block:(id (^)(id, NSArray *, NSMutableDictionary *))block arguments:(NSArray *)arguments
{
    self = [super initWithExpressionType:type];
    if (self != nil)
    {
        _block = [block copy];
        _arguments = [arguments copy];
    }
    return self;
}

- (void)dealloc
{
    [_block release];
    [_arguments release];
    [super dealloc];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    [NSException raise:NSInvalidArgumentException format:@"Cannot decode block expressions"];
    [self release];
    return nil;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [NSException raise:NSInvalidArgumentException format:@"Cannot encode block expressions"];
    DEBUG_BREAK();
}

- (NSExpression *)_expressionWithSubstitutionVariables:(NSDictionary *)variables
{
    if (!_NSPredicateSubstitutionCheck(variables))
    {
        return nil;
    }

    NSMutableArray *newArguments = [NSMutableArray array];

    for (NSExpression *e in _arguments)
    {
        [newArguments addObject:[e _expressionWithSubstitutionVariables:variables]];
    }

    return [NSExpression expressionForBlock:_block arguments:newArguments];
}

- (id)copyWithZone:(NSZone *)zone
{
    return [[[self class] alloc] initWithType:[self expressionType] block:_block arguments:_arguments];
}

- (NSArray *)arguments
{
    return _arguments;
}

- (id (^)(id, NSArray *, NSMutableDictionary *))expressionBlock
{
    return _block;
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

    for (NSExpression *e in _arguments)
    {
        [e acceptVisitor:visitor flags:flags];
    }

    if ((flags & NSPredicateVisitorVisitInternalNodes) != 0)
    {
        [visitor visitPredicateExpression:self];
    }
}

- (NSString *)predicateFormat
{
    return [NSString stringWithFormat:@"BLOCK(%p, %p)", _block, _arguments];
}

- (id)expressionValueWithObject:(id)object context:(NSMutableDictionary *)context
{
    if (_NSExpressionEvaluationCheck(self))
    {
        return nil;
    }

    NSMutableArray *evaluatedArguments = [[[NSMutableArray array] init] autorelease];

    for (NSExpression *e in _arguments)
    {
        [evaluatedArguments addObject:[e expressionValueWithObject:object context:context]];
    }

    return _block(object, evaluatedArguments, context);
}

@end
