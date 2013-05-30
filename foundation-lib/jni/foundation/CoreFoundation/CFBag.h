//
// CFBag.h
//
// Copyright Apportable Inc. All rights reserved.
//
// Portions of this project are derived from the CoreFoundation
// implementation from the Cocotron project.
//
// Copyright (c) 2008-2009 Christopher J. W. Lloyd
//

#ifndef _CFBAG_H_
#define _CFBAG_H_

#include <CoreFoundation/CFBase.h>

__BEGIN_DECLS

typedef const void * (*CFBagRetainCallBack)(CFAllocatorRef allocator, const void *value);
typedef void (*CFBagReleaseCallBack)(CFAllocatorRef allocator, const void *value);
typedef CFStringRef (*CFBagCopyDescriptionCallBack)(const void *value);
typedef Boolean (*CFBagEqualCallBack)(const void *value1, const void *value2);
typedef CFHashCode (*CFBagHashCallBack)(const void *value);

typedef struct {
    CFIndex version;
    CFBagRetainCallBack retain;
    CFBagReleaseCallBack release;
    CFBagCopyDescriptionCallBack copyDescription;
    CFBagEqualCallBack equal;
    CFBagHashCallBack hash;
} CFBagCallBacks;

extern const CFBagCallBacks kCFTypeBagCallBacks;
extern const CFBagCallBacks kCFCopyStringBagCallBacks;

typedef void (*CFBagApplierFunction)(const void *value, void *context);

typedef const struct __CFBag * CFBagRef;
typedef struct __CFBag * CFMutableBagRef;

extern CFTypeID CFBagGetTypeID(void);
extern CFBagRef CFBagCreate(CFAllocatorRef allocator, const void **values, CFIndex numValues, const CFBagCallBacks *callBacks);
extern CFBagRef CFBagCreateCopy(CFAllocatorRef allocator, CFBagRef theBag);
extern CFMutableBagRef CFBagCreateMutable(CFAllocatorRef allocator, CFIndex capacity, const CFBagCallBacks *callBacks);
extern CFMutableBagRef CFBagCreateMutableCopy(CFAllocatorRef allocator, CFIndex capacity, CFBagRef theBag);
extern CFIndex CFBagGetCount(CFBagRef theBag);
extern CFIndex CFBagGetCountOfValue(CFBagRef theBag, const void *value);
extern Boolean CFBagContainsValue(CFBagRef theBag, const void *value);
extern const void *CFBagGetValue(CFBagRef theBag, const void *value);
extern Boolean CFBagGetValueIfPresent(CFBagRef theBag, const void *candidate, const void **value);
extern void CFBagGetValues(CFBagRef theBag, const void **values);
extern void CFBagApplyFunction(CFBagRef theBag, CFBagApplierFunction applier, void *context);
extern void CFBagAddValue(CFMutableBagRef theBag, const void *value);
extern void CFBagReplaceValue(CFMutableBagRef theBag, const void *value);
extern void CFBagSetValue(CFMutableBagRef theBag, const void *value);
extern void CFBagRemoveValue(CFMutableBagRef theBag, const void *value);
extern void CFBagRemoveAllValues(CFMutableBagRef theBag);

__END_DECLS

#endif /* _CFBAG_H_ */

