//
//  NSPlatform.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <CoreFoundation/CFBundle.h>
#import <Foundation/NSObject.h>
#import <Foundation/NSBundle.h>
#import <Foundation/NSString.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSException.h>
#import <objc/runtime.h>
#import "wrap.h"

extern void __CFInitialize();
extern char ***_NSGetArgv(void);

static void _enumerationMutationHandler(id object)
{
    [NSException raise:NSGenericException format:@"Illegal mutation while fast enumerating %@", object];
}

static void NSPlatformInitialize() __attribute__((constructor));
static void NSPlatformInitialize()
{
    __CFInitialize();
    @autoreleasepool {
        NSString* appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:(id)kCFBundleExecutableKey];
        __printf_tag = strdup([appName UTF8String]);
        char ***argv = _NSGetArgv();
        snprintf((*argv)[0], PATH_MAX, "%s/%s", __virtual_prefix(virtual_bundle), __printf_tag);

        objc_setEnumerationMutationHandler(_enumerationMutationHandler);
    }
}
