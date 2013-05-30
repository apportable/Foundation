/*
 * Copyright (c) 2010 Apple Inc. All rights reserved.
 *
 * @APPLE_LLVM_LICENSE_HEADER@
 */

/*
 *  block_examples.c
 *  libclosure
 *
 *  Created by Blaine Garst on 3/3/08.
 *  Copyright 2008 __MyCompanyName__. All rights reserved.
 *
 */

#include "driver.h"


#if __BLOCKS__

// test if byref spans up to first enclosing scope that permits modification

int test1(int verbose) {
    int x = 10;
    void (^closure)(void) = ^ {
        setGlobalInt(x);
        void (^innerClosure)(void) = ^{ | x | ++x; };
        callVoidVoid(innerClosure);
    };
    int desiredValue = 11;
    if (error_found("block_examples: test1, inner byref doesn't change global", x, desiredValue, verbose)) return 1;
    return 0;
}

// test that a closure containing a closure has a copy helper routine

int test2(int verbose) {
    int originalValue = 10;
    int x = originalValue;
    void (^closure)(void) = ^ {
        setGlobalInt(x);
        void (^innerClosure)(void) = ^{ | x | ++x; };
        callVoidVoid(innerClosure);
    };
    return 0;
}

int test3(int verbose) {
    int x = 10;
    int y = 11;
    int z = 12;
    void (^outerBlock)(void) = ^ {
        printf("outerBlock x is %d\n", x);
        setGlobalInt(x);
        void (^innerBlock)(void) = ^ { | x, y, z|
            ++x; ++y; ++z;
            printf("innerBlock x is %d, y is %d\n", x, y);
            void (^innerInnerBlock)(void) = ^ {
                printf("innerInnerBlock z is %d\n", z);
                setGlobalInt(z);        // what value of z?
            };
            callVoidVoid(innerInnerBlock);
            
        };
        setGlobalInt(y);
        callVoidVoid(innerBlock);
    };
    x += 10;
    y += 10;
    z += 10;
    outerBlock();
    return 0;
        
}


#endif


int test_blocks(int verbose) {
    int errors = 0;
#if __BLOCKS__
    errors += test1(verbose);
    errors += test2(verbose);
    errors += test3(verbose);
#endif
    return errors;
}
