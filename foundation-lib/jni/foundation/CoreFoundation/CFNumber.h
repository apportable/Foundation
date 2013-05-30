//
// CFNumber.h
//
// Copyright Apportable Inc. All rights reserved.
//
// Portions of this project are derived from the CoreFoundation
// implementation from the Cocotron project.
//
// Copyright (c) 2008-2009 Christopher J. W. Lloyd
//

#ifndef _CFNUMBER_H_
#define _CFNUMBER_H_

#import <CoreFoundation/CFBase.h>

typedef struct __CFBoolean *CFBooleanRef;

typedef struct __NSNumber *CFNumberRef;

typedef enum {
   kCFNumberSInt8Type     = 1,
   kCFNumberSInt16Type    = 2,
   kCFNumberSInt32Type    = 3,
   kCFNumberSInt64Type    = 4,
   kCFNumberFloat32Type   = 5,
   kCFNumberFloat64Type   = 6,
   kCFNumberCharType      = 7,
   kCFNumberShortType     = 8,
   kCFNumberIntType       = 9,
   kCFNumberLongType      = 10,
   kCFNumberLongLongType  = 11,
   kCFNumberFloatType     = 12,
   kCFNumberDoubleType    = 13,
   kCFNumberCFIndexType   = 14,
   kCFNumberNSIntegerType = 15,
   kCFNumberCGFloatType   = 16,
   kCFNumberMaxType       = kCFNumberCGFloatType,
} CFNumberType;

CF_EXPORT const CFBooleanRef kCFBooleanTrue;
CF_EXPORT const CFBooleanRef kCFBooleanFalse;

CF_EXPORT CFTypeID CFBooleanGetTypeID(void);

CF_EXPORT Boolean CFBooleanGetValue(CFBooleanRef boolean);

CF_EXPORT const CFNumberRef kCFNumberPositiveInfinity;
CF_EXPORT const CFNumberRef kCFNumberNegativeInfinity;
CF_EXPORT const CFNumberRef kCFNumberNaN;

CF_EXPORT CFTypeID CFNumberGetTypeID(void);

CF_EXPORT CFNumberRef CFNumberCreate(CFAllocatorRef allocator,CFNumberType type,const void *valuep);

CF_EXPORT CFComparisonResult CFNumberCompare(CFNumberRef self,CFNumberRef other,void *context);
CF_EXPORT CFIndex CFNumberGetByteSize(CFNumberRef self);
CF_EXPORT CFNumberType CFNumberGetType(CFNumberRef self);
CF_EXPORT Boolean CFNumberGetValue(CFNumberRef self,CFNumberType type,void *valuep);
CF_EXPORT Boolean CFNumberIsFloatType(CFNumberRef self);

#endif /* _CFNUMBER_H_ */
