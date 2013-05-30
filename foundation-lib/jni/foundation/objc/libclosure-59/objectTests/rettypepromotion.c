/*
 * Copyright (c) 2010 Apple Inc. All rights reserved.
 *
 * @APPLE_LLVM_LICENSE_HEADER@
 */

/*
 *  rettypepromotion.c
 *  testObjects
 *
 *  Created by Blaine Garst on 11/3/08.
 *  Copyright 2008 __MyCompanyName__. All rights reserved.
 *
 */
 
// TEST_CONFIG RUN=0
/*
TEST_BUILD_OUTPUT
.*rettypepromotion.c: In function '.*main.*':
.*rettypepromotion.c:48: error: incompatible block pointer types initializing 'int \(\^\)\(void \*, void \*\)', expected 'long int \(\^\)\(void \*, void \*\)'
OR
.*rettypepromotion.c: In function '.*main.*':
.*rettypepromotion.c:48: error: cannot convert 'e \(\^\)\(void\*, void\*\)' to 'long int \(\^\)\(void\*, void\*\)' for argument '1' to 'void sortWithBlock\(long int \(\^\)\(void\*, void\*\)\)'
OR
.*rettypepromotion.c:44:19: error: incompatible block pointer types passing 'int \(\^\)\(void \*, void \*\)' to parameter of type 'long \(\^\)\(void \*, void \*\)'
.*rettypepromotion.c:39:27: note: passing argument to parameter 'comp' here
OR
.*rettypepromotion.c:44:5: error: no matching function for call to 'sortWithBlock'
.*rettypepromotion.c:39:6: note: candidate function not viable: no known conversion from 'e \(\^\)\(void \*, void \*\)' to 'long \(\^\)\(void \*, void \*\)' for 1st argument
END
 */

#include <stdio.h>
#include <stdlib.h>
#include "test.h"

typedef enum { LESS = -1, EQUAL, GREATER } e;

void sortWithBlock(long (^comp)(void *arg1, void *arg2)) {
    comp(0, 0);
}

int main() {
    sortWithBlock(^(void *arg1 __unused, void *arg2 __unused) {
        if (random()) return LESS;
        if (random()) return EQUAL;
        return GREATER;
    });

    succeed(__FILE__);
}
