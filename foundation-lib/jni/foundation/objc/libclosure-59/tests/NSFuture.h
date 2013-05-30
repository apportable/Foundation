/*
 * Copyright (c) 2010 Apple Inc. All rights reserved.
 *
 * @APPLE_LLVM_LICENSE_HEADER@
 */

//
//  NSFuture.h
//
//  Copyright 2008 Apple, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#if __CLOSURE__
#define CLOSURE(type) type (^)()
#else
#import "Block_private.h"
#define CLOSURE(type) struct closure_basic *
#endif


#if MAC_OS_X_VERSION_10_6 <= MAC_OS_X_VERSION_MAX_ALLOWED

@interface NSFuture : NSObject <NSCopying> {

}

/*
  Create a future.
  The closure is copied and scheduled for invocation asynchronously.
  Accessing the value will synchronize, if necessary, with the completion of the closure invocation, and return that result.
*/

+ (NSFuture *)objectFutureWithClosure:(CLOSURE(id))closure;
+ (NSFuture *)stringFutureWithClosure:(CLOSURE(NSString *))closure;

+ (NSFuture *)charFutureWithClosure:(CLOSURE(char))closure;
+ (NSFuture *)unsignedCharFutureWithClosure:(CLOSURE(unsigned char))closure;
+ (NSFuture *)shortFutureWithClosure:(CLOSURE(short))closure;
+ (NSFuture *)unsignedShortFutureWithClosure:(CLOSURE(unsigned short))closure;
+ (NSFuture *)longFutureWithClosure:(CLOSURE(long))closure;
+ (NSFuture *)unsignedLongFutureWithClosure:(CLOSURE(unsigned long))closure;
+ (NSFuture *)longLongFutureWithClosure:(CLOSURE(long long))closure;
+ (NSFuture *)unsignedLongLongFutureWithClosure:(CLOSURE(unsigned long long))closure;
+ (NSFuture *)floatFutureWithClosure:(CLOSURE(float))closure;
+ (NSFuture *)doubleFutureWithClosure:(CLOSURE(double))closure;
+ (NSFuture *)boolFutureWithClosure:(CLOSURE(BOOL))closure;
+ (NSFuture *)integerFutureWithClosure:(CLOSURE(NSInteger))closure;
+ (NSFuture *)unsignedIntegerFutureWithClosure:(CLOSURE(NSUInteger))closure;

+ (NSFuture *)voidFutureWithClosure:(CLOSURE(void))closure;

// these synchronize with the completion of the closure and return the value in the form requested

- (char)charValue;
- (unsigned char)unsignedCharValue;
- (short)shortValue;
- (unsigned short)unsignedShortValue;
- (NSInteger)integerValue;
- (NSUInteger)unsignedIntegerValue;
- (long)longValue;
- (unsigned long)unsignedLongValue;
- (long long)longLongValue;
- (unsigned long long)unsignedLongLongValue;
- (float)floatValue;
- (double)doubleValue;
- (BOOL)boolValue;
- (NSInteger)integerValue;
- (NSUInteger)unsignedIntegerValue;

- (id)objectValue;
- (NSString *)stringValue;

- (void)voidValue; // synchronization with completion only
@end

#endif
