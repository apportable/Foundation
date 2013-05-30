#ifndef __CFHOST__
#define __CFHOST__

#include <CFNetwork/CFNetworkDefs.h>
#include <CoreFoundation/CoreFoundation.h>
#include <CoreFoundation/CFStream.h>

__BEGIN_DECLS

typedef struct __CFHost* CFHostRef;

extern const SInt32 kCFStreamErrorDomainNetDB;
extern const SInt32 kCFStreamErrorDomainSystemConfiguration;

typedef enum  {
  kCFHostAddresses    = 0,
  kCFHostNames        = 1,
  kCFHostReachability = 2
} CFHostInfoType;

typedef struct {
    CFIndex version;
    void *info;
    CFAllocatorRetainCallBack retain;
    CFAllocatorReleaseCallBack release;
    CFAllocatorCopyDescriptionCallBack copyDescription;
} CFHostClientContext;

typedef void  (*CFHostClientCallBack)(CFHostRef theHost, CFHostInfoType typeInfo, const CFStreamError *error, void *info);
CFN_EXPORT CFTypeID CFHostGetTypeID(void);
CFN_EXPORT CFHostRef CFHostCreateWithName( CFAllocatorRef allocator, CFStringRef hostname);
CFN_EXPORT CFHostRef CFHostCreateWithAddress( CFAllocatorRef allocator, CFDataRef addr);
CFN_EXPORT CFHostRef CFHostCreateCopy( CFAllocatorRef alloc, CFHostRef host);
CFN_EXPORT Boolean CFHostStartInfoResolution( CFHostRef theHost, CFHostInfoType info, CFStreamError * error);
CFN_EXPORT CFArrayRef CFHostGetAddressing( CFHostRef theHost, Boolean * hasBeenResolved);
CFN_EXPORT CFArrayRef CFHostGetNames( CFHostRef theHost, Boolean * hasBeenResolved);
CFN_EXPORT CFDataRef CFHostGetReachability( CFHostRef theHost, Boolean * hasBeenResolved);
CFN_EXPORT void CFHostCancelInfoResolution( CFHostRef theHost, CFHostInfoType info);
CFN_EXPORT Boolean CFHostSetClient( CFHostRef theHost, CFHostClientCallBack clientCB, CFHostClientContext * clientContext);
CFN_EXPORT void CFHostScheduleWithRunLoop( CFHostRef theHost, CFRunLoopRef runLoop, CFStringRef runLoopMode);
CFN_EXPORT void CFHostUnscheduleFromRunLoop( CFHostRef theHost, CFRunLoopRef runLoop, CFStringRef runLoopMode);

__END_DECLS

#endif /* __CFHOST__ */

