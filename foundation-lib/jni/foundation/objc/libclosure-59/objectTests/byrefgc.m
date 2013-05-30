/*
 * Copyright (c) 2010 Apple Inc. All rights reserved.
 *
 * @APPLE_LLVM_LICENSE_HEADER@
 */

//
//  byrefgc.m
//  testObjects
//
//  Created by Blaine Garst on 5/16/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

// TEST_CONFIG SDK=macosx
// TEST_CFLAGS -framework Foundation


#import <objc/objc-auto.h>
#import <Foundation/Foundation.h>
#import <stdio.h>
#import <Block.h>
#import "test.h"

int DidFinalize = 0;
int GotHi = 0;

int VersionCounter = 0;

@interface TestObject : NSObject {
    int version;
}
- (void) hi;
@end

@implementation TestObject


- init {
    version = VersionCounter++;
    return self;
}

- (void)finalize {
    DidFinalize++;
    [super finalize];
}
- (void) hi {
    GotHi++;
}

@end


void (^get_block(void))(void) {
    __block TestObject * to = [[TestObject alloc] init];
    return [^{ [to hi]; to = [[TestObject alloc] init]; } copy];
}

int main() {
    
    void (^voidvoid)(void) = get_block();
    voidvoid();
    voidvoid();
    voidvoid();
    voidvoid();
    voidvoid();
    voidvoid();
    voidvoid = nil;
    for (int i = 0; i < 8000; ++i) {
        [NSObject new];
    }
    if (objc_collectingEnabled()) {
        objc_collect(OBJC_EXHAUSTIVE_COLLECTION|OBJC_WAIT_UNTIL_DONE);
        if ((DidFinalize + 2) < VersionCounter) {
            fail("didn't recover all objects %d/%d", DidFinalize, VersionCounter);
        }
    }

    succeed(__FILE__);
}
