/*
 * Copyright (c) 2010 Apple Inc. All rights reserved.
 *
 * @APPLE_LLVM_LICENSE_HEADER@
 */

/*
  TEST_CONFIG SDK=macosx
 */

#import <objc/objc-auto.h>
#import <Foundation/Foundation.h>
#import "test.h"

int GlobalInt = 0;

id objc_assign_global(id val __unused, id *dest __unused) {
    GlobalInt = 1;
    return (id)0;
}

id objc_assign_ivar(id val __unused, id dest __unused, ptrdiff_t offset __unused) {
    GlobalInt = 1;
    return (id)0;
}

id objc_assign_strongCast(id val __unused, id *dest __unused) {
    GlobalInt = 1;
    return (id)0;
}


//void (^GlobalVoidVoid)(void);


int main() {
   // an object should not be retained within a stack Block
   __block int i = 0;
   void (^blockA)(void) __unused = ^ {  ++i; };
   if (GlobalInt != 0) {
       fail("write-barrier assignment of stack block");
   }

   succeed(__FILE__);
}
