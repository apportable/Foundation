/*
 * Copyright (c) 2010 Apple Inc. All rights reserved.
 *
 * @APPLE_LLVM_LICENSE_HEADER@
 */

// TEST_CONFIG SDK=macosx MEM=gc
// TEST_CFLAGS -framework Foundation

#import <objc/objc-auto.h>
#import <Foundation/Foundation.h>
#import <Block.h>
#import "test.h"

int countem(NSHashTable *table) {
    int result = 0;
    for (id elem in table)
        ++result;
    return result;
}

int main() {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSHashTable *weakSet = [NSHashTable hashTableWithWeakObjects];
    void (^local)(void) = ^{ [weakSet count]; };
    extern id _Block_copy_collectable(void *);
    //[weakSet addObject:_Block_copy_collectable(local)];
    [weakSet addObject:Block_copy(local)];
    [weakSet addObject:Block_copy(local)];
    [weakSet addObject:Block_copy(local)];
    [weakSet addObject:Block_copy(local)];
    [weakSet addObject:Block_copy(local)];
    [weakSet addObject:Block_copy(local)];
    //printf("gc block... we hope\n%s\n", _Block_dump(Block_copy(local)));
    if (objc_collectingEnabled()) {
        objc_collect(OBJC_EXHAUSTIVE_COLLECTION|OBJC_WAIT_UNTIL_DONE);
        int count = countem(weakSet);
        if (count != 6) {
            fail("didn't recover %d of %d items", count, 6);
        }
    }

    [pool release];

    succeed(__FILE__);
}
