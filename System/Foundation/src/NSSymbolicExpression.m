//
//  NSSymbolicExpression.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "NSExpressionInternal.h"

@implementation NSSymbolicExpression
{
    NSString *_token;
}

static NSString * const NSTokenKey = @"NSToken";

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (id)initWithString:(NSString *)string
{
    self = [super initWithExpressionType:NSSymbolicExpressionType];
    if (self != nil)
    {
        _token = [string retain];
    }
    return self;
}

- (void)dealloc
{
    [_token release];
    [super dealloc];
}

- (NSUInteger)hash
{
    return [_token hash];
}

- (BOOL)isEqual:(id)other
{
    if (self == other)
    {
        return YES;
    }
    if (![other isKindOfClass:[NSSymbolicExpression self]])
    {
        return NO;
    }
    return [_token isEqual:((NSSymbolicExpression *)other)->_token];
}

- (id)copyWithZone:(NSZone *)zone
{
    return [[[self class] alloc] initWithString:_token];
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
        _token = [decoder decodeObjectOfClass:[NSString self] forKey:NSTokenKey];
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

    [coder encodeObject:_token forKey:NSTokenKey];
}

- (id)constantValue
{
    return _token;
}

- (NSString *)predicateFormat
{
    return _token;
}

- (id)expressionValueWithObject:(id)object context:(NSMutableDictionary *)context
{
    if (!_NSExpressionEvaluationCheck(self))
    {
        return nil;
    }

    return self;
}

@end
