//
// CFBase.h
//
// Copyright Apportable Inc. All rights reserved.
//
// Portions of this project are derived from the CoreFoundation
// implementation from the Cocotron project.
//
// Copyright (c) 2008-2009 Christopher J. W. Lloyd
//

#ifndef _CFBASE_H_
#define _CFBASE_H_

#include <limits.h>
#include <stdint.h>
#include <sys/cdefs.h>

#include <AvailabilityMacros.h>
#include <Availability.h>
#include <MacTypes.h>

#ifdef __cplusplus
#define CF_EXPORT extern "C"
#else
#define CF_EXPORT extern 
#endif // __cplusplus

#if !defined(DEBUG)
#define CF_INLINE static __inline__ __attribute__((always_inline))
#else
#define CF_INLINE static inline
#endif

#if !defined(CF_EXTERN_C_BEGIN)
#if defined(__cplusplus)
#define CF_EXTERN_C_BEGIN extern "C" {
#define CF_EXTERN_C_END }
#else
#define CF_EXTERN_C_BEGIN
#define CF_EXTERN_C_END
#endif
#endif

#ifndef CF_RETURNS_RETAINED
#if __has_feature(attribute_cf_returns_retained)
#define CF_RETURNS_RETAINED __attribute__((cf_returns_retained))
#else
#define CF_RETURNS_RETAINED
#endif
#endif

#ifndef CF_RETURNS_NOT_RETAINED
#if __has_feature(attribute_cf_returns_not_retained)
#define CF_RETURNS_NOT_RETAINED __attribute__((cf_returns_not_retained))
#else
#define CF_RETURNS_NOT_RETAINED
#endif
#endif

#ifndef CF_CONSUMED
#if __has_feature(attribute_cf_consumed)
#define CF_CONSUMED __attribute__((cf_consumed))
#else
#define CF_CONSUMED
#endif
#endif

#define CF_ENUM(type, name) type name; enum
#define CF_OPTIONS(type, name) type name; enum

enum
{
    kCFNotFound = LONG_MAX
};

/* Apple's Foundation imports CoreGraphics in order to get some of the basic CG* types, unfortunately
   this is a hassle on platforms where you just want to use Foundation, so we put them in CoreFoundation and see what happens
*/
#ifndef CGFLOAT_DEFINED
typedef float CGFloat;
#define CGFLOAT_DEFINED
#define CGFLOAT_MIN FLT_MIN
#define CGFLOAT_MAX FLT_MAX
#endif

// FIXME:
#ifndef _MACH_PORT_T
#define _MACH_PORT_T
typedef int mach_port_t;
#endif

#ifndef __MACTYPES__
typedef unsigned short UniChar;
typedef unsigned int UTF32Char;
typedef float Float32;
typedef double Float64;
// ---

typedef signed char SInt8;
typedef unsigned char UInt8;
typedef signed short SInt16;
typedef unsigned short UInt16;
typedef signed long SInt32;
typedef unsigned long UInt32;
typedef signed long long SInt64;
typedef unsigned long long UInt64;

typedef char       Boolean;
typedef UInt32 FourCharCode;
typedef SInt32 OSStatus;
typedef SInt16 OSErr;

#endif 

typedef unsigned CFUInteger;
typedef int CFInteger;
typedef const void *CFTypeRef;
typedef const struct __CFString * CFStringRef;
typedef struct __CFString * CFMutableStringRef;
typedef CFUInteger CFTypeID;
typedef CFUInteger CFHashCode;
typedef CFInteger  CFIndex;
typedef CFUInteger CFOptionFlags;

typedef CFTypeRef CFPropertyListRef;

typedef struct {
   CFIndex location;
   CFIndex length;
} CFRange;

static inline CFRange CFRangeMake(CFIndex loc, CFIndex len){
   CFRange result={loc, len};

   return result;
}

#define kCFNull (CFTypeRef)[NSNull null]

#ifndef TRUE
#define TRUE ((Boolean)1)
#endif

#ifndef FALSE
#define FALSE ((Boolean)0)
#endif

typedef CF_ENUM(CFIndex, CFComparisonResult){
   kCFCompareLessThan    = -1L, 
   kCFCompareEqualTo     = 0, 
   kCFCompareGreaterThan = 1
} ;

typedef CFComparisonResult (*CFComparatorFunction)(const void *value, const void *other, void *context);

typedef struct CFAllocator *CFAllocatorRef;

typedef void       *(*CFAllocatorAllocateCallBack)(CFIndex size, CFOptionFlags hint, void *info);
typedef void        (*CFAllocatorDeallocateCallBack)(void *ptr, void *info);
typedef CFStringRef (*CFAllocatorCopyDescriptionCallBack)(const void *info);
typedef CFIndex     (*CFAllocatorPreferredSizeCallBack)(CFIndex size, CFOptionFlags hint, void *info);
typedef void       *(*CFAllocatorReallocateCallBack)(void *ptr, CFIndex size, CFOptionFlags hint, void *info);
typedef void        (*CFAllocatorReleaseCallBack)(const void *info);
typedef const void *(*CFAllocatorRetainCallBack)(const void *info);

