//
//  NSGrammarCheckingResult.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "NSGrammarCheckingResult.h"
#import <Foundation/NSArray.h>

@implementation NSGrammarCheckingResult

- (id)initWithRange:(NSRange)range details:(NSArray *)details
{
    self = [super init];
    if (self)
    {
        _range = range;
        _details = [details copy];
    }
    return self;
}

- (void)dealloc
{
    [_details release];
    [super dealloc];
}

- (NSArray *)grammarDetails
{
    return _details;
}

- (NSRange)range
{
    return _range;
}

- (NSTextCheckingType)resultType
{
    return NSTextCheckingTypeGrammar;
}


@end
