/*
 * Copyright (c) 2010 Apple Inc. All rights reserved.
 *
 * @APPLE_LLVM_LICENSE_HEADER@
 */


//
//  weakblockassign.m
//  testObjects
//
//  Created by Blaine Garst on 10/30/08.
//  Copyright 2008 Apple. All rights reserved.
//
// TEST_CONFIG SDK=macosx
// TEST_CFLAGS -framework Foundation

// rdar://5847976
// Super basic test - does compiler a) compile and b) call out on assignments

#import <objc/objc-auto.h>
#import "test.h"

#if OBJC_NO_GC

int main() {
    succeed(__FILE__);
}

#else

#import <Foundation/Foundation.h>

// provide our own version for testing

int GotCalled = 0;

id objc_assign_weak(id value, id *location) {
    ++GotCalled;
    return *location = value;
}

int recovered = 0;

@interface TestObject : NSObject {
}
@end

@implementation TestObject
- (id)retain {
    fail("Whoops, retain called!");
}
- (void)finalize {
    ++recovered;
    [super finalize];
}
- (void)dealloc {
    ++recovered;
    [super dealloc];
}
@end


void testRR() {
    // create test object
    TestObject *to = [[TestObject alloc] init];
    __block TestObject *__weak  testObject = to;    // initialization does NOT require support function
    
    // there could be a Block that references "testObject" and that block could have been copied to the
    // heap and the Block_byref forwarding pointer aims at the heap object.
    // Assigning to it should trigger, under GC, the objc_assign_weak call
    testObject = (TestObject *)[NSObject new];    // won't last long :-)
}

int main() {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    GotCalled = 0;
    testRR();
    if ([NSGarbageCollector defaultCollector] && GotCalled == 0) {
        fail("didn't call out to support function on assignment!!");
    } else if (! [NSGarbageCollector defaultCollector] && GotCalled != 0) {
        fail("did call out to support function on assignment!!");
    }
    [pool drain];

    succeed(__FILE__);
}

#endif
