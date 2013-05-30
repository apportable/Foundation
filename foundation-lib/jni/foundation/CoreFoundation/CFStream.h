//
// CFStream.h
//
// Copyright Apportable Inc. All rights reserved.
//

#ifndef _CFSTREAM_H_
#define _CFSTREAM_H_

#include <CoreFoundation/CFBase.h>
#include <CoreFoundation/CFString.h>
#include <CoreFoundation/CFDictionary.h>
#include <CoreFoundation/CFRunLoop.h>
#include <CoreFoundation/CFSocket.h>
#include <CoreFoundation/CFError.h>
#include <CoreFoundation/CFURL.h>

__BEGIN_DECLS

typedef struct __CFReadStream *CFReadStreamRef;
typedef struct __CFWriteStream *CFWriteStreamRef;

enum {
    kCFStreamEventNone = 0,
    kCFStreamEventOpenCompleted = 1,
    kCFStreamEventHasBytesAvailable = 2,
    kCFStreamEventCanAcceptBytes = 4, 
    kCFStreamEventErrorOccurred = 8,
    kCFStreamEventEndEncountered = 16
};
typedef CFOptionFlags CFStreamEventType;


enum {
    kCFStreamStatusNotOpen = 0,
    kCFStreamStatusOpening,
    kCFStreamStatusOpen,
    kCFStreamStatusReading,
    kCFStreamStatusWriting,
    kCFStreamStatusAtEnd,
    kCFStreamStatusClosed,
    kCFStreamStatusError
};
typedef CFIndex CFStreamStatus;

enum {
    kCFStreamErrorDomainCustom = -1,
    kCFStreamErrorDomainPOSIX = 1,
    kCFStreamErrorDomainMacOSStatus
};
typedef CFIndex CFStreamErrorDomain;

typedef struct {
    CFIndex domain; 
    SInt32 error;
} CFStreamError;

typedef struct {
    CFIndex version;
    void *info;
    void *(*retain)(void *info);
    void (*release)(void *info);
    CFStringRef (*copyDescription)(void *info);
} CFStreamClientContext;

typedef void (*CFReadStreamClientCallBack)(CFReadStreamRef stream, CFStreamEventType type, void *clientCallBackInfo);
typedef void (*CFWriteStreamClientCallBack)(CFWriteStreamRef stream, CFStreamEventType type, void *clientCallBackInfo);

extern const CFStringRef kCFStreamPropertyDataWritten;
extern const CFStringRef kCFStreamPropertyAppendToFile;
extern const CFStringRef kCFStreamPropertySocketNativeHandle;
extern const CFStringRef kCFStreamPropertySocketRemoteHostName;
extern const CFStringRef kCFStreamPropertySocketRemotePortNumber;

extern CFTypeID CFReadStreamGetTypeID(void);
extern CFTypeID CFWriteStreamGetTypeID(void);

extern CFReadStreamRef CFReadStreamCreateWithBytesNoCopy(CFAllocatorRef alloc, const UInt8 *bytes, CFIndex length, CFAllocatorRef bytesDeallocator);
extern CFWriteStreamRef CFWriteStreamCreateWithBuffer(CFAllocatorRef alloc, UInt8 *buffer, CFIndex bufferCapacity);
extern CFWriteStreamRef CFWriteStreamCreateWithAllocatedBuffers(CFAllocatorRef alloc, CFAllocatorRef bufferAllocator);
extern CFReadStreamRef CFReadStreamCreateWithFile(CFAllocatorRef alloc, CFURLRef fileURL);
extern CFWriteStreamRef CFWriteStreamCreateWithFile(CFAllocatorRef alloc, CFURLRef fileURL);
extern void CFStreamCreateBoundPair(CFAllocatorRef alloc, CFReadStreamRef *readStream, CFWriteStreamRef *writeStream, CFIndex transferBufferSize);
extern void CFStreamCreatePairWithSocket(CFAllocatorRef alloc, CFSocketNativeHandle sock, CFReadStreamRef *readStream, CFWriteStreamRef *writeStream);
extern void CFStreamCreatePairWithSocketToHost(CFAllocatorRef alloc, CFStringRef host, UInt32 port, CFReadStreamRef *readStream, CFWriteStreamRef *writeStream);
extern void CFStreamCreatePairWithPeerSocketSignature(CFAllocatorRef alloc, const CFSocketSignature *signature, CFReadStreamRef *readStream, CFWriteStreamRef *writeStream);
extern CFStreamStatus CFReadStreamGetStatus(CFReadStreamRef stream);
extern CFStreamStatus CFWriteStreamGetStatus(CFWriteStreamRef stream);
extern CFErrorRef CFReadStreamCopyError(CFReadStreamRef stream);
extern CFErrorRef CFWriteStreamCopyError(CFWriteStreamRef stream);
extern Boolean CFReadStreamOpen(CFReadStreamRef stream);
extern Boolean CFWriteStreamOpen(CFWriteStreamRef stream);
extern void CFReadStreamClose(CFReadStreamRef stream);
extern void CFWriteStreamClose(CFWriteStreamRef stream);
extern Boolean CFReadStreamHasBytesAvailable(CFReadStreamRef stream);
extern CFIndex CFReadStreamRead(CFReadStreamRef stream, UInt8 *buffer, CFIndex bufferLength);
extern const UInt8 *CFReadStreamGetBuffer(CFReadStreamRef stream, CFIndex maxBytesToRead, CFIndex *numBytesRead);
extern Boolean CFWriteStreamCanAcceptBytes(CFWriteStreamRef stream);
extern CFIndex CFWriteStreamWrite(CFWriteStreamRef stream, const UInt8 *buffer, CFIndex bufferLength);
extern CFTypeRef CFReadStreamCopyProperty(CFReadStreamRef stream, CFStringRef propertyName);
extern CFTypeRef CFWriteStreamCopyProperty(CFWriteStreamRef stream, CFStringRef propertyName);
extern Boolean CFReadStreamSetProperty(CFReadStreamRef stream, CFStringRef propertyName, CFTypeRef propertyValue);
extern Boolean CFWriteStreamSetProperty(CFWriteStreamRef stream, CFStringRef propertyName, CFTypeRef propertyValue);
extern Boolean CFReadStreamSetClient(CFReadStreamRef stream, CFOptionFlags streamEvents, CFReadStreamClientCallBack clientCB, CFStreamClientContext *clientContext);
extern Boolean CFWriteStreamSetClient(CFWriteStreamRef stream, CFOptionFlags streamEvents, CFWriteStreamClientCallBack clientCB, CFStreamClientContext *clientContext);
extern void CFReadStreamScheduleWithRunLoop(CFReadStreamRef stream, CFRunLoopRef runLoop, CFStringRef runLoopMode);
extern void CFWriteStreamScheduleWithRunLoop(CFWriteStreamRef stream, CFRunLoopRef runLoop, CFStringRef runLoopMode);
extern void CFReadStreamUnscheduleFromRunLoop(CFReadStreamRef stream, CFRunLoopRef runLoop, CFStringRef runLoopMode);
extern void CFWriteStreamUnscheduleFromRunLoop(CFWriteStreamRef stream, CFRunLoopRef runLoop, CFStringRef runLoopMode);
extern CFStreamError CFReadStreamGetError(CFReadStreamRef stream);
extern CFStreamError CFWriteStreamGetError(CFWriteStreamRef stream);

__END_DECLS
    
#endif /* _CFSTREAM_H_ */