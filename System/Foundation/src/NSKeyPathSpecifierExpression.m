//
//  NSKeyPathSpecifierExpression.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "NSExpressionInternal.h"

#import "_NSPredicateUtilities.h"

@implementation NSKeyPathSpecifierExpression
{
    NSString *_value;
}

static NSString * const NSKeyPathKey = @"NSKeyPath";

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (id)initWithObject:(id)keyPath
{
    self = [super initWithExpressionType:NSKeyPathSpecifierExpressionType];
    if (self != nil)
    {
        _value = [keyPath retain];
    }
    return self;
}

- (void)dealloc
{
    [_value release];
    [super dealloc];
}

- (NSUInteger)hash
{
    return [[self keyPath] hash];
}

- (BOOL)isEqual:(id)other
{
    if (self == other)
    {
        return YES;
    }
    if (![other isKindOfClass:[NSKeyPathSpecifierExpression self]])
    {
        return NO;
    }
    return [[self keyPath] isEqual:[other keyPath]];
}

- (id)copyWithZone:(NSZone *)zone
{
    return [[NSKeyPathSpecifierExpression alloc] initWithObject:_value];
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
        _value = [[decoder decodeObjectOfClass:[NSString self] forKey:NSKeyPathKey] retain];
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

    [coder encodeObject:_value forKey:NSKeyPathKey];
}

- (id)constantValue
{
    return _value;
}

- (NSString *)keyPath
{
    return _value;
}

- (NSString *)predicateFormat
{
    NSMutableString *desc = [NSMutableString string];

    BOOL useDot = NO;
    for (NSString *component in [[self keyPath] componentsSeparatedByString:@"."])
    {
        if (useDot)
        {
            [desc appendString:@"."];
        }
        if ([_NSPredicateUtilities _isReservedWordInParser:component])
        {
            [desc appendString:@"#"];
        }
        [desc appendString:component];
        useDot = YES;
    }

    return desc;
}

- (id)expressionValueWithObject:(id)object context:(NSMutableDictionary *)context
{
    if (!_NSExpressionEvaluationCheck(self))
    {
        return nil;
    }

    return _value;
}

@end
