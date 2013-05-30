/*
 * Copyright (c) 2010 Apple Inc. All rights reserved.
 *
 * @APPLE_LLVM_LICENSE_HEADER@
 */

/*
 *  voidarg.c
 *  testObjects
 *
 *  Created by Blaine Garst on 2/17/09.
 *  Copyright 2009 Apple. All rights reserved.
 *
 */

// PURPOSE should complain about missing 'void' but both GCC and clang are supporting K&R instead
// TEST_DISABLED

#import <stdio.h>
#import "test.h"

int Global;

void (^globalBlock)() = ^{ ++Global; };         // should be void (^gb)(void) = ...

int main(int argc __unused, char *argv[]) {
    succeed(__FILE__);
}
