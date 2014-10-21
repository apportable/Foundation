//
//  NSProxy.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/NSProxy.h>
#import <Foundation/NSString.h>
#import <Foundation/NSInvocation.h>
#import <Foundation/NSMethodSignature.h>
#import <Foundation/NSException.h>
#import <Foundation/NSZone.h>
#import "NSMessageBuilder.h"
#import <objc/runtime.h>
#import <objc/message.h>

OBJC_EXPORT bool _objc_rootIsDeallocating(id obj);
OBJC_EXPORT bool _objc_rootReleaseWasZero(id obj);
OBJC_EXPORT bool _objc_rootTryRetain(id obj);
OBJC_EXPORT id _objc_rootAlloc(Class cls);
OBJC_EXPORT id _objc_rootAllocWithZone(Class cls, NSZone *zone);
OBJC_EXPORT id _objc_rootAutorelease(id obj);
OBJC_EXPORT id _objc_rootRetain(id obj);
OBJC_EXPORT NSZone *_objc_rootZone(id obj);
OBJC_EXPORT uintptr_t _objc_rootHash(id obj);
OBJC_EXPORT uintptr_t _objc_rootRetainCount(id obj);
OBJC_EXPORT void _objc_rootDealloc(id obj);



@implementation NSProxy

+ (NSString *)description
{
    return [NSString stringWithFormat:@"%s", class_getName(self)];
}

+ (IMP)methodForSelector:(SEL)sel
{
    if (sel == NULL)
    {
        [NSException raise:NSInvalidArgumentException format:@"NULL is a invalid selector"];
        return NULL;
    }
    return class_getMethodImplementation(object_getClass((id)self), sel);
}

+ (IMP)instanceMethodForSelector:(SEL)sel
{
    if (sel == NULL)
    {
        [NSException raise:NSInvalidArgumentException format:@"NULL is a invalid selector"];
        return NULL;
    }
    return class_getMethodImplementation(self, sel);
}

+ (BOOL)instancesRespondToSelector:(SEL)sel
{
    if (sel == NULL)
    {
        return NO;
    }
    return class_respondsToSelector(self, sel);
}

+ (BOOL)conformsToProtocol:(Protocol *)protocol
{
    if (protocol == NULL)
    {
        return NO;
    }
    for (Class cls = self; cls; cls = class_getSuperclass(cls))
    {
        if (class_conformsToProtocol(cls, protocol))
        {
            return YES;
        }
    }
    return NO;
}

+ (BOOL)isKindOfClass:(Class)aClass
{
    for (Class cls = object_getClass((id)self); cls; cls = class_getSuperclass(cls))
    {
        if (cls == aClass)
        {
            return YES;
        }
    }
    return NO;
}

+ (BOOL)isMemberOfClass:(Class)aClass
{
    return object_getClass((id)self) == aClass;
}

+ (BOOL)isSubclassOfClass:(Class)aClass
{
    for (Class cls = self; cls; cls = class_getSuperclass(cls))
    {
        if (cls == aClass)
        {
            return YES;
        }
    }
    return NO;
}

+ (BOOL)isProxy
{
    return NO; // huh?
}

+ (BOOL)isFault
{
    return NO;
}

+ (id)performSelector:(SEL)sel
{
    if (sel == NULL)
    {
        [self doesNotRecognizeSelector:sel];
    }
    return ((id(*)(id, SEL))objc_msgSend)((id)self, sel);
}

+ (id)performSelector:(SEL)sel withObject:(id)object
{
    if (sel == NULL)
    {
        [self doesNotRecognizeSelector:sel];
    }
    return ((id(*)(id, SEL, id))objc_msgSend)((id)self, sel, object);
}

+ (id)performSelector:(SEL)sel withObject:(id)obj1 withObject:(id)obj2
{
    if (sel == NULL)
    {
        [self doesNotRecognizeSelector:sel];
    }
    return ((id(*)(id, SEL, id, id))objc_msgSend)((id)self, sel, obj1, obj2);
}

