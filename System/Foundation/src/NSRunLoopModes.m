//
//  NSRunLoopModes.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/NSString.h>
#import <CoreFoundation/CFRunLoop.h>

#import "NSRunLoopModesInternal.h"

// Forgive me, the loader is not merging NSStrings/CFStrings correctly
// This is a VERY hacky workaround.
#warning https://code.google.com/p/apportable/issues/detail?id=370

NSString *NSDefaultRunLoopMode = nil;
NSString *NSRunLoopCommonModes = nil;

static void NSRunLoopModeFix(void) __attribute__((constructor));
static void NSRunLoopModeFix(void)
{
    NSDefaultRunLoopMode = (NSString *)kCFRunLoopDefaultMode;
    NSRunLoopCommonModes = (NSString *)kCFRunLoopCommonModes;
}
