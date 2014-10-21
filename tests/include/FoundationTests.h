//
//  FoundationTests.h
//  FoundationTests
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

#define FoundationTest(c) c##TestsApportable

struct testName {
    const char *methodName;
    int line;
    struct testName *next;
};

#define testcase(name, ...) \
interface FoundationTest(name) : NSObject @end \
static struct testName name##TestNames = {0}; \
static struct testName *_testNames = &name##TestNames; \
static void name##Register(void) __attribute((constructor)); \
static void name##Register(void) { registerTestClass([FoundationTest(name) class]); } \
@implementation FoundationTest(name) \
__VA_ARGS__ \
+ (struct testName *)testNames { return _testNames; } \

#define test(name) \
static void  __attribute((constructor)) name##Register(void){ \
struct testName *name = malloc(sizeof(*name)); \
*name = (struct testName) { .methodName = #name, .line = __LINE__, .next = _testNames, }; \
_testNames = name; \
} \
- (BOOL)name \

#define testassert(b, ...) do { if (!_testassert(b , ##__VA_ARGS__, __FILE__, __LINE__)) return NO; } while (NO)
BOOL _testassert(BOOL b, const char *file, int line) __attribute__((analyzer_noreturn));

#define track(sup) ({ \
    SubclassTracker *__tracker = subclassTrackerForObject(self, YES); \
    [__tracker track:_cmd]; \
    YES; \
}) ? sup : sup

#if TARGET_IPHONE_SIMULATOR
#define IOS_SIMULATOR_BUG_FAILURE() NSLog(@"SKIPPING FAILURE DUE TO SIMULATOR BUG!"); testassert(0)
#else
#define IOS_SIMULATOR_BUG_FAILURE()
#endif

void runFoundationTests(void);

@interface InequalObject : NSObject
@end

@interface SubclassTracker : NSObject

- (id)initWithClass:(Class)cls;
- (void)track:(SEL)cmd;
+ (BOOL)verify:(id)target commands:(SEL)cmd, ... NS_REQUIRES_NIL_TERMINATION;
+ (BOOL)dumpVerification:(id)target; // used to build testasserts

@end

SubclassTracker *subclassTrackerForObject(id<NSObject> object, BOOL createIfMissing);

@interface TrackerProxy : NSProxy

- (id)initWithObject:(NSObject*)object;
- (BOOL)verifyCommands:(SEL)cmd, ... NS_REQUIRES_NIL_TERMINATION;
- (BOOL)dumpVerification;

@end

@interface DeallocWatcher : NSObject

- (id)initWithBlock:(dispatch_block_t)block;

@end

extern void registerTestClass(Class cls);
