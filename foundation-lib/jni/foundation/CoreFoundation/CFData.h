//
// CFData.h
//
// Copyright Apportable Inc. All rights reserved.
//
// Portions of this project are derived from the CoreFoundation
// implementation from the Cocotron project.
//
// Copyright (c) 2008-2009 Christopher J. W. Lloyd
//

#ifndef _CFDATA_H_
#define _CFDATA_H_

typedef const struct __CFMutableData *CFDataRef;
typedef struct __CFMutableData *CFMutableDataRef;

#import <CoreFoundation/CFBase.h>

CF_EXPORT CFTypeID CFDataGetTypeID(void);

CF_EXPORT CFDataRef CFDataCreate(CFAllocatorRef allocator, const uint8_t *bytes, CFIndex length);
CF_EXPORT CFDataRef CFDataCreateWithBytesNoCopy(CFAllocatorRef allocator, const uint8_t *bytes, CFIndex length, CFAllocatorRef bytesAllocator);

CF_EXPORT CFDataRef CFDataCreateCopy(CFAllocatorRef allocator, CFDataRef self);

CF_EXPORT CFIndex CFDataGetLength(CFDataRef self);
CF_EXPORT const uint8_t *CFDataGetBytePtr(CFDataRef self);
CF_EXPORT void CFDataGetBytes(CFDataRef self, CFRange range, uint8_t *bytes);

// mutable

CF_EXPORT CFMutableDataRef CFDataCreateMutable(CFAllocatorRef allocator, CFIndex capacity);

CF_EXPORT uint8_t *CFDataGetMutableBytePtr(CFMutableDataRef self);

CF_EXPORT void CFDataSetLength(CFMutableDataRef self, CFIndex length);
CF_EXPORT void CFDataAppendBytes(CFMutableDataRef self, const uint8_t *bytes, CFIndex length);
CF_EXPORT void CFDataDeleteBytes(CFMutableDataRef self, CFRange range);
CF_EXPORT void CFDataIncreaseLength(CFMutableDataRef self, CFIndex delta);
CF_EXPORT void CFDataReplaceBytes(CFMutableDataRef self, CFRange range, const uint8_t *bytes, CFIndex length);
 
#endif /* _CFDATA_H_ */
