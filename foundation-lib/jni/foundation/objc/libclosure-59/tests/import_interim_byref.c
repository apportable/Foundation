/*
 * Copyright (c) 2010 Apple Inc. All rights reserved.
 *
 * @APPLE_LLVM_LICENSE_HEADER@
 */

/*
 *  import_interim_byref.c
 *  Examples
 *
 *  Created by Blaine Garst on 2/13/08.
 *  Copyright 2008 __MyCompanyName__. All rights reserved.
 *
 */



#include "driver.h"

// Interim closure implementation - merely keep addresses of stack until we learn
// how to move other parameters into byref block
//
//

#if __BLOCKS__
int import_byref_interim_real(int verbose) {
    int x = rand();
    int y = 15;
    void (^myClosure)(void) = ^ (void) { | y | setGlobalInt(x+y); ++y;};
    x++;
    callVoidVoid(myClosure);

    int globalValue = getGlobalInt();
    int desiredValue = x+y-2;
    if (error_found("import_byref_interim", globalValue, desiredValue, verbose)) return 1;

#if FULL_CLOSURES
    void (^myClosureCopy)(void) = Block_copy(myClosure);
    callVoidVoid(myClosureCopy);

    globalValue = getGlobalInt();
    if (error_found("import_byref_interim copy", globalValue, desiredValue, verbose)) return 1;

    Block_release(myClosureCopy);
#endif
    return 0;
}

#endif __BLOCKS__


struct import_byref_interim_struct {
  struct Block_basic base;
  const int x;
  int *py;
};
  
// the "thunks" compiled for the invoke entry point of the import_byref

void invoke_import_byref_interim(struct import_byref_interim_struct *aBlock) {
  // no return value so just a void invoke
  // the compound statement rewritten to reference locals via the const copies.
  {
    //printf("closure x is %d and y is %d\n", aBlock->x, *aBlock->py);
    setGlobalInt(aBlock->x + *aBlock->py);
    ++*aBlock->py;
   }
}


// The rewritten version of the code above

int import_byref_interim(int verbose) {
   int x = rand();
   int y = 15;
   
   struct import_byref_interim_struct myClosure = {
        { 0, BLOCK_NO_COPY, sizeof(struct import_byref_interim_struct),
            (void (*)(void *))invoke_import_byref_interim,
        },
        x, // capture x
        &y // capture y
   };
   x++;
   callVoidVoid(&myClosure.base);
   
   int globalValue = getGlobalInt();
   int desiredValue = x+y-2;
   if (error_found("import_byref_interim", globalValue, desiredValue, verbose)) return 1;

#if FULL_CLOSURES
    struct import_byref_interim_struct *myClosureCopy = Block_copy(&myClosure.base);
    callVoidVoid(&myClosureCopy->base);
   
    globalValue = getGlobalInt();
    if (error_found("import_byref_interim copy", globalValue, desiredValue, verbose)) return 1;
    Block_release(myClosureCopy);
#endif
    
    
    return 0;
}
