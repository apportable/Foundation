//
//  NSAnyKeyExpression.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "NSExpressionInternal.h"

@implementation NSAnyKeyExpression

#define NSAnyKeyExpressionHash 8674

static NSAnyKeyExpression *__anyKeyExpression;

+ (void)initialize
{
    if (__anyKeyExpression == nil)
    {
        __anyKeyExpression = NSAllocateObject([NSAnyKeyExpression self], 0, NULL);
        [__anyKeyExpression _initPrivate];
    }
}

+ (id)allocWithZone:(NSZone *)zone
{
    return __anyKeyExpression;
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
    return __anyKeyExpression;
}

- (id)_initPrivate
{
    self = [super initWithExpressionType:NSAnyKeyExpressionType];
    return self;
}

- (NSString *)predicateFormat
{
    return @"ANYKEY";
}

- (NSUInteger)hash
{
    return NSAnyKeyExpressionHash;
}

- (BOOL)isEqual:(id)other
{
    return [self class] == [other class];
}

- (id)expressionValueWithObject:(id)object context:(NSMutableDictionary *)context
{
    [NSException raise:NSInvalidArgumentException format:@"Cannot evaluate any key expression"];
    return nil;
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

- (id)initWithCoder:(NSCoder *)decoder
{
    if (!_NSPredicateKeyedArchiverCheck(decoder))
    {
        [self release];
        return nil;
    }

    return __anyKeyExpression;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    if (!_NSPredicateKeyedArchiverCheck(coder))
    {
        return;
    }

    [super encodeWithCoder:coder];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)init
{
    return self;
}

@end
