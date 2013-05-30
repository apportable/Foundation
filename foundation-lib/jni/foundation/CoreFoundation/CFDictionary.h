//
// CFDictionary.h
//
// Copyright Apportable Inc. All rights reserved.
//

typedef const struct __CFDictionary *CFDictionaryRef;
typedef struct __CFDictionary *CFMutableDictionaryRef;

#import <CoreFoundation/CFBase.h>
#import <CoreFoundation/CFString.h>

typedef const void *(*CFDictionaryRetainCallBack)(CFAllocatorRef allocator, const void *value);
typedef void (*CFDictionaryReleaseCallBack)(CFAllocatorRef allocator, const void *value);
typedef CFStringRef (*CFDictionaryCopyDescriptionCallBack)(const void *value);
typedef Boolean (*CFDictionaryEqualCallBack)(const void *value, const void *other);
typedef CFHashCode (*CFDictionaryHashCallBack)(const void *value);

typedef struct  {
   CFIndex version;
   CFDictionaryRetainCallBack retain;
   CFDictionaryReleaseCallBack release;
   CFDictionaryCopyDescriptionCallBack copyDescription;
   CFDictionaryEqualCallBack equal;
   CFDictionaryHashCallBack hash;
} CFDictionaryKeyCallBacks;

typedef struct  {
   CFIndex version;
   CFDictionaryRetainCallBack retain;
   CFDictionaryReleaseCallBack release;
   CFDictionaryCopyDescriptionCallBack copyDescription;
   CFDictionaryEqualCallBack equal;
} CFDictionaryValueCallBacks;

typedef void (*CFDictionaryApplierFunction)(const void *key, const void *value, void *context);

CF_EXPORT const CFDictionaryKeyCallBacks kCFCopyStringDictionaryKeyCallBacks;
CF_EXPORT const CFDictionaryKeyCallBacks kCFTypeDictionaryKeyCallBacks;
CF_EXPORT const CFDictionaryValueCallBacks kCFTypeDictionaryValueCallBacks;

CF_EXPORT CFTypeID CFDictionaryGetTypeID(void);
CF_EXPORT CFDictionaryRef CFDictionaryCreate(CFAllocatorRef allocator, 
                                                         const void **keys,
                                                         const void **values,
                                                         CFIndex count,
                                                         const CFDictionaryKeyCallBacks *keyCallbacks,
                                                         const CFDictionaryValueCallBacks *valueCallbacks);

CF_EXPORT CFDictionaryRef CFDictionaryCreateCopy(CFAllocatorRef allocator, CFDictionaryRef self);

CF_EXPORT void CFDictionaryApplyFunction(CFDictionaryRef self, CFDictionaryApplierFunction function, void *context);
CF_EXPORT Boolean CFDictionaryContainsKey(CFDictionaryRef self, const void *key);
CF_EXPORT Boolean CFDictionaryContainsValue(CFDictionaryRef self, const void *value);
CF_EXPORT CFIndex CFDictionaryGetCount(CFDictionaryRef self);
CF_EXPORT CFIndex CFDictionaryGetCountOfKey(CFDictionaryRef self, const void *key);
CF_EXPORT CFIndex CFDictionaryGetCountOfValue(CFDictionaryRef self, const void *value);
CF_EXPORT void CFDictionaryGetKeysAndValues(CFDictionaryRef self, const void **keys, const void **values);
CF_EXPORT const void *CFDictionaryGetValue(CFDictionaryRef self, const void *key);
CF_EXPORT Boolean CFDictionaryGetValueIfPresent(CFDictionaryRef self, const void *key, const void **value);

CF_EXPORT CFMutableDictionaryRef CFDictionaryCreateMutable(CFAllocatorRef allocator,
                                                                       CFIndex capacity,
                                                                       const CFDictionaryKeyCallBacks *keyCallbacks,
                                                                       const CFDictionaryValueCallBacks *valueCallbacks);

CF_EXPORT CFMutableDictionaryRef CFDictionaryCreateMutableCopy(CFAllocatorRef allocator, CFIndex capacity, CFDictionaryRef self);

CF_EXPORT void CFDictionaryAddValue(CFMutableDictionaryRef self, const void *key, const void *value);
CF_EXPORT void CFDictionaryRemoveAllValues(CFMutableDictionaryRef self);
CF_EXPORT void CFDictionaryRemoveValue(CFMutableDictionaryRef self, const void *key);
CF_EXPORT void CFDictionaryReplaceValue(CFMutableDictionaryRef self, const void *key, const void *value);
CF_EXPORT void CFDictionarySetValue(CFMutableDictionaryRef self, const void *key, const void *value);



