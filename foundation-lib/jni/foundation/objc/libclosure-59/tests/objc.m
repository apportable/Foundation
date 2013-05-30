/*
 * Copyright (c) 2010 Apple Inc. All rights reserved.
 *
 * @APPLE_LLVM_LICENSE_HEADER@
 */

//
//  objc.m
//  libclosure
//
//  Created by Blaine Garst on 3/10/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "driver.h"
#import <Foundation/Foundation.h>
//#import <Foundation/NSBlock.h>

@interface TestObject : NSObject {
@public
    int refcount;
    id aSlot;
}
- (int) testVerbosely:(int)verbose;
- (void)doesSomethingWithClosure:(void (^)(void))aClosure;
- (void)doesSomethingElseWithClosure:(void (^)(NSObject *))aClosure;

- (void)updateIvar;

@end

@implementation TestObject
- (void)doesSomethingWithClosure:(void (^)(void))aClosure { }
- (void)doesSomethingElseWithClosure:(void (^)(NSObject *))aClosure { }

- (id) retain {
    ++refcount;
    return self;
}

- (int)retainCounter {
    return refcount + 1;
}

- (void) release {
   if (refcount == 0) [self dealloc];
   else --refcount;
}


- (int) testVerbosely:(int)verbose
 {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    int errors = 0;
    aSlot = [[NSObject alloc] init];
    
    int initialRetainCounter = [self retainCounter];
    
    void (^myClosure)(void) = ^{
        printf("[aSlot retainCount] == %d\n", [aSlot retainCount]);
    };
    
    
    int afterClosureRetainCounter = [self retainCounter];
    
    //printf("%s", _Block_dump(myClosure));
    
    void (^myClosureCopy)(void) = Block_copy(myClosure);
    
    int afterClosureCopyRetainCounter = [self retainCounter];
    
    if (afterClosureRetainCounter > initialRetainCounter) {
        printf("testVerbosely: after closure, retain count is %d vs before %d\n", afterClosureRetainCounter, initialRetainCounter);
        ++errors;
    }
    
    if (afterClosureCopyRetainCounter <= afterClosureRetainCounter) {
        printf("testVerbosely: closure copy did not retain interior object\n");
        ++errors;
    }
    
    [aSlot release];
    aSlot = nil;
    
    if (errors == 0 && verbose) printf("testVerbosely: objc import object test success\n");
    [pool drain];
    return errors;
   
}

- (void)updateIvar {
    void (^myClosure)(void) = ^{ id tmp = aSlot; aSlot = nil; aSlot = tmp; };
    //void (^myClosure2)(void) = ^{ |aSlot| id tmp = aSlot; aSlot = nil; aSlot = tmp; };
}

@end

// can a Block update an ivar
int test_objc3(int verbose) {
    int errors = 0;
    TestObject *to = [[TestObject alloc] init];
    return 0;
}

int test_objc2(int verbose) {
    int errors = 0;
    TestObject *to = [[TestObject alloc] init];

    errors += [to testVerbosely:verbose];
    [to release];
    return errors;
}

// byref object
int test_objc1_1(int verbose) {
    int errors = 0;
#if FULL_CLOSURES
    TestObject *to = [[TestObject alloc] init];
    
    // make sure a closure with to gets it retained on a copy
    
    int initialRetainCounter = [to retainCounter];
    
    void (^myClosure)(void) = ^{ | to |
        printf("[to retainCounter] == %d\n", [to retainCounter]);
    };
    
    int afterClosureRetainCounter = [to retainCounter];
    
    void (^myClosureCopy)(void) = Block_copy(myClosure);
    
    int afterClosureCopyRetainCounter = [to retainCounter];
    
    if (afterClosureRetainCounter > initialRetainCounter) {
        printf("after closure, retain count is %d vs before %d\n", afterClosureRetainCounter, initialRetainCounter);
        ++errors;
    }
    
    if (afterClosureCopyRetainCounter <= afterClosureRetainCounter) {
        printf("closure copy did not retain interior object\n");
        ++errors;
    }
    
    [to release];
    
#endif
    return errors;
}

