#import "FoundationTests.h"

#import <CoreFoundation/CFRunLoop.h>
#import <pthread.h>
#import <libkern/OSAtomic.h>

@testcase(CFRunLoop)

test(GetCurrent)
{
    CFRunLoopRef rl = CFRunLoopGetCurrent();

    // Get current must return the current thread's runloop
    testassert(rl != NULL);

    return YES;
}

test(GetMain)
{
    CFRunLoopRef rl = CFRunLoopGetMain();

    // Get main must return the main thread's runloop
    testassert(rl != NULL);

    return YES;
}


/* These tests are a bit abusive and take some time so they should stay commented out unless you are running them specifically
static int runloopDeallocEvents = 0;

static void *runLoopStart(void *ctx)
{
    DeallocWatcher *watcher = [[DeallocWatcher alloc] initWithBlock:^{
        OSAtomicIncrement32(&runloopDeallocEvents);
    }];
    objc_setAssociatedObject((id)CFRunLoopGetCurrent(), &runloopDeallocEvents, watcher, OBJC_ASSOCIATION_RETAIN);
    [watcher release];
    return NULL;
}

test(CFTLSReleaseCycles)
{
    runloopDeallocEvents = 0;
    for (int i = 0; i < 1025; i++)
    {
        pthread_t t;
        pthread_create(&t, NULL, &runLoopStart, NULL);
        usleep(300);
    }
    sleep(5);
    testassert(runloopDeallocEvents == 1025);
    return YES;
}

static void *runLoopStart2(void *ctx)
{
    [NSRunLoop currentRunLoop];
    return NULL;
}

test(NSTLSReleaseCycles)
{
    for (int i = 0; i < 1025; i++)
    {
        pthread_t t;
        pthread_create(&t, NULL, &runLoopStart2, NULL);
        usleep(100);
    }
    return YES;
}

#define SOURCES_RUN_IN_SAME_FUNCTION 1
#define SOURCES_RUN_IN_SAME_FUNCTION_AND_RESCHEDULE 2

static BOOL sourceAHasRun;
static BOOL sourceBHasRun;
static BOOL returnAfterSourceHandled;

typedef struct SourceInfoStruct {
    char *name;
    CFRunLoopSourceRef source;
    CFRunLoopRef runLoop;
} SourceInfoStruct;

static void _runloopSourceARunner(void *info) {
    sourceAHasRun = YES;
}

static void _runloopSourceBRunner(void *info) {
    sourceBHasRun = YES;
}

static void _mergedSourceRunners(void *info) {
    SourceInfoStruct *sourceInfo = (SourceInfoStruct*)info;
    if (strstr(sourceInfo->name, "contextA")) {
        sourceAHasRun = YES;
    } else if (strstr(sourceInfo->name, "contextB")) {
        sourceBHasRun = YES;
    }
}

static void _mergeAndRescheduleSourceRunners(void *info) {
    SourceInfoStruct *sourceInfo = (SourceInfoStruct*)info;
    if (sourceInfo->source != NULL) {
        CFRunLoopSourceSignal(sourceInfo->source);
        if (sourceInfo->runLoop != NULL) {
            //NSLog(@"running source %s", sourceInfo->name);
            CFRunLoopWakeUp(sourceInfo->runLoop);
        }
    }

    if (strstr(sourceInfo->name, "contextA")) {
        sourceAHasRun = YES;
    } else if (strstr(sourceInfo->name, "contextB")) {
        sourceBHasRun = YES;
    }
}

static void *runLoopStart3(void *ctx) {
    
    CFRunLoopRef runLoop = CFRunLoopGetCurrent();
    
    void (*sourceRunner)(void *) = NULL;
    int arg = (int) *(int*)ctx;
    
    if (arg == SOURCES_RUN_IN_SAME_FUNCTION) {
        sourceRunner = &_mergedSourceRunners;
    } else if (arg == SOURCES_RUN_IN_SAME_FUNCTION_AND_RESCHEDULE) {
        sourceRunner = &_mergeAndRescheduleSourceRunners;
    } else {
        sourceRunner = &_runloopSourceARunner;
    }
    SourceInfoStruct *infoStructA = malloc(sizeof(SourceInfoStruct));
    infoStructA->name = strdup("contextA");
    infoStructA->runLoop = runLoop;
    CFRunLoopSourceContext *contextA = malloc(sizeof(CFRunLoopSourceContext));
    CFRunLoopSourceContext contextATemplate = {
        0,
        infoStructA,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        (void (*)(void *))sourceRunner
    };
    memcpy(contextA, &contextATemplate, sizeof(CFRunLoopSourceContext));
    CFRunLoopSourceRef sourceA = CFRunLoopSourceCreate(kCFAllocatorDefault, 0, contextA);
    infoStructA->source = sourceA;
    CFRunLoopAddSource(runLoop, sourceA, kCFRunLoopDefaultMode);
    CFRunLoopSourceSignal(sourceA);
    CFRunLoopWakeUp(runLoop);

    if (arg == 0) {
        sourceRunner = &_runloopSourceBRunner;
    }
    SourceInfoStruct *infoStructB = malloc(sizeof(SourceInfoStruct));
    infoStructB->name = strdup("contextB");
    infoStructB->runLoop = runLoop;
    CFRunLoopSourceContext *contextB = malloc(sizeof(CFRunLoopSourceContext));
    CFRunLoopSourceContext contextBTemplate = {
        0,
        infoStructB,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        (void (*)(void *))sourceRunner
    };
    memcpy(contextB, &contextBTemplate, sizeof(CFRunLoopSourceContext));
    CFRunLoopSourceRef sourceB = CFRunLoopSourceCreate(kCFAllocatorDefault, 0, contextB);
    infoStructB->source = sourceB;
    CFRunLoopAddSource(runLoop, sourceB, kCFRunLoopDefaultMode);
    CFRunLoopSourceSignal(sourceB);
    CFRunLoopWakeUp(runLoop);

    NSTimeInterval theFuture = [NSDate timeIntervalSinceReferenceDate] + 4.0;
    while ([NSDate timeIntervalSinceReferenceDate] < theFuture) {
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.0, returnAfterSourceHandled);
        usleep(500);
    }
    
    CFRunLoopRemoveSource(runLoop, sourceA, kCFRunLoopDefaultMode);
    CFRunLoopRemoveSource(runLoop, sourceB, kCFRunLoopDefaultMode);
    
    free(contextA);
    free(contextB);

    CFRelease(sourceA);
    CFRelease(sourceB);
    
    free(infoStructA->name);
    free(infoStructB->name);
    free(infoStructA);
    free(infoStructB);
    
    return NULL;
}

test(CFRunLoopAddSource1)
{
    sourceAHasRun = NO;
    sourceBHasRun = NO;
    returnAfterSourceHandled = NO;
    
    pthread_t t;
    int arg = 0;
    pthread_create(&t, NULL, &runLoopStart3, &arg);
    pthread_join(t, NULL);

    testassert(sourceAHasRun && sourceBHasRun);
    
    return YES;
}

test(CFRunLoopAddSource1a)
{
    sourceAHasRun = NO;
    sourceBHasRun = NO;
    returnAfterSourceHandled = YES; // variant
    
    pthread_t t;
    int arg = 0;
    pthread_create(&t, NULL, &runLoopStart3, &arg);
    pthread_join(t, NULL);
    
    testassert(sourceAHasRun && sourceBHasRun);
    
    return YES;
}

test(CFRunLoopAddSource2)
{
    sourceAHasRun = NO;
    sourceBHasRun = NO;
    returnAfterSourceHandled = NO;
    
    pthread_t t;
    int arg = SOURCES_RUN_IN_SAME_FUNCTION;
    pthread_create(&t, NULL, &runLoopStart3, &arg);
    pthread_join(t, NULL);
    
    testassert(sourceAHasRun && sourceBHasRun);
    
    return YES;
}

test(CFRunLoopAddSource2a)
{
    sourceAHasRun = NO;
    sourceBHasRun = NO;
    returnAfterSourceHandled = YES;
    
    pthread_t t;
    int arg = SOURCES_RUN_IN_SAME_FUNCTION;
    pthread_create(&t, NULL, &runLoopStart3, &arg);
    pthread_join(t, NULL);
    
    testassert(sourceAHasRun && sourceBHasRun);
    
    return YES;
}

test(CFRunLoopAddSource3)
{
    sourceAHasRun = NO;
    sourceBHasRun = NO;
    returnAfterSourceHandled = NO;
    
    int arg = SOURCES_RUN_IN_SAME_FUNCTION;
    runLoopStart3(&arg);
    
    testassert(sourceAHasRun && sourceBHasRun);
    
    return YES;
}

test(CFRunLoopAddSource3a)
{
    sourceAHasRun = NO;
    sourceBHasRun = NO;
    returnAfterSourceHandled = YES;
    
    int arg = SOURCES_RUN_IN_SAME_FUNCTION;
    runLoopStart3(&arg);
    
    testassert(sourceAHasRun && sourceBHasRun);
    
    return YES;
}

test(CFRunLoopNoStarvation)
{
    sourceAHasRun = NO;
    sourceBHasRun = NO;
    returnAfterSourceHandled = NO;
    
    int arg = SOURCES_RUN_IN_SAME_FUNCTION_AND_RESCHEDULE;
    runLoopStart3(&arg);
    
    testassert(sourceAHasRun && sourceBHasRun);
    
    return YES;
}

test(CFRunLoopThatShowsStarvation)
{
    sourceAHasRun = NO;
    sourceBHasRun = NO;
    returnAfterSourceHandled = YES;

    int arg = SOURCES_RUN_IN_SAME_FUNCTION_AND_RESCHEDULE;
    runLoopStart3(&arg);
    
    testassert(sourceAHasRun || sourceBHasRun);
    testassert(!(sourceAHasRun && sourceBHasRun));
    
    return YES;
}
*/

@end
