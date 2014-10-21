//
//  NSLockTests.m
//  FoundationTests
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "FoundationTests.h"
#import <pthread.h>

@testcase(NSLock)

test(Creation)
{
    NSLock *lock = [[NSLock alloc] init];
    testassert(lock != nil);
    [lock release];

    return YES;
}

test(BasicLock)
{
    NSLock* lock = [[NSLock alloc] init];
    for (int i = 0;  i < 100; i++)
    {
        [lock lock];
        [lock unlock];
    }
    [lock release];
    return YES;
}

test(NoninitedBehavior)
{
    NSLock* lock = [NSLock alloc];
    // should warn
    [lock unlock];
    [lock unlock];

    // should warn but not deadlock
    [lock lock];
    [lock lock];

    BOOL tryLockVal = [lock tryLock];
    testassert(!tryLockVal);

    BOOL lockDateVal = [lock lockBeforeDate:[NSDate dateWithTimeIntervalSinceNow:1.]];
    testassert(lockDateVal);

    return YES;
}

typedef struct {
    int *count;
    int  workerID;
    NSLock *lock;
    int startValue;
    int endValue;
} WorkerStruct;


#define kWorkAmountPerThread (10000)
static void *workerThread(void *data)
{
    WorkerStruct* workOrder = (WorkerStruct*)data;
    // lock for the entire work
    [workOrder->lock lock];

    workOrder->startValue = (*(workOrder->count));
    for (int i = 0; i < kWorkAmountPerThread; i++)
    {
        (*(workOrder->count))++;
    }
    workOrder->endValue = (*(workOrder->count));

    [workOrder->lock unlock];

    return NULL;
}

#define kNumTestThreads (2)
test(TwoThreadsLock)
{
    NSLock *lock = [[NSLock alloc] init];
    int workInt;
    WorkerStruct workOrder[kNumTestThreads];
    pthread_t threads[kNumTestThreads];
    for (int i = 0; i < kNumTestThreads; i++)
    {
        workOrder[i].count = &workInt;
        workOrder[i].workerID = i;
        workOrder[i].lock = lock;
        pthread_create(&threads[i], NULL, &workerThread, &workOrder[i]);
    }

    for (int i = 0; i < kNumTestThreads; i++)
    {
        pthread_join(threads[i], NULL);
        testassert(workOrder[i].startValue + kWorkAmountPerThread == workOrder[i].endValue);
    }
    [lock release];

    return YES;
}

test(RecusiveLock)
{
    NSRecursiveLock *rLock = [[NSRecursiveLock alloc] init];

    [self recursiveLockHelper:100 lock:rLock];
    [rLock release];
    return YES;
}

- (void)recursiveLockHelper:(int)depth lock:(NSRecursiveLock *)rLock
{
    if (depth <= 0)
    {
        return;
    }

    [rLock lock];
    [self recursiveLockHelper:depth -1 lock:rLock];
    [rLock unlock];
}


#define kNumSignals (10000)
typedef struct {
    NSCondition *cond;
    int val;
} SignalData;

static void *signalingThread(void *ctx)
{
    SignalData* signalData = (SignalData*) ctx;
    for (int i = 0; i < kNumSignals; i++) {
        [signalData->cond lock];

        usleep(10);
        signalData->val++;
        [signalData->cond signal];
        [signalData->cond unlock];
    }
    return NULL;
}

static SignalData data;
test(Condition)
{
    NSCondition *cond = [[NSCondition alloc] init];

    data.val = 0;
    data.cond = cond;

    pthread_t thread;
    // this thread steps  nd waits for the signaling thread to do some long thing and signal
    int ourSignalCount = 0;

    pthread_create(&thread, NULL, &signalingThread, &data);
    sleep(1);
    while (data.val < kNumSignals)
    {
        [data.cond lock];
        int val = data.val;
        while (val == data.val)
        {
            [data.cond wait];
        }
        ourSignalCount++;
        testassert(data.val == ourSignalCount);
        [data.cond unlock];
    }
    [cond release];

    return YES;
}

test(ConditionNonInited)
{
    NSCondition* cond = [NSCondition alloc];
    [cond lock];
    [cond lock];

    [cond wait];
    [cond wait];
    return YES;
}

test(ConditionLockInitialValue)
{
    NSConditionLock *condLock = [[NSConditionLock alloc] init];
    testassert([condLock condition] == 0);
    return YES;
}

test(ConditionLockWhenConditionNotEqual)
{
    NSConditionLock *condLock = [[NSConditionLock alloc] initWithCondition:2];
    BOOL locked = [condLock lockWhenCondition:1 beforeDate:[NSDate date]];
    testassert(!locked);
    return YES;
}

@end
