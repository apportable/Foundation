#import <TargetConditionals.h>

#if defined(__cplusplus)
#define FOUNDATION_EXTERN extern "C"
#else
#define FOUNDATION_EXTERN extern
#endif

#define FOUNDATION_EXPORT FOUNDATION_EXTERN
#define FOUNDATION_IMPORT FOUNDATION_EXTERN

#if !defined(NS_INLINE)
#if defined(__GNUC__)
#define NS_INLINE static __inline__ __attribute__((always_inline))
#elif defined(__cplusplus)
#define NS_INLINE static inline
#endif
#endif

#if !defined(FOUNDATION_STATIC_INLINE)
#define FOUNDATION_STATIC_INLINE static __inline__
#endif

#if !defined(FOUNDATION_EXTERN_INLINE)
#define FOUNDATION_EXTERN_INLINE extern __inline__
#endif

#if !defined(NS_REQUIRES_NIL_TERMINATION)
#define NS_REQUIRES_NIL_TERMINATION __attribute__((sentinel(0,1)))
#endif

#if !defined(NS_BLOCKS_AVAILABLE)
#define NS_BLOCKS_AVAILABLE 1
#endif

#if !defined(NS_NONATOMIC_IOSONLY)
#define NS_NONATOMIC_IOSONLY nonatomic
#endif

#if !defined(NS_NONATOMIC_IPHONEONLY)
#define NS_NONATOMIC_IPHONEONLY NS_NONATOMIC_IOSONLY
#endif

#if !defined(NS_FORMAT_FUNCTION)
#define NS_FORMAT_FUNCTION(F,A) __attribute__((format(__NSString__, F, A)))
#endif

#if !defined(NS_FORMAT_ARGUMENT)
#define NS_FORMAT_ARGUMENT(A) __attribute__ ((format_arg(A)))
#endif

#ifndef __has_feature
#define __has_feature(x) 0
#endif

#ifndef __has_extension
#define __has_extension(x) 0
#endif

#ifndef __has_attribute
#define __has_attribute(x) 0
#endif

#if __has_feature(attribute_ns_returns_retained)
#define NS_RETURNS_RETAINED __attribute__((ns_returns_retained))
#else
#define NS_RETURNS_RETAINED
#endif

#if __has_feature(attribute_ns_returns_not_retained)
#define NS_RETURNS_NOT_RETAINED __attribute__((ns_returns_not_retained))
#else
#define NS_RETURNS_NOT_RETAINED
#endif

#ifndef NS_RETURNS_INNER_POINTER
#if __has_attribute(objc_returns_inner_pointer)
#define NS_RETURNS_INNER_POINTER __attribute__((objc_returns_inner_pointer))
#else
#define NS_RETURNS_INNER_POINTER
#endif
#endif

#if __has_feature(objc_arc)
#define NS_AUTOMATED_REFCOUNT_UNAVAILABLE __attribute__((unavailable("not available in automatic reference counting mode")))
#else
#define NS_AUTOMATED_REFCOUNT_UNAVAILABLE
#endif

#if __has_attribute(objc_arc_weak_reference_unavailable)
#define NS_AUTOMATED_REFCOUNT_WEAK_UNAVAILABLE __attribute__((objc_arc_weak_reference_unavailable))
#else
#define NS_AUTOMATED_REFCOUNT_WEAK_UNAVAILABLE
#endif

#if __has_attribute(objc_requires_property_definitions)
#define NS_REQUIRES_PROPERTY_DEFINITIONS __attribute__((objc_requires_property_definitions))

#else
#define NS_REQUIRES_PROPERTY_DEFINITIONS
#endif

#if __has_feature(attribute_ns_consumes_self)
#define NS_REPLACES_RECEIVER __attribute__((ns_consumes_self)) NS_RETURNS_RETAINED
#else
#define NS_REPLACES_RECEIVER
#endif

#if __has_feature(attribute_ns_consumed)
#define NS_RELEASES_ARGUMENT __attribute__((ns_consumed))
#else
#define NS_RELEASES_ARGUMENT
#endif

#if !defined(NS_VALID_UNTIL_END_OF_SCOPE) && __has_attribute(objc_precise_lifetime)
#define NS_VALID_UNTIL_END_OF_SCOPE __attribute__((objc_precise_lifetime))
#else
#define NS_VALID_UNTIL_END_OF_SCOPE
#endif

