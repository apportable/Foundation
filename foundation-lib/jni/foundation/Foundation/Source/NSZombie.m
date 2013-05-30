#ifndef NDEBUG
#import <objc/runtime.h>
#import "common.h"
#import "Foundation/NSMethodSignature.h"
#import "Foundation/NSInvocation.h"
#import "Foundation/NSLock.h"
#import "Foundation/NSAutoreleasePool.h"
#import "Foundation/NSArray.h"
#import "Foundation/NSMapTable.h"
#import "Foundation/utstripe.h"
#import "GSPrivate.h"
#import "GNUstepBase/GSLocale.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-objc-isa-usage"

//provided by libv
extern void __print_backtrace(void);

static void _nszombie_setup(void) __attribute__((constructor));
static void _make_zombie(NSObject *o);
static void _flush_zombies(void);
static void _log_zombie(id o, SEL sel);

void NSZombiesEnable(BOOL deallocateZombies);
void NSZombiesFlushZombies(void);
void NSZombiesDisable(void);
void __nszombie_called_break(void);

#define MAX_ZOMBIE_PAGE_COUNT 512

typedef struct _NSZombiePage NSZombiePage;
struct _NSZombiePage {
    NSZombiePage *next;
    int count;
    id zombie[MAX_ZOMBIE_PAGE_COUNT];
};


#if __has_attribute(objc_root_class)
__attribute__((objc_root_class))
#endif
@interface  NSZombie
{
    Class isa;
}
- (Class)class;
- (void)forwardInvocation:(NSInvocation*)anInvocation;
- (NSMethodSignature*)methodSignatureForSelector:(SEL)aSelector;
@end


BOOL NSZombieEnabled = NO;
BOOL NSDeallocateZombies = NO;

static NSLock       *allocationLock;
static Class zombieClass = NULL;
static NSMapTable   *zombieMap = NULL;
static Class nsobjectClass = NULL;
static SEL deallocSelector = NULL;
static Method originalDeallocMethod = NULL;
static Method zombieDeallocMethod = NULL;
static IMP originalDeallocImpl = NULL;
static IMP zombieDeallocImpl = NULL;

static NSZombiePage *current_zombie_page = NULL;


@class NSZombie;
@interface NSObject (NSZombie)
- (void)_zombieDealloc;
@end

@implementation NSObject (NSZombie)

- (void)_zombieDealloc {
    //TODO: check for tagged pointer

    objc_destructInstance(self);
    _make_zombie(self);
    if (NSDeallocateZombies == YES)
    {
        free(self);
    }
}

@end


static void _nszombie_setup(void) {
    allocationLock = [NSLock new];
    deallocSelector = sel_getUid("dealloc");
    SEL zombieDeallocSelector = sel_getUid("_zombieDealloc");
    nsobjectClass = objc_getClass("NSObject");
    originalDeallocMethod = class_getInstanceMethod(nsobjectClass, deallocSelector);
    zombieDeallocMethod = class_getInstanceMethod(nsobjectClass, zombieDeallocSelector);
    originalDeallocImpl = method_getImplementation(originalDeallocMethod);

    zombieMap = NSCreateMapTable(NSNonOwnedPointerMapKeyCallBacks,
                                 NSNonOwnedPointerMapValueCallBacks, 0);
    zombieClass = [NSZombie class];
    if (!NSZombieEnabled) {
        NSZombieEnabled = GSPrivateEnvironmentFlag("NSZombieEnabled", NO);
    }
    if (NSDeallocateZombies) {
        NSDeallocateZombies = GSPrivateEnvironmentFlag("NSDeallocateZombies", YES);
    }
}

static void _flush_zombies(void) {
    while (current_zombie_page != NULL)
    {
        for (int idx = current_zombie_page->count-1; idx >= 0; idx--) {
            id zombie = current_zombie_page->zombie[idx];
            free(zombie);
        }
        NSZombiePage *next = current_zombie_page->next;
        free(current_zombie_page);
        current_zombie_page = next;
    }
}

