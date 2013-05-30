/**Implementation for NSOperation for GNUStep
   Copyright (C) 2009,2010 Free Software Foundation, Inc.

   Written by:  Gregory Casamento <greg.casamento@gmail.com>
   Written by:  Richard Frith-Macdonald <rfm@gnu.org>
   Date: 2009,2010

   This file is part of the GNUstep Base Library.

   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2 of the License, or (at your option) any later version.

   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
   Boston, MA 02111 USA.

   <title>NSOperation class reference</title>
   $Date: 2008-06-08 11:38:33 +0100 (Sun, 08 Jun 2008) $ $Revision: 26606 $
 */

#import "common.h"
#import "Foundation/NSOperation.h"
#import "Foundation/NSLock.h"
#import "Foundation/NSMachPort.h"
#import "Foundation/NSRunLoop.h"
#import "Foundation/NSSet.h"
#import <pthread.h>
#import <semaphore.h>

#define GS_NSOperation_IVARS \
    NSRecursiveLock *lock; \
    NSConditionLock *cond; \
    NSOperationQueuePriority priority; \
    double threadPriority; \
    BOOL cancelled; \
    BOOL concurrent; \
    BOOL executing; \
    BOOL finished; \
    BOOL blocked; \
    BOOL ready; \
    NSMutableArray *dependencies; \
    void (^completionBlock)(void); \
    NSOperationQueue *queue;

#define MAX_CONCURRENT_OPS 5

#define GS_NSOperationQueue_IVARS \
    NSInteger maxConcurrent; \
    NSString *name; \
    pthread_mutex_t operationLock; \
    NSMutableArray *operations; \
    BOOL suspended; \
    void *group; \
    NSMutableArray *operationThreads; \
    pthread_mutex_t operationThreadsLock; \
    NSUInteger lastThreadIndex; \

#import "Foundation/NSArray.h"
#import "Foundation/NSAutoreleasePool.h"
#import "Foundation/NSDictionary.h"
#import "Foundation/NSEnumerator.h"
#import "Foundation/NSException.h"
#import "Foundation/NSKeyValueObserving.h"
#import "Foundation/NSThread.h"
#import "Foundation/NSInvocation.h"
#import "GSPrivate.h"

#define GSInternal  NSOperationInternal
#include  "GSInternal.h"
GS_PRIVATE_INTERNAL(NSOperation)

/* The pool of threads for 'non-concurrent' operations in a queue.
 */
#define POOL  8

static NSArray  *empty = nil;

@interface  NSOperation (Private)
- (void)_finish;
@end

@implementation NSOperation

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString*)theKey
{
    /* Handle all KVO manually
     */
    return NO;
}

+ (void)initialize
{
    empty = [NSArray new];
}

- (void)_setQueue:(NSOperationQueue *)operationQueue
{
    internal->queue = operationQueue;
}

- (void)addDependency:(NSOperation *)op
{
    if (![op isKindOfClass:[NSOperation class]])
    {
        [NSException raise:NSInvalidArgumentException
         format:@"[%@-%@] dependency is not an NSOperation",
         NSStringFromClass([self class]), NSStringFromSelector(_cmd)];
        return;
    }
    if (op == self)
    {
        [NSException raise:NSInvalidArgumentException
         format:@"[%@-%@] attempt to add dependency on self",
         NSStringFromClass([self class]), NSStringFromSelector(_cmd)];
        return;
    }
    [internal->lock lock];
    if (internal->dependencies == nil)
    {
        internal->dependencies = [[NSMutableArray alloc] initWithCapacity:5];
    }
    NS_DURING
    {
        if (NSNotFound == [internal->dependencies indexOfObjectIdenticalTo:op])
        {
            [self willChangeValueForKey:@"dependencies"];
            [internal->dependencies addObject:op];
            /* We only need to watch for changes if it's possible for them to
             * happen and make a difference.
             */
            if (NO == [op isFinished]
                && NO == [self isCancelled]
                && NO == [self isExecuting]
                && NO == [self isFinished])
            {
                /* Can change readiness if we are neither cancelled nor
                 * executing nor finished.  So we need to observe for the
                 * finish of the dependency.
                 */
                // [op addObserver: self
                //      forKeyPath: @"isFinished"
                //         options: NSKeyValueObservingOptionNew
                //         context: NULL];
                if (internal->ready == YES)
                {
                    /* The new dependency stops us being ready ...
                     * change state.
                     */
                    [self willChangeValueForKey:@"isReady"];
                    internal->ready = NO;
                    [self didChangeValueForKey:@"isReady"];
                }
            }
            [self didChangeValueForKey:@"dependencies"];
        }
    }
    NS_HANDLER
    {
        [internal->lock unlock];
        NSLog(@"Problem adding dependency: %@", localException);
        return;
    }
    NS_ENDHANDLER
    [internal->lock unlock];
}

