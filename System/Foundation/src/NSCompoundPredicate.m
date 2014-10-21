//
//  NSCompoundPredicate.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/NSCompoundPredicate.h>

#import "NSCompoundPredicateOperator.h"
#import "NSNestedDictionary.h"
#import "NSPredicateInternal.h"
#import "_NSPredicateUtilities.h"

#import <Foundation/NSException.h>
#import <Foundation/NSKeyedArchiver.h>
#import <Foundation/NSOrderedSet.h>

static NSString * const NSSubpredicatesKey = @"NSSubpredicates";
static NSString * const NSCompoundPredicateTypeKey = @"NSCompoundPredicateType";

@implementation NSCompoundPredicate
{
    void *_reserved2;
    NSCompoundPredicateType _type;
    NSArray *_subpredicates;
}

+ (BOOL)supportsSecureCoding
{
    return YES;
}

+ (id)_operatorForType:(NSCompoundPredicateType)type
{
    switch ((NSUInteger)type)
    {
        case NSNotPredicateType:
        {
            return [NSCompoundPredicateOperator notPredicateOperator];
        }
        case NSAndPredicateType:
        {
            return [NSCompoundPredicateOperator andPredicateOperator];
        }
        case NSOrPredicateType:
        {
            return [NSCompoundPredicateOperator orPredicateOperator];
        }
        default:
        {
            [NSException raise:NSInternalInconsistencyException format:@"Bad compound predicate type"];
            return nil;
        }
    }
}

+ (NSPredicate *)andPredicateWithSubpredicates:(NSArray *)subpredicates
{
    return [[[self alloc] initWithType:NSAndPredicateType subpredicates:subpredicates] autorelease];
}

+ (NSPredicate *)orPredicateWithSubpredicates:(NSArray *)subpredicates
{
    return [[[self alloc] initWithType:NSOrPredicateType subpredicates:subpredicates] autorelease];
}

+ (NSPredicate *)notPredicateWithSubpredicate:(NSPredicate *)predicate
{
    NSArray *subpredicates = [NSArray arrayWithObject:predicate];
    return [[[self alloc] initWithType:NSNotPredicateType subpredicates:subpredicates] autorelease];
}

- (id)initWithType:(NSCompoundPredicateType)type subpredicates:(NSArray *)subpredicates
{
    switch ((NSUInteger)type)
    {
        case NSNotPredicateType:
            if ([subpredicates count] == 0)
            {
                [NSException raise:NSInvalidArgumentException format:@"Not compound predicate must have at least one subpredicate"];
                [self release];
                return nil;
            }
        case NSAndPredicateType:
        case NSOrPredicateType:
            break;
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Bad compound predicate type"];
            return nil;
    }

    self = [super init];
    if (self != nil)
    {
        _type = type;
        _subpredicates = [subpredicates copy];
    }
    return self;
}

