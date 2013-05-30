/*
 * Copyright (c) 2010 Apple Inc. All rights reserved.
 *
 * @APPLE_LLVM_LICENSE_HEADER@
 */

// TEST_CONFIG SDK=macosx MEM=gc
// TEST_CFLAGS -framework Foundation

#import <objc/objc-auto.h>
#import <Foundation/Foundation.h>
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

@interface Foo : NSObject {
@public
    void (^__weak ivar)(void);
}
@end
@implementation Foo
@end


int main() {
    // an object should not be retained within a stack Block
    __block int i = 0;
    void (^local)(void);
    Foo *foo = [[Foo alloc] init];
    foo->ivar = ^ {  ++i; };
    local = foo->ivar;
    if (GlobalInt2 != 1) {
        fail("problem with weak read of ivar");
    }

    succeed(__FILE__);
}

