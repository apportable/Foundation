/*
 * Copyright (c) 2010 Apple Inc. All rights reserved.
 *
 * @APPLE_LLVM_LICENSE_HEADER@
 */

/*
  TEST_CONFIG SDK=macosx MEM=gc
 */

#import <stdio.h>
#import <stdlib.h>
#import <objc/objc-auto.h>
#import "test.h"

int GlobalInt = 0;

#ifdef __cplusplus
extern "C" {
#endif
id objc_assign_global(id val __unused, id *dest __unused) {
    GlobalInt = 1;
    return (id)0;
}

id objc_assign_ivar(id val __unused, id dest __unused, ptrdiff_t offset __unused) {
    GlobalInt = 0;
    return (id)0;
}

id objc_assign_strongCast(id val __unused, id *dest __unused) {
    GlobalInt = 1;
    return (id)0;
}

#ifdef __cplusplus
}
#endif

typedef struct {
    void (^ivarBlock)(void);
} StructWithBlock_t;


int main() {
   StructWithBlock_t *swbp = (StructWithBlock_t *)malloc(sizeof(StructWithBlock_t*));
   __block int i = 10;
   // assigning a Block into an struct slot should elicit a write-barrier under GC
   swbp->ivarBlock = ^ { ++i; };
   if (GlobalInt != 1) {
       fail("missing strong cast write-barrier for Block");
   }

   succeed(__FILE__);
}