CF_EXPORT const CFAllocatorRef kCFAllocatorDefault;
CF_EXPORT const CFAllocatorRef kCFAllocatorSystemDefault;
CF_EXPORT const CFAllocatorRef kCFAllocatorMalloc;
CF_EXPORT const CFAllocatorRef kCFAllocatorMallocZone;
CF_EXPORT const CFAllocatorRef kCFAllocatorNull;
CF_EXPORT const CFAllocatorRef kCFAllocatorUseContext;

CF_EXPORT CFAllocatorRef CFAllocatorGetDefault(void);
CF_EXPORT void CFAllocatorSetDefault(CFAllocatorRef self);

CF_EXPORT CFTypeID CFAllocatorGetTypeID(void);

CF_EXPORT void *CFAllocatorAllocate(CFAllocatorRef self, CFIndex size, CFOptionFlags hint);
CF_EXPORT void CFAllocatorDeallocate(CFAllocatorRef self, void *ptr);
CF_EXPORT void *CFAllocatorReallocate(CFAllocatorRef self, void *ptr, CFIndex size, CFOptionFlags hint);


CF_EXPORT CFTypeID CFGetTypeID(CFTypeRef self);

CF_EXPORT CFTypeRef CFRetain(CFTypeRef self);
CF_EXPORT void CFRelease(CFTypeRef self);
CF_EXPORT CFIndex CFGetRetainCount(CFTypeRef self);

CF_EXPORT CFAllocatorRef CFGetAllocator(CFTypeRef self);

CF_EXPORT CFHashCode CFHash(CFTypeRef self);
CF_EXPORT Boolean CFEqual(CFTypeRef self, CFTypeRef other);
CF_EXPORT CFTypeRef CFMakeCollectable(CFTypeRef self);

CF_EXPORT CFStringRef CFCopyTypeIDDescription(CFTypeID typeID);
CF_EXPORT CFStringRef CFCopyDescription(CFTypeRef self);

#ifdef WINDOWS
CF_EXPORT unsigned int sleep(unsigned int seconds);
CF_EXPORT size_t strlcpy(char *dst, const char *src, size_t size);
CF_EXPORT void bzero(void *ptr, size_t size);
CF_EXPORT void bcopy(const void *s1, void *s2, size_t n);
CF_EXPORT int bcmp(const void *s1, void *s2, size_t n);
CF_EXPORT int mkstemps(char *template, int suffixlen);
#endif

#define kCFCoreFoundationVersionNumber_iPhoneOS_2_0	478.23
#define kCFCoreFoundationVersionNumber_iPhoneOS_2_1 478.26
#define kCFCoreFoundationVersionNumber_iPhoneOS_2_2 478.29
#define kCFCoreFoundationVersionNumber_iPhoneOS_3_0 478.47
#define kCFCoreFoundationVersionNumber_iPhoneOS_3_1 478.52
#define kCFCoreFoundationVersionNumber_iPhoneOS_3_2 478.61
#define kCFCoreFoundationVersionNumber_iOS_4_0 550.32
#define kCFCoreFoundationVersionNumber_iOS_4_1 550.38
#define kCFCoreFoundationVersionNumber_iOS_4_2 550.52

#define kCFCoreFoundationVersionNumber kCFCoreFoundationVersionNumber_iPhoneOS_2_0

#ifndef CF_WARN_UNIMPLEMENTED
#define CF_WARN_UNIMPLEMENTED 1
#endif

#define CF_UNIMPLEMENTED_WARNING_MESSAGE "Unimplemented or incomplete implementation."
#ifdef CF_ASSERT_UNIMPLEMENTED
#define CF_UNIMPLEMENTED __attribute__((unavailable(CF_UNIMPLEMENTED_WARNING_MESSAGE)))
#elif CF_WARN_UNIMPLEMENTED
#define CF_UNIMPLEMENTED __attribute__((deprecated(CF_UNIMPLEMENTED_WARNING_MESSAGE)))
#else
#define CF_UNIMPLEMENTED
#endif

#ifdef DEBUG_LOG
#define CF_DEBUG_LOG DEBUG_LOG
#else
#define CF_DEBUG_LOG(...)
#endif

/* Use CF_UNIMPLEMENT_FN macros to provide dummy implementation that
 * logs "unimplemented" message and returns null. Works with objc methods too.
 * Examples:
 *   CF_UNIMPLEMENT_FN(int DoThisAndThat(int argc, const char** argv));
 *   CF_UNIMPLEMENT_FN(- (int)doThisAndThatWithArgc:(int)argc argv:(const char**)argv);
 */
#define CF_UNIMPLEMENT_FN(...) \
    __VA_ARGS__ { \
        CF_DEBUG_LOG("%s is NOT implemented!", __FUNCTION__); \
        return 0; \
    }

#define CF_UNIMPLEMENT_VOID_FN(...) \
    __VA_ARGS__ { \
        CF_DEBUG_LOG("%s is NOT implemented!", __FUNCTION__); \
    }

#define CF_UNIMPLEMENT_STRUCT_FN(StructType, ...) \
    __VA_ARGS__ { \
        CF_DEBUG_LOG("%s is NOT implemented!", __FUNCTION__); \
        StructType result = {0}; \
        return result; \
    }

#endif /* _CFBASE_H_ */