#ifndef NS_ROOT_CLASS
#if __has_attribute(objc_root_class)
#define NS_ROOT_CLASS __attribute__((objc_root_class))
#else
#define NS_ROOT_CLASS
#endif
#endif

#ifndef NS_REQUIRES_SUPER
#if __has_attribute(objc_requires_super)
#define NS_REQUIRES_SUPER __attribute__((objc_requires_super))
#else
#define NS_REQUIRES_SUPER
#endif
#endif

#ifndef NS_DESIGNATED_INITIALIZER
#if __has_attribute(objc_designated_initializer)
#define NS_DESIGNATED_INITIALIZER __attribute__((objc_designated_initializer))
#else
#define NS_DESIGNATED_INITIALIZER
#endif
#endif

#ifndef NS_PROTOCOL_REQUIRES_EXPLICIT_IMPLEMENTATION
#if __has_attribute(objc_protocol_requires_explicit_implementation)
#define NS_PROTOCOL_REQUIRES_EXPLICIT_IMPLEMENTATION __attribute__((objc_protocol_requires_explicit_implementation))
#else
#define NS_PROTOCOL_REQUIRES_EXPLICIT_IMPLEMENTATION
#endif
#endif


#if !__has_feature(objc_instancetype)
#undef instancetype
#define instancetype id
#endif

#if !defined(NS_UNAVAILABLE)
#define NS_UNAVAILABLE UNAVAILABLE_ATTRIBUTE
#endif

#if !defined(__unsafe_unretained)
#define __unsafe_unretained
#endif

#import <objc/objc.h>
#import <stdarg.h>
#import <stdint.h>
#import <limits.h>
#import <AvailabilityMacros.h>
#import <Availability.h>

#define NS_AVAILABLE(_mac, _ios) __OSX_AVAILABLE_STARTING(__MAC_##_mac, __IPHONE_##_ios)
#define NS_AVAILABLE_MAC(_mac) __OSX_AVAILABLE_STARTING(__MAC_##_mac, __IPHONE_NA)
#define NS_AVAILABLE_IOS(_ios) __OSX_AVAILABLE_STARTING(__MAC_NA, __IPHONE_##_ios)
#define NS_DEPRECATED(_macIntro, _macDep, _iosIntro, _iosDep) __OSX_AVAILABLE_BUT_DEPRECATED(__MAC_##_macIntro, __MAC_##_macDep, __IPHONE_##_iosIntro, __IPHONE_##_iosDep)
#define NS_DEPRECATED_MAC(_macIntro, _macDep) __OSX_AVAILABLE_BUT_DEPRECATED(__MAC_##_macIntro, __MAC_##_macDep, __IPHONE_NA, __IPHONE_NA)
#define NS_DEPRECATED_IOS(_iosIntro, _iosDep) __OSX_AVAILABLE_BUT_DEPRECATED(__MAC_NA, __MAC_NA, __IPHONE_##_iosIntro, __IPHONE_##_iosDep)

#define NS_AVAILABLE_IPHONE(_ios) NS_AVAILABLE_IOS(_ios)
#define NS_DEPRECATED_IPHONE(_iosIntro, _iosDep) NS_DEPRECATED_IOS(_iosIntro, _iosDep)

#if (__MAC_OS_X_VERSION_MIN_REQUIRED >= __MAC_10_6 || __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_3_1) && \
    ((__has_feature(objc_weak_class) || \
     (defined(__llvm__) && defined(__APPLE_CC__) && (__APPLE_CC__ >= 5658)) || \
     (defined(__APPLE_CC__) && (__APPLE_CC__ >= 5666))))
#define NS_CLASS_AVAILABLE(_mac, _ios) __attribute__((visibility("default"))) __OSX_AVAILABLE_STARTING(__MAC_##_mac, __IPHONE_##_ios)
#else
#define NS_CLASS_AVAILABLE(_mac, _ios)
#endif

#define NS_CLASS_AVAILABLE_IOS(_ios) NS_CLASS_AVAILABLE(NA, _ios)
#define NS_CLASS_AVAILABLE_MAC(_mac) NS_CLASS_AVAILABLE(_mac, NA)

