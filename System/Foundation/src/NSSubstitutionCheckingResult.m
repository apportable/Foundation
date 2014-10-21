//
//  NSSubstitutionCheckingResult.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "NSSubstitutionCheckingResult.h"
#import <Foundation/NSString.h>

@implementation NSSubstitutionCheckingResult

- (id)initWithRange:(NSRange)range replacementString:(NSString *)replacementString
{
    self = [super init];
    if (self)
    {
        _range = range;
        _replacementString = [replacementString copy];
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (NSString *)replacementString
{
    return _replacementString;
}

- (NSRange)range
{
    return _range;
}

@end

@implementation NSCorrectionCheckingResult

- (NSTextCheckingType)resultType
{
    return NSTextCheckingTypeCorrection;
}

@end

@implementation NSDashCheckingResult

- (NSTextCheckingType)resultType
{
    return NSTextCheckingTypeDash;
}

@end

@implementation NSQuoteCheckingResult

- (NSTextCheckingType)resultType
{
    return NSTextCheckingTypeQuote;
}

@end
