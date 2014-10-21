//
//  NSCustomPredicateOperator.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "NSCustomPredicateOperator.h"

#import <objc/message.h>

static NSString * const NSSelectorNameKey = @"NSSelectorName";

@implementation NSCustomPredicateOperator
{
    SEL _selector;
}

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (id)initWithCustomSelector:(SEL)customSelector modifier:(NSComparisonPredicateModifier)modifier
{
    self = [super initWithOperatorType:NSCustomSelectorPredicateOperatorType modifier:modifier];
    if (self != nil)
    {
        _selector = customSelector;
    }
    return self;
}

- (BOOL)performPrimitiveOperationUsingObject:(id)target andObject:(id)arg
{
    if (target == nil)
    {
        [NSException raise:NSInvalidArgumentException format:@"Cannot perform operation on nil target"];
        return NO;
    }

    return (BOOL)objc_msgSend(target, [self selector], arg);
}

- (id)symbol
{
    return NSStringFromSelector(_selector);
}

- (BOOL)isEqual:(id)other
{
    if (other == self)
    {
        return YES;
    }
    if (![other isKindOfClass:[NSCustomPredicateOperator class]])
    {
        return NO;
    }
    if ([other operatorType] != [self operatorType])
    {
        return NO;
    }
    if ([other selector] != [self selector])
    {
        return NO;
    }
    return [other modifier] == [self modifier];
}

- (SEL)selector
{
    return _selector;
}

- (id)copyWithZone:(NSZone *)zone
{
    return [[NSCustomPredicateOperator alloc] initWithCustomSelector:[self selector] modifier:[self modifier]];
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
        _selector = NSSelectorFromString([decoder decodeObjectForKey:NSSelectorNameKey]);
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

    [coder encodeObject:NSStringFromSelector(_selector) forKey:NSSelectorNameKey];
}

@end
