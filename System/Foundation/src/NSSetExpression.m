//
//  NSSetExpression.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "NSExpressionInternal.h"

#import "_NSPredicateUtilities.h"

#import <Foundation/NSKeyedArchiver.h>

@implementation NSSetExpression
{
    NSExpression *_left;
    NSExpression *_right;
}

static NSString * const NSLeftExpressionKey = @"NSLeftExpression";
static NSString * const NSRightExpressionKey = @"NSRightExpression";

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (void)dealloc
{
    [_left release];
    [_right release];
    [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone
{
    NSExpression *left = [_left copy];
    NSExpression *right = [_right copy];
    NSExpressionType type = [self expressionType];

    NSSetExpression *copy = [[[self class] alloc] initWithType:type leftExpression:left rightExpression:right];

    [left release];
    [right release];

    return copy;
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
        NSSet *predicateAllowedClasses = [_NSPredicateUtilities _expressionClassesForSecureCoding];
        NSSet *allowedClasses = _NSPredicateAllowedClasses(decoder, predicateAllowedClasses);

        _left = [[decoder decodeObjectOfClasses:allowedClasses forKey:NSLeftExpressionKey] retain];
        _right = [[decoder decodeObjectOfClasses:allowedClasses forKey:NSRightExpressionKey] retain];

        if (![_left isKindOfClass:[NSExpression self]])
        {
            [self release];
            [NSException raise:NSInvalidUnarchiveOperationException format:@"Bad decoded expression %@", _left];
            return nil;
        }
        if (![_right isKindOfClass:[NSExpression self]])
        {
            [self release];
            [NSException raise:NSInvalidUnarchiveOperationException format:@"Bad decoded expression %@", _right];
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

    [coder encodeObject:[self leftExpression] forKey:NSLeftExpressionKey];
    [coder encodeObject:[self rightExpression] forKey:NSRightExpressionKey];
}

- (BOOL)isEqual:(id)other
{
    if (self == other)
    {
        return YES;
    }
    if ([self expressionType] != [other expressionType])
    {
        return NO;
    }
    if (![_left isEqual:[other leftExpression]])
    {
        return NO;
    }
    if (![_right isEqual:[other rightExpression]])
    {
        return NO;
    }
    return YES;
}

- (id)initWithType:(NSExpressionType)type leftExpression:(NSExpression *)left rightExpression:(NSExpression *)right
{
    self = [super initWithExpressionType:type];
    if (self != nil)
    {
        _left = [left retain];
        _right = [right retain];
    }
    return self;
}

- (NSExpression *)rightExpression
{
    return _right;
}

- (NSExpression *)leftExpression
{
    return _left;
}

- (void)allowEvaluation
{
    [_left allowEvaluation];
    [_right allowEvaluation];

    [super allowEvaluation];
}

- (NSString *)predicateFormat
{
    NSString *type = nil;
    switch ([self expressionType])
    {
        case NSMinusSetExpressionType:
            type = @"MINUS";
            break;
        case NSIntersectSetExpressionType:
            type = @"INTERSECT";
            break;
        case NSUnionSetExpressionType:
            type = @"UNION";
            break;
        default:
            DEBUG_BREAK();
    }

    return [NSString stringWithFormat:@"%@ %@ %@", [_left predicateFormat], type, [_right predicateFormat]];
}

- (void)acceptVisitor:(id)visitor flags:(NSPredicateVisitorFlags)flags
{
    if ((flags & NSPredicateVisitorVisitExpressions) != 0)
    {
        return;
    }

    if ((flags & NSPredicateVisitorVisitInternalNodes) != 0)
    {
        [visitor visitPredicateExpression:self];
    }

    [_left acceptVisitor:visitor flags:flags];
    [_right acceptVisitor:visitor flags:flags];

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

    id leftContainer = [[self leftExpression] expressionValueWithObject:object context:context];
    id leftSet = nil;
    if (leftContainer != nil)
    {
        if ([leftContainer isNSSet__])
        {
            leftSet = [[leftContainer mutableCopy] autorelease];
        }
        else if ([leftContainer isNSArray__])
        {
            leftSet = [NSSet setWithArray:leftContainer];
        }
        else if ([leftContainer isNSOrderedSet__])
        {
            leftSet = [NSSet setWithArray:[leftContainer array]];
        }
        else
        {
            [NSException raise:NSInvalidArgumentException format:@"Left hand side was not a collection"];
            return nil;
        }
    }

    id rightContainer = [[self rightExpression] expressionValueWithObject:object context:context];
    id rightSet = nil;
    if (rightContainer != nil)
    {
        if ([rightContainer isNSSet__])
        {
            rightSet = [[rightContainer mutableCopy] autorelease];
        }
        else if ([rightContainer isNSArray__])
        {
            rightSet = [NSSet setWithArray:rightContainer];
        }
        else if ([rightContainer isNSOrderedSet__])
        {
            rightSet = [NSSet setWithArray:[rightContainer array]];
        }
        else if ([rightContainer isNSDictionary__])
        {
            rightSet = [NSSet setWithArray:[rightContainer allValues]];
        }
        else
        {
            [NSException raise:NSInvalidArgumentException format:@"Right hand side was not a collection"];
            return nil;
        }
    }

    switch ([self expressionType])
    {
        case NSUnionSetExpressionType:
            [leftSet unionSet:rightSet];
            break;
        case NSIntersectSetExpressionType:
            [leftSet intersectSet:rightSet];
            break;
        case NSMinusSetExpressionType:
            [leftSet minusSet:rightSet];
            break;
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Bad set expression type %ld", (long)[self expressionType]];
            return nil;
    }

    return leftSet;
}

- (NSExpression *)_expressionWithSubstitutionVariables:(NSDictionary *)variables
{
    if (!_NSPredicateSubstitutionCheck(variables))
    {
        return nil;
    }

    NSExpressionType type = [self expressionType];
    NSExpression *left = [[self leftExpression] _expressionWithSubstitutionVariables:variables];
    NSExpression *right = [[self rightExpression] _expressionWithSubstitutionVariables:variables];

    return [[[NSSetExpression alloc] initWithType:type leftExpression:left rightExpression:right] autorelease];
}

@end
