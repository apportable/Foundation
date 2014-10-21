//
//  NSConstantValueExpression.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "NSExpressionInternal.h"
#import "_NSPredicateUtilities.h"

#import <objc/runtime.h>

static NSString * const NSConstantValueKey = @"NSConstantValue";
static NSString * const NSConstantValueClassNameKey = @"NSConstantValueClassName";

@implementation NSConstantValueExpression
{
    id constantValue;
}

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (void)dealloc
{
    [constantValue release];
    [super dealloc];
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
        NSSet *predicateAllowedClasses = [_NSPredicateUtilities _constantValueClassesForSecureCoding];
        NSSet *allowedClasses = _NSPredicateAllowedClasses(decoder, predicateAllowedClasses);

        constantValue = [[decoder decodeObjectOfClasses:allowedClasses forKey:NSConstantValueKey] retain];
        if (constantValue == nil)
        {
            NSString *className = [decoder decodeObjectOfClass:[NSString self] forKey:NSConstantValueClassNameKey];
            constantValue = NSClassFromString(className);
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

    id value = [self constantValue];

    if (class_isMetaClass(object_getClass(value)))
    {
        [coder encodeObject:NSStringFromClass([value class]) forKey:NSConstantValueClassNameKey];
    }
    else
    {
        [coder encodeObject:value forKey:NSConstantValueKey];
    }
}

- (NSUInteger)hash
{
    return [constantValue hash];
}

- (BOOL)isEqual:(id)other
{
    if (self == other)
    {
        return YES;
    }
    if (![other isKindOfClass:[NSConstantValueExpression self]])
    {
        return NO;
    }
    return [constantValue isEqual:[other constantValue]];
}

- (id)copyWithZone:(NSZone *)zone
{
    return [[[self class] alloc] initWithObject:constantValue];
}

- (id)initWithObject:(id)object
{
    self = [super initWithExpressionType:NSConstantValueExpressionType];
    if (self != nil)
    {
        constantValue = [object retain];
    }
    return self;
}

- (id)expressionValueWithObject:(id)object context:(NSMutableDictionary *)context
{
    if (!_NSExpressionEvaluationCheck(self))
    {
        return nil;
    }

    return constantValue;
}

- (id)expressionValueWithObject:(id)object
{
    if (!_NSExpressionEvaluationCheck(self))
    {
        return nil;
    }

    return constantValue;
}

- (id)constantValue
{
    return constantValue;
}

- (NSString *)predicateFormat
{
    if (constantValue == nil)
    {
        return @"nil";
    }

    if ([constantValue isNSValue__])
    {
        return [constantValue description];
    }

    if ([constantValue isNSString__])
    {
        return [_NSPredicateUtilities _parserableStringDescription:(NSString *)constantValue];
    }

    if ([constantValue isNSDate__])
    {
        return [_NSPredicateUtilities _parserableDateDescription:(NSDate *)constantValue];
    }

    if ([constantValue isNSArray__] ||
        [constantValue isNSDictionary__] ||
        [constantValue isNSSet__] ||
        [constantValue isNSOrderedSet__])
    {
        return [_NSPredicateUtilities _parserableCollectionDescription:constantValue];
    }

    return [constantValue description];
}

@end
