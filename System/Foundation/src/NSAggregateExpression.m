//
//  NSAggregateExpression.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "NSExpressionInternal.h"

#import <Foundation/NSDictionary.h>
#import <Foundation/NSException.h>
#import <Foundation/NSKeyedArchiver.h>
#import <Foundation/NSNull.h>
#import <Foundation/NSOrderedSet.h>

#import "NSObjectInternal.h"
#import "_NSPredicateUtilities.h"

@implementation NSAggregateExpression
{
    id _collection;
}

static NSString * const NSCollectionKey = @"NSCollection";

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (void)dealloc
{
    [_collection release];
    [super dealloc];
}

- (id)initWithCollection:(id)collection
{
    if (![collection isNSArray__] &&
        ![collection isNSSet__] &&
        ![collection isNSOrderedSet__])
    {
        [NSException raise:NSInvalidArgumentException format:@"Collection must be an array, set, or ordered set"];
        [self release];
        return nil;
    }

    self = [super initWithExpressionType:NSAggregateExpressionType];
    if (self != nil)
    {
        _collection = [collection retain];
    }
    return self;
}

- (void)acceptVisitor:(id)visitor flags:(NSPredicateVisitorFlags)flags
{
    if ((flags & NSPredicateVisitorVisitExpressions) == 0)
    {
        return;
    }

    if ((flags & NSPredicateVisitorVisitInternalNodes) != 0)
    {
        [visitor visitPredicateExpression:self];
    }

    for (NSExpression *e in _collection)
    {
        [e acceptVisitor:visitor flags:flags];
    }

    if ((flags & NSPredicateVisitorVisitInternalNodes) != 0)
    {
        [visitor visitPredicateExpression:self];
    }
}

- (id)expressionValueWithObject:(id)object context:(NSMutableDictionary *)context
{
    if (!_NSExpressionEvaluationCheck(self))
    {
        return nil;
    }

    NSMutableArray *value = [[[NSMutableArray alloc] init] autorelease];

    for (NSExpression *e in _collection)
    {
        id v = [e expressionValueWithObject:object context:context];
        if (v == nil)
        {
            v = [NSNull null];
        }
        [value addObject:v];
    }

    return value;
}

- (NSUInteger)hash
{
    return [_collection hash];
}

- (BOOL)isEqual:(id)other
{
    if (self == other)
    {
        return YES;
    }
    if (![other isKindOfClass:[NSAggregateExpression self]])
    {
        return NO;
    }
    return [_collection isEqual:[(NSAggregateExpression *)other collection]];
}

- (id)copyWithZone:(NSZone *)zone
{
    return [[[self class] alloc] initWithCollection:_collection];
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
        NSSet *predicateAllowedClasses = [_NSPredicateUtilities _extendedExpressionClassesForSecureCoding];
        NSSet *allowedClasses = _NSPredicateAllowedClasses(decoder, predicateAllowedClasses);

        _collection = [[decoder decodeObjectOfClasses:allowedClasses forKey:NSCollectionKey] retain];
        if (_collection == nil)
        {
            return self;
        }

        if (![_collection isKindOfClass:[NSArray self]] &&
            ![_collection isKindOfClass:[NSDictionary self]] &&
            ![_collection isKindOfClass:[NSOrderedSet self]] &&
            ![_collection isKindOfClass:[NSSet self]])
        {
            [self release];
            [NSException raise:NSInvalidUnarchiveOperationException format:@"Bad subpredicate collection class %@", [_collection class]];
            return nil;
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

    [coder encodeObject:_collection forKey:NSCollectionKey];
}

- (id)collection
{
    return _collection;
}

- (id)constantValue
{
    return _collection;
}

- (NSString *)predicateFormat
{
    if ([_collection isNSArray__] ||
        [_collection isNSDictionary__] ||
        [_collection isNSOrderedSet__] ||
        [_collection isNSSet__])
    {
        return [_NSPredicateUtilities _parserableCollectionDescription:_collection];
    }
    else
    {
        return [_collection description];
    }
}

- (void)allowEvaluation
{
    for (NSExpression *e in _collection)
    {
        [e allowEvaluation];
    }

    [super allowEvaluation];
}

- (NSExpression *)_expressionWithSubstitutionVariables:(NSDictionary *)variables
{
    if (!_NSPredicateSubstitutionCheck(variables))
    {
        return nil;
    }

    NSMutableArray *newCollection = [[[NSMutableArray alloc] init] autorelease];

    for (NSExpression *e in _collection)
    {
        [newCollection addObject:[e _expressionWithSubstitutionVariables:variables]];
    }

    return [[[[self class] alloc] initWithCollection:newCollection] autorelease];
}

@end