- (void)cancel
{
    if (NO == internal->cancelled && NO == [self isFinished])
    {
        [internal->lock lock];
        if (NO == internal->cancelled && NO == [self isFinished])
        {
            NS_DURING
            {
                [self willChangeValueForKey:@"isCancelled"];
                internal->cancelled = YES;
                if (NO == internal->ready)
                {
                    [self willChangeValueForKey:@"isReady"];
                    internal->ready = YES;
                    [self didChangeValueForKey:@"isReady"];
                }
                [self didChangeValueForKey:@"isCancelled"];
            }
            NS_HANDLER
            {
                [internal->lock unlock];
                NSLog(@"Problem cancelling operation: %@", localException);
                return;
            }
            NS_ENDHANDLER
        }
        [internal->lock unlock];
    }
}

- (void)dealloc
{
    if (internal != nil)
    {
        NSOperation *op;

        while ((op = [internal->dependencies lastObject]) != nil)
        {
            [self removeDependency:op];
        }
        RELEASE(internal->dependencies);
        RELEASE(internal->cond);
        RELEASE(internal->lock);
        RELEASE(internal->completionBlock);
        GS_DESTROY_INTERNAL(NSOperation);
    }
    [super dealloc];
}

- (NSArray *)dependencies
{
    NSArray *a;

    if (internal->dependencies == nil)
    {
        a = empty;  // OSX return an empty array
    }
    else
    {
        [internal->lock lock];
        a = [NSArray arrayWithArray:internal->dependencies];
        [internal->lock unlock];
    }
    return a;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        GS_CREATE_INTERNAL(NSOperation);
        internal->priority = NSOperationQueuePriorityNormal;
        internal->threadPriority = 0.5;
        internal->ready = YES;
        internal->lock = [NSRecursiveLock new];
    }
    return self;
}

- (BOOL)isCancelled
{
    return internal->cancelled;
}

- (BOOL)isExecuting
{
    return internal->executing;
}

- (BOOL)isFinished
{
    return internal->finished;
}

- (BOOL)isConcurrent
{
    return internal->concurrent;
}

- (BOOL)isReady
{
    return internal->ready;
}

- (void)main;
{
    return; // OSX default implementation does nothing
}

- (void)observeValueForKeyPath:(NSString *)keyPath
    ofObject:(id)object
    change:(NSDictionary *)change
    context:(void *)context
{
    [internal->lock lock];

    /* We only observe isFinished changes, and we can remove self as an
     * observer once we know the operation has finished since it can never
     * become unfinished.
     */
    [object removeObserver:self
     forKeyPath:@"isFinished"];

    if (object == self)
    {
        /* We have finished and need to unlock the condition lock so that
         * any waiting thread can continue.
         */
        [internal->cond lock];
        [internal->cond unlockWithCondition:1];
    }
    else if (NO == internal->ready)
    {
        NSEnumerator  *en;
        NSOperation *op;

        /* Some dependency has finished (or been removed) ...
         * so we need to check to see if we are now ready unless we know we are.
         * This is protected by locks so that an update due to an observed
         * change in one thread won't interrupt anything in another thread.
         */
        en = [internal->dependencies objectEnumerator];
        while ((op = [en nextObject]) != nil)
        {
            if (NO == [op isFinished]) {
                break;
            }
        }
        if (op == nil)
        {
            [self willChangeValueForKey:@"isReady"];
            internal->ready = YES;
            [self didChangeValueForKey:@"isReady"];
        }
    }
    [internal->lock unlock];
}

- (NSOperationQueuePriority)queuePriority
{
    return internal->priority;
}