#if __has_feature(enumerator_attributes) && __has_attribute(availability)
#define NS_ENUM_AVAILABLE(_mac, _ios) __OSX_AVAILABLE_STARTING(__MAC_##_mac, __IPHONE_##_ios)
#define NS_ENUM_AVAILABLE_MAC(_mac) __OSX_AVAILABLE_STARTING(__MAC_##_mac, __IPHONE_NA)
#define NS_ENUM_AVAILABLE_IOS(_ios) __OSX_AVAILABLE_STARTING(__MAC_NA, __IPHONE_##_ios)
#define NS_ENUM_DEPRECATED(_macIntro, _macDep, _iosIntro, _iosDep) __OSX_AVAILABLE_BUT_DEPRECATED(__MAC_##_macIntro, __MAC_##_macDep, __IPHONE_##_iosIntro, __IPHONE_##_iosDep)
#define NS_ENUM_DEPRECATED_MAC(_macIntro, _macDep) __OSX_AVAILABLE_BUT_DEPRECATED(__MAC_##_macIntro, __MAC_##_macDep, __IPHONE_NA, __IPHONE_NA)
#define NS_ENUM_DEPRECATED_IOS(_iosIntro, _iosDep) __OSX_AVAILABLE_BUT_DEPRECATED(__MAC_NA, __MAC_NA, __IPHONE_##_iosIntro, __IPHONE_##_iosDep)
#else
#define NS_ENUM_AVAILABLE(_mac, _ios)
#define NS_ENUM_AVAILABLE_MAC(_mac)
#define NS_ENUM_AVAILABLE_IOS(_ios)
#define NS_ENUM_DEPRECATED(_macIntro, _macDep, _iosIntro, _iosDep)
#define NS_ENUM_DEPRECATED_MAC(_macIntro, _macDep)
#define NS_ENUM_DEPRECATED_IOS(_iosIntro, _iosDep)
#endif

#if (__cplusplus && __cplusplus >= 201103L && (__has_extension(cxx_strong_enums) || __has_feature(objc_fixed_enum))) || (!__cplusplus && __has_feature(objc_fixed_enum))
#define NS_ENUM(_type, _name) enum _name : _type _name; enum _name : _type
#if (__cplusplus)
#define NS_OPTIONS(_type, _name) _type _name; enum : _type
#else
#define NS_OPTIONS(_type, _name) enum _name : _type _name; enum _name : _type
#endif
#else
#define NS_ENUM(_type, _name) _type _name; enum
#define NS_OPTIONS(_type, _name) _type _name; enum
#endif

FOUNDATION_EXPORT double NSFoundationVersionNumber;

#if TARGET_OS_IPHONE
#define NSFoundationVersionNumber_iPhoneOS_2_0  678.24
#define NSFoundationVersionNumber_iPhoneOS_2_1  678.26
#define NSFoundationVersionNumber_iPhoneOS_2_2  678.29
#define NSFoundationVersionNumber_iPhoneOS_3_0  678.47
#define NSFoundationVersionNumber_iPhoneOS_3_1  678.51
#define NSFoundationVersionNumber_iPhoneOS_3_2  678.60
#define NSFoundationVersionNumber_iOS_4_0  751.32
#define NSFoundationVersionNumber_iOS_4_1  751.37
#define NSFoundationVersionNumber_iOS_4_2  751.49
#define NSFoundationVersionNumber_iOS_4_3  751.49
#define NSFoundationVersionNumber_iOS_5_0  881.00
#define NSFoundationVersionNumber_iOS_5_1  890.10
#define NSFoundationVersionNumber_iOS_6_0  993.00
#define NSFoundationVersionNumber_iOS_6_1  993.00
#endif

#if __LP64__ || (TARGET_OS_EMBEDDED && !TARGET_OS_IPHONE) || TARGET_OS_WIN32 || NS_BUILD_32_LIKE_64
typedef long NSInteger;
typedef unsigned long NSUInteger;
#else
typedef int NSInteger;
typedef unsigned int NSUInteger;
#endif

#define NSIntegerMax    LONG_MAX
#define NSIntegerMin    LONG_MIN
#define NSUIntegerMax   ULONG_MAX

#define NSINTEGER_DEFINED 1

@class NSString, Protocol;

FOUNDATION_EXPORT NSString *NSStringFromSelector(SEL aSelector);
FOUNDATION_EXPORT SEL NSSelectorFromString(NSString *aSelectorName);

