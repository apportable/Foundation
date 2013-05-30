//
// CFURL.h
//
// Copyright Apportable Inc. All rights reserved.
//
// Portions of this project are derived from the CoreFoundation
// implementation from the Cocotron project.
//
// Copyright (c) 2008-2009 Christopher J. W. Lloyd
//

#ifndef _CFURL_H_
#define _CFURL_H_

#import <CoreFoundation/CFBase.h>
#import <CoreFoundation/CFData.h>
#import <CoreFoundation/CFString.h>

typedef struct __NSURL *CFURLRef;

typedef enum {
   kCFURLComponentScheme            = 1,
   kCFURLComponentNetLocation       = 2,
   kCFURLComponentPath              = 3,
   kCFURLComponentResourceSpecifier = 4,
   kCFURLComponentUser              = 5,
   kCFURLComponentPassword          = 6,
   kCFURLComponentUserInfo          = 7,
   kCFURLComponentHost              = 8,
   kCFURLComponentPort              = 9,
   kCFURLComponentParameterString   = 10,
   kCFURLComponentQuery             = 11,
   kCFURLComponentFragment          = 12,
} CFURLComponentType;

typedef enum  {
   kCFURLPOSIXPathStyle   = 0,
   kCFURLHFSPathStyle     = 1,
   kCFURLWindowsPathStyle = 2,
} CFURLPathStyle;

CF_EXPORT CFTypeID CFURLGetTypeID(void);

CF_EXPORT CFURLRef CFURLCreateAbsoluteURLWithBytes(CFAllocatorRef allocator, const uint8_t *bytes, CFIndex length, CFStringEncoding encoding, CFURLRef baseURL, Boolean useCompatibilityMode);
CF_EXPORT CFURLRef CFURLCreateWithBytes(CFAllocatorRef allocator, const uint8_t *bytes, CFIndex length, CFStringEncoding encoding, CFURLRef baseURL);
CF_EXPORT CFURLRef CFURLCreateWithFileSystemPath(CFAllocatorRef allocator, CFStringRef path, CFURLPathStyle pathStyle, Boolean isDirectory);
CF_EXPORT CFURLRef CFURLCreateWithFileSystemPathRelativeToBase(CFAllocatorRef allocator, CFStringRef path, CFURLPathStyle pathStyle, Boolean isDirectory, CFURLRef baseURL);
CF_EXPORT CFURLRef CFURLCreateWithString(CFAllocatorRef allocator, CFStringRef string, CFURLRef baseURL);
CF_EXPORT CFURLRef CFURLCreateFromFileSystemRepresentation(CFAllocatorRef allocator, const uint8_t *buffer, CFIndex length, Boolean isDirectory);
CF_EXPORT CFURLRef CFURLCreateFromFileSystemRepresentationRelativeToBase(CFAllocatorRef allocator, const uint8_t *buffer, CFIndex length, Boolean isDirectory, CFURLRef baseURL);

CF_EXPORT CFURLRef    CFURLCopyAbsoluteURL(CFURLRef url);

CF_EXPORT CFStringRef CFURLGetString(CFURLRef self);
CF_EXPORT CFURLRef CFURLGetBaseURL(CFURLRef self);
CF_EXPORT Boolean CFURLCanBeDecomposed(CFURLRef self);
CF_EXPORT CFStringRef CFURLCopyFileSystemPath(CFURLRef self, CFURLPathStyle pathStyle);
CF_EXPORT CFStringRef CFURLCopyFragment(CFURLRef self, CFStringRef charactersToLeaveEscaped);
CF_EXPORT CFStringRef CFURLCopyHostName(CFURLRef self);
CF_EXPORT CFStringRef CFURLCopyLastPathComponent(CFURLRef self);
CF_EXPORT CFStringRef CFURLCopyNetLocation(CFURLRef self);
CF_EXPORT CFStringRef CFURLCopyParameterString(CFURLRef self, CFStringRef charactersToLeaveEscaped);
CF_EXPORT CFStringRef CFURLCopyPassword(CFURLRef self);
CF_EXPORT CFStringRef CFURLCopyPath(CFURLRef self);
CF_EXPORT CFStringRef CFURLCopyPathExtension(CFURLRef self);
CF_EXPORT CFStringRef CFURLCopyQueryString(CFURLRef self, CFStringRef charactersToLeaveEscaped);
CF_EXPORT CFStringRef CFURLCopyResourceSpecifier(CFURLRef self);
CF_EXPORT CFStringRef CFURLCopyScheme(CFURLRef self);
CF_EXPORT CFStringRef CFURLCopyStrictPath(CFURLRef self, Boolean *isAbsolute);
CF_EXPORT CFStringRef CFURLCopyUserName(CFURLRef self);
CF_EXPORT CFInteger CFURLGetPortNumber(CFURLRef self);
CF_EXPORT Boolean CFURLHasDirectoryPath(CFURLRef self);

CF_EXPORT CFURLRef CFURLCreateCopyAppendingPathComponent(CFAllocatorRef allocator, CFURLRef self, CFStringRef pathComponent, Boolean isDirectory);
CF_EXPORT CFURLRef CFURLCreateCopyAppendingPathExtension(CFAllocatorRef allocator, CFURLRef self, CFStringRef extension);
CF_EXPORT CFURLRef CFURLCreateCopyDeletingLastPathComponent(CFAllocatorRef allocator, CFURLRef self);
CF_EXPORT CFURLRef CFURLCreateCopyDeletingPathExtension(CFAllocatorRef allocator, CFURLRef self);
CF_EXPORT CFDataRef CFURLCreateData(CFAllocatorRef allocator, CFURLRef self, CFStringEncoding encoding, Boolean escapeWhitespace);
CF_EXPORT CFStringRef CFURLCreateStringByAddingPercentEscapes(CFAllocatorRef allocator, CFStringRef string, CFStringRef charactersToLeaveUnescaped, CFStringRef charactersToBeEscaped, CFStringEncoding encoding);
CF_EXPORT CFStringRef CFURLCreateStringByReplacingPercentEscapes(CFAllocatorRef allocator, CFStringRef string, CFStringRef charactersToLeaveEscaped);
CF_EXPORT CFStringRef CFURLCreateStringByReplacingPercentEscapesUsingEncoding(CFAllocatorRef allocator, CFStringRef string, CFStringRef charactersToLeaveEscaped, CFStringEncoding encoding);
CF_EXPORT CFRange CFURLGetByteRangeForComponent(CFURLRef self, CFURLComponentType component, CFRange *rangeIncludingSeparators);
CF_EXPORT CFIndex CFURLGetBytes(CFURLRef self, uint8_t *buffer, CFIndex bufferLength);
CF_EXPORT Boolean CFURLGetFileSystemRepresentation(CFURLRef self, Boolean resolveAgainstBase, uint8_t *buffer, CFIndex bufferLength);

#endif /* _CFURL_H_ */
