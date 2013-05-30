/*
 * Copyright (c) 2010 Apple Inc. All rights reserved.
 *
 * @APPLE_LLVM_LICENSE_HEADER@
 */

// TEST_CONFIG SDK=macosx MEM=gc

#import <stdio.h>
#import <stdlib.h>
#import <objc/objc-auto.h>
#import "test.h"

int GlobalInt = 0;
int GlobalInt2 = 0;

#ifdef __cplusplus
extern "C" {
#endif
id objc_assign_weak(id value, id *location) {
    GlobalInt = 1;
    *location = value;
    return value;
}

id objc_read_weak(id *location) {
    GlobalInt2 = 1;
    return *location;
}
#ifdef __cplusplus
}
#endif


void (^__weak Henry)(void);

int main() {
    // an object should not be retained within a stack Block
    void (^local)(void);
    __block int i = 10;
    Henry = ^ {  ++i; };
    local = Henry;
    if (GlobalInt2 != 1) {
        fail("problem with weak read barrier of global block");
    }
    
    succeed(__FILE__);
}

