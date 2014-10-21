//
//  NSObject.m
//  CoreFoundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/NSObject.h>
#import <Foundation/NSString.h>
#import <Foundation/NSMethodSignature.h>
#import <Foundation/NSInvocation.h>
#import <Foundation/NSException.h>
#import "CFString.h"
#import "NSZombie.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import <stdio.h>
#import <libv/libv.h>

void __CFZombifyNSObject(void) {
    Class cls = objc_lookUpClass("NSObject");
    Method dealloc_zombie = class_getInstanceMethod(cls, @selector(__dealloc_zombie));
    Method dealloc = class_getInstanceMethod(cls, @selector(dealloc));
    method_exchangeImplementations(dealloc_zombie, dealloc);
}

BREAKPOINT_FUNCTION(void NSUnrecognizedForwarding())

// TODO: This should be split into Foundation

@implementation NSObject (NSObject)

+ (void)doesNotRecognizeSelector:(SEL)sel
{
    if (_GETENV(BOOL, "NSUnrecognizedForwardingDisabled"))
    {
        RELEASE_LOG("+[%s %s]: unrecognized selector sent to instance %p; set a breakpoint on NSUnrecognizedForwarding to debug", class_getName(self), sel_getName(sel), self);
        NSUnrecognizedForwarding();
    }
    else
    {
        // DONT EVEN THINK ABOUT REMOVING/HACKING AROUND THIS!
        // EVER!
        // ...
        // yes, I mean YOU!
        [NSException raise:NSInvalidArgumentException format:@"+[%s %s]: unrecognized selector sent to instance %p", class_getName(self), sel_getName(sel), self];
    }
}

- (void)doesNotRecognizeSelector:(SEL)sel
{
    if (_GETENV(BOOL, "NSUnrecognizedForwardingDisabled"))
    {
        RELEASE_LOG("+[%s %s]: unrecognized selector sent to instance %p; set a breakpoint on NSUnrecognizedForwarding to debug", object_getClassName(self), sel_getName(sel), self);
        NSUnrecognizedForwarding();
    }
    else
    {
        // DONT EVEN THINK ABOUT REMOVING/HACKING AROUND THIS!
        // EVER!
        // ...
        // yes, I mean YOU!
        [NSException raise:NSInvalidArgumentException format:@"-[%s %s]: unrecognized selector sent to instance %p", object_getClassName(self), sel_getName(sel), self];
    }
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


- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel
{
    if (sel == NULL)
    {
        return nil;
    }

    Method m = class_getInstanceMethod(object_getClass(self), sel);

    if (m == NULL)
    {
        return nil;
    }

    return [NSMethodSignature signatureWithObjCTypes:method_getTypeEncoding(m)];
}

+ (NSString *)debugDescription
{
    return [self description];
}

+ (NSString *)description
{
    CFStringRef description = CFStringCreateWithCString(kCFAllocatorDefault, class_getName(self), kCFStringEncodingUTF8);
    return [(NSString *)description autorelease];
}

- (NSString *)debugDescription
{
    return [self description];
}

- (NSString *)description
{
    CFStringRef description = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("<%s: %p>"), object_getClassName(self), self);
    return [(NSString *)description autorelease];
}

+ (BOOL)implementsSelector:(SEL)selector
{
    if (selector == NULL)
    {
        [NSException raise:NSInvalidArgumentException format:@"selector cannot be NULL"];
        return NO;
    }

    return class_getMethodImplementation(object_getClass(self), selector) != (IMP)&_objc_msgForward;
}

- (BOOL)implementsSelector:(SEL)selector
{
    if (selector == NULL)
    {
        [NSException raise:NSInvalidArgumentException format:@"selector cannot be NULL"];
        return NO;
    }

    // sneaky! this calls [self class]!!
    return class_getMethodImplementation([self class], selector) != (IMP)&_objc_msgForward;
}

+ (BOOL)instancesImplementSelector:(SEL)selector
{
    if (selector == NULL)
    {
        [NSException raise:NSInvalidArgumentException format:@"selector cannot be NULL"];
        return NO;
    }

    return class_getMethodImplementation(self, selector) != (IMP)&_objc_msgForward;
}

+ (void)forwardInvocation:(NSInvocation *)inv
{
    [inv setTarget:self];
    [inv invoke];
}

- (void)forwardInvocation:(NSInvocation *)inv
{
    [inv setTarget:self];
    [inv invoke];
}

- (void)__dealloc_zombie
{
    const char *className = object_getClassName(self);
    char *zombieClassName = NULL;
    do {
        if (asprintf(&zombieClassName, "%s%s", ZOMBIE_PREFIX, className) == -1)
        {
            break;
        }

        Class zombieClass = objc_getClass(zombieClassName);
        
        if (zombieClass == Nil) 
        {
            zombieClass = objc_duplicateClass(objc_getClass(ZOMBIE_PREFIX), zombieClassName, 0);
        }

        if (zombieClass == Nil)
        {
            break;
        }

        objc_destructInstance(self);

        object_setClass(self, zombieClass);

    } while (0);
    
    if (zombieClassName != NULL)
    {
        free(zombieClassName);
    }
}

@end

@implementation NSObject (NSCoderMethods)

- (BOOL)_allowsDirectEncoding
{
    return NO;
}

+ (NSInteger)version
{
    return class_getVersion(self);
}

+ (void)setVersion:(NSInteger)aVersion
{
    class_setVersion(self, aVersion);
}

- (Class)classForCoder
{
    return [self class];
}

- (id)replacementObjectForCoder:(NSCoder *)aCoder
{
    return self;
}

- (id)awakeAfterUsingCoder:(NSCoder *)aDecoder
{
    return self;
}

@end

@implementation NSObject (__NSIsKinds)

- (BOOL)isNSValue__
{
    return NO;
}

- (BOOL)isNSTimeZone__
{
    return NO;
}

- (BOOL)isNSString__
{
    return NO;
}

- (BOOL)isNSSet__
{
    return NO;
}

- (BOOL)isNSOrderedSet__
{
    return NO;
}

- (BOOL)isNSNumber__
{
    return NO;
}

- (BOOL)isNSDictionary__
{
    return NO;
}

- (BOOL)isNSDate__
{
    return NO;
}

- (BOOL)isNSData__
{
    return NO;
}

- (BOOL)isNSArray__
{
    return NO;
}

@end

