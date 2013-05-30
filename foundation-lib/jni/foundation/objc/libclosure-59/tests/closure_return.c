/*
 * Copyright (c) 2010 Apple Inc. All rights reserved.
 *
 * @APPLE_LLVM_LICENSE_HEADER@
 */

/*
 *  Block_return.c
 *  Examples
 *
 *  Created by Blaine Garst on 1/31/08.
 *  Copyright 2008 Apple. All rights reserved.
 *
 */


#include "driver.h"

//
// Example closure code generated for specific Blocks
//

//
// Computing and accessing a result value
// Now that Blocks don't keep return values, not much to see here.
//

#if __BLOCKS__
int result_value_example_real(int verbose) {
   int (^myClosure)(void) = myClosure = ^ (void) { return 12; };
   
   // invoke it
   // extract return value
   int result = myClosure();
    if (result == 12) {
        if (verbose) printf("result extracted successfully\n");
        return 0;
    }
    else {
        printf("oops, result not extracted properly, should be 12 but is %d\n", result);
        return 1;
    }

}

#endif __BLOCKS__

struct result_value_example_struct {
  struct Block_basic base;
};

// thunk(s) generated

int invoke_result_value_example(struct result_value_example_struct *aBlock) {
    return 12;
}


int result_value_example(int verbose) {
   struct result_value_example_struct onStack = {
        { 0, 0, sizeof(struct result_value_example_struct),
            (void (*)(void *))invoke_result_value_example,
        }
    };
    struct result_value_example_struct *myClosure = &onStack;
    
    int result = (*(int (*)(struct return_value_example_struct*))myClosure->base.Block_invoke)(myClosure);
    
    if (result == 12) {
        if (verbose) printf("result extracted successfully\n");
        return 0;
    }
    else {
        printf("oops, result not extracted properly, should be 12 but is %d\n", result);
        return 1;
    }
}

