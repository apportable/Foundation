//
// CFRuntime.h
//
// Copyright Apportable Inc. All rights reserved.
//

#ifndef _CFRUNTIME_H_
#define _CFRUNTIME_H_

#include <CoreFoundation/CFBase.h>

__BEGIN_DECLS

static const CFTypeID _kCFRuntimeNotATypeID = 0;

typedef struct
{
    CFIndex version;
    const char* className;
    void (*init)(CFTypeRef cf);
    CFTypeRef (*copy)(CFAllocatorRef allocator, CFTypeRef cf);
    void (*finalize)(CFTypeRef cf);
    Boolean (*equal)(CFTypeRef cf1, CFTypeRef cf2);
    CFHashCode (*hash)(CFTypeRef cf);
    CFStringRef (*copyFormattingDesc)(CFTypeRef cf, CFDictionaryRef formatOptions);
    CFStringRef (*copyDebugDesc)(CFTypeRef cf);
} CFRuntimeClass;

typedef struct
{
    const void* _isa;
    CFTypeID _typeID;
} CFRuntimeBase;

extern CFTypeID _CFRuntimeRegisterClass(const CFRuntimeClass* const cls);

extern CFTypeRef _CFRuntimeCreateInstance(CFAllocatorRef allocator,
                                          CFTypeID typeID, CFUInteger extraBytes,
                                          unsigned char* category);

extern const CFRuntimeClass* _CFRuntimeGetClassWithTypeID(CFTypeID typeID);

__END_DECLS

#endif /* _CFRUNTIME_H_ */
