//
// CFSet.h
//
// Copyright Apportable Inc. All rights reserved.
//

#ifndef _CFSET_H_
#define _CFSET_H_

typedef const struct __CFSet * CFSetRef;
typedef struct __CFSet * CFMutableSetRef;

#import <CoreFoundation/CFBase.h>
#import <CoreFoundation/CFString.h>

typedef const void * (*CFSetRetainCallBack)(CFAllocatorRef allocator, const void *value);
typedef void (*CFSetReleaseCallBack)(CFAllocatorRef allocator, const void *value);
typedef CFStringRef (*CFSetCopyDescriptionCallBack)(const void *value);
typedef Boolean (*CFSetEqualCallBack)(const void *value1, const void *value2);
typedef CFHashCode (*CFSetHashCallBack)(const void *value);

typedef void (*CFSetApplierFunction)(const void *value, void *context);

typedef struct {
    CFIndex version;
    CFSetRetainCallBack retain;
    CFSetReleaseCallBack release;
    CFSetCopyDescriptionCallBack copyDescription;
    CFSetEqualCallBack equal;
    CFSetHashCallBack hash;
} CFSetCallBacks;

CF_EXPORT const CFSetCallBacks kCFTypeSetCallBacks;
CF_EXPORT const CFSetCallBacks kCFCopyStringSetCallBacks;

CF_EXPORT CFTypeID CFSetGetTypeID(void);
CF_EXPORT CFSetRef CFSetCreate(CFAllocatorRef allocator, const void **values, CFIndex numValues, const CFSetCallBacks *callBacks);
CF_EXPORT CFSetRef CFSetCreateCopy(CFAllocatorRef allocator, CFSetRef theSet);
CF_EXPORT CFMutableSetRef CFSetCreateMutable(CFAllocatorRef allocator, CFIndex capacity, const CFSetCallBacks *callBacks);
CF_EXPORT CFMutableSetRef CFSetCreateMutableCopy(CFAllocatorRef allocator, CFIndex capacity, CFSetRef theSet);
CF_EXPORT CFIndex CFSetGetCount(CFSetRef theSet);
CF_EXPORT CFIndex CFSetGetCountOfValue(CFSetRef theSet, const void *value);
CF_EXPORT Boolean CFSetContainsValue(CFSetRef theSet, const void *value);
CF_EXPORT const void *CFSetGetValue(CFSetRef theSet, const void *value);
CF_EXPORT Boolean CFSetGetValueIfPresent(CFSetRef theSet, const void *candidate, const void **value);
CF_EXPORT void CFSetGetValues(CFSetRef theSet, const void **values);
CF_EXPORT void CFSetApplyFunction(CFSetRef theSet, CFSetApplierFunction applier, void *context);
CF_EXPORT void CFSetAddValue(CFMutableSetRef theSet, const void *value);
CF_EXPORT void CFSetReplaceValue(CFMutableSetRef theSet, const void *value);
CF_EXPORT void CFSetSetValue(CFMutableSetRef theSet, const void *value);
CF_EXPORT void CFSetRemoveValue(CFMutableSetRef theSet, const void *value);
CF_EXPORT void CFSetRemoveAllValues(CFMutableSetRef theSet);

#endif /* _CFSET_H_ */