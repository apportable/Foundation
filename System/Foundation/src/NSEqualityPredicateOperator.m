//
//  NSEqualityPredicateOperator.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "NSEqualityPredicateOperator.h"

#import "_NSPredicateOperatorUtilities.h"

#import <objc/message.h>

@implementation NSEqualityPredicateOperator
{
    BOOL _negate;
    NSComparisonPredicateOptions _options;
}

static NSString * const NSNegateKey = @"NSNegate";
static NSString * const NSOptionsKey = @"NSOptions";

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (id)initWithOperatorType:(NSPredicateOperatorType)type modifier:(NSComparisonPredicateModifier)modifier negate:(BOOL)negate options:(NSComparisonPredicateOptions)options
{
    self = [super initWithOperatorType:type modifier:modifier];
    if (self != nil)
    {
        _negate = negate;
        _options = options;
    }
    return self;
}

- (id)initWithOperatorType:(NSPredicateOperatorType)type modifier:(NSComparisonPredicateModifier)modifier negate:(BOOL)negate
{
    self = [super initWithOperatorType:type modifier:modifier];
    if (self != nil)
    {
        _negate = negate;
    }
    return self;
}

- (BOOL)performPrimitiveOperationUsingObject:(id)lhs andObject:(id)rhs
{
    if (lhs == nil && rhs == nil)
    {
        return !_negate;
    }

    if (lhs == nil || rhs == nil)
    {
        return _negate;
    }

    if (_options == 0 ||
        ![lhs isNSString__] ||
        ![rhs isNSString__])
    {
        SEL sel = [self selector];
        BOOL eq = (BOOL)objc_msgSend(lhs, sel, rhs);
        return _negate ^ eq;
    }

    CFLocaleRef locale = NULL;
    if ((_options & NSLocaleSensitivePredicateOption) != 0)
    {
        locale = [_NSPredicateOperatorUtilities retainedLocale];
        [(id)locale autorelease];
    }

    CFStringCompareFlags flags = 0;
    if ((_options & NSNormalizedPredicateOption) == 0)
    {
        if ((_options & NSCaseInsensitivePredicateOption) != 0)
        {
            flags |= kCFCompareCaseInsensitive;
            flags |= kCFCompareWidthInsensitive;
        }
        if ((_options & NSDiacriticInsensitivePredicateOption) != 0)
        {
            flags |= kCFCompareDiacriticInsensitive;
            flags |= kCFCompareWidthInsensitive;
        }
    }
    switch (CFStringCompareWithOptionsAndLocale((CFStringRef)lhs, (CFStringRef)rhs, CFRangeMake(0, [lhs length]), flags, locale))
    {
        case kCFCompareEqualTo:
            return !_negate;
        default:
            return _negate;
    }
}

- (id)copyWithZone:(NSZone *)zone
{
    NSPredicateOperatorType type = [self operatorType];
    NSComparisonPredicateModifier modifier = [self modifier];
    NSComparisonPredicateOptions options = [self options];
    BOOL isNegation = [self isNegation];

    return [[[self class] alloc] initWithOperatorType:type modifier:modifier negate:isNegation options:options];
}

- (BOOL)isEqual:(id)other
{
    if (self == other)
    {
        return YES;
    }
    if (![other isKindOfClass:[NSEqualityPredicateOperator self]])
    {
        return NO;
    }
    if ([self operatorType] != [other operatorType])
    {
        return NO;
    }
    if ([self modifier] != [other modifier])
    {
        return NO;
    }
    if ([self isNegation] != [other isNegation])
    {
        return NO;
    }
    if ([self options] != [other options])
    {
        return NO;
    }
    return YES;
}

- (void)_setOptions:(NSComparisonPredicateOptions)options
{
    _options = options;
}

- (NSComparisonPredicateOptions)options
{
    return _options;
}

- (void)setNegation:(BOOL)negation
{
    _negate = negation;
}

- (BOOL)isNegation
{
    return _negate;
}

- (NSString *)predicateFormat
{
    return [NSString stringWithFormat:@"%@%@", [self symbol], comparisonPredicateOptionDescription(_options)];
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
        _negate = [decoder decodeBoolForKey:NSNegateKey];
        _options = [decoder decodeIntegerForKey:NSOptionsKey];
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

    [coder encodeBool:_negate forKey:NSNegateKey];
    [coder encodeInteger:_options forKey:NSOptionsKey];
}

@end
