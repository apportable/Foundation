/*
 * Copyright (c) 2010 Apple Inc. All rights reserved.
 *
 * @APPLE_LLVM_LICENSE_HEADER@
 */

/*
 *  import_global.c
 *  libclosure
 *
 *  Created by Blaine Garst on 2/25/08.
 *  Copyright 2008 __MyCompanyName__. All rights reserved.
 *
 */

#include "driver.h"

int TestGlobal = 0;

#if __BLOCKS__

int import_global_real(int verbose) {
    TestGlobal = rand();
    void (^myClosure)(void) = myClosure = ^ (void) { setGlobalInt(TestGlobal);};
    TestGlobal += 1000;
    callVoidVoid(myClosure);

    int globalValue = getGlobalInt();
    int desiredValue = TestGlobal;
    if (error_found("import_global_real", globalValue, desiredValue, verbose)) return 1;

    return 0;
}

#endif __BLOCKS__

// the closure data structure sythesized for the import_byref
struct import_global_struct {
  struct Block_basic base;
};


void invoke_import_global(struct import_global_struct *aBlock) {
  // no return value so just a void invoke
  // the compound statement rewritten to reference locals via the const copies.
  {
    setGlobalInt(TestGlobal);
   }
}

int import_global(int verbose) {
    TestGlobal = rand();
    struct import_global_struct onStack = {
        { 0, 0, sizeof(struct import_global_struct),
            (void (*)(void *))invoke_import_global,
         }
    };
    struct import_global_struct *myClosure = &onStack;
    TestGlobal += 1000;
    callVoidVoid(myClosure);
    int globalValue = getGlobalInt();
    int desiredValue = TestGlobal;
    if (error_found("import_global_real", globalValue, desiredValue, verbose)) return 1;

    return 0;
}
