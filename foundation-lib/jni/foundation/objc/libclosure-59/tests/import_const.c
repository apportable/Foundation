/*
 * Copyright (c) 2010 Apple Inc. All rights reserved.
 *
 * @APPLE_LLVM_LICENSE_HEADER@
 */

/*
 *  import_const.c
 *  ClosureTest
 *
 *  Created by Blaine Garst on 1/25/08.
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

/*
    todo:  const of byref variable
    local1
    closure1 { | local1 |
        ++local1
        closure2 {
            local1   // const copy at time closure1 is RUN not defined
        }
        closure2()
    }
*/


#if __BLOCKS__
int imports_example_real(int verbose) {
   int x = rand();
   int y = 15;
   void (^myClosure)(void);
   myClosure  = ^(void) { setGlobalInt(x + y); };
   x++;
   y++;
   callVoidVoid(myClosure);
   
   int globalValue = getGlobalInt();
   int desiredValue = x + y - 2;
   if (error_found("imports_example", globalValue, desiredValue, verbose)) return 1;

   void (^myClosureCopy)(void) = Block_copy(myClosure);
   setGlobalInt(x - 1000);
   callVoidVoid(myClosureCopy);
   globalValue = getGlobalInt();
   if (error_found("imports_example copy", globalValue, desiredValue, verbose)) return 1;
   Block_release(myClosureCopy);
   return 0;
}

#endif __BLOCKS__

struct imports_example_struct {
  struct Block_basic base;
  const int x;
  const int y;
};
  
// the "thunks" compiled for the invoke entry point of the imports_example

void invoke_imports_example(struct imports_example_struct *aBlock) {
  // no return value so just a void invoke
  // the compound statement rewritten to reference locals via the const copies.
   {
    //printf("closure x is %d and y is %d\n", aBlock->x, aBlock->y);
    setGlobalInt(aBlock->x + aBlock->y);
   }
}


// The rewritten version of the code above

int imports_example(int verbose) {
    int x = rand();
    int y = x + 1000;

    struct imports_example_struct onStack = {
        { 0, 0, sizeof(struct imports_example_struct),
            (void (*)(void *))invoke_imports_example,
        },
        x, // capture x
        y // capture y
    };
    struct imports_example_struct *myClosure = &onStack;

    x++;
    y++;
    callVoidVoid(myClosure);

    int globalValue = getGlobalInt();
    int desiredValue = x + y - 2;
    if (error_found("imports_example", globalValue, desiredValue, verbose)) return 1;

    struct imports_example_struct *myClosure_copy = Block_copy(myClosure);
    setGlobalInt(x - 1000);
    callVoidVoid(myClosure_copy);
    globalValue = getGlobalInt();
    if (error_found("imports_example copy", globalValue, desiredValue, verbose)) return 1;
    Block_release(myClosure_copy);
    return 0;
}

#if 1

/*
 * now lets import a closure into a closure
 */
 
#if __BLOCKS__
int imports_example2_real(int verbose) {
    int x = 10;
    int y = 14;

    void (^myImportedClosure)(void)  = ^(void) { setGlobalInt(x + y); };
    void (^anotherClosure)(void) = ^(void) {
        myImportedClosure(); // import and invoke the closure
    };

    anotherClosure();

    int globalValue = getGlobalInt();
    int desiredValue = x + y;
    if (error_found("imports_example2", globalValue, desiredValue, verbose)) return 1;
    
    void (^anotherClosureCopy)(void) = Block_copy(anotherClosure);
     
    globalValue = getGlobalInt();
    if (error_found("imports_example2 copy", globalValue, desiredValue, verbose)) return 1;

    Block_release(anotherClosureCopy);
    return 0;
}

#endif __BLOCKS__

struct imports_example2_struct {
  struct Block_basic base;
  struct imports_example_struct *myImportedClosure;
  const int y;
};


// copy the specific closure
void copy_imports_example2(struct imports_example2_struct *dst, struct imports_example2_struct *src) {
    // the following generic stuff should go in the generic Block_copy routine
    // if we supply it with a sizeof field to snarf


    // the following is closure specific stuff.
    
    // Reference/copy the imported closure.
    // need to copy a stack based closure or "keep" a heap based one
    // XXX this may in fact create several copies of a single stack based closure if it is referenced
    // from several other Blocks.
    //dst->myImportedClosure = Block_copy(src->myImportedClosure);
    _Block_copy_assign(&dst->myImportedClosure, src->myImportedClosure);
}

// the closure 'destructor'    
void destroy_imports_example2(struct imports_example2_struct *aBlock) {
    // do closure specific unwork
    Block_release(aBlock->myImportedClosure);
}

void invoke_imports_example2(struct imports_example2_struct *aBlock) {
    // no return value so just a void invoke

    (*aBlock->myImportedClosure->base.Block_invoke)(aBlock->myImportedClosure);
}

int imports_example2(int verbose) {
    int x = 10;
    int y = 14;
    
    struct imports_example_struct myClosure = {
        { 0, 0, sizeof(struct imports_example_struct),
            (void (*)(void *))invoke_imports_example,
        },
        x, // capture x
        y // capture y
    };
    struct imports_example2_struct stackLocation2 = {
        { 0, BLOCK_HAS_COPY_DISPOSE, sizeof(struct imports_example2_struct),
            (void (*)(void *))invoke_imports_example2,
            (void (*)(void *, void *))copy_imports_example2,
            (void (*)(void *))destroy_imports_example2 },
         &myClosure
    };
    struct imports_example2_struct *anotherClosure = &stackLocation2;
    
    (*anotherClosure->base.Block_invoke)(anotherClosure);
    
    int globalValue = getGlobalInt();
    int desiredValue = x + y;
    if (error_found("imports_example2", globalValue, desiredValue, verbose)) return 1;
    
    struct imports_example2_struct *anotherClosureCopy = Block_copy(anotherClosure);
    (*anotherClosureCopy->base.Block_invoke)(anotherClosureCopy);
    
    globalValue = getGlobalInt();
    if (error_found("imports_example2 copy", globalValue, desiredValue, verbose)) return 1;

    Block_release(anotherClosureCopy);
    
    return 0;
}

#endif
    
