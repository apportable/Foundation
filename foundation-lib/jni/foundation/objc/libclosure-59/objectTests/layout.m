/*
 * Copyright (c) 2010 Apple Inc. All rights reserved.
 *
 * @APPLE_LLVM_LICENSE_HEADER@
 */

//
//  layout.m
//  bocktest
//
//  Created by Blaine Garst on 3/21/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

// TEST_CONFIG SDK=macosx
// TEST_CFLAGS -framework Foundation

#include <Foundation/Foundation.h>
#include <objc/runtime.h>
#include "test.h"

@interface TestObject : NSObject {
    int (^getInt)(void);
    int object;
}
@property(copy) int (^getInt)(void);
@end

@implementation TestObject
@synthesize getInt;
@end


int main() {
    [[NSAutoreleasePool alloc] init];
    if (! [NSGarbageCollector defaultCollector]) {
        succeed(__FILE__);
    }

    TestObject *to = [[TestObject alloc] init];
    //to = [NSCalendarDate new];
    const uint8_t *layout = (const uint8_t *)class_getIvarLayout(*(Class *)to);
    if (!layout) {
        fail("no layout for class TestObject!!!");
    }
    //printf("layout is:\n");
    int cursor = 0;
    // we're looking for slot 1
    int seeking = 1;
    while (*layout) {
        int skip = (*layout) >> 4;
        int process = (*layout) & 0xf;
        //printf("(%x) skip %d, process %d\n", (*layout), skip, process);
        cursor += skip;
        if ((cursor <= seeking) && ((cursor + process) > seeking)) {
            succeed(__FILE__);
        }
        cursor += process;
        ++layout;
    }

    fail("didn't scan slot %d\n", seeking);
}
