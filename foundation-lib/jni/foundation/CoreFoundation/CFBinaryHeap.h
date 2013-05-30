//
// CFBinaryHeap.h
//
// Copyright Apportable Inc. All rights reserved.
//
// Portions of this project are derived from the CoreFoundation
// implementation from the Cocotron project.
//
// Copyright (c) 2008-2009 Christopher J. W. Lloyd
//

#ifndef _CFBINARYHEAP_H_
#define _CFBINARYHEAP_H_

#import <CoreFoundation/CFBase.h>

typedef struct CFBinaryHeap *CFBinaryHeapRef;

typedef const void *(*CFBinaryHeapRetainCallBack)(CFAllocatorRef allocator,const void *value);
typedef void (*CFBinaryHeapReleaseCallBack)(CFAllocatorRef allocator,const void *value);
typedef CFAllocatorCopyDescriptionCallBack CFBinaryHeapCopyDescriptionCallBack;
typedef CFComparisonResult (*CFBinaryHeapCompareCallBack)(const void *value,const void *other,void *info);

typedef struct  {
   CFIndex version;
   CFBinaryHeapRetainCallBack retain;
   CFBinaryHeapReleaseCallBack release;
   CFBinaryHeapCopyDescriptionCallBack copyDescription;
   CFBinaryHeapCompareCallBack compare;
} CFBinaryHeapCallBacks;

typedef struct  {
   CFIndex version;
   void *info;
   CFAllocatorRetainCallBack retain;
   CFAllocatorReleaseCallBack release;
   CFAllocatorCopyDescriptionCallBack copyDescription;
} CFBinaryHeapCompareContext;
typedef void (*CFBinaryHeapApplierFunction)(const void *value,void *context);

CF_EXPORT const CFBinaryHeapCallBacks kCFStringBinaryHeapCallBacks;

CF_EXPORT void CFBinaryHeapAddValue(CFBinaryHeapRef self,const void *value);
CF_EXPORT void CFBinaryHeapApplyFunction(CFBinaryHeapRef self,CFBinaryHeapApplierFunction function,void *context);
CF_EXPORT Boolean CFBinaryHeapContainsValue(CFBinaryHeapRef self,const void *value);
CF_EXPORT CFBinaryHeapRef CFBinaryHeapCreate(CFAllocatorRef allocator,CFIndex capacity,const CFBinaryHeapCallBacks *callbacks,const CFBinaryHeapCompareContext *context);
CF_EXPORT CFBinaryHeapRef CFBinaryHeapCreateCopy(CFAllocatorRef allocator,CFIndex capacity,CFBinaryHeapRef self);
CF_EXPORT CFIndex CFBinaryHeapGetCount(CFBinaryHeapRef self);
CF_EXPORT CFIndex CFBinaryHeapGetCountOfValue(CFBinaryHeapRef self,const void *value);
CF_EXPORT const void *CFBinaryHeapGetMinimum(CFBinaryHeapRef self);
CF_EXPORT Boolean CFBinaryHeapGetMinimumIfPresent(CFBinaryHeapRef self,const void **valuep);
CF_EXPORT void CFBinaryHeapGetValues(CFBinaryHeapRef self,const void **values);
CF_EXPORT void CFBinaryHeapRemoveAllValues(CFBinaryHeapRef self);
CF_EXPORT void CFBinaryHeapRemoveMinimumValue(CFBinaryHeapRef self);

#endif /* _CFBINARYHEAP_H_ */