+ (NSUInteger)hash
{
    return _objc_rootHash((id)self);
}

+ (BOOL)isEqual:(id)other
{
    return self == other;
}

+ (NSString *)_copyDescription
{
    NSString *desc = nil;
    @autoreleasepool {
        desc = [[self description] retain];
    }
    return desc;
}

+ (NSString *)debugDescription
{
    return [self description];
}

+ (NSZone *)zone
{
    return _objc_rootZone((id)self);
}

+ (BOOL)retainWeakReference
{
    return YES;
}

+ (BOOL)allowsWeakReference
{
    return YES;
}

+ (BOOL)_isDeallocating
{
    return NO;
}

+ (BOOL)_tryRetain
{
    return NO;
}

+ (void)dealloc
{
    [NSException raise:NSInvalidArgumentException format:@"Attempting to deallocate a class"];
}

+ (id)init
{
    [NSException raise:NSInvalidArgumentException format:@"Attempting to init a class"];
    return nil;
}

+ (void)doesNotRecognizeSelector:(SEL)sel
{
    [NSException raise:NSInvalidArgumentException format:@"Selector not recognized +[%s %s]", class_getName(self), sel_getName(sel)];
}

+ (void)forwardInvocation:(NSInvocation *)inv
{
    [self doesNotRecognizeSelector:[inv selector]];
}

+ (NSMethodSignature *)methodSignatureForSelector:(SEL)sel
{
    if (sel == NULL)
    {
        return nil;
    }
    Method m = class_getClassMethod(self, sel);
    if (m == NULL)
    {
        return nil;
    }
    return [NSMethodSignature signatureWithObjCTypes:method_getTypeEncoding(m)];
}

+ (NSMethodSignature *)instanceMethodSignatureForSelector:(SEL)sel
{
    if (sel == NULL)
    {
        return nil;
    }
    Method m = class_getInstanceMethod(self, sel);
    if (m == NULL)
    {
        return nil;
    }
    return [NSMethodSignature signatureWithObjCTypes:method_getTypeEncoding(m)];
}

+ (id)forwardingTargetForSelector:(SEL)sel
{
    return nil;
}

+ (BOOL)isAncestorOfObject:(id)obj
{
    for (Class cls = [obj class]; cls; cls = class_getSuperclass(cls))
    {
        if (cls == self)
        {
            return YES;
        }
    }
    return NO;
}

+ (BOOL)respondsToSelector:(SEL)sel
{
    if (sel == NULL)
    {
        return NO;
    }
    return class_respondsToSelector(object_getClass((id)self), sel);
}

+ (id)mutableCopyWithZone:(NSZone *)zone
{
    return self;
}

+ (id)mutableCopy
{
    return self;
}

+ (id)copyWithZone:(NSZone *)zone
{
    return self;
}

+ (id)copy
{
    return self;
}

+ (NSUInteger)retainCount
{
    return ULONG_MAX;
}

+ (id)autorelease
{
    return self;
}

+ (oneway void)release
{

}

+ (id)retain
{
    return self;
}

+ (id)self
{
    return self;
}

+ (Class)superclass
{
    return class_getSuperclass(self);
}

+ (Class)class
{
    return self;
}

+ (id)alloc
{
    return _objc_rootAlloc(self);
}

+ (id)allocWithZone:(NSZone *)zone
{
    return _objc_rootAllocWithZone(self, zone);
}

+ (void)initialize
{

}

- (BOOL)respondsToSelector:(SEL)sel
{
    BOOL retVal = NO;
    NSInvocation *inv = nil;
    id receiver = _NSMessageBuilder(self, &inv, _cmd, sel);
    [receiver forwardInvocation:inv];
    [receiver getReturnValue:&retVal];
    object_dispose(receiver);
    return retVal;
}

