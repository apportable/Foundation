//
//  NSFalsePredicate.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "NSPredicateInternal.h"

// this is public, probably because it is funny...
NSFalsePredicate *_NSTheOneFalsePredicate = nil;

@implementation NSFalsePredicate

+ (void)initialize
{
    if (_NSTheOneFalsePredicate == nil)
    {
        _NSTheOneFalsePredicate = NSAllocateObject(self, 0, NSDefaultMallocZone());
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

+ (NSFalsePredicate *)defaultInstance
{
    return _NSTheOneFalsePredicate;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return _NSTheOneFalsePredicate;
}

- (void)acceptVisitor:(id)visitor flags:(NSPredicateVisitorFlags)flags
{
    [visitor visitPredicate:self];
}

- (BOOL)evaluateWithObject:(id)object substitutionVariables:(NSDictionary *)variables
{
    return NO;
}

- (NSString *)predicateFormat
{
    return @"FALSEPREDICATE";
}

- (NSUInteger)hash
{
    return 0;
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
    if (!_NSPredicateKeyedArchiverCheck(decoder))
    {
        [self release];
        return nil;
    }

    return _NSTheOneFalsePredicate;
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
