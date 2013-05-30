/*
 * Copyright (c) 2010 Apple Inc. All rights reserved.
 *
 * @APPLE_LLVM_LICENSE_HEADER@
 */

// TEST_DISABLED

// rdar://6439600

#import <stdio.h>
#import <stdlib.h>
#import "test.h"

#define NUMBER_OF_BLOCKS 100
int main (int argc __unused, const char * argv[]) {
    int (^x[NUMBER_OF_BLOCKS])();
    int i;
    
    for(i=0; i<NUMBER_OF_BLOCKS; i++) x[i] = ^{ return i; };

    for(i=0; i<NUMBER_OF_BLOCKS; i++) {
        if (x[i]() != i) {
            fail("%d != %d\n", x[i](), i);
        }
    }
    
    succeed(__FILE__);
}
