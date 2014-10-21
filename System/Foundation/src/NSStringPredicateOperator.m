//
//  NSStringPredicateOperator.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "NSStringPredicateOperator.h"

static NSString * const NSFlagsKey = @"NSFlags";

@implementation NSStringPredicateOperator
{
    NSComparisonPredicateOptions _flags;
}

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (id)initWithOperatorType:(NSPredicateOperatorType)type modifier:(NSComparisonPredicateModifier)modifier variant:(NSUInteger)variant
{
    self = [super initWithOperatorType:type modifier:modifier];
    if (self != nil)
    {
        [self _setOptions:variant];
    }
    return self;
}

- (NSComparisonPredicateOptions)options
{
    return _flags;
}

- (NSComparisonPredicateOptions)flags
{
    return _flags;
}

- (void)_setOptions:(NSComparisonPredicateOptions)options
{
    _flags = options & 0x1f;
}

- (id)copyWithZone:(NSZone *)zone
{
    return [[self class] _newOperatorWithType:[self operatorType] modifier:[self modifier] options:_flags];
}

- (BOOL)isEqual:(id)other
{
    if (other == self)
    {
        return YES;
    }
    if (![other isKindOfClass:[NSStringPredicateOperator class]])
    {
        return NO;
    }
    if ([other operatorType] != [self operatorType])
    {
        return NO;
    }
    if ([other modifier] != [self modifier])
    {
        return NO;
    }
    return [other flags] == [self flags];
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
        [self _setOptions:[decoder decodeIntegerForKey:NSFlagsKey]];
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

    [coder encodeInteger:[self flags] forKey:NSFlagsKey];
}

- (NSString *)_modifierString
{
    NSMutableString *modifierString = [NSMutableString stringWithString:@"["];
    
    if (_flags & NSCaseInsensitivePredicateOption) {
        [modifierString appendString:@"c"];
    }
    
    if (_flags & NSDiacriticInsensitivePredicateOption) {
        [modifierString appendString:@"d"];
    }
    
    if (_flags & NSNormalizedPredicateOption) {
        [modifierString appendString:@"n"];
    }
    
    if (_flags & NSLocaleSensitivePredicateOption) {
        [modifierString appendString:@"l"];
    }
        
    [modifierString appendString:@"]"];
    
    return modifierString;
}

@end