void NSZombiesEnable(BOOL deallocateZombies) {
    if ([allocationLock lockBeforeDate:[NSDate dateWithTimeIntervalSinceNow:3.0]]) {
        if (!NSZombieEnabled) {
            NSZombieEnabled = YES;
            NSDeallocateZombies = deallocateZombies;
            method_exchangeImplementations(originalDeallocMethod, zombieDeallocMethod);
        }
        [allocationLock unlock];
    }
    else {
        DEBUG_LOG("allocationLock was not sucessfully aquired.");
    }
}

void NSZombiesFlushZombies(void) {
    if ([allocationLock lockBeforeDate:[NSDate dateWithTimeIntervalSinceNow:3.0]]) {
        _flush_zombies();
        [allocationLock unlock];
    }
    else {
        DEBUG_LOG("allocationLock was not sucessfully aquired.");
    }
}

void NSZombiesDisable(void) {
    if ([allocationLock lockBeforeDate:[NSDate dateWithTimeIntervalSinceNow:3.0]]) {
        if (NSZombieEnabled) {
            NSZombieEnabled = NO;
            _flush_zombies();
            method_exchangeImplementations(zombieDeallocMethod, originalDeallocMethod);
        }
        [allocationLock unlock];
    }
    else {
        DEBUG_LOG("allocationLock was not sucessfully aquired.");
    }
}

static void _make_zombie(NSObject *o) {
    Class c = object_getClass(o);
    object_setClass(o, zombieClass);

    // save the reference to this object with it's class
    [allocationLock lock];
    NSMapInsert(zombieMap, (void*)o, (void*)c);
    if (!NSDeallocateZombies) {
        if (!current_zombie_page)
        {
            current_zombie_page = malloc(sizeof(NSZombiePage));
            current_zombie_page->count = 0;
            current_zombie_page->next = NULL;
        }
        else if (current_zombie_page->count == MAX_ZOMBIE_PAGE_COUNT)
        {
            NSZombiePage *new_page = malloc(sizeof(NSZombiePage));
            new_page->count = 0;
            new_page->next = current_zombie_page;
            current_zombie_page = new_page;
        }

        int idx = current_zombie_page->count;
        current_zombie_page->zombie[idx] = o;
        current_zombie_page->count = idx+1;
    }
    [allocationLock unlock];
}

void __nszombie_called_break() {
    //noop for breakpoints
}

static void _log_zombie(id o, SEL sel) {
    Class c = Nil;

    [allocationLock lock];
    c = NSMapGet(zombieMap, (void*)o);
    [allocationLock unlock];

    if (c) {
        DEBUG_LOG("Deallocated %s (%p) sent %s. printing backtrace. set a breakpoint on __nszombie_called_break to debug.",
                  class_getName(c), o, sel_getName(sel));
    }
    else {
        DEBUG_LOG("Deallocated object (%p) sent %s. printing backtrace. set a  breakpoint on __nszombie_called_break to debug.",
                  o, sel_getName(sel));
    }
    __print_backtrace();
    __nszombie_called_break();
}

@implementation NSZombie

- (Class)class
{
    return (Class)isa;
}

- (Class)originalClass
{
    return NSMapGet(zombieMap, (void*)self);
}

- (void)forwardInvocation:(NSInvocation*)anInvocation
{
    NSUInteger size = [[anInvocation methodSignature] methodReturnLength];
    unsigned char v[size];
    memset(v, '\0', size);
    _log_zombie(self, [anInvocation selector]);
    [anInvocation setReturnValue:(void*)v];
    return;
}

- (NSMethodSignature*)methodSignatureForSelector:(SEL)aSelector
{
    if (!aSelector)
    {
        return nil;
    }

    [allocationLock lock];
    Class c = NSMapGet(zombieMap, (void*)self);
    [allocationLock unlock];
    return [c instanceMethodSignatureForSelector:aSelector];
}

@end

#pragma clang diagnostic pop

#endif
