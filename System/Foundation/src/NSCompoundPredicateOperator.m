//
//  NSCompoundPredicateOperator.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "NSCompoundPredicateOperator.h"

#import <dispatch/dispatch.h>
#import <Foundation/NSCompoundPredicate.h>

@implementation NSCompoundPredicateOperator

+ (NSCompoundPredicateOperator *)notPredicateOperator
{
    static NSCompoundPredicateOperator *notPO;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        notPO = [[NSCompoundPredicateOperator alloc] initWithOperatorType:(NSPredicateOperatorType)NSNotPredicateType];
    });
    return notPO;
}

+ (NSCompoundPredicateOperator *)orPredicateOperator
{
    static NSCompoundPredicateOperator *orPO;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        orPO = [[NSCompoundPredicateOperator alloc] initWithOperatorType:(NSPredicateOperatorType)NSOrPredicateType];
    });
    return orPO;
}

+ (NSCompoundPredicateOperator *)andPredicateOperator
{
    static NSCompoundPredicateOperator *andPO;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        andPO = [[NSCompoundPredicateOperator alloc] initWithOperatorType:(NSPredicateOperatorType)NSAndPredicateType];
    });
    return andPO;
}

- (BOOL)evaluatePredicates:(NSArray *)predicates withObject:(id)object substitutionVariables:(NSDictionary *)variables
{
    switch ((NSUInteger)[self operatorType])
    {
        case NSNotPredicateType:
        {
            NSPredicate *pred = [predicates objectAtIndex:0];
            return ![pred evaluateWithObject:object substitutionVariables:variables];
        }
        case NSAndPredicateType:
        {
            for (NSPredicate *pred in predicates)
            {
                if (![pred evaluateWithObject:object substitutionVariables:variables])
                {
                    return NO;
                }
            }
            return YES;
        }
        case NSOrPredicateType:
        {
            for (NSPredicate *pred in predicates)
            {
                if ([pred evaluateWithObject:object substitutionVariables:variables])
                {
                    return YES;
                }
            }
            return NO;
        }
        default:
        {
            [NSException raise:NSInternalInconsistencyException format:@"Bad compound predicate operator type %ld", (long)[self operatorType]];
            return NO;
        }
    }
}

- (BOOL)evaluatePredicates:(id)predicates withObject:(id)object
{
    return [self evaluatePredicates:predicates withObject:object substitutionVariables:nil];
}

- (NSString *)symbol
{
    switch ((NSUInteger)[self operatorType])
    {
        case NSNotPredicateType:
            return @"NOT";
        case NSAndPredicateType:
            return @"AND";
        case NSOrPredicateType:
            return @"OR";
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Bad compound predicate operator type %ld", (long)[self operatorType]];
            return nil;
    }
}

- (NSString *)predicateFormat
{
    return [self symbol];
}

- (id)copyWithZone:(NSZone *)zone
{
    return [self retain];
}

@end