FOUNDATION_EXPORT NSString *NSStringFromClass(Class aClass);
FOUNDATION_EXPORT Class NSClassFromString(NSString *aClassName);

FOUNDATION_EXPORT NSString *NSStringFromProtocol(Protocol *proto) NS_AVAILABLE(10_5, 2_0);
FOUNDATION_EXPORT Protocol *NSProtocolFromString(NSString *namestr) NS_AVAILABLE(10_5, 2_0);

FOUNDATION_EXPORT const char *NSGetSizeAndAlignment(const char *typePtr, NSUInteger *sizep, NSUInteger *alignp);

FOUNDATION_EXPORT void NSLog(NSString *format, ...) NS_FORMAT_FUNCTION(1,2);
FOUNDATION_EXPORT void NSLogv(NSString *format, va_list args) NS_FORMAT_FUNCTION(1,0);

typedef NS_ENUM(NSInteger, NSComparisonResult) {NSOrderedAscending = -1L, NSOrderedSame, NSOrderedDescending};

#if NS_BLOCKS_AVAILABLE
typedef NSComparisonResult (^NSComparator)(id obj1, id obj2);
#endif

enum {
    NSEnumerationConcurrent = (1UL << 0),
    NSEnumerationReverse = (1UL << 1),
};
typedef NSUInteger NSEnumerationOptions;

enum {
    NSSortConcurrent = (1UL << 0),
    NSSortStable = (1UL << 4),
};
typedef NSUInteger NSSortOptions;

enum {NSNotFound = NSIntegerMax};

#if !defined(YES)
    #define YES    (BOOL)1
#endif

#if !defined(NO)
    #define NO    (BOOL)0
#endif

#if __clang__

#define __MINMAXPASTE__(A,B) A##B

#if !defined(MIN)
    #define __MIN(A,B,C) ({ __typeof__(A) __MINMAXPASTE__(__a,C) = (A); __typeof__(B) __MINMAXPASTE__(__b,C) = (B); __MINMAXPASTE__(__a,C) < __MINMAXPASTE__(__b,C) ? __MINMAXPASTE__(__a,C) : __MINMAXPASTE__(__b,C); })
    #define MIN(A,B) __MIN(A,B,__COUNTER__)
#endif

#if !defined(MAX)
    #define __MAX(A,B,C) ({ __typeof__(A) __MINMAXPASTE__(__a,C) = (A); __typeof__(B) __MINMAXPASTE__(__b,C) = (B); __MINMAXPASTE__(__a,C) < __MINMAXPASTE__(__b,C) ? __MINMAXPASTE__(__b,C) : __MINMAXPASTE__(__a,C); })
    #define MAX(A,B) __MAX(A,B,__COUNTER__)
#endif

#if !defined(ABS)
    #define __ABS(A,C)    ({ __typeof__(A) __MINMAXPASTE__(__a,C) = (A); __MINMAXPASTE__(__a,C) < 0 ? -__MINMAXPASTE__(__a,C) : __MINMAXPASTE__(__a,C); })
    #define ABS(A) __ABS(A,__COUNTER__)
#endif

#else

#if defined(__GNUC__) && !defined(__STRICT_ANSI__)

#if !defined(MIN)
    #define MIN(A,B)    ({ __typeof__(A) __a = (A); __typeof__(B) __b = (B); __a < __b ? __a : __b; })
#endif

#if !defined(MAX)
    #define MAX(A,B)    ({ __typeof__(A) __a = (A); __typeof__(B) __b = (B); __a < __b ? __b : __a; })
#endif

#if !defined(ABS)
    #define ABS(A)    ({ __typeof__(A) __a = (A); __a < 0 ? -__a : __a; })
#endif

#else

#if !defined(MIN)
    #define MIN(A,B)    ((A) < (B) ? (A) : (B))
#endif

#if !defined(MAX)
    #define MAX(A,B)    ((A) > (B) ? (A) : (B))
#endif

#if !defined(ABS)
    #define ABS(A)    ((A) < 0 ? (-(A)) : (A))
#endif

#endif    /* __GNUC__ */
#endif    /* __clang__ */

#ifndef NS_UNIMPLEMENTED
#define NS_UNIMPLEMENTED CF_UNIMPLEMENTED
#endif
