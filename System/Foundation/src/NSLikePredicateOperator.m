//
//  NSLikePredicateOperator.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "NSLikePredicateOperator.h"

@implementation NSLikePredicateOperator

- (BOOL)_shouldEscapeForLike
{
    return YES;
}

- (SEL)selector
{
    return sel_registerName("like:");
}

- (NSString *)symbol
{
    return [@"LIKE" stringByAppendingString:[self _modifierString]];
}

@end
