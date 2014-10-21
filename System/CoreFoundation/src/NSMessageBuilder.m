//
//  NSMessageBuilder.m
//  CoreFoundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "NSMessageBuilder.h"
#import <Foundation/NSInvocation.h>
#import <Foundation/NSMethodSignature.h>
#import <objc/runtime.h>

@implementation __NSMessageBuilder

id _NSMessageBuilder(id proxy, NSInvocation **inv, SEL _cmd, void *arg)
{
    __NSMessageBuilder *builder = class_createInstance(objc_getClass("__NSMessageBuilder"), 0);
    builder->_target = proxy;

    // this is not exactly correct, since this is intended to traverse over a distributed 
    // object bridge here but it is a reasonable approximation of what happens

    Class cls = object_getClass(proxy);
    Method m = class_getClassMethod(cls, _cmd);
    NSMethodSignature *sig = nil;

    if (m != NULL)
    {
       sig = [NSMethodSignature signatureWithObjCTypes:method_getTypeEncoding(m)]; 
    }
    
    *inv = [NSInvocation invocationWithMethodSignature:sig];
    [*inv setSelector:_cmd];
    [*inv setArgument:&arg atIndex:2];

    return builder;
}


+ (void)initialize
{

}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel
{
    return [_target methodSignatureForSelector:sel];
}

- (void)forwardInvocation:(NSInvocation *)inv
{
    [inv setTarget:_target];
    if (_addr != NULL)
    {
        *(id *)_addr = [[inv retain] autorelease];
    }

    // this is again an aproximation of a remote message
    // which by default will throw (however the description may be 
    // slightly misleading; but no one should depend on that anyways...)
    [_target forwardInvocation:inv];
}

@end