- (void)removeDependency:(NSOperation *)op
{
    [internal->lock lock];
    NS_DURING
    {
        if (NSNotFound != [internal->dependencies indexOfObjectIdenticalTo:op])
        {
            [op removeObserver:self
             forKeyPath:@"isFinished"];
            [self willChangeValueForKey:@"dependencies"];
            [internal->dependencies removeObject:op];
            if (NO == internal->ready)
            {
                /* The dependency may cause us to become ready ...
                 * fake an observation so we can deal with that.
                 */
                [self observeValueForKeyPath:@"isFinished"
                 ofObject:op
                 change:nil
                 context:nil];
            }
            [self didChangeValueForKey:@"dependencies"];
        }
    }
    NS_HANDLER
    {
        [internal->lock unlock];
        NSLog(@"Problem removing dependency: %@", localException);
        return;
    }
    NS_ENDHANDLER
    [internal->lock unlock];
}

- (void)setQueuePriority:(NSOperationQueuePriority)pri
{
    if (pri <= NSOperationQueuePriorityVeryLow) {
        pri = NSOperationQueuePriorityVeryLow;
    }
    else if (pri <= NSOperationQueuePriorityLow) {
        pri = NSOperationQueuePriorityLow;
    }
    else if (pri < NSOperationQueuePriorityHigh) {
        pri = NSOperationQueuePriorityNormal;
    }
    else if (pri < NSOperationQueuePriorityVeryHigh) {
        pri = NSOperationQueuePriorityHigh;
    }
    else{
        pri = NSOperationQueuePriorityVeryHigh;
    }

    if (pri != internal->priority)
    {
        [internal->lock lock];
        if (pri != internal->priority)
        {
            NS_DURING
            {
                [self willChangeValueForKey:@"queuePriority"];
                internal->priority = pri;
                [self didChangeValueForKey:@"queuePriority"];
            }
            NS_HANDLER
            {
                [internal->lock unlock];
                NSLog(@"Problem setting priority: %@", localException);
                return;
            }
            NS_ENDHANDLER
        }
        [internal->lock unlock];
    }
}

- (void)setThreadPriority:(double)pri
{
    if (pri > 1) {pri = 1; }
    else if (pri < 0) {pri = 0; }
    internal->threadPriority = pri;
}

- (void)start
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    double prio = [NSThread  threadPriority];

    [internal->lock lock];
    if (YES == [self isConcurrent])
    {
        [internal->lock unlock];
        [pool drain];
        [NSException raise:NSInvalidArgumentException
         format:@"[%@-%@] called on concurrent operation",
         NSStringFromClass([self class]), NSStringFromSelector(_cmd)];
        return;
    }
    if (YES == [self isExecuting])
    {
        [internal->lock unlock];
        [pool drain];
        [NSException raise:NSInvalidArgumentException
         format:@"[%@-%@] called on executing operation",
         NSStringFromClass([self class]), NSStringFromSelector(_cmd)];
        return;
    }
    if (YES == [self isFinished])
    {
        [internal->lock unlock];
        [pool drain];
        [NSException raise:NSInvalidArgumentException
         format:@"[%@-%@] called on finished operation",
         NSStringFromClass([self class]), NSStringFromSelector(_cmd)];
        return;
    }
    if (NO == [self isReady])
    {
        [internal->lock unlock];
        [pool drain];
        [NSException raise:NSInvalidArgumentException
         format:@"[%@-%@] called on operation which is not ready",
         NSStringFromClass([self class]), NSStringFromSelector(_cmd)];
        return;
    }
    if (NO == internal->executing)
    {
        [self willChangeValueForKey:@"isExecuting"];
        internal->executing = YES;
        [self didChangeValueForKey:@"isExecuting"];
    }
    if (NO == [self isCancelled])
    {
        NSRunLoop *loop = [NSRunLoop currentRunLoop];
        [NSThread setThreadPriority:internal->threadPriority];
        [internal->lock unlock];
        [self main];
    }
    else
    {
        [internal->lock unlock];
    }

    [self _finish];
    [pool drain];
}

- (void)_start
{
    [self willChangeValueForKey:@"isExecuting"];
    internal->executing = YES;
    [self willChangeValueForKey:@"isExecuting"];
}

- (void)_stop
{
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    internal->executing = NO;
    internal->finished = YES;
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
}

- (double)threadPriority
{
    return internal->threadPriority;
}