int test_objc1(int verbose) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    int errors = 0;
    TestObject *to = [[TestObject alloc] init];
    
    // make sure a closure with to gets it retained on a copy
    
    int initialRetainCounter = [to retainCounter];
    
    void (^myClosure)(void) = ^{
        printf("[to retainCounter] == %d\n", [to retainCounter]);
    };
    
    int afterClosureRetainCounter = [to retainCounter];
    
    void (^myClosureCopy)(void) = Block_copy(myClosure);
    
    int afterClosureCopyRetainCounter = [to retainCounter];
    
    if (afterClosureRetainCounter > initialRetainCounter) {
        printf("after closure, retain count is %d vs before %d\n", afterClosureRetainCounter, initialRetainCounter);
        ++errors;
    }
    
    if (afterClosureCopyRetainCounter <= afterClosureRetainCounter) {
        printf("closure copy did not retain interior object\n");
        ++errors;
    }
    
    [to release];
    [pool drain];
    
    return errors;
}

#if 0
const char *_Block_dump(const void *block) {
    struct Block_basic *closure = (struct Block_basic *)block;
    static char buffer[256], *cp = buffer;
    if (closure == NULL) {
        sprintf(cp, "NULL passed to _Block_dump\n");
        return buffer;
    }
    if (closure->isa == NULL) {
        cp += sprintf(cp, "isa: NULL\n");
    }
    else if (closure->isa == _NSConcreteStackBlock) {
        cp += sprintf(cp, "isa: stack Block (%p)\n", _NSConcreteStackBlock);
    }
    else if (closure->isa == _NSConcreteMallocBlock) {
        cp += sprintf(cp, "isa: malloc heap Block\n");
    }
    else if (closure->isa == _NSConcreteAutoBlock) {
        cp += sprintf(cp, "isa: GC heap Block\n");
    }
    else {
        cp += sprintf(cp, "isa: %p\n", closure->isa);
    }
    cp += sprintf(cp, "flags:");
    if (closure->Block_flags & BLOCK_NEEDS_FREE) {
        cp += sprintf(cp, " FREEME");
    }
    if (closure->Block_flags & BLOCK_HAS_COPY_DISPOSE) {
        cp += sprintf(cp, " HASHELP");
    }
    if (closure->Block_flags & BLOCK_NO_COPY) {
        cp += sprintf(cp, " HASBYREF");
    }
    if (closure->Block_flags & BLOCK_IS_GC) {
        cp += sprintf(cp, " ISGC");
    }
    cp += sprintf(cp, "\nrefcount: %d\nsize: %d\n", closure->Block_flags & 0xfff, closure->Block_size);
    cp += sprintf(cp, "invoke: %p\n", closure->Block_invoke);
    return buffer; 
}
#endif

int test_stackObject(int verbose) {
printf("testing stack object\n");
    //makesubclasses();
    void (^voidvoid)(void) = ^{ printf("hellow world\n"); };
    //_NSMakeBlockObject((const void *)voidvoid);
    printf("before voidvoid copy: %s", _Block_dump(voidvoid));
    void (^voidvoidCopy)(void) = (void (^)(void))(void *)[(id)(void *)voidvoid copy];
    printf("after voidvoid copy, voidvoidCopy is %s", _Block_dump(voidvoidCopy));
    [(id)(void *)voidvoidCopy release];
printf("done testing stack object\n");
}


int test_objc(int verbose) {
    int errors = 0;
    
    errors += test_objc1_1(verbose);
    errors += test_objc1(verbose);
    errors += test_objc2(verbose);
    errors += test_objc3(verbose);
#if NEWER_OBJC
    errors += test_stackObject(verbose);
#endif
    if (errors == 0 && verbose) printf("objc import object test success\n");
    return errors;
}
