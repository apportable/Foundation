/*
 * Copyright (c) 2010 Apple Inc. All rights reserved.
 *
 * @APPLE_LLVM_LICENSE_HEADER@
 */

/*  block_prop.m
    Created by Chris Parker on 29 Sep 2008
    compiler should warn that block properties require a copy attribute
*/

// rdar://6379842 warn: 'copy' attribute
// TEST_CONFIG MEM=gc
// TEST_CFLAGS -fobjc-gc-only -framework Foundation
/*
TEST_BUILD_OUTPUT
.*block_prop.m:29:(1:)? warning: 'copy' attribute must be specified for the block property( 'someBlock')? when -fobjc-gc-only is specified
END
*/

#import <Foundation/Foundation.h>
#import <Block.h>
#import "test.h"

@interface Thing : NSObject {
    void (^someBlock)(void);
}

@property void(^someBlock)(void);

- (void)emit;

@end

@implementation Thing

@synthesize someBlock;

- (void)emit {
    someBlock();
}

- (void)dealloc {
    if (someBlock) Block_release(someBlock);
    [super dealloc];
}

@end

int main () {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    Thing *t = [Thing new];
    
    [t setSomeBlock:^{ }];
    [t emit];
    
    [t release];
    
    [pool drain];

    succeed(__FILE__);
}
