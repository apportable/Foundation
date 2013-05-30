/*
 * Copyright (c) 2010 Apple Inc. All rights reserved.
 *
 * @APPLE_LLVM_LICENSE_HEADER@
 */

/*
 *  import_byref.c
 *  Examples
 *
 *  Created by Blaine Garst on 2/1/08.
 *  Copyright 2008 __MyCompanyName__. All rights reserved.
 *
 */


#include "driver.h"

//
// Example closure code generated for specific Blocks
//

//
// Fully bound computation on const imported locals
//

#if __BLOCKS__
int import_byref_real(int verbose) {
    int x = rand();
    int y = 15;
    void (^myClosure)(void) = ^ (void) { | y | setGlobalInt(x+y); ++y;};
    x++;
    callVoidVoid(myClosure);

    int globalValue = getGlobalInt();
    int desiredValue = x + y - 2;
    if (error_found("import byref", globalValue, desiredValue, verbose)) return 1;

#if FULL_CLOSURES
// not yet
    void (^myClosureCopy)(void) = Block_copy(myClosure);
    callVoidVoid(myClosureCopy, NULL);

    globalValue = getGlobalInt();
    if (error_found("import byref copy", globalValue, desiredValue, verbose)) return 1;

    Block_release(myClosureCopy);
#endif
    return 0;
}

#endif __BLOCKS__

// the closure data structure sythesized for the import_byref
struct import_byref_shared_struct {
    struct Block_byref base;
    int y;
};


struct import_byref_struct {
  struct Block_basic base;
  const int x;
  struct import_byref_shared_struct *shared_struct;
};

void print_byref_struct(struct import_byref_shared_struct *ibs) {
   printf("byref structure @ %p:\n", ibs);
   printf("forwarding: %p\nrefcount: %d\nsize: %d\n", ibs->base.forwarding, ibs->base.flags, ibs->base.size);
   printf("y: %d\n\n", ibs->y);
}
  
// the "thunks" compiled for the invoke entry point of the import_byref

void invoke_import_byref(struct import_byref_struct *aBlock) {
  // no return value so just a void invoke
  // the compound statement rewritten to reference locals via the const copies.
  {
    setGlobalInt(aBlock->x + aBlock->shared_struct->y);
    ++aBlock->shared_struct->y;
   }
}

// fix up the just copied closure
void copy_import_byref(struct import_byref_struct *dst, struct import_byref_struct *src) {

   // do closure specific work
   // the new closure can't reference the stack, so update it's pointer.
   // _Block_byref_assign_copy will either copy it to the heap or bump the heap refcount
   //print_byref_struct(aBlock->shared_struct);
   _Block_byref_assign_copy(&dst->shared_struct, src->shared_struct);
    //print_byref_struct(aBlock->shared_struct);

}

// the closure 'destructor'
// Only called when destroying a heap based closure
void destroy_import_byref(struct import_byref_struct *aBlock) {
    // do closure specific unwork
    // lose the heap based closure's reference to the shared struct
    // The lexical scope will also have this call synthesized
    Block_release_byref(aBlock->shared_struct);
}

// The rewritten version of the code above

int import_byref(int verbose) {
    int x = rand();
    // XXX move this into support routine
    struct import_byref_shared_struct shared_struct;
    shared_struct.base.flags = 0;//BLOCK_HAS_COPY_DISPOSE;
    shared_struct.base.forwarding = &shared_struct;
    shared_struct.base.size = sizeof(struct import_byref_shared_struct);

    // this byref does not contain
    // 1) another closure
    // 2) an id
    // 3) a C++ stack object
    // and so, there is nothing for it to do on preserve/destroy
    shared_struct.base.byref_destroy = NULL;
    shared_struct.base.byref_keep = NULL;

    shared_struct.y = 15;
    struct import_byref_struct myClosure = {
        { 0, BLOCK_HAS_COPY_DISPOSE, sizeof(struct import_byref_struct),
            (void (*)(void *))invoke_import_byref,
            (void (*)(void *, void *))copy_import_byref,
            (void (*)(void *))destroy_import_byref
        },
        x, // capture x
        &shared_struct // capture y
    };
    x++;
    callVoidVoid(&myClosure.base);

    int globalValue = getGlobalInt();
    int desiredValue = x + ((struct import_byref_shared_struct *)(shared_struct.base.forwarding))->y - 2;
    if (error_found("import byref", globalValue, desiredValue, verbose)) return 1;

    struct import_byref_struct *myClosureCopy = Block_copy(&myClosure);
    callVoidVoid(&myClosureCopy->base);

    globalValue = getGlobalInt();
    ++desiredValue;  // y was incr'ed after first invocation
    if (error_found("import byref copy", globalValue, desiredValue, verbose)) return 1;

    Block_release(myClosureCopy);

    // the following is synthesized sometime after the last use of all shared variables
    // the first time any closure that uses shared_struct is copied, an extra refcount on that new
    // copy is provided for this stack frame's use.  This stack frame needs to relinquish that code.

    // XXX if shared_struct.base.forwarding != &shared_struct) ...
    Block_release_byref(shared_struct.base.forwarding);

    return 0;
}
