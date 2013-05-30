/*
 * Copyright (c) 2010 Apple Inc. All rights reserved.
 *
 * @APPLE_LLVM_LICENSE_HEADER@
 */

//
//  NSFuture.m
//  libclosure
//
//  Created by Blaine Garst on 2/19/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "NSFuture.h"
#import "Block_private.h"
#import <pthread.h>
#include <libkern/OSAtomic.h>

typedef struct {
    pthread_mutex_t mutex;
    pthread_cond_t condition;
    void (*original_invoke)(void *);
    union {
        char charValue;
        unsigned char unsignedCharValue;
        short shortValue;
        unsigned short unsignedShortValue;
        NSInteger integerValue;
        NSUInteger unsignedIntegerValue;
        long longValue;
        unsigned long unsignedLongValue;
        long long longLongValue;
        unsigned long long unsignedLongLongValue;
        float floatValue;
        double doubleValue;
        id objectValue;
        NSString *stringValue;
    } u;
    int32_t refcount;
    BOOL    isRetainedObject;
    BOOL    isInvalid;
    BOOL    isDone;
} extra_t;


@interface NSConcreteFuture : NSFuture {
@public
    // mimic's compiler version exactly XXX how to improve this?
    int Block_flags;  // int32_t
    int Block_sz; // XXX should be packed into Block_flags
    void (*Block_invoke)(void *);
    void (*Block_copy)(void *, void *);
    void (*Block_dispose)(void *);
}
@end

        
@implementation NSFuture
static void futureIntInvoke(NSConcreteFuture *future) {
    extra_t *extra = (extra_t *)(((char *)future)+future->Block_sz);
    
    typedef int (*intInvoker)(NSConcreteFuture *);
    intInvoker ii = (intInvoker)extra->original_invoke;
    extra->u.integerValue = ii(future);
    
    pthread_mutex_lock(&extra->mutex);
    extra->isDone = YES;
    pthread_mutex_unlock(&extra->mutex);
    pthread_cond_signal(&extra->condition);
}


+ (NSFuture *)integerFutureWithClosure:(CLOSURE(NSInteger))closure {
    unsigned int size = Block_size(closure);
    // XXX spec it out such that closures are padded in size to 2*(sizeof(void *))
    // e.g. aligned to double
    NSConcreteFuture *result = (NSConcreteFuture *)NSAllocateObject([NSConcreteFuture self], sizeof(extra_t), NULL);
    // XXX
    // XXX Stolen from runtime.c
    // XXX
    memmove(result, closure, ((struct Block_basic *)closure)->Block_size);
    result->Block_flags &= ~(0xff);
    // XXX probably need to set CLOSURE_NEEDS_RELEASE
    result->Block_flags |= BLOCK_NEEDS_FREE | 1;  // give it a refcount of 1
    if (result->Block_flags & BLOCK_HAS_COPY_DISPOSE) {
        (*result->Block_copy)(result, closure); // do fixup
    }
    // XXX
    // XXX End Theft
    // XXX
    extra_t *extra = (extra_t *)(((char *)result)+size);
    // XXX
    // XXX should be able to "borrow" a pair of these from a global queue in a single
    // atomic instruction so that we don't have to keep allocating/initing their contents
    pthread_mutex_init(&extra->mutex, 0);
    pthread_cond_init(&extra->condition, 0);
    extra->isDone = FALSE;
    return result;
}

// XXX methods that throw

@end

@implementation NSConcreteFuture
- (void)invalidate {
    extra_t *extra = (extra_t *)(((char *)self)+Block_size(self));
    if (extra->isInvalid) return;
    if (extra->isRetainedObject) [extra->u.objectValue release];
    pthread_cond_destroy(&extra->condition);
    extra->isInvalid = YES;
}
- (void)dealloc {
    [self invalidate];
    [super dealloc];
}
- (void) finalize {
    [self invalidate];
    [super finalize];
}
- (id) retain {
    OSAtomicIncrement32(&Block_flags);
}
- (void)release {
    if ((Block_flags & 0xff) == 1) {
        if (Block_flags & BLOCK_HAS_COPY_DISPOSE) _Block_release(self);
        [self dealloc];
    }
    else OSAtomicDecrement32(&Block_flags);
}

- (NSInteger)intValue {
    extra_t *extra = (extra_t *)(((char *)self)+Block_size(self));
    if (!extra->isDone) {
        pthread_mutex_lock(&extra->mutex);
        while (!extra->isDone)
            pthread_cond_wait(&extra->condition, &extra->mutex);
        pthread_mutex_unlock(&extra->mutex);
        // XXX release the mutex & condition??
    }
    return extra->u.integerValue;
}
@end
