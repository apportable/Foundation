//
//  NSTruePredicate.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "NSPredicateInternal.h"

// this is public, probably because it is funny...
NSTruePredicate *_NSTheOneTruePredicate = nil;

@implementation NSTruePredicate

+ (void)initialize
{
    if (_NSTheOneTruePredicate == nil)
    {
        _NSTheOneTruePredicate = NSAllocateObject(self, 0, NSDefaultMallocZone());
    }
}

+ (BOOL)_allowsEvaluation
{
    return YES;
}

+ (BOOL)supportsSecureCoding
{
    return YES;
}

+ (NSTruePredicate *)defaultInstance
{
    return _NSTheOneTruePredicate;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return _NSTheOneTruePredicate;
}

- (void)acceptVisitor:(id)visitor flags:(NSPredicateVisitorFlags)flags
{
    [visitor visitPredicate:self];
}

- (BOOL)evaluateWithObject:(id)object substitutionVariables:(NSDictionary *)variables
{
    return YES;
}

- (NSString *)predicateFormat
{
    return @"TRUEPREDICATE";
}

- (NSUInteger)hash
{
    return 1;
}

- (BOOL)isEqual:(id)other
{
    return self == other;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if (![decoder allowsKeyedCoding])
    {
        [NSException raise:NSInvalidArgumentException format:@"Coder must allow keyed coding for predicates"];
        return nil;
    }

    return _NSTheOneTruePredicate;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    if (!_NSPredicateKeyedArchiverCheck(coder))
    {
        return;
    }

    [super encodeWithCoder:coder];
}

SINGLETON_RR()

- (BOOL)_tryRetain
{
    return YES;
}

- (BOOL)_isDeallocating
{
    return NO;
}

@end
