/*
 * Copyright (c) 2010 Apple Inc. All rights reserved.
 *
 * @APPLE_LLVM_LICENSE_HEADER@
 */

/*
 *  parameters.c
 *  ClosureTest
 *
 *  Created by Blaine Garst on 1/28/08.
 *  Copyright 2008 __MyCompanyName__. All rights reserved.
 *
 */

#include "driver.h"

//
// Example closure code generated for specific Blocks
//

//
// Partially bound closure referencing const and byref args
//

#if __BLOCKS__
int parameters_example_real(int verbose) {
    int desiredValue = 100;
    void (^myClosure)(int);
    myClosure = ^ (int param) {
        setGlobalInt(param);
    };
    myClosure(desiredValue);
    int globalValue = getGlobalInt();
    if (error_found("parameters_real", globalValue, desiredValue, verbose)) return 1;
    return 0;
}

#endif __BLOCKS__

struct parameters_example_struct {
    struct Block_basic base;
};

// the "thunks" compiled for the invoke entry point of the parameters_example

void invoke_parameters_example(struct parameters_example_struct *aBlock, int param) {
  {
    setGlobalInt(param);
  }
}


// The rewritten version of the code above

int parameters_example(int verbose) {
    int desiredValue = 100;
    struct parameters_example_struct literal = {
        { 0, 0, sizeof(struct parameters_example_struct),
            (void (*)(void *))invoke_parameters_example,
        },
    };
    struct parameters_example_struct *myClosure = &literal;

    // get a type correct function pointer for the invocation function
    void (*correct)(struct parameters_example_struct *, int);
    correct = (void (*)(struct parameters_example_struct *, int))myClosure->base.Block_invoke;
    // call the closure with itself as first arg and the parameter 100
    correct(myClosure, desiredValue);

    int globalValue = getGlobalInt();
    if (error_found("parameters_real", globalValue, desiredValue, verbose)) return 1;
    return 0;
    
}
