/*
 * Copyright (c) 2010 Apple Inc. All rights reserved.
 *
 * @APPLE_LLVM_LICENSE_HEADER@
 */

/*
 *  driver.h
 *  ClosureTest
 *
 *  Created by Blaine Garst on 1/25/08.
 *  Copyright 2008 __MyCompanyName__. All rights reserved.
 *
 */

#include <stdio.h>
#include "../Block.h"
#include "../Block_private.h"

// test routines to set/get a global.  Note that getting is destructive - do it once only.
void setGlobalInt(int value);
int getGlobalInt() ;


// call void returning closure that takes void
//void callVoidVoid(void (^voidvoid)(void));
void callVoidVoid(void *voidvoid);

// error checking
int error_found(const char *name, int globalValue, int desiredValue, int verbose);


enum {
    VERBOSE = 1,
};

// when byref closures can be copied turn this on to try out copying case
//#define FULL_CLOSURES

// when objc4-377 then
#define NEWER_OBJC 1

int parameters_example(int verbose);
int result_value_example(int verbose);
int imports_example(int verbose);
int imports_example2(int verbose);
int import_byref_interim(int verbose);
int import_byref(int verbose);
int import_global(int verbose);
int test_blocks(int verbose);
int test_objc(int verbose);
