/** Interface to ObjC runtime for GNUStep
   Copyright (C) 1995, 1997, 2000 Free Software Foundation, Inc.

   Written by:  Andrew Kachites McCallum <mccallum@gnu.ai.mit.edu>
   Date: 1995

   This file is part of the GNUstep Base Library.

   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2 of the License, or (at your option) any later version.

   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
   Boston, MA 02111 USA.

    AutogsdocSource: NSObjCRuntime.m
    AutogsdocSource: NSLog.m

 */

#ifndef __NSObjCRuntime_h_GNUSTEP_BASE_INCLUDE
#define __NSObjCRuntime_h_GNUSTEP_BASE_INCLUDE

#include <stdarg.h>
#include <limits.h>

#import <GNUstepBase/GSVersionMacros.h>
#import <GNUstepBase/GSConfig.h>
#import <CoreFoundation/CFBase.h>

#if defined(__cplusplus)
#define FOUNDATION_EXTERN extern "C"
#else
#define FOUNDATION_EXTERN extern
#endif

#define FOUNDATION_EXPORT  FOUNDATION_EXTERN
#define FOUNDATION_IMPORT FOUNDATION_EXTERN

#define NS_ENUM(type, name) type name; enum
#define NS_OPTIONS(type, name) type name; enum

/* These typedefs must be in place before GSObjCRuntime.h is imported.
 */

#if !defined(NSINTEGER_DEFINED)
typedef int NSInteger;
typedef unsigned int NSUInteger;

#endif /* !defined(NSINTEGER_DEFINED) */

#define NSIntegerMax    LONG_MAX
#define NSIntegerMin    LONG_MIN
#define NSUIntegerMax   ULONG_MAX

#define NSINTEGER_DEFINED 1

#if defined(__cplusplus)
extern "C" {
#endif

enum
{
    /**
     * Specifies that the enumeration is concurrency-safe.  Note that this does
     * not mean that it will be carried out in a concurrent manner, only that
     * it can be.
     */
    NSEnumerationConcurrent = (1UL << 0),
    /**
     * Specifies that the enumeration should happen in the opposite of the
     * natural order of the collection.
     */
    NSEnumerationReverse = (1UL << 1)
};

/** Bitfield used to specify options to control enumeration over collections.
 */
typedef NSUInteger NSEnumerationOptions;

/**
 * Contains values <code>NSOrderedSame</code>, <code>NSOrderedAscending</code>
 * <code>NSOrderedDescending</code>, for left hand side equals, less than, or
 * greater than right hand side.
 */

typedef NS_ENUM (NSInteger, NSComparisonResult) {
    NSOrderedAscending = -1L,
    NSOrderedSame,
    NSOrderedDescending
};

#import <GNUstepBase/GSObjCRuntime.h>

#if OS_API_VERSION(100500,GS_API_LATEST)
GS_EXPORT NSString  *NSStringFromProtocol(Protocol *aProtocol);
GS_EXPORT Protocol  *NSProtocolFromString(NSString *aProtocolName);
#endif
GS_EXPORT SEL       NSSelectorFromString(NSString *aSelectorName);
GS_EXPORT NSString  *NSStringFromSelector(SEL aSelector);
GS_EXPORT SEL       NSSelectorFromString(NSString *aSelectorName);
GS_EXPORT Class     NSClassFromString(NSString *aClassName);
GS_EXPORT NSString  *NSStringFromClass(Class aClass);
GS_EXPORT const char    *NSGetSizeAndAlignment(const char *typePtr,
                                               NSUInteger *sizep, NSUInteger *alignp);
GS_EXPORT BOOL NSSelectorsEqual(SEL sel1, SEL sel2);

#if OS_API_VERSION(GS_API_NONE, GS_API_NONE)
/* Logging */
/**
 *  OpenStep spec states that log messages go to stderr, but just in case
 *  someone wants them to go somewhere else, they can implement a function
 *  like this and assign a pointer to it to _NSLog_printf_handler.
 */
typedef void NSLog_printf_handler (NSString* message);
GS_EXPORT NSLog_printf_handler  *_NSLog_printf_handler;
GS_EXPORT int _NSLogDescriptor;
@class NSRecursiveLock;
GS_EXPORT NSRecursiveLock   *GSLogLock(void);
#endif

#if !defined(NDEBUG) && defined(__BUILT_WITH_SCONS_SYSTEM__)
#define NSLogv(fmt, args) \
    DEBUG_LOG("%s", [[[[NSString alloc] initWithFormat:fmt arguments:args] autorelease] UTF8String])
#define NSLog(fmt, ...) \
    DEBUG_LOG("%s", [[NSString stringWithFormat:fmt, ## __VA_ARGS__] UTF8String])
#else
GS_EXPORT void          NSLog (NSString *format, ...);
GS_EXPORT void          NSLogv (NSString *format, va_list args);
#endif

// Added by Apportable
#define NS_INLINE static inline

#if defined(__cplusplus)
}
#endif

#if !defined(NS_REQUIRES_NIL_TERMINATION)
#define NS_REQUIRES_NIL_TERMINATION __attribute__((sentinel(0,1)))
//#define NS_REQUIRES_NIL_TERMINATION __attribute__((sentinel))
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

#define NS_FORMAT_FUNCTION(F,A) __attribute__((format(__NSString__, F, A)))
#define NS_FORMAT_ARGUMENT(A) __attribute__ ((format_arg(A)))

#ifndef NS_UNIMPLEMENTED
#define NS_UNIMPLEMENTED CF_UNIMPLEMENTED
#endif

#ifdef APPORTABLE
#define NS_AVAILABLE_IOS(version)
#endif

#ifndef NS_BLOCKS_AVAILABLE
#define NS_BLOCKS_AVAILABLE 1
#endif

GS_EXPORT double NSFoundationVersionNumber;

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
#define NSFoundationVersionNumber_iOS_5_0  881
#define NSFoundationVersionNumber_iOS_5_1  890.1

#endif /* __NSObjCRuntime_h_GNUSTEP_BASE_INCLUDE */
