//
//  NSPredicate.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "NSPredicateInternal.h"
#import "_NSPredicateOperatorUtilities.h"
#import <Foundation/NSArray.h>
#import <Foundation/NSDictionary.h>
#import "NSObjectInternal.h"
#import <Foundation/NSOrderedSet.h>
#import <Foundation/NSSet.h>
#import <Foundation/NSString.h>
#import "_NSPredicateOperatorUtilities.h"

#import <CoreFoundation/CFLocale.h>

@implementation NSPredicate
{
    NSPredicateEvaluationFlags _predicateFlags;
    NSUInteger reserved;
}

+ (NSPredicate *)predicateWithFormat:(NSString *)predicateFormat argumentArray:(NSArray *)arguments
{
    return _parsePredicateArray(predicateFormat, arguments);
}

+ (NSPredicate *)predicateWithFormat:(NSString *)predicateFormat, ...
{
    va_list args;
    va_start(args, predicateFormat);
    NSPredicate *predicate = [self predicateWithFormat:predicateFormat arguments:args];
    va_end(args);
    return predicate;
}

+ (NSPredicate *)predicateWithFormat:(NSString *)predicateFormat arguments:(va_list)args
{
    return _parsePredicateVarArgs(predicateFormat, args);
}

+ (NSPredicate *)predicateWithValue:(BOOL)value
{
    if (value)
    {
        return [[[NSTruePredicate alloc] init] autorelease];
    }
    else
    {
        return [[[NSFalsePredicate alloc] init] autorelease];
    }
}

+ (NSPredicate *)predicateWithBlock:(BOOL (^)(id evaluatedObject, NSDictionary *bindings))block
{
    return [[[NSBlockPredicate alloc] initWithBlock:block] autorelease];
}

+ (NSString *)newStringFrom:(id)source usingUnicodeTransforms:(unsigned long long)transforms
{
    return [_NSPredicateOperatorUtilities newStringFrom:source usingUnicodeTransforms:transforms];
}

+ (BOOL)supportsSecureCoding
{
    return YES;
}

+ (CFLocaleRef)retainedLocale
{
    return [_NSPredicateOperatorUtilities retainedLocale];
}

- (NSString *)predicateFormat
{
    NSRequestConcreteImplementation();
    return nil;
}

- (NSPredicate *)predicateWithSubstitutionVariables:(NSDictionary *)substitution
{
    if (substitution == nil)
    {
        [NSException raise:NSInvalidArgumentException format:@"Cannot substitute nil bindings"];
        return nil;
    }

    return self;
}

- (BOOL)evaluateWithObject:(id)object
{
    return [self evaluateWithObject:object substitutionVariables:nil];
}

- (BOOL)evaluateWithObject:(id)object substitutionVariables:(NSDictionary *)variables
{
    NSRequestConcreteImplementation();
    return NO;
}

- (NSString *)description
{
    return [self predicateFormat];
}

- (void)acceptVisitor:(id)visitor flags:(NSPredicateVisitorFlags)flags
{
    NSRequestConcreteImplementation();
}

- (id)copyWithZone:(NSZone *)zone
{
    NSRequestConcreteImplementation();
    return nil;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if (_NSPredicateKeyedArchiverCheck(decoder))
    {
        [self release];
        return nil;
    }

    self = [self init];
    if (self != nil)
    {
        _predicateFlags = ~NSPredicateEvaluationBlocked;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    _NSPredicateKeyedArchiverCheck(coder);
}

- (void)allowEvaluation
{
    _predicateFlags &= ~NSPredicateEvaluationBlocked;
}

- (BOOL)_allowsEvaluation
{
    return !((_predicateFlags & NSPredicateEvaluationBlocked) != 0);
}

@end

static NSUInteger __filterObjectsUsingPredicate(id container, id *objects, NSPredicate *predicate)
{
    NSUInteger count = 0;
    for (id object in container)
    {
        if ([predicate evaluateWithObject:object])
        {
            objects[count] = object;
            count++;
        }
    }
    return count;
}

@implementation NSArray (NSPredicateSupport)

- (NSArray *)filteredArrayUsingPredicate:(NSPredicate *)predicate
{
    if (predicate == nil)
    {
        [NSException raise:NSInvalidArgumentException format:@"nil predicate is invalid"];
        return nil;
    }

    NSUInteger count = [self count];
    id *objects = malloc(sizeof(id) * count);
    if (objects == NULL)
    {
        [NSException raise:NSMallocException format:@"unable to allocate object buffer"];
        return nil;
    }

    count = __filterObjectsUsingPredicate(self, objects, predicate);
    NSArray *results = [[NSArray alloc] initWithObjects:objects count:count];
    free(objects);
    return [results autorelease];
}

@end

@implementation NSMutableArray (NSPredicateSupport)

- (void)filterUsingPredicate:(NSPredicate *)predicate
{
    if (predicate == nil)
    {
        [NSException raise:NSInvalidArgumentException format:@"nil predicate is invalid"];
        return;
    }

    NSUInteger count = [self count];
    id *objects = malloc(sizeof(id) * count);
    if (objects == NULL)
    {
        [NSException raise:NSMallocException format:@"unable to allocate object buffer"];
        return;
    }

    count = __filterObjectsUsingPredicate(self, objects, predicate);
    NSArray *results = [[NSArray alloc] initWithObjects:objects count:count];
    [self setArray:results];
    [results release];
    free(objects);
}

@end

@implementation NSSet (NSPredicateSupport)

- (NSSet *)filteredSetUsingPredicate:(NSPredicate *)predicate
{
    if (predicate == nil)
    {
        [NSException raise:NSInvalidArgumentException format:@"nil predicate is invalid"];
        return nil;
    }

    NSUInteger count = [self count];
    id *objects = malloc(sizeof(id) * count);
    if (objects == NULL)
    {
        [NSException raise:NSMallocException format:@"unable to allocate object buffer"];
        return nil;
    }

    count = __filterObjectsUsingPredicate(self, objects, predicate);
    NSSet *results = [[NSSet alloc] initWithObjects:objects count:count];
    free(objects);
    return [results autorelease];
}

@end

@implementation NSMutableSet (NSPredicateSupport)

- (void)filterUsingPredicate:(NSPredicate *)predicate
{
    if (predicate == nil)
    {
        [NSException raise:NSInvalidArgumentException format:@"nil predicate is invalid"];
        return;
    }

    NSUInteger count = [self count];
    id *objects = malloc(sizeof(id) * count);
    if (objects == NULL)
    {
        [NSException raise:NSMallocException format:@"unable to allocate object buffer"];
        return;
    }

    count = __filterObjectsUsingPredicate(self, objects, predicate);
    NSSet *results = [[NSSet alloc] initWithObjects:objects count:count];
    [self setSet:results];
    [results release];
    free(objects);
}

@end

@implementation NSOrderedSet (NSPredicateSupport)

- (NSOrderedSet *)filteredOrderedSetUsingPredicate:(NSPredicate *)predicate
{
    if (predicate == nil)
    {
        [NSException raise:NSInvalidArgumentException format:@"nil predicate is invalid"];
        return nil;
    }

    NSUInteger count = [self count];
    id *objects = malloc(sizeof(id) * count);
    if (objects == NULL)
    {
        [NSException raise:NSMallocException format:@"unable to allocate object buffer"];
        return nil;
    }

    count = __filterObjectsUsingPredicate(self, objects, predicate);
    NSOrderedSet *results = [[NSOrderedSet alloc] initWithObjects:objects count:count];
    free(objects);
    return [results autorelease];
}

@end

@interface NSMutableOrderedSet (Internal)
- (void)setOrderedSet:(NSOrderedSet *)orderedSet;
@end

@implementation NSMutableOrderedSet (NSPredicateSupport)

- (void)filterUsingPredicate:(NSPredicate *)predicate
{
    if (predicate == nil)
    {
        [NSException raise:NSInvalidArgumentException format:@"nil predicate is invalid"];
        return;
    }

    NSUInteger count = [self count];
    id *objects = malloc(sizeof(id) * count);
    if (objects == NULL)
    {
        [NSException raise:NSMallocException format:@"unable to allocate object buffer"];
        return;
    }

    count = __filterObjectsUsingPredicate(self, objects, predicate);
    NSOrderedSet *results = [[NSOrderedSet alloc] initWithObjects:objects count:count];
    [self setOrderedSet:results];
    [results release];
    free(objects);
}

@end
