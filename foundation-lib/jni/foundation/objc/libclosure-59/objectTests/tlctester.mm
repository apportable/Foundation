/*
 * Copyright (c) 2010 Apple Inc. All rights reserved.
 *
 * @APPLE_LLVM_LICENSE_HEADER@
 */

//
//  tlctester.m
//  tests
//
//  Created by Blaine Garst on 5/7/08.
//  Copyright 2008-2009 Apple. All rights reserved.
//

// TEST_DISABLED
// TEST_CFLAGS -framework Foundation

#import <Foundation/Foundation.h>
#import <pthread.h>
#import <objc/objc-auto.h>
#include <libkern/OSAtomic.h>
#include <sys/time.h>
#include <Block.h>
#include "test.h"

// This is not a Block test at all; rather a property list test

typedef struct {
    float a, b;
    //int c[10];  makes problem go away
} twofloats;

@interface TestObject : NSObject {
    twofloats tf;
}
@property twofloats tf;
@end

@implementation TestObject
@synthesize tf;
@end
    
double timeofday() {
    struct timeval raw;
    gettimeofday(&raw, NULL);
    return (double)raw.tv_sec + (double)raw.tv_usec/10e6;
}




void *callBlock(void *block) {
    void (^realBlock)(void) = (void (^)(void))block;
    while(1) {
        realBlock();
    }
    return (void *)0;
}

int main(int argc, char *argv[]) {
    int nthreads = 8;
    int sleeptime = 1;
    int verbose = 0;
    const char *whoami = argv[0];
    --argc;
    ++argv;
    if (argc > 0 && !strncmp("-v", argv[0], 2)) {
        verbose = 1;
        --argc;
        ++argv;
    }
    if (argc > 0) {
        nthreads = atoi(argv[0]);
        --argc;
        ++argv;
    }
    if (argc > 0) {
        sleeptime = atoi(argv[0]);
        --argc;
        ++argv;
    }
    if (nthreads == 0 || sleeptime == 0) {
        printf("Usage: %s [nthreads [sleeptime]]\n", whoami);
        return 0;
    }
    if (nthreads > 100) nthreads = 100;
    if (verbose) printf("running %d threads for %d seconds\n", nthreads, sleeptime);
    pthread_t threads[nthreads];
    //double start = timeofday();
    TestObject *to = [[TestObject alloc] init];
    for (int i = 0; i < nthreads/2; ++i) {
        void (^setter)(void) = ^{
                twofloats tf = { (float)i, (float)i };
                to.tf = tf; // set to a pair of values
        };
        pthread_create(&threads[i], NULL, callBlock, (void *)Block_copy(setter));
    }
    for (int i = 0; i < nthreads/2; ++i) {
        void (^getter)(void) = ^{
                twofloats tf = to.tf;
                if (tf.a != tf.b) {
                    printf("got inconsistent values %f and %f\n", tf.a, tf.b);
                    exit(1);
                }
        };
        pthread_create(&threads[i], NULL, callBlock, (void *)Block_copy(getter));
    }
#if 0
    for (int i = 0; i < nthreads; ++i)
        pthread_join(threads[i], NULL);
#endif
    sleep(sleeptime);
    return 0;
}
