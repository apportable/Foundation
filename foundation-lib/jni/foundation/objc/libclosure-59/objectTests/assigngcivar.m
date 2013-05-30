/*
 * Copyright (c) 2010 Apple Inc. All rights reserved.
 *
 * @APPLE_LLVM_LICENSE_HEADER@
 */

/*
  TEST_CONFIG SDK=macosx MEM=gc
  TEST_CFLAGS -framework Foundation
 */

#import <objc/objc-auto.h>
#import <Foundation/Foundation.h>
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
    GlobalInt = 1;
    return (id)0;
}

id objc_assign_strongCast(id val __unused, id *dest __unused) {
    GlobalInt = 0;
    return (id)0;
}
#ifdef __cplusplus
}
#endif

@interface TestObject : NSObject {
@public
    void (^ivarBlock)(void);
    id x;
}
@end

@implementation TestObject
@end


int main() {
   __block int i = 0;
   TestObject *to = [[TestObject alloc] init];
   // assigning a Block into an ivar should elicit a  write-barrier under GC
   to->ivarBlock =  ^ {  ++i; };		// fails to gen write-barrier
   //to->x = to;				// gens write-barrier
   if (GlobalInt != 1) {
       fail("missing ivar write-barrier for Block");
   }

   succeed(__FILE__);
}

