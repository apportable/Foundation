//
//  NSLinkCheckingResult.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "NSLinkCheckingResult.h"
#import <Foundation/NSURL.h>

@implementation NSLinkCheckingResult

- (id)initWithRange:(NSRange)range URL:(NSURL *)url
{
    self = [super init];
    if (self)
    {
        _range = range;
        _url = [url copy];
    }
    return self;
}

- (void)dealloc
{
    [_url release];
    [super dealloc];
}

- (NSURL *)URL
{
    return _url;
}

- (NSRange)range
{
    return _range;
}

- (NSTextCheckingType)resultType
{
    return NSTextCheckingTypeLink;
}

@end
