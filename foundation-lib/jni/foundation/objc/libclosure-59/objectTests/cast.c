/*
 * Copyright (c) 2010 Apple Inc. All rights reserved.
 *
 * @APPLE_LLVM_LICENSE_HEADER@
 */

/*
 *  cast.c
 *  testObjects
 *
 *  Created by Blaine Garst on 2/17/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

// PURPOSE should allow casting of a Block reference to an arbitrary pointer and back
// TEST_DISABLED

#include <stdio.h>
#include "test.h"

int main() {

    void (^aBlock)(void);
    int *ip;
    char *cp;
    double *dp;

    ip = (int *)aBlock;
    cp = (char *)aBlock;
    dp = (double *)aBlock;
    aBlock = (void (^)(void))ip;
    aBlock = (void (^)(void))cp;
    aBlock = (void (^)(void))dp;

    succeed(__FILE__);
}
