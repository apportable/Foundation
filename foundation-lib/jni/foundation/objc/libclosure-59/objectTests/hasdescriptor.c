/*
 * Copyright (c) 2010 Apple Inc. All rights reserved.
 *
 * @APPLE_LLVM_LICENSE_HEADER@
 */

// TEST_CONFIG

#include <stdio.h>
#include <Block_private.h>
#include "test.h"

int main(int argc, char *argv[] __unused) {
    void (^inner)(void) = ^ { printf("argc was %d\n", argc); };
    void (^outer)(void) = ^{
        inner();
        inner();
    };
    //printf("size of inner is %ld\n", Block_size(inner));
    //printf("size of outer is %ld\n", Block_size(outer));
    if (Block_size(inner) != Block_size(outer)) {
        fail("not the same size, using old compiler??");
    }

    succeed(__FILE__);
}
