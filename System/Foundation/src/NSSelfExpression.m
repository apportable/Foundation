//
//  NSSelfExpression.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "NSExpressionInternal.h"

@implementation NSSelfExpression

static NSSelfExpression *__Self;

+ (void)initialize
{
    if (__Self == nil)
    {
        __Self = NSAllocateObject([NSSelfExpression self], 0, NULL);
        [__Self _initPrivate];
    }
}

+ (BOOL)_allowsEvaluation
{
    return YES;
}

+ (BOOL)supportsSecureCoding
{
    return YES;
}

+ (id)defaultInstance
{
    return __Self;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return __Self;
}

- (id)_initPrivate
{
    self = [super initWithExpressionType:NSSelfExpressionType];
    return self;
}

- (id)init
{
    return self;
}

- (NSUInteger)hash
{
    return NSSelfExpressionHash;
}

- (BOOL)isEqual:(id)other
{
    return [self class] == [other class];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if (!_NSPredicateKeyedArchiverCheck(decoder))
    {
        [self release];
        return nil;
    }

    return __Self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    if (!_NSPredicateKeyedArchiverCheck(coder))
    {
        return;
    }

    [super encodeWithCoder:coder];
}

- (id)autorelease
{
    return self;
}

- (BOOL)_tryRetain
{
    return YES;
}

- (BOOL)_isDeallocating
{
    return NO;
}

- (oneway void)release
{
}

- (NSUInteger)retainCount
{
    return NSUIntegerMax;
}

- (id)retain
{
    return self;
}

- (NSString *)predicateFormat
{
    return @"SELF";
}

- (id)expressionValueWithObject:(id)object context:(NSMutableDictionary *)context
{
    return object;
}

@end
