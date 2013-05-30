//
// CFArray.h
//
// Copyright Apportable Inc. All rights reserved.
//
// Portions of this project are derived from the CoreFoundation
// implementation from the Cocotron project.
//
// Copyright (c) 2008-2009 Christopher J. W. Lloyd
//

#ifndef _CFARRAY_H_
#define _CFARRAY_H_

typedef struct __CFArray *CFArrayRef;
typedef struct __CFArray *CFMutableArrayRef;

#import <CoreFoundation/CFBase.h>
#import <CoreFoundation/CFString.h>

typedef const void *(*CFArrayRetainCallBack)(CFAllocatorRef allocator, const void *value);
typedef void (*CFArrayReleaseCallBack)(CFAllocatorRef allocator, const void *value);
typedef CFStringRef (*CFArrayCopyDescriptionCallBack)(const void *value);
typedef Boolean (*CFArrayEqualCallBack)(const void *value, const void *other);

typedef struct {
   CFIndex version;
   CFArrayRetainCallBack retain;
   CFArrayReleaseCallBack release;
   CFArrayCopyDescriptionCallBack copyDescription;
   CFArrayEqualCallBack equal;
} CFArrayCallBacks;

typedef void (*CFArrayApplierFunction)(const void *value, void *context);

CF_EXPORT const CFArrayCallBacks kCFTypeArrayCallBacks;

CF_EXPORT CFTypeID CFArrayGetTypeID(void);

CF_EXPORT CFArrayRef CFArrayCreate(CFAllocatorRef allocator, const void **values, CFIndex count, const CFArrayCallBacks *callbacks);

CF_EXPORT CFArrayRef CFArrayCreateCopy(CFAllocatorRef allocator, CFArrayRef self);

CF_EXPORT CFIndex CFArrayGetCount(CFArrayRef self);
CF_EXPORT const void * CFArrayGetValueAtIndex(CFArrayRef self, CFIndex index);
CF_EXPORT void CFArrayGetValues(CFArrayRef self, CFRange range, const void **values);
CF_EXPORT Boolean CFArrayContainsValue(CFArrayRef self, CFRange range, const void *value);
CF_EXPORT CFIndex CFArrayGetFirstIndexOfValue(CFArrayRef self, CFRange range, const void *value);
CF_EXPORT CFIndex CFArrayGetLastIndexOfValue(CFArrayRef self, CFRange range, const void *value);
CF_EXPORT CFIndex CFArrayGetCountOfValue(CFArrayRef self, CFRange range, const void *value);
CF_EXPORT void CFArrayApplyFunction(CFArrayRef self, CFRange range, CFArrayApplierFunction function, void *context);
CF_EXPORT CFIndex CFArrayBSearchValues(CFArrayRef self, CFRange range, const void *value, CFComparatorFunction function, void *context);

// mutable

CF_EXPORT CFMutableArrayRef CFArrayCreateMutable(CFAllocatorRef allocator, CFIndex capacity, const CFArrayCallBacks *callbacks);

CF_EXPORT CFMutableArrayRef CFArrayCreateMutableCopy(CFAllocatorRef allocator, CFIndex capacity, CFArrayRef self);

CF_EXPORT void CFArrayAppendValue(CFMutableArrayRef self, const void *value);
CF_EXPORT void CFArrayAppendArray(CFMutableArrayRef self, CFArrayRef other, CFRange range);
CF_EXPORT void CFArrayRemoveValueAtIndex(CFMutableArrayRef self, CFIndex index);
CF_EXPORT void CFArrayRemoveAllValues(CFMutableArrayRef self);
CF_EXPORT void CFArrayInsertValueAtIndex(CFMutableArrayRef self, CFIndex index, const void *value);
CF_EXPORT void CFArraySetValueAtIndex(CFMutableArrayRef self, CFIndex index, const void *value);
CF_EXPORT void CFArrayReplaceValues(CFMutableArrayRef self, CFRange range, const void **values, CFIndex count);
CF_EXPORT void CFArrayExchangeValuesAtIndices(CFMutableArrayRef self, CFIndex index, CFIndex other);
CF_EXPORT void CFArraySortValues(CFMutableArrayRef self, CFRange range, CFComparatorFunction function, void *context);

#endif /* _CFARRAY_H_ */