- (void)waitUntilFinished
{
    if (NO == [self isFinished])
    {
        [internal->lock lock];
        if (nil == internal->cond)
        {
            /* Set up condition to wait on and observer to unblock.
             */
            internal->cond = [[NSConditionLock alloc] initWithCondition:0];
            // [self addObserver: self
            //        forKeyPath: @"isFinished"
            //           options: NSKeyValueObservingOptionNew
            //           context: NULL];
            /* Some other thread could have marked us as finished while we
             * were setting up ... so we can fake the observation if needed.
             */
            if (YES == [self isFinished])
            {
                [self observeValueForKeyPath:@"isFinished"
                 ofObject:self
                 change:nil
                 context:nil];
            }
        }
        [internal->lock unlock];
        [internal->cond lockWhenCondition:1];   // Wait for finish
        [internal->cond unlockWithCondition:1];   // Signal any other watchers
    }
}

- (void)setCompletionBlock:(void (^)(void))block
{
    internal->completionBlock = _Block_copy(block);
}

- (void (^)(void))completionBlock
{
    return internal->completionBlock;
}

@end

@implementation NSOperation (Private)
- (void)_finish
{
    /* retain while finishing so that we don't get deallocated when our
     * queue removes and releases us.
     */
    [self retain];
    [internal->lock lock];
    if (NO == internal->finished)
    {
        if (NO == internal->executing)
        {
            [self willChangeValueForKey:@"isExecuting"];
            [self willChangeValueForKey:@"isFinished"];
            internal->executing = NO;
            internal->finished = YES;
            [internal->queue observeValueForKeyPath:@"isFinished" ofObject:self change:nil context:NULL];
            [self didChangeValueForKey:@"isFinished"];
            [self didChangeValueForKey:@"isExecuting"];
        }
        else
        {
            [self willChangeValueForKey:@"isFinished"];
            internal->finished = YES;
            [internal->queue observeValueForKeyPath:@"isFinished" ofObject:self change:nil context:NULL];
            [self didChangeValueForKey:@"isFinished"];
        }
        if (internal->completionBlock != NULL)
        {
            internal->completionBlock();
        }
    }
    [internal->lock unlock];
    [self release];
}

@end

#undef  GSInternal
#define GSInternal  NSOperationQueueInternal
#include  "GSInternal.h"
GS_PRIVATE_INTERNAL(NSOperationQueue)

@interface NSMachPort (Private)
- (void)receivedEvent:(void *)data type:(int)type extra:(void *)extra forMode:(NSString *)mode;
@end

@interface NSOperationQueueSource : NSMachPort {
    BOOL *_suspendedRef;
    NSMutableArray *_operations;
    pthread_mutex_t *_operationLockRef;
}
- (id)initWithQueue:(NSMutableArray *)queue lock:(pthread_mutex_t *)lock suspend:(BOOL *)suspend;
@end

@implementation NSOperationQueueSource

- (id)initWithQueue:(NSMutableArray *)queue lock:(pthread_mutex_t *)lock suspend:(BOOL *)suspend
{
    self = [super init];
    if (self)
    {
        _operations = queue;
        _operationLockRef = lock;
        _suspendedRef = suspend;
    }
    return self;
}

- (void)receivedEvent:(void *)data type:(int)type extra:(void *)extra forMode:(NSString *)mode
{
    if (!*_suspendedRef)
    {
        NSOperation *op = NULL;
        pthread_mutex_lock(_operationLockRef);
        if ([_operations count] > 0)
        {
            op = [[_operations objectAtIndex:0] retain];
            [_operations removeObjectAtIndex:0];
        }
        pthread_mutex_unlock(_operationLockRef);
        if (op != NULL)
        {
            [op start];
            [op release];
        }
        else
        {
            [[NSRunLoop currentRunLoop] removePort:self forMode:NSDefaultRunLoopMode];
        }
    }
    [super receivedEvent:data type:type extra:extra forMode:mode];
}

@end

@implementation NSOperationQueue

static NSString const *NSOperationQueueKey = @"NSOperationQueue";
static pthread_mutex_t queueLock = PTHREAD_MUTEX_INITIALIZER;