- (BOOL)conformsToProtocol:(Protocol *)protocol
{
    BOOL retVal = NO;
    NSInvocation *inv = nil;
    id receiver = _NSMessageBuilder(self, &inv, _cmd, protocol);
    [self forwardInvocation:inv];
    [receiver getReturnValue:&retVal];
    object_dispose(receiver);
    return retVal;
}

- (BOOL)isMemberOfClass:(Class)cls
{
    BOOL retVal = NO;
    NSInvocation *inv = nil;
    id receiver = _NSMessageBuilder(self, &inv, _cmd, cls);
    [receiver forwardInvocation:inv];
    [receiver getReturnValue:&retVal];
    object_dispose(receiver);
    return retVal;
}

- (BOOL)isKindOfClass:(Class)aClass
{
    BOOL retVal = NO;
    NSInvocation *inv = nil;
    id receiver = _NSMessageBuilder(self, &inv, _cmd, aClass);
    [receiver forwardInvocation:inv];
    [inv getReturnValue:&retVal];
    object_dispose(receiver);
    return retVal;
}

- (BOOL)isProxy
{
    return YES;
}

- (BOOL)isFault
{
    return NO;
}

- (id)performSelector:(SEL)sel
{
    if (sel == NULL)
    {
        [self doesNotRecognizeSelector:sel];
    }
    return ((id(*)(id, SEL))objc_msgSend)((id)self, sel);
}

- (id)performSelector:(SEL)sel withObject:(id)object
{
    if (sel == NULL)
    {
        [self doesNotRecognizeSelector:sel];
    }
    return ((id(*)(id, SEL, id))objc_msgSend)((id)self, sel, object);
}

- (id)performSelector:(SEL)sel withObject:(id)obj1 withObject:(id)obj2
{
    if (sel == NULL)
    {
        [self doesNotRecognizeSelector:sel];
    }
    return ((id(*)(id, SEL, id, id))objc_msgSend)((id)self, sel, obj1, obj2);
}

- (NSUInteger)hash
{
    return _objc_rootHash(self);
}

- (BOOL)isEqual:(id)other
{
    return other == self;
}

- (NSString *)_copyDescription
{
    NSString *desc = nil;
    @autoreleasepool {
        desc = [[self description] retain];
    }
    return desc;
}

- (NSString *)debugDescription
{
    return [self description];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%s %p>", class_getName([self class]), self];
}

- (BOOL)_allowsDirectEncoding
{
    return NO;
}

- (NSZone *)zone
{
    return _objc_rootZone(self);
}

- (void)dealloc
{
    _objc_rootDealloc(self);
}

- (BOOL)retainWeakReference
{
    return [self _tryRetain];
}

- (BOOL)allowsWeakReference
{
    return ![self _isDeallocating];
}

- (BOOL)_tryRetain
{
    return _objc_rootTryRetain(self);
}

- (BOOL)_isDeallocating
{
    return _objc_rootIsDeallocating(self);
}

- (id)autorelease
{
    return _objc_rootAutorelease(self);
}

- (oneway void)release
{
    if (_objc_rootReleaseWasZero(self) == false) {
        return;
    }
    [self dealloc];
}

- (NSUInteger)retainCount
{
    return _objc_rootRetainCount(self);
}

- (id)retain
{
    return _objc_rootRetain(self);
}

- (void)doesNotRecognizeSelector:(SEL)sel
{
    [NSException raise:NSInvalidArgumentException format:@"Selector not recognized -[%s %s]", class_getName(object_getClass(self)), sel_getName(sel)];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel
{
    [NSException raise:NSInvalidArgumentException format:@"-[NSProxy methodSignatureForSelector:]"];
    return nil;
}

- (void)forwardInvocation:(NSInvocation *)inv
{
    [NSException raise:NSInvalidArgumentException format:@"-[NSProxy forwardInvocation:]"];
}

- (id)forwardingTargetForSelector:(SEL)sel
{
    return nil;
}

- (id)self
{
    return self;
}

- (Class)superclass
{
    return class_getSuperclass([self class]);
}

- (Class)class
{
    return object_getClass(self);
}

@end
