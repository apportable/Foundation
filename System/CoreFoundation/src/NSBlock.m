//
//  NSBlock.m
//  CoreFoundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "NSBlock.h"
#import <dispatch/dispatch.h>
#import <objc/runtime.h>

extern Class objc_initializeClassPair(Class superclass_gen, const char *name, Class cls_gen, Class meta_gen);

static inline BOOL createBlockClass(const char *sup, const char *name, void *dest)
{
    Class cls = objc_getClass(sup);
    if (cls == Nil)
    {
        return NO;
    }
    Class meta = calloc(class_getInstanceSize(object_getClass(cls)), 1);
    if (meta == Nil)
    {
        return NO;
    }
    Class registered = objc_initializeClassPair(cls, name, dest, meta);
    if (registered == Nil)
    {
        return NO;
    }
    objc_registerClassPair(registered);
    return YES;
}

static void NSBlockInitialize() __attribute__((constructor));
static void NSBlockInitialize()
{
    if (createBlockClass("__NSStackBlock", "__NSStackBlock__", &_NSConcreteStackBlock) == NO)
    {
        DEBUG_LOG("Failure to create stack block class");
        abort();
    }
    if (createBlockClass("__NSMallocBlock", "__NSMallocBlock__", &_NSConcreteMallocBlock) == NO)
    {
        DEBUG_LOG("Failure to create malloc block class");
        abort();
    }
    if (createBlockClass("__NSAutoBlock", "__NSAutoBlock__", &_NSConcreteAutoBlock) == NO)
    {
        DEBUG_LOG("Failure to create auto block class");
        abort();
    }
    if (createBlockClass("__NSFinalizingBlock", "__NSFinalizingBlock__", &_NSConcreteFinalizingBlock) == NO)
    {
        DEBUG_LOG("Failure to create finalizing block class");
        abort();
    }
    if (createBlockClass("__NSGlobalBlock", "__NSGlobalBlock__", &_NSConcreteGlobalBlock) == NO)
    {
        DEBUG_LOG("Failure to create global block class");
        abort();
    }
    if (createBlockClass("__NSBlockVariable", "__NSBlockVariable__", &_NSConcreteWeakBlockVariable) == NO)
    {
        DEBUG_LOG("Failure to create block variable class");
        abort();
    }
}

@implementation NSBlock (Extensions)

- (void)performAfterDelay:(NSTimeInterval)delay
{
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), (dispatch_block_t)self);
}
- (id)copy
{
    return Block_copy(self);
}

@end


@implementation __NSStackBlock

- (id)autorelease
{
    return self;
}

- (NSUInteger)retainCount
{
    return 1;
}

- (oneway void)release
{
    
}

- (id)retain
{
    return self;
}

@end

@implementation __NSMallocBlock

- (BOOL)_isDeallocating
{
    return _Block_isDeallocating(self);
}

- (BOOL)_tryRetain
{
    return _Block_tryRetain(self);
}

- (unsigned int)retainCount
{
    return 1;
}

- (oneway void)release
{
    Block_release(self);
}

- (id)retain
{
    return Block_copy(self);
}

@end

@implementation __NSAutoBlock

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)copy
{
    return self;
}

@end

@implementation __NSFinalizingBlock

- (void)finalize
{
    // NO! go away! why are you using garbage collection?!
}

@end

@implementation __NSGlobalBlock

- (BOOL)_isDeallocating
{
    return NO;
}

- (BOOL)_tryRetain
{
    return YES;
}

- (NSUInteger)retainCount
{
    return 1;
}

- (id)retain
{
    return self;
}

- (oneway void)release
{
    
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)copy
{
    return self;
}

@end

@implementation __NSBlockVariable

@end
