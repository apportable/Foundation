//
//  NSSpellCheckingResult.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "NSSpellCheckingResult.h"

@implementation NSSpellCheckingResult

- (id)initWithRange:(NSRange)range
{
    self = [super init];
    if (self)
    {
        _range = range;
    }
    return self;
}

- (NSRange)range
{
    return _range;
}

- (NSTextCheckingType)resultType
{
    return NSTextCheckingTypeSpelling;
}


@end