+ (id)queueForThread:(NSThread *)thread
{
    pthread_mutex_lock(&queueLock);
    NSMutableDictionary *threadDictionary = [thread threadDictionary];
    NSOperationQueue *queue = [threadDictionary objectForKey:NSOperationQueueKey];
    if (queue == NULL)
    {
        if ([thread isMainThread])
        {
            queue = [[NSOperationQueue alloc] initForMainThread];
        }
        else
        {
            queue = [[NSOperationQueue alloc] initForThread:thread];
        }
        if (queue != NULL)
        {
            [threadDictionary setObject:queue forKey:NSOperationQueueKey];
        }
        [queue release];
    }
    pthread_mutex_unlock(&queueLock);
    return queue;
}

+ (id)currentQueue
{
    return [NSOperationQueue queueForThread:[NSThread currentThread]];
}

+ (id)mainQueue
{
    return [NSOperationQueue queueForThread:[NSThread mainThread]];
}

- (id)initForMainThread
{
    return [self initForThread:[NSThread mainThread]];
}

- (id)initForThread:(NSThread *)thread
{
    self = [super init];
    if (self)
    {
        GS_CREATE_INTERNAL(NSOperationQueue);
        pthread_mutex_init(&internal->operationThreadsLock, NULL);
        pthread_mutex_init(&internal->operationLock, NULL);
        internal->suspended = YES;
        internal->operations = [[NSMutableArray alloc] init];
        internal->operationThreads = [[NSMutableArray alloc] init];
        [self setMaxConcurrentOperationCount:3];
    }
    return self;
}

- (id)init
{
    return [self initForThread:[NSThread currentThread]];
}

- (void)dealloc
{
    if (internal != NULL)
    {
        [self setSuspended:YES];
        // cleanup any un-performed operations
        [self cancelAllOperations];
        // wait until any running operations are done
        [self waitUntilAllOperationsAreFinished];

        // drain the thread pool
        pthread_mutex_lock(&internal->operationThreadsLock);
        [internal->operationThreads release];
        internal->operationThreads = NULL;
        pthread_mutex_unlock(&internal->operationThreadsLock);

        // drain the operation queue
        pthread_mutex_lock(&internal->operationLock);
        [internal->operations release];
        internal->operations = NULL;
        pthread_mutex_unlock(&internal->operationLock);

        pthread_mutex_destroy(&internal->operationThreadsLock);
        pthread_mutex_destroy(&internal->operationLock);

        [internal->name release];

        GS_DESTROY_INTERNAL(NSOperationQueue);
    }

    [super dealloc];
}

- (void)updateOperationThreads
{
    pthread_mutex_lock(&internal->operationThreadsLock);
    while ([internal->operationThreads count] < internal->maxConcurrent)
    {
        NSThread *operationThread = [[NSThread alloc] initWithTarget:self selector:@selector(queue) object:nil];
        [internal->operationThreads addObject:operationThread];
        [operationThread start];
        [operationThread release];
    }
    pthread_mutex_unlock(&internal->operationThreadsLock);
}

- (void)addOperationWithBlock:(void (^)(void))block
{
    [self addOperation:[NSBlockOperation blockOperationWithBlock:block]];
}

- (void)addOperation:(NSOperation *)op
{
    [self addOperations:[NSArray arrayWithObjects:op, nil] waitUntilFinished:NO];
}

- (void)addOperations:(NSArray *)ops waitUntilFinished:(BOOL)shouldWait
{
    pthread_mutex_lock(&internal->operationLock);
    [internal->operations addObjectsFromArray:ops];
    pthread_mutex_unlock(&internal->operationLock);
    [self updateOperationThreads];
    if (shouldWait)
    {
        [self waitUntilAllOperationsAreFinished];
    }
}

- (void)cancelAllOperations
{
    pthread_mutex_lock(&internal->operationLock);
    [internal->operations removeAllObjects];
    pthread_mutex_unlock(&internal->operationLock);
}

- (BOOL)isSuspended
{
    return internal->suspended;
}

- (NSInteger)maxConcurrentOperationCount
{
    return internal->maxConcurrent;
}

- (NSString*)name
{
    return internal->name;
}

- (NSUInteger)operationCount
{
    NSUInteger count;
    pthread_mutex_lock(&internal->operationLock);
    count = [internal->operations count];
    pthread_mutex_unlock(&internal->operationLock);
    return count;
}

- (NSArray *)operations
{
    NSArray *ops;
    pthread_mutex_lock(&internal->operationLock);
    ops = [NSArray arrayWithArray:internal->operations];
    pthread_mutex_unlock(&internal->operationLock);
    return ops;
}

