//
//  NSObjCRuntime.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/NSString.h>
#import "ForFoundationOnly.h"
#import <objc/runtime.h>

extern Class NSClassFromObject(id object);
Class NSClassFromObject(id object)
{
    return [object class];
}

NSString *NSStringFromSelector(SEL aSelector)
{
    if (aSelector == NULL)
    {
        return nil;
    }
    else
    {
        return [NSString stringWithUTF8String:sel_getName(aSelector)];
    }
}

SEL NSSelectorFromString(NSString *aSelectorName)
{
    if (aSelectorName == nil)
    {
        return NULL;
    }
    else
    {
        const char *name = [aSelectorName UTF8String];
        return sel_registerName(name);
    }
}

NSString *NSStringFromClass(Class cls)
{
    if (cls == Nil)
    {
        return nil;
    }
    else
    {
        return [NSString stringWithUTF8String: class_getName(cls)];
    }
}

Class NSClassFromString(NSString *aClassName)
{
    return objc_lookUpClass([aClassName UTF8String]);
}

/*!
 @bug   If proto is nil, this will crash on iOS.
 */

NSString *NSStringFromProtocol(Protocol *proto)
{
    return [NSString stringWithUTF8String:protocol_getName(proto)];
}

Protocol *NSProtocolFromString(NSString *namestr)
{
    if (namestr == nil)
    {
        return NULL;
    }
    else
    {
        return objc_getProtocol([namestr UTF8String]);
    }
}

extern CFTypeRef _CFAutoreleasePoolAddObject(CFTypeRef obj);


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-objc-isa-usage"
#pragma clang diagnostic ignored "-Wimplicit-function-declaration"

id NSAllocateObject(Class aClass, NSUInteger extraBytes, NSZone *zone)
{
    return ___CFAllocateObject2(aClass, extraBytes);
}

void NSDeallocateObject(id object)
{
    if (object->isa)
    {
        return;
    }

    object_dispose(object);
    free(object);
}

id NSCopyObject(id object, NSUInteger extraBytes, NSZone *zone)
{
    id cpy = nil;
    if (object != NULL)
    {
        cpy = object_copy(object, extraBytes);
        Class cls = NSClassFromObject(object);
        object_setClass(cpy, cls);
    }
    return cpy;

}

BOOL NSShouldRetainWithZone(id anObject, NSZone *requestedZone)
{
    return YES;
}

void NSIncrementExtraRefCount(id object)
{
    if (object)
    {
        _objc_rootRetain(object);
    }
}

BOOL NSDecrementExtraRefCountWasZero(id object)
{
    BOOL wasZero = NO;
    if (object)
    {
        wasZero = _objc_rootReleaseWasZero(object);
    }
    return wasZero;
}

NSUInteger NSExtraRefCount(id object)
{
    NSUInteger refCnt = 0;
    if (object)
    {
        refCnt = _objc_rootRetainCount(object) - 1;
    }
    return refCnt;
}

extern id NSAutoreleaseObject(id obj);
id NSAutoreleaseObject(id obj)
{
    return (id)_CFAutoreleasePoolAddObject((CFTypeRef)obj);
}

__attribute__((visibility("default"))) extern NSString *_NSNewStringFromCString(const char *cString);
NSString *_NSNewStringFromCString(const char *cString)
{
    return (NSString *)CFStringCreateWithBytes(kCFAllocatorDefault, cString, strlen(cString), kCFStringEncodingUTF8, false);
}
