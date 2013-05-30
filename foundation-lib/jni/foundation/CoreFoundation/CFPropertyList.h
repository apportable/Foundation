//
// CFPropertyList.h
//
// Copyright Apportable Inc. All rights reserved.
//
// Portions of this project are derived from the CoreFoundation
// implementation from the Cocotron project.
//
// Copyright (c) 2008-2009 Christopher J. W. Lloyd
//

#ifndef _CFPROPERTYLIST_H_
#define _CFPROPERTYLIST_H_

#import <CoreFoundation/CFBase.h>
#import <CoreFoundation/CFStream.h>

typedef enum  {
    kCFPropertyListOpenStepFormat    = 1,
    kCFPropertyListXMLFormat_v1_0    = 100,
    kCFPropertyListBinaryFormat_v1_0 = 200,
} CFPropertyListFormat;

typedef enum  {
   kCFPropertyListImmutable                  = 0, 
   kCFPropertyListMutableContainers          = 1, 
   kCFPropertyListMutableContainersAndLeaves = 2, 
} CFPropertyListMutabilityOptions;

CF_EXPORT CFPropertyListRef CFPropertyListCreateFromStream(CFAllocatorRef allocator, CFReadStreamRef stream, CFIndex length, CFOptionFlags options, CFPropertyListFormat *format, CFStringRef *error);
CF_EXPORT CFPropertyListRef CFPropertyListCreateFromXMLData(CFAllocatorRef allocator, CFDataRef data, CFOptionFlags options, CFStringRef *error);

CF_EXPORT CFPropertyListRef CFPropertyListCreateDeepCopy(CFAllocatorRef allocator, CFPropertyListRef self, CFOptionFlags options);

CF_EXPORT CFDataRef CFPropertyListCreateXMLData(CFAllocatorRef allocator, CFPropertyListRef self);
CF_EXPORT Boolean CFPropertyListIsValid(CFPropertyListRef self, CFPropertyListFormat format);
CF_EXPORT CFIndex CFPropertyListWriteToStream(CFPropertyListRef self, CFWriteStreamRef stream, CFPropertyListFormat format, CFStringRef *error);

#endif /* _CFPROPERTYLIST_H_ */