- (void)queue
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSOperationQueueSource *source = [[NSOperationQueueSource alloc] initWithQueue:internal->operations lock:&internal->operationLock suspend:&internal->suspended];
    NSRunLoop *loop = [NSRunLoop currentRunLoop];
    [loop addPort:source forMode:NSDefaultRunLoopMode];
    [loop run]; // run until the source is removed from the loop (e.g. the queue
                // is drained)
    pthread_mutex_lock(&internal->operationThreadsLock);
    [internal->operationThreads removeObject:[NSThread currentThread]];
    pthread_mutex_unlock(&internal->operationThreadsLock);
    [source release];
    [pool drain];
}

- (void)setMaxConcurrentOperationCount:(NSInteger)cnt
{
    NSInteger effectiveCount = cnt;
    if (cnt == NSOperationQueueDefaultMaxConcurrentOperationCount || cnt > MAX_CONCURRENT_OPS)
    {
        effectiveCount = MAX_CONCURRENT_OPS;
    }
    else if (cnt < 0)
    {
        NSLog(@"Invalid concurrent operation count!: %d", cnt);
        return;
    }
    if (internal->maxConcurrent != cnt)
    {
        internal->maxConcurrent = cnt;
        [self updateOperationThreads];
    }
}

- (void)setName:(NSString*)s
{
    if (internal->name != s && ![internal->name isEqualToString:s])
    {
        [internal->name release];
        internal->name = [s copy];
    }
}

- (void)setSuspended:(BOOL)flag
{
    if (internal->suspended != flag)
    {
        internal->suspended = flag;
    }
}

- (void)waitUntilAllOperationsAreFinished
{
    int count = 0;
    NSRunLoop *loop = [NSRunLoop currentRunLoop];
    do {
        pthread_mutex_lock(&internal->operationThreadsLock);
        count = [internal->operationThreads count];
        pthread_mutex_unlock(&internal->operationThreadsLock);
        // Let the run loop tick for a bit while there is more to be done...
        if (count > 0)
        {
            NSDate *limit = [[NSDate alloc] initWithTimeIntervalSinceNow:1.0];
            [loop runMode:NSDefaultRunLoopMode beforeDate:limit];
            [limit release];
        }
    } while(count > 0);
}

@end

@implementation NSInvocationOperation

- (id)initWithTarget:(id)target selector:(SEL)sel object:(id)arg
{
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[target methodSignatureForSelector:sel]];
    [inv setTarget:target];
    [inv setSelector:sel];
    [inv setArgument:&arg atIndex:2];
    return [self initWithInvocation:inv];
}

- (id)initWithInvocation:(NSInvocation *)inv
{
    self = [super init];
    if (self)
    {
        _inv = [inv retain];
        [inv retainArguments];
    }
    return self;
}

- (void)dealloc
{
    [_inv release];
    _inv = NULL;
    [super dealloc];
}

- (NSInvocation *)invocation
{
    return (NSInvocation *)_inv;
}

- (void)main
{
    [self _start];
    [(NSInvocation *)_inv invoke];
    [self _stop];
}

- (id)result
{
    id result = NULL;
    [(NSInvocation *)_inv getReturnValue : &result];
    return result;
}

@end

@implementation NSBlockOperation

- (id)initWithBlock:(void (^)(void))block
{
    self = [super init];
    if (self)
    {
        _private2 = [[NSMutableArray alloc] initWithObjects:block, NULL];
    }
    return self;
}

- (void)dealloc
{
    [_private2 release];
    _private2 = NULL;
    [super dealloc];
}

+ (id)blockOperationWithBlock:(void (^)(void))block
{
    return [[[self alloc] initWithBlock:block] autorelease];
}

- (void)addExecutionBlock:(void (^)(void))block
{
    [_private2 addObject:block];
}
- (NSArray *)executionBlocks
{
    return _private2;
}

- (void)main
{
    [self _start];
    NSEnumerator *blockEnum = [_private2 objectEnumerator];
    void (^block)(void) = (void (^)(void))[blockEnum nextObject];
    while(block != NULL)
    {
        block();
        block = (void (^)(void))[blockEnum nextObject];
    }
    [self _stop];
}

@end

