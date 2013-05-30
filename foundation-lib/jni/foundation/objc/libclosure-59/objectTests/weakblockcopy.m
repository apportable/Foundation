/*
 * Copyright (c) 2010 Apple Inc. All rights reserved.
 *
 * @APPLE_LLVM_LICENSE_HEADER@
 */

//
//  weakblock.m
//  testObjects
//
//  Created by Blaine Garst on 10/30/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//
// TEST_CONFIG SDK=macosx
// TEST_CFLAGS -framework Foundation
//
// Super basic test - does compiler a) compile and b) call out on assignments

#import <Foundation/Foundation.h>
#import "Block_private.h"
#import <objc/objc-auto.h>
#import "test.h"

// provide our own version for testing

int GotCalled = 0;

int Errors = 0;

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


id (^testCopy(void))(void) {
    // create test object
    TestObject *to = [[TestObject alloc] init];
    __block TestObject *__weak  testObject = to;    // iniitialization does NOT require support function
    //id (^b)(void) = [^{ return testObject; } copy];  // g++ rejects this
    id (^b)(void) = [^id{ return testObject; } copy];
    return b;
}

void *test(void *arg __unused)
{
    objc_registerThreadWithCollector();
    NSMutableArray *array = (NSMutableArray *)arg;

    GotCalled = 0;
    for (int i = 0; i < 200; ++i) {
        [array addObject:testCopy()];
    }

    return NULL;
}

int main() {

    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSMutableArray *array = [NSMutableArray array];
    [[NSGarbageCollector defaultCollector] disableCollectorForPointer:array];

    pthread_t th;
    pthread_create(&th, NULL, test, array);
    pthread_join(th, NULL);

#if defined(__clang__)  &&  defined(__cplusplus)
#define USE_B b
    id (^b)(void);
    testwarn("clang++ rdar://8295106");
#else
#define USE_B id (^b)(void)
#endif

    for (USE_B in array) {
        if (b() == nil) {
            fail("whoops, lost a __weak __block id");
        }
    }
    if (objc_collectingEnabled()) {
        objc_collect(OBJC_EXHAUSTIVE_COLLECTION | OBJC_WAIT_UNTIL_DONE);
        objc_collect(OBJC_EXHAUSTIVE_COLLECTION | OBJC_WAIT_UNTIL_DONE);
        for (USE_B in array) {
            if (b() != nil) {
                fail("whoops, kept a __weak __block id");
            }
        }
    }

    [pool drain];

    succeed(__FILE__);
}
