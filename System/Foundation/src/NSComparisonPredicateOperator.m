//
//  NSComparisonPredicateOperator.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "NSComparisonPredicateOperator.h"

#import "_NSPredicateOperatorUtilities.h"

#import <objc/message.h>

static NSString * const NSOptionsKey = @"NSOptions";
static NSString * const NSVariantKey = @"NSVariant";

@implementation NSComparisonPredicateOperator
{
    NSPredicateOperatorType _variant;
    NSComparisonPredicateOptions _options;
}

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (id)initWithOperatorType:(NSPredicateOperatorType)type modifier:(NSComparisonPredicateModifier)modifier variant:(NSPredicateOperatorType)variant options:(NSComparisonPredicateOptions)options
{
    self = [self initWithOperatorType:type modifier:modifier variant:variant];
    if (self != nil)
    {
        _options = options;
    }
    return self;
}

- (id)initWithOperatorType:(NSPredicateOperatorType)type modifier:(NSComparisonPredicateModifier)modifier variant:(NSPredicateOperatorType)variant
{
    self = [super initWithOperatorType:type modifier:modifier];
    if (self != nil)
    {
        _variant = variant;
    }
    return self;
}

- (BOOL)performPrimitiveOperationUsingObject:(id)lhs andObject:(id)rhs
{
    if (lhs == nil && rhs == nil)
    {
        switch (_variant)
        {
            case NSLessThanPredicateOperatorType:
            case NSGreaterThanPredicateOperatorType:
                return NO;
            case NSLessThanOrEqualToPredicateOperatorType:
            case NSGreaterThanOrEqualToPredicateOperatorType:
                return YES;
            default:
                [NSException raise:NSInternalInconsistencyException format:@"Bad comparison predicate variant: %ld", (long)_variant];
                return NO;
        }
    }

    if (lhs == nil || rhs == nil)
    {
        return NO;
    }

    NSComparisonResult comp;
    if (_options != 0 &&
        [lhs isNSString__] &&
        [rhs isNSString__])
    {
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

        comp = (NSComparisonResult)CFStringCompareWithOptionsAndLocale((CFStringRef)lhs, (CFStringRef)rhs, CFRangeMake(0, [lhs length]), flags, locale);
    }
    else
    {
        comp = (NSComparisonResult)objc_msgSend(lhs, [self selector], rhs);
    }

    switch (_variant)
    {
        case NSLessThanPredicateOperatorType:
            return comp == NSOrderedAscending;
        case NSLessThanOrEqualToPredicateOperatorType:
            return comp != NSOrderedDescending;
        case NSGreaterThanPredicateOperatorType:
            return comp == NSOrderedDescending;
        case NSGreaterThanOrEqualToPredicateOperatorType:
            return comp != NSOrderedAscending;
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Bad comparison predicate variant: %ld", (long)_variant];
            return NO;
    }
}

- (BOOL)isEqual:(id)other
{
    if (self == other)
    {
        return YES;
    }
    if (![other isKindOfClass:[NSComparisonPredicateOperator self]])
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
    if ([self variant] != [other variant])
    {
        return NO;
    }
    if ([self options] != [other options])
    {
        return NO;
    }
    return YES;
}

- (NSComparisonPredicateOptions)options
{
    return _options;
}

- (NSPredicateOperatorType)variant
{
    return _variant;
}

- (NSString *)predicateFormat
{
    return [NSString stringWithFormat:@"%@%@", [self symbol], comparisonPredicateOptionDescription(_options)];
}

- (id)copyWithZone:(NSZone *)zone
{
    return [[[self class] alloc] initWithOperatorType:[self operatorType] modifier:[self modifier] variant:[self variant] options:[self options]];
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
        _variant = [decoder decodeIntegerForKey:NSVariantKey];
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

    [coder encodeInteger:[self variant] forKey:NSVariantKey];
    [coder encodeInteger:[self options] forKey:NSOptionsKey];
}

@end
