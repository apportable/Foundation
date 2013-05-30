//
// CFSocket.h
//
// Copyright Apportable Inc. All rights reserved.
//

#ifndef _CFSOCKET_H_
#define _CFSOCKET_H_

#include <CoreFoundation/CFBase.h>

__BEGIN_DECLS

typedef int CFSocketNativeHandle;
enum {
    kCFSocketSuccess = 0,
    kCFSocketError   = -1,
    kCFSocketTimeout = -2
};
typedef CFIndex CFSocketError;

enum {
    kCFSocketNoCallBack      = 0,
    kCFSocketReadCallBack    = 1,
    kCFSocketAcceptCallBack  = 2,
    kCFSocketDataCallBack    = 3,
    kCFSocketConnectCallBack = 4,
    kCFSocketWriteCallBack   = 8
};
typedef CFOptionFlags CFSocketCallBackType;

typedef struct __CFSocket *CFSocketRef;

typedef struct {
    SInt32 protocolFamily;
    SInt32 socketType;
    SInt32 protocol;
    CFDataRef address;
} CFSocketSignature;

typedef struct {
    CFIndex version;
    void *info;
    const void *(*retain)(const void *info);
    void (*release)(const void *info);
    CFStringRef (*copyDescription)(const void *info);
} CFSocketContext;

enum {
    kCFSocketAutomaticallyReenableReadCallBack   = 1,
    kCFSocketAutomaticallyReenableAcceptCallBack = 2,
    kCFSocketAutomaticallyReenableDataCallBack   = 3,
    kCFSocketAutomaticallyReenableWriteCallBack  = 8,
    kCFSocketLeaveErrors                         = 64,
    kCFSocketCloseOnInvalidate                   = 128
};

typedef void (*CFSocketCallBack)(CFSocketRef s, CFSocketCallBackType type, CFDataRef address, const void *data, void *info);

extern const CFStringRef kCFSocketCommandKey;
extern const CFStringRef kCFSocketNameKey;
extern const CFStringRef kCFSocketValueKey;
extern const CFStringRef kCFSocketResultKey;
extern const CFStringRef kCFSocketErrorKey;
extern const CFStringRef kCFSocketRegisterCommand;
extern const CFStringRef kCFSocketRetrieveCommand;

extern CFTypeID CFSocketGetTypeID(void);
extern CFSocketRef CFSocketCreate(CFAllocatorRef allocator, SInt32 protocolFamily, SInt32 socketType, SInt32 protocol, CFOptionFlags callBackTypes, CFSocketCallBack callout, const CFSocketContext *context);
extern CFSocketRef CFSocketCreateWithNative(CFAllocatorRef allocator, CFSocketNativeHandle sock, CFOptionFlags callBackTypes, CFSocketCallBack callout, const CFSocketContext *context);
extern CFSocketRef CFSocketCreateWithSocketSignature(CFAllocatorRef allocator, const CFSocketSignature *signature, CFOptionFlags callBackTypes, CFSocketCallBack callout, const CFSocketContext *context);
extern CFSocketRef CFSocketCreateConnectedToSocketSignature(CFAllocatorRef allocator, const CFSocketSignature *signature, CFOptionFlags callBackTypes, CFSocketCallBack callout, const CFSocketContext *context, CFTimeInterval timeout);
extern CFSocketError CFSocketSetAddress(CFSocketRef s, CFDataRef address);
extern CFSocketError CFSocketConnectToAddress(CFSocketRef s, CFDataRef address, CFTimeInterval timeout);
extern void CFSocketInvalidate(CFSocketRef s);
extern Boolean CFSocketIsValid(CFSocketRef s);
extern CFDataRef CFSocketCopyAddress(CFSocketRef s);
extern CFDataRef CFSocketCopyPeerAddress(CFSocketRef s);
extern void CFSocketGetContext(CFSocketRef s, CFSocketContext *context);
extern CFSocketNativeHandle CFSocketGetNative(CFSocketRef s);
extern CFRunLoopSourceRef CFSocketCreateRunLoopSource(CFAllocatorRef allocator, CFSocketRef s, CFIndex order);
extern CFOptionFlags CFSocketGetSocketFlags(CFSocketRef s);
extern void CFSocketSetSocketFlags(CFSocketRef s, CFOptionFlags flags);
extern void CFSocketDisableCallBacks(CFSocketRef s, CFOptionFlags callBackTypes);
extern void CFSocketEnableCallBacks(CFSocketRef s, CFOptionFlags callBackTypes);
extern CFSocketError CFSocketSendData(CFSocketRef s, CFDataRef address, CFDataRef data, CFTimeInterval timeout);
extern CFSocketError CFSocketRegisterValue(const CFSocketSignature *nameServerSignature, CFTimeInterval timeout, CFStringRef name, CFPropertyListRef value);
extern CFSocketError CFSocketCopyRegisteredValue(const CFSocketSignature *nameServerSignature, CFTimeInterval timeout, CFStringRef name, CFPropertyListRef *value, CFDataRef *nameServerAddress);
extern CFSocketError CFSocketRegisterSocketSignature(const CFSocketSignature *nameServerSignature, CFTimeInterval timeout, CFStringRef name, const CFSocketSignature *signature);
extern CFSocketError CFSocketCopyRegisteredSocketSignature(const CFSocketSignature *nameServerSignature, CFTimeInterval timeout, CFStringRef name, CFSocketSignature *signature, CFDataRef *nameServerAddress);
extern CFSocketError CFSocketUnregister(const CFSocketSignature *nameServerSignature, CFTimeInterval timeout, CFStringRef name);
extern void CFSocketSetDefaultNameRegistryPortNumber(UInt16 port);
extern UInt16 CFSocketGetDefaultNameRegistryPortNumber(void);

__END_DECLS

#endif /* _CFSOCKET_H_ */
