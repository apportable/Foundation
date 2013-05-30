//
// CFUUID.h
//
// Copyright Apportable Inc. All rights reserved.
//
// Portions of this project are derived from the CoreFoundation
// implementation from the Cocotron project.
//
// Copyright (c) 2008-2009 Christopher J. W. Lloyd
//

#ifndef _CFUUID_H_

#import <CoreFoundation/CFBase.h>

typedef struct __CFUUID *CFUUIDRef;

typedef struct {
   uint8_t byte0;
   uint8_t byte1;
   uint8_t byte2;
   uint8_t byte3;
   uint8_t byte4;
   uint8_t byte5;
   uint8_t byte6;
   uint8_t byte7;
   uint8_t byte8;
   uint8_t byte9;
   uint8_t byte10;
   uint8_t byte11;
   uint8_t byte12;
   uint8_t byte13;
   uint8_t byte14;
   uint8_t byte15;
} CFUUIDBytes;

CF_EXPORT CFTypeID CFUUIDGetTypeID(void);

CF_EXPORT CFUUIDRef CFUUIDCreate(CFAllocatorRef alloc);
CF_EXPORT CFUUIDRef CFUUIDCreateFromString(CFAllocatorRef allocator, CFStringRef string);
CF_EXPORT CFUUIDRef CFUUIDCreateFromUUIDBytes(CFAllocatorRef allocator, CFUUIDBytes bytes);
CF_EXPORT CFUUIDRef CFUUIDCreateWithBytes(CFAllocatorRef allocator, uint8_t byte0, uint8_t byte1, uint8_t byte2, uint8_t byte3, uint8_t byte4, uint8_t byte5, uint8_t byte6, uint8_t byte7, uint8_t byte8, uint8_t byte9, uint8_t byte10, uint8_t byte11, uint8_t byte12, uint8_t byte13, uint8_t byte14, uint8_t byte15);

CF_EXPORT CFUUIDRef CFUUIDGetConstantUUIDWithBytes(CFAllocatorRef allocator, uint8_t byte0, uint8_t byte1, uint8_t byte2, uint8_t byte3, uint8_t byte4, uint8_t byte5, uint8_t byte6, uint8_t byte7, uint8_t byte8, uint8_t byte9, uint8_t byte10, uint8_t byte11, uint8_t byte12, uint8_t byte13, uint8_t byte14, uint8_t byte15);

CF_EXPORT CFUUIDBytes CFUUIDGetUUIDBytes(CFUUIDRef uuid);

CF_EXPORT CFStringRef CFUUIDCreateString(CFAllocatorRef allocator, CFUUIDRef uuid);

#endif /* _CFUUID_H_ */
