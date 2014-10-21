//
//  FoundationTests.m
//  FoundationTests
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#include <stdio.h>

#import <objc/runtime.h>
#import <signal.h>
#import <setjmp.h>

#import "FoundationTests.h"

#ifndef DEBUG_LOG
#define DEBUG_LOG printf
#endif

#if __LP64__
#error 64 bit tests currently do not work correctly https://code.google.com/p/apportable/issues/detail?id=605
#endif

static void* SubclassTrackerKey = @"SubclassTracker";

SubclassTracker *subclassTrackerForObject(id<NSObject> object, BOOL createIfMissing)
{
    SubclassTracker *tracker = (SubclassTracker *)objc_getAssociatedObject(object, SubclassTrackerKey);
    if (tracker == nil && createIfMissing) {
        tracker = [[SubclassTracker alloc] initWithClass:[object class]];
        objc_setAssociatedObject(object, SubclassTrackerKey, tracker, OBJC_ASSOCIATION_RETAIN);
        [tracker release];
    }
    return tracker;
}

void clearSubclassTrackerForObject(id<NSObject> object)
{
    objc_setAssociatedObject(object, SubclassTrackerKey, nil, OBJC_ASSOCIATION_ASSIGN);
}

@implementation SubclassTracker {
    CFMutableArrayRef calls;
    Class class;
}

static CFStringRef sel_copyDescription(const void *value)
{
    if (value == NULL)
    {
        return CFSTR("<NULL>");
    }
    return CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("@selector(%s)"), sel_getName((SEL)value));
}

- (id)initWithClass:(Class)cls
{
    self = [super init];
    if (self)
    {
        class = cls;
        CFArrayCallBacks callbacks = {
            .version = 0,
            .copyDescription = &sel_copyDescription
        };
        calls = CFArrayCreateMutable(kCFAllocatorDefault, 0, &callbacks);
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)track:(SEL)cmd
{
    CFArrayAppendValue(calls, cmd);
}

- (CFArrayRef)calls
{
    return calls;
}

+ (BOOL)verify:(id)target commands:(SEL)cmd, ...
{
    va_list args;
    va_start(args, cmd);
    BOOL result = [self verify:target firstCommand:cmd otherCommands:args];
    va_end(args);
    return result;
}

+ (BOOL)verify:(id)target firstCommand:(SEL)cmd otherCommands:(va_list)args
{
    SubclassTracker *tracker = subclassTrackerForObject(target, NO);
    if (tracker == nil)
    {
        return NO;
    }
    CFArrayCallBacks callbacks = {
        .version = 0,
        .copyDescription = &sel_copyDescription
    };
    CFMutableArrayRef expected = CFArrayCreateMutable(kCFAllocatorDefault, 0, &callbacks);
    CFArrayRef calls = [tracker calls];
    
    for (SEL command = cmd; command; command = va_arg(args, SEL))
    {
        CFArrayAppendValue(expected, command);
    }
    
    if (CFEqual(calls, expected))
    {
        return YES;
    }
    else
    {

        DEBUG_LOG("Expected call pattern: %s", [(NSString *)CFCopyDescription(expected) UTF8String]);
        DEBUG_LOG("Received call pattern: %s", [(NSString *)CFCopyDescription(calls) UTF8String]);
        return NO;
    }
}

+ (BOOL)dumpVerification:(id)target
{
    SubclassTracker *tracker = subclassTrackerForObject(target, NO);
    if (tracker == nil)
    {
        return NO;
    }
    CFArrayRef calls = [tracker calls];
    CFIndex count = CFArrayGetCount(calls);
    NSMutableString *verification = [NSMutableString stringWithFormat:@"BOOL verified = [%s verify:target commands:", object_getClassName(self)];
    for (CFIndex index = 0; index < count; index++)
    {
        SEL command = (SEL)CFArrayGetValueAtIndex(calls, index);
        [verification appendFormat:@"@selector(%s), ", sel_getName(command)];
    }
    [verification appendString:@"nil];\n testassert(verified);\n"];
    printf("%s", [verification UTF8String]);
    return YES;
}

@end

@implementation DeallocWatcher {
    dispatch_block_t _block;
}

- (id)initWithBlock:(dispatch_block_t)block
{
    self = [super init];
    if (self)
    {
        _block = Block_copy(block);
    }
    return self;
}

- (void)dealloc
{
    _block();
    Block_release(_block);
    [super dealloc];
}

@end

@implementation TrackerProxy
{
    NSObject *_object;
}

-(id)initWithObject:(NSObject*)object
{
    if (self)
    {
        _object = [object retain];
    }
    return self;
}

- (BOOL)verifyCommands:(SEL)cmd, ...
{
    va_list args;
    va_start(args, cmd);
    BOOL result = [SubclassTracker verify:_object firstCommand:cmd otherCommands:args];
    va_end(args);
    return result;
}

- (BOOL)dumpVerification
{
    return [SubclassTracker dumpVerification:_object];
}

-(void)dealloc
{
    clearSubclassTrackerForObject(_object);
    
    [_object release];
    
    [super dealloc];
}

- (NSString *)description
{
    SubclassTracker *tracker = subclassTrackerForObject(_object, YES);
    [tracker track:_cmd];
    
    return [_object description];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
	return [_object methodSignatureForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    SubclassTracker *tracker = subclassTrackerForObject(_object, YES);
    
    SEL cmd = anInvocation.selector;
    [tracker track:cmd];
    
	[anInvocation invokeWithTarget:_object];
}

@end


static void failure_log(const char *error)
{
    DEBUG_LOG("%s", error);
}

static unsigned int total_success_count = 0;
static unsigned int total_assertion_count = 0;
static unsigned int total_uncaught_exception_count = 0;
static unsigned int total_failure_count = 0;
static unsigned int total_signal_count = 0;
static unsigned int total_test_count = 0;

static sigjmp_buf jbuf;
static int signal_hit = 0;

static void test_signal(int sig)
{
    signal_hit = sig;
    siglongjmp(jbuf, 1);
}

struct testClassEntry {
    Class cls;
    NSUInteger count;
    struct testName *methods;
} *testClasses = NULL;
static int testClassCount = 0;
static int testClassCapacity = 0;

void registerTestClass(Class cls)
{
    if (testClasses == NULL)
    {
        testClassCapacity = 128;
        testClasses = malloc(testClassCapacity * sizeof(*testClasses));
        if (testClasses == NULL)
        {
            abort();
            return;
        }
    }
    else if (testClassCount + 1 > testClassCapacity)
    {
        testClassCapacity *= 2;
        struct testClassEntry *buffer = realloc(testClasses, testClassCapacity * sizeof(*testClasses));
        if (buffer == NULL)
        {
            abort();
            return;
        }
        testClasses = buffer;
    }
    testClasses[testClassCount++] = (struct testClassEntry) {
        .cls = cls,
        .methods = NULL,
    };
}

static void runTests(struct testClassEntry *testSuite)
{
    Class c = testSuite->cls;
    id tests = [[c alloc] init];
    const char *class_name = class_getName(c);

    unsigned int success_count = 0;
    unsigned int assertion_count = 0;
    unsigned int uncaught_exception_count = 0;
    unsigned int failure_count = 0;
    unsigned int signal_count = 0;
    unsigned int test_count = 0;

    DEBUG_LOG("Running tests for %.*s:\n", (int)strlen(class_name) - (int)strlen("TestsApportable"), class_name);

    for (unsigned int idx = 0; idx < testSuite->count; idx++)
    {
        const char *sel_name = testSuite->methods[idx].methodName;
        SEL sel = sel_registerName(testSuite->methods[idx].methodName);
        Method m = class_getInstanceMethod(c, sel);
        IMP imp = method_getImplementation(m);

        BOOL success = NO;
        BOOL exception = NO;

        void (*sigsegv_handler)(int) = signal(SIGSEGV, &test_signal);
        void (*sigbus_handler)(int) = signal(SIGBUS, &test_signal);
        void (*sigtrap_handler)(int) = signal(SIGTRAP, &test_signal);
        signal_hit = 0;
        if (sigsetjmp(jbuf, 1) == 0) {
            @try
            {
                @autoreleasepool {
                    total_test_count++;
                    test_count++;
                    success = (BOOL)imp(tests, sel);
                    if (!success)
                    {
                        assertion_count++;
                        total_assertion_count++;
                    }
                }
            }
            @catch (NSException *e)
            {
                exception = YES;
                char error[4096] = {0};
                snprintf(error, 4096, "%s: %s UNCAUGHT EXCEPTION\n%s\n", class_name, sel_name, [[e reason] UTF8String]);
                failure_log(error);
            }
        }

        signal(SIGTRAP, sigtrap_handler);
        signal(SIGBUS, sigbus_handler);
        signal(SIGSEGV, sigsegv_handler);

        success = success && !signal_hit;

        if (success)
        {
            success_count++;
            total_success_count++;
        }
        else
        {
            if (exception)
            {
                uncaught_exception_count++;
                total_uncaught_exception_count++;
            }

            if (signal_hit)
            {
                signal_count++;
                DEBUG_LOG("Got signal %s\n", strsignal(signal_hit));
                total_signal_count++;
            }

            DEBUG_LOG("%s: %s FAILED\n", class_name, sel_name);
            failure_count++;
            total_failure_count++;
        }
    }

    DEBUG_LOG("%u/%u successes\n", success_count, test_count);
    if (success_count < test_count)
    {
        DEBUG_LOG("%u assertions\n", assertion_count);
        DEBUG_LOG("%u uncaught exceptions\n", uncaught_exception_count);
        DEBUG_LOG("%u signals raised\n", signal_count);
        DEBUG_LOG("%u failures (assertions, signals, and uncaught exceptions)\n", failure_count);
    }
    DEBUG_LOG("\n");

    [tests release];
}

void runFoundationTests(void)
{
    if (testClassCount == 0)
    {
        DEBUG_LOG("No tests are registered\n");
        return;
    }

    qsort_b(testClasses, testClassCount, sizeof(struct testClassEntry), ^(const void *c1, const void *c2) {
        return strcmp(class_getName(((struct testClassEntry *)c1)->cls), class_getName(((struct testClassEntry *)c2)->cls));
    });

    for (unsigned testClassIdx = 0; testClassIdx < testClassCount; testClassIdx++)
    {
        struct testClassEntry *tc = &testClasses[testClassIdx];
        struct testName *testNames = (struct testName *)[tc->cls testNames];
        struct testName *ptr = testNames;

        tc->count = 0;
        while (ptr->methodName != NULL)
        {
            tc->count++;
            ptr = ptr->next;
        }

        tc->methods = malloc(tc->count * sizeof(*tc->methods));

        ptr = testNames;
        for (NSUInteger idx = 0; idx < tc->count; idx++)
        {
            tc->methods[idx] = *ptr;
            ptr = ptr->next;
        }

        qsort_b(tc->methods, tc->count, sizeof(struct testName), ^int(const void *c1, const void *c2) {
            return ((struct testName *)c1)->line - ((struct testName *)c2)->line;
        });

        runTests(tc);

        free(tc->methods);
    }

    DEBUG_LOG("Foundation test totals %.02f%%\n", 100.0 * ((double)total_success_count / (double)total_test_count));
    DEBUG_LOG("%u/%u successes\n", total_success_count, total_test_count);
    DEBUG_LOG("%u assertions\n", total_assertion_count);
    DEBUG_LOG("%u uncaught exceptions\n", total_uncaught_exception_count);
    DEBUG_LOG("%u signals raised\n", total_signal_count);
    DEBUG_LOG("%u failures (assertions, signals, and uncaught exceptions)\n\n", total_failure_count);
}

static void test_failure(const char *file, int line)
{
    char msg[4096] = {0};
    snprintf(msg, 4096, "Test failure at %s:%d\n", file, line);
    failure_log(msg);
}

BOOL _testassert(BOOL b, const char *file, int line)
{
    if (!(b))
    {
        test_failure(file, line);
        return NO;
    }

    return YES;
}
