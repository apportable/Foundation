/*
 * Copyright (c) 2010 Apple Inc. All rights reserved.
 *
 * @APPLE_LLVM_LICENSE_HEADER@
 */

/*  block_layout.m
    Created by Patrick Beard on 3 Sep 2010
*/

// rdar://problem/8389489 rdar://problem/8389489 need Block layout accessor
// TEST_CONFIG MEM=gc
// TEST_CFLAGS -framework Foundation
// TEST_DISABLED

#import <Foundation/Foundation.h>
#import <Block.h>
#import <Block_private.h>
#import <dispatch/dispatch.h>
#import <assert.h>
#import "test.h"

int main (int argc, char const* argv[]) {
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    
    NSObject *o = [NSObject new];
    NSString *s = [NSString stringWithFormat:@"argc = arg, argv = %p", argc, argv];

    dispatch_block_t block = ^{
        NSLog(@"o = %@", o);
        NSLog(@"s = %@", s);
    };
    block = [block copy];
    
    const char *layout = _Block_layout(block);
    assert (layout != NULL);
    
    block();
    [block release];
    
    [pool drain];
    
    succeed(__FILE__);
}
