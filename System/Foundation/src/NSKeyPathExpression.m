//
//  NSKeyPathExpression.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "NSExpressionInternal.h"

#import <Foundation/NSKeyValueCoding.h>

@implementation NSKeyPathExpression

- (void)dealloc
{
    [super dealloc];
}

- (id)initWithKeyPath:(id)keyPath
{
    NSSelfExpression *operand = [[NSSelfExpression alloc] init];
    NSMutableArray *args = [[NSMutableArray alloc] init];
    SEL selector = @selector(valueForKeyPath:);
    if ([keyPath isKindOfClass:[NSKeyPathSpecifierExpression class]] && [[keyPath keyPath] rangeOfString:@"."].location == NSNotFound)
    {
        selector = @selector(valueForKey:);
    }
    [args addObject:keyPath];
    self = [super initWithExpressionType:NSKeyPathExpressionType operand:operand selector:selector argumentArray:args];
    [operand release];
    [args release];
    return self;
}

- (id)initWithOperand:(id)operand andKeyPath:(id)keyPath
{
    NSMutableArray *args = [[NSMutableArray alloc] init];
    SEL selector = @selector(valueForKeyPath:);
    if ([keyPath isKindOfClass:[NSKeyPathSpecifierExpression class]] && [[keyPath keyPath] rangeOfString:@"."].location == NSNotFound)
    {
        selector = @selector(valueForKey:);
    }
    [args addObject:keyPath];
    self = [super initWithExpressionType:NSKeyPathExpressionType operand:operand selector:selector argumentArray:args];
    [args release];
    return self;
}

- (NSString *)keyPath
{
    if ([[self operand] isKindOfClass:[NSSelfExpression self]])
    {
        return [[self pathExpression] keyPath];
    }
    else
    {
        return [super keyPath];
    }
}

- (NSExpression *)pathExpression
{
    return [[self arguments] objectAtIndex:0];
}

- (NSString *)predicateFormat
{
    NSExpression *pathExpression = [self pathExpression];
    NSExpression *operand = [self operand];

    if ([operand isKindOfClass:[NSSelfExpression self]] && [pathExpression isKindOfClass:[NSKeyPathSpecifierExpression self]])
    {
        return [pathExpression predicateFormat];
    }

    NSString *pathDescription = [pathExpression predicateFormat];
    NSString *operandDescription = [operand predicateFormat];
    return [NSString stringWithFormat:@"%@.%@", operandDescription, pathDescription];
}

@end
