/*
 * Copyright (c) 2010 Apple Inc. All rights reserved.
 *
 * @APPLE_LLVM_LICENSE_HEADER@
 */
/*
 *  shorthandexpression.c
 *  testObjects
 *
 *  Created by Blaine Garst on 9/16/08.
 *  Copyright 2008 Apple. All rights reserved.
 *
 */

// TEST_CONFIG RUN=0

/*
TEST_BUILD_OUTPUT
.*shorthandexpression.c: In function '.*__foo_block_invoke_1.*':
.*shorthandexpression.c:36: error: blocks require { }
OR
.*shorthandexpression.c:36:(38|57): error: expected expression
OR
.*shorthandexpression.c: In function 'void __foo_block_invoke_1\(void\*\)':
.*shorthandexpression.c:36: error: expected `{' before 'printf'
.*shorthandexpression.c: In function 'void foo\(\)':
.*shorthandexpression.c:36: error: cannot convert 'void \(\^\)\(\)' to 'int \(\^\)\(\)' in initialization
.*shorthandexpression.c:36: error: expected ',' or ';' before 'printf'
END
*/

#include <stdio.h>
#include "test.h"

void foo() {
    int (^b)(void) __unused = ^(void)printf("hello world\n");
}

int main() {
    fail("this shouldn't compile\n");
}
