/*
 * Copyright (c) 2010 Apple Inc. All rights reserved.
 *
 * @APPLE_LLVM_LICENSE_HEADER@
 */

//
//  counting.m
//  testObjects
//
//  Created by Blaine Garst on 9/23/08.
//  Copyright 2008 Apple. All rights reserved.
//
// rdar://6557292
// TEST_CFLAGS -framework Foundation

#import <Foundation/Foundation.h>
#import <objc/objc-auto.h>
#import <Block.h>
#import <stdio.h>
#import <libkern/OSAtomic.h>
#import "test.h"

int allocated = 0;
int recovered = 0;

@interface TestObject : NSObject
@end
@implementation TestObject
- init {
    // printf("allocated...\n");
    OSAtomicIncrement32(&allocated);
    return self;
}
- (void)dealloc {
    // printf("deallocated...\n");
    OSAtomicIncrement32(&recovered);
    [super dealloc];
}
- (void)finalize {
    // printf("finalized...\n");
    OSAtomicIncrement32(&recovered);
    [super finalize];
}

#if 0
- (id)retain {
    printf("retaining...\n");
    return [super retain];
}

- (void)release {
    printf("releasing...\n");
    [super release];
}
#endif
@end

void recoverMemory(const char *caller) {
    objc_collect(OBJC_EXHAUSTIVE_COLLECTION|OBJC_WAIT_UNTIL_DONE);
    objc_collect(OBJC_EXHAUSTIVE_COLLECTION|OBJC_WAIT_UNTIL_DONE);
    if (recovered != allocated) {
        fail("after %s recovered %d vs allocated %d", caller, recovered, allocated);
    }
}

// test that basic refcounting works
void *testsingle(void *arg __unused) {
    objc_registerThreadWithCollector();
    TestObject *to = [TestObject new];
    void (^b)(void) = [^{ printf("hi %p\n", to); } copy];
    [b release];
    [to release];
    return NULL;
}

void *testlatch(void *arg __unused) {
    objc_registerThreadWithCollector();
    TestObject *to = [TestObject new];
    void (^b)(void) = [^{ printf("hi %p\n", to); } copy];
    for (int i = 0; i < 0xfffff; ++i) {
        (void)Block_copy(b);
    }
    for (int i = 0; i < 10; ++i) {
        Block_release(b);
    }
    [b release];
    [to release];
    // lie - b should not be recovered because it has been over-retained
    OSAtomicIncrement32(&recovered);
    return NULL;
}

void *testmultiple(void *arg __unused) {
    objc_registerThreadWithCollector();
    TestObject *to = [TestObject new];
    void (^b)(void) = [^{ printf("hi %p\n", to); } copy];
#if 2
    for (int i = 0; i < 10; ++i) {
        (void)Block_copy(b);
    }
    for (int i = 0; i < 10; ++i) {
        Block_release(b);
    }
#endif
    [b release];
    [to release];
    return NULL;
}

int main() {
    pthread_t th;

    pthread_create(&th, NULL, testsingle, NULL);
    pthread_join(th, NULL);
    pthread_create(&th, NULL, testsingle, NULL);
    pthread_join(th, NULL);
    pthread_create(&th, NULL, testsingle, NULL);
    pthread_join(th, NULL);
    pthread_create(&th, NULL, testsingle, NULL);
    pthread_join(th, NULL);
    recoverMemory("testsingle");

    pthread_create(&th, NULL, testlatch, NULL);
    pthread_join(th, NULL);
    recoverMemory("testlatch");

    pthread_create(&th, NULL, testmultiple, NULL);
    pthread_join(th, NULL);
    recoverMemory("testmultiple");

    succeed(__FILE__);
}
