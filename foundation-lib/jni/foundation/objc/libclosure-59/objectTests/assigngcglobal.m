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

id objc_assign_global(id val __unused, id *dest __unused) {
    GlobalInt = 1;
    return (id)0;
}

id objc_assign_ivar(id val __unused, id dest __unused, ptrdiff_t offset __unused) {
    GlobalInt = 0;
    return (id)0;
}

id objc_assign_strongCast(id val __unused, id *dest __unused) {
    GlobalInt = 0;
    return (id)0;
}


void (^GlobalVoidVoid)(void);


int main() {
   __block int i = 0;
   // assigning a Block into a global should elicit a global write-barrier under GC
   GlobalVoidVoid = ^ {  ++i; };
   if (GlobalInt != 1) {
       fail("missing global write-barrier for Block");
   }

   succeed(__FILE__);
}