- (void)dealloc
{
    [_subpredicates release];
    [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone
{
    NSCompoundPredicateType type = [self compoundPredicateType];
    NSArray *subpredicates = [self subpredicates];

    return [[[self class] alloc] initWithType:type subpredicates:subpredicates];
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
        NSSet *predicateAllowedClasses = [_NSPredicateUtilities _compoundPredicateClassesForSecureCoding];
        NSSet *allowedClasses = _NSPredicateAllowedClasses(decoder, predicateAllowedClasses);

        _type = [decoder decodeIntegerForKey:NSCompoundPredicateTypeKey];
        _subpredicates = [[decoder decodeObjectOfClasses:allowedClasses forKey:NSSubpredicatesKey] retain];

        if (![_subpredicates isKindOfClass:[NSArray self]] &&
            ![_subpredicates isKindOfClass:[NSOrderedSet self]] &&
            ![_subpredicates isKindOfClass:[NSSet self]])
        {
            [self release];
            [NSException raise:NSInvalidUnarchiveOperationException format:@"Bad subpredicate collection class %@", _subpredicates];
            return nil;
        }

        for (id pred in _subpredicates)
        {
            if (![pred isKindOfClass:[NSPredicate self]])
            {
                [self release];
                [NSException raise:NSInvalidUnarchiveOperationException format:@"Bad decoded predicate %@", pred];
                return nil;
            }
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

    [coder encodeObject:[self subpredicates] forKey:NSSubpredicatesKey];
    [coder encodeInteger:[self compoundPredicateType] forKey:NSCompoundPredicateTypeKey];
}

- (id)predicateOperator
{
    return [self _predicateOperator];
}

- (NSCompoundPredicateOperator *)_predicateOperator
{
    return [[self class] _operatorForType:[self compoundPredicateType]];
}

- (id)predicateWithSubstitutionVariables:(NSDictionary *)variables
{
    if (!_NSPredicateSubstitutionCheck(variables))
    {
        return nil;
    }

    NSMutableArray *newSubpredicates = [NSMutableArray array];

    for (NSPredicate *pred in [self subpredicates])
    {
        [newSubpredicates addObject:[pred predicateWithSubstitutionVariables:variables]];
    }

    return [[[[self class] alloc] initWithType:[self compoundPredicateType] subpredicates:newSubpredicates] autorelease];
}

- (void)acceptVisitor:(id)visitor flags:(NSPredicateVisitorFlags)flags
{
    if ((flags & NSPredicateVisitorVisitInternalNodes) != 0)
    {
        [visitor visitPredicate:self];
        [self _acceptSubpredicates:visitor flags:flags];
    }
    else
    {
        [self _acceptSubpredicates:visitor flags:flags];
        [visitor visitPredicate:self];
    }
}

- (void)_acceptSubpredicates:(id)visitor flags:(NSPredicateVisitorFlags)flags
{
    for (NSPredicate *pred in [self subpredicates])
    {
        [pred acceptVisitor:visitor flags:flags];
    }
}

- (BOOL)evaluateWithObject:(id)object substitutionVariables:(NSDictionary *)variables
{
    if (!_NSPredicateEvaluationCheck(self))
    {
        return NO;
    }

    NSCompoundPredicateOperator *op = [self _predicateOperator];
    if (op == nil)
    {
        return NO;
    }

    NSArray *subpredicates = [self subpredicates];
    if (subpredicates == nil)
    {
        return NO;
    }

    Class nestedDictClass = [_NSNestedDictionary class];
    size_t nestedDictSize = class_getInstanceSize(nestedDictClass);
    char nestedDictBuffer[nestedDictSize];

    _NSNestedDictionary *nestedDict;
    if (variables == nil || [variables isKindOfClass:nestedDictClass])
    {
        nestedDict = (_NSNestedDictionary *)variables;
    }
    else
    {
        memset(nestedDictBuffer, 0, nestedDictSize);
        nestedDict = (_NSNestedDictionary *)nestedDictBuffer;
        object_setClass(nestedDict, nestedDictClass);
        nestedDict->_bindings = variables;
    }

    BOOL evaluation = [op evaluatePredicates:subpredicates withObject:object substitutionVariables:nestedDict];

    if ((void *)nestedDict == (void *)nestedDictBuffer && nestedDict->_locals != nil)
    {
        [nestedDict->_locals release];
    }

    return evaluation;
}

- (NSUInteger)hash
{
    return [[self subpredicates] hash];
}

- (BOOL)isEqual:(id)other
{
    if (self == other)
    {
        return YES;
    }
    if (![other isKindOfClass:[NSCompoundPredicate self]])
    {
        return NO;
    }
    if ([self compoundPredicateType] != [self compoundPredicateType])
    {
        return NO;
    }
    if (![[self subpredicates] isEqual:[other subpredicates]])
    {
        return NO;
    }
    return YES;
}

- (NSString *)predicateFormat
{
    NSUInteger count = [[self subpredicates] count];
    NSCompoundPredicateType type = [self compoundPredicateType];

    if (count == 0)
    {
        switch (type)
        {
            case NSNotPredicateType:
                [NSException raise:NSInternalInconsistencyException format:@"Not predicate must have exactly one subpredicate"];
                return nil;
            case NSAndPredicateType:
                return [[NSTruePredicate defaultInstance] predicateFormat];
            case NSOrPredicateType:
                return [[NSFalsePredicate defaultInstance] predicateFormat];
        }
    }

    NSArray *subpredicates = [self subpredicates];

    if (count == 1)
    {
        NSPredicate *subpredicate = [subpredicates objectAtIndex:0];
        switch (type)
        {
            case NSNotPredicateType:
                return [NSString stringWithFormat:@"%@ %@", [[self _predicateOperator] description], [self _subpredicateDescription:subpredicate]];
            case NSAndPredicateType:
            case NSOrPredicateType:
                return [subpredicate predicateFormat];
        }
    }

    NSString *op = [NSString stringWithFormat:@" %@ ", [[self _predicateOperator] description]];

    NSMutableString *desc = [NSMutableString stringWithString:[self _subpredicateDescription:[subpredicates objectAtIndex:0]]];

    for (NSUInteger idx = 1; idx < count; idx++)
    {
        [desc appendString:op];
        [desc appendString:[self _subpredicateDescription:[subpredicates objectAtIndex:idx]]];
    }

    return desc;
}

- (NSString *)_subpredicateDescription:(NSPredicate *)subpredicate
{
    NSString *subpredicateDesc = [subpredicate description];

    if ([subpredicate isKindOfClass:[NSCompoundPredicate class]])
    {
        return [NSString stringWithFormat:@"(%@)", subpredicateDesc];
    }
    else
    {
        return subpredicateDesc;
    }
}

- (NSArray *)subpredicates
{
    return _subpredicates;
}

- (NSCompoundPredicateType)compoundPredicateType
{
    return _type;
}

- (void)allowEvaluation
{
    for (NSPredicate *pred in _subpredicates)
    {
        [pred allowEvaluation];
    }

    [super allowEvaluation];
}

@end
