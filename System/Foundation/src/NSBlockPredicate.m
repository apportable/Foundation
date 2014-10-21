//
//  NSBlockPredicate.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "NSPredicateInternal.h"

@implementation NSBlockPredicate {
    BOOL (^_block)(id evaluatedObject, NSDictionary *bindings);
}

- (void)dealloc
{
    [_block release];
    [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone
{
    return [[[self class] alloc] initWithBlock:_block];
}

- (id)_predicateBlock
{
    return _block;
}

- (id)initWithBlock:(BOOL (^)(id evaluateWithObject, NSDictionary *bindings))block
{
    self = [super init];
    if (self != nil)
    {
        _block = [block copy];
    }
    return self;
}

- (id)predicateWithSubstitutionVariables:(NSDictionary *)variables
{
    return [self copy];
}

- (void)acceptVisitor:(id)visitor flags:(NSPredicateVisitorFlags)flags
{
    [visitor visitPredicate:self];
}

- (NSString *)predicateFormat
{
    return [NSString stringWithFormat:@"BLOCKPREDICATE(%p)", _block];
}

- (BOOL)evaluateWithObject:(id)objects substitutionVariables:(NSDictionary *)variables
{
    if (!_NSPredicateEvaluationCheck(self))
    {
        return NO;
    }
    return _block(objects, variables);
}

- (id)initWithCoder:(NSCoder *)decoder
{
    [NSException raise:NSInvalidArgumentException format:@"Cannot decode block predicates"];
    [self release];
    return nil;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [NSException raise:NSInvalidArgumentException format:@"Cannot encode block predicates"];
}

- (BOOL)supportsSecureCoding
{
    return NO;
}

@end
