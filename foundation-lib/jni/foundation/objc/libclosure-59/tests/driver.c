/*
 * Copyright (c) 2010 Apple Inc. All rights reserved.
 *
 * @APPLE_LLVM_LICENSE_HEADER@
 */

/*
 *  basic.c
 *  ClosureTest
 *  This is pretty much the test runner code.
 *
 *  Created by Blaine Garst on 1/25/08.
 *  Copyright 2008 __MyCompanyName__. All rights reserved.
 *
 */

#include "driver.h"



// pretend this is the GCD do_work code
void callVoidVoid(void *arg) {
   // assume this a GCD style fully bound closure
   struct Block_basic *aBlock = (struct Block_basic *)arg;
   aBlock->Block_invoke(aBlock);  // aBlock()
}

int GlobalInt;
void setGlobalInt(int value) { GlobalInt = value; }
int getGlobalInt() { int tmp = GlobalInt; GlobalInt = 0; return tmp; }



int main(int argc, char *argv[]) {

    int errors = 0;
    int verbose = VERBOSE;

    if (verbose) printf("Handling hand generated test cases\n");
    errors += parameters_example(verbose);
    errors += result_value_example(verbose);
    errors += imports_example(verbose);
    //errors += imports_example2(verbose);

    errors += import_byref(verbose);
    errors += import_byref_interim(verbose);
    errors += import_global(verbose);

#if __BLOCKS__
    errors += test_blocks(verbose);
    
    if (verbose) printf("\nhandling compiler generated test cases\n");
    errors += result_value_example_real(verbose);
    errors += parameters_example_real(verbose);
    errors += import_global_real(verbose);
    errors += imports_example_real(verbose);
    //errors += imports_example2_real(verbose);

    errors += import_byref_real(verbose);
    errors += import_byref_interim_real(verbose);
    
    errors += test_objc(verbose);
    

#endif
    return errors;
}

void aDoNothingFunction() {
}

// error handling
int error_found(const char *name, int globalValue, int desiredValue, int verbose) {
   if (globalValue != desiredValue) {
        printf("%s globalValue %d, should be %d\n", name, globalValue, desiredValue);
        aDoNothingFunction();
        return 1;
    }
    else {
        if (verbose) printf("%s saw correct values\n", name);
    }
    return 0;
}
