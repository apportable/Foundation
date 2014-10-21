//
//  NSBetweenPredicateOperator.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "NSBetweenPredicateOperator.h"

#import <objc/message.h>

@implementation NSBetweenPredicateOperator

- (void)_setOptions:(NSComparisonPredicateOptions)options
{
}

- (BOOL)performPrimitiveOperationUsingObject:(id)obj andObject:(NSArray *)array
{
    if (obj == nil || array == nil)
    {
        return NO;
    }

    if (![array isNSArray__])
    {
        [NSException raise:NSInvalidArgumentException format:@"Cannot use between predicate operator on non-array %@", array];
        return NO;
    }

    if ([array count] != 2)
    {
        [NSException raise:NSInvalidArgumentException format:@"Must use between predicate operator on array with 2 elements"];
        return NO;
    }

    id upperBound = [array objectAtIndex:0];
    id lowerBound = [array objectAtIndex:1];

    SEL comp = [self selector];

    if ((NSComparisonResult)objc_msgSend(upperBound, comp, lowerBound) == NSOrderedAscending)
    {
        id temp = upperBound;
        upperBound = lowerBound;
        lowerBound = temp;
    }

    if ((NSComparisonResult)objc_msgSend(upperBound, comp, obj) ==  NSOrderedAscending ||
        (NSComparisonResult)objc_msgSend(obj, comp, lowerBound) ==  NSOrderedAscending)
    {
        return NO;
    }

    return YES;
}

- (id)copyWithZone:(NSZone *)zone
{
    NSPredicateOperatorType type = [self operatorType];
    NSComparisonPredicateModifier modifier = [self modifier];

    return [[self class] _newOperatorWithType:type modifier:modifier options:0];
}

@end
