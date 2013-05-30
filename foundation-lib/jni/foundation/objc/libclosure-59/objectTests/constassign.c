/*
 * Copyright (c) 2010 Apple Inc. All rights reserved.
 *
 * @APPLE_LLVM_LICENSE_HEADER@
 */

//
//  constassign.c
//
//  Created by Blaine Garst on 3/21/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.

// TEST_CONFIG RUN=0

/*
TEST_BUILD_OUTPUT
.*constassign.c:38:12: error: read-only variable is not assignable
.*constassign.c:39:10: error: read-only variable is not assignable
OR
.*constassign.c: In function '.*main.*':
.*constassign.c:38: error: assignment of read-only variable 'blockA'
.*constassign.c:39: error: assignment of read-only variable 'fptr'
END
*/

// shouldn't be able to assign to a const pointer
// CONFIG error: assignment of read-only

#import <stdio.h>
#import "test.h"

void foo(void) { printf("I'm in foo\n"); }
void bar(void) { printf("I'm in bar\n"); }

int main() {
    void (*const fptr)(void) = foo;
    void (^const  blockA)(void) = ^ { printf("hello\n"); };
    blockA = ^ { printf("world\n"); } ;
    fptr = bar;
    fail("should not compile");
}
