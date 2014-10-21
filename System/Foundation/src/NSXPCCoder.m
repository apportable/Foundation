//
//  NSXPCCoder.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "NSCoderInternal.h"

@implementation NSXPCCoder

- (void)dealloc
{
    [_userInfo release];
    [super dealloc];
}

@end
