//
// CFError.h
//
// Copyright Apportable Inc. All rights reserved.
//
// Portions of this project are derived from the CoreFoundation
// implementation from the Cocotron project.
//
// Copyright (c) 2008-2009 Christopher J. W. Lloyd
//

#ifndef _CFERROR_H_
#define _CFERROR_H_

#import <CoreFoundation/CFBase.h>

typedef struct __NSError *CFErrorRef;

CF_EXPORT const CFStringRef kCFErrorDomainPOSIX;
CF_EXPORT const CFStringRef kCFErrorDomainCocoa;
CF_EXPORT const CFStringRef kCFErrorDomainOSStatus;
CF_EXPORT const CFStringRef kCFErrorDomainMach;

CF_EXPORT const CFStringRef kCFErrorDescriptionKey;
CF_EXPORT const CFStringRef kCFErrorLocalizedDescriptionKey;
CF_EXPORT const CFStringRef kCFErrorUnderlyingErrorKey;
CF_EXPORT const CFStringRef kCFErrorLocalizedFailureReasonKey;
CF_EXPORT const CFStringRef kCFErrorLocalizedRecoverySuggestionKey;

CF_EXPORT CFTypeID CFErrorGetTypeID(void);

CF_EXPORT CFErrorRef CFErrorCreate(CFAllocatorRef allocator, CFStringRef domain, CFIndex code, CFDictionaryRef userInfo);
CF_EXPORT CFErrorRef CFErrorCreateWithUserInfoKeysAndValues(CFAllocatorRef allocator,
																		CFStringRef domain,
																		CFIndex code,
																		const void *const *userInfoKeys,
																		const void *const *userInfoValues,
																		CFIndex userInfoCount);

CF_EXPORT CFStringRef CFErrorGetDomain(CFErrorRef self);
CF_EXPORT CFIndex CFErrorGetCode(CFErrorRef self);
CF_EXPORT CFDictionaryRef CFErrorCopyUserInfo(CFErrorRef self);
CF_EXPORT CFStringRef CFErrorCopyFailureReason(CFErrorRef self);
CF_EXPORT CFStringRef CFErrorCopyRecoverySuggestion(CFErrorRef self);
CF_EXPORT CFStringRef CFErrorCopyDescription(CFErrorRef self);

#endif /* _CFERROR_H_ */
