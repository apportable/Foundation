/*
 * Copyright (c) 2010 Apple Inc. All rights reserved.
 *
 * @APPLE_LLVM_LICENSE_HEADER@
 */

// PURPOSE check _Block_has_signature, _Block_signature, and _Block_use_stret.
// TEST_CONFIG

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <Block.h>
#include <Block_private.h>
#include "test.h"

typedef struct bigbig {
    int array[512];
} BigStruct_t;

void* (^global)(void) = ^{ return malloc(sizeof(struct bigbig)); };
BigStruct_t (^global_stret)(void) = ^{ return *(BigStruct_t *)malloc(sizeof(struct bigbig)); };

int main()
{
    void* (^local)(void) = ^{ return malloc(sizeof(struct bigbig)); };
    BigStruct_t (^local_stret)(void) = ^{ return *(BigStruct_t *)malloc(sizeof(struct bigbig)); };

    // signatures: emitted by clang, but not llvm-gcc or gcc
#if __clang__
    testassert(_Block_has_signature(local));
    testassert(_Block_has_signature(global));
    testassert(_Block_has_signature(local_stret));
    testassert(_Block_has_signature(global_stret));
#  if __LP64__
#   define P "8"
#  else
#   define P "4"
#  endif
    testassert(0 == strcmp(_Block_signature(local), "^v"P"@?0"));
    testassert(0 == strcmp(_Block_signature(global), "^v"P"@?0"));
    testassert(0 == strcmp(_Block_signature(local_stret), "{bigbig=[512i]}"P"@?0"));
    testassert(0 == strcmp(_Block_signature(global_stret), "{bigbig=[512i]}"P"@?0"));
#else
    testassert(!_Block_has_signature(local));
    testassert(!_Block_has_signature(global));
    testassert(!_Block_has_signature(local_stret));
    testassert(!_Block_has_signature(global_stret));
    testassert(!_Block_signature(local));
    testassert(!_Block_signature(global));
    testassert(!_Block_signature(local_stret));
    testassert(!_Block_signature(global_stret));
#endif

    // stret flag: emitted by clang and llvm-gcc, but not gcc
    testassert(! _Block_use_stret(local));
    testassert(! _Block_use_stret(global));
#if defined(__clang__)  ||  defined(__llvm__)
#  if !__clang__
    testwarn("llvm-gcc rdar://8143947");
#  else
    testassert(_Block_use_stret(local_stret));
    testassert(_Block_use_stret(global_stret));
#  endif
#else
    testassert(!_Block_use_stret(local_stret));
    testassert(!_Block_use_stret(global_stret));
#endif

    succeed(__FILE__);
}
