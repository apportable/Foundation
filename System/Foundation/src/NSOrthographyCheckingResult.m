//
//  NSOrthographyCheckingResult.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "NSOrthographyCheckingResult.h"
#import <Foundation/NSOrthography.h>

@implementation NSOrthographyCheckingResult

- (id)initWithRange:(NSRange)range orthography:(NSOrthography *)orthography
{
    self = [super init];
    if (self)
    {
        _orthography = [orthography copy];
    }
    return self;
}

- (void)dealloc
{
    [_orthography release];
    [super dealloc];
}

- (NSOrthography *)orthography
{
    return _orthography;
}

- (NSRange)range
{
    return _range;
}

- (NSTextCheckingType)resultType
{
    return NSTextCheckingTypeOrthography;
}

@end
