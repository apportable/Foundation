
#ifndef __CFNETSERVICES__
#define __CFNETSERVICES__

#include <CFNetwork/CFNetworkDefs.h>
#include <CoreFoundation/CFBase.h>
#include <CoreFoundation/CFStream.h>

__BEGIN_DECLS

typedef struct __CFNetService*		  CFNetServiceRef;
typedef struct __CFNetServiceMonitor*   CFNetServiceMonitorRef;
typedef struct __CFNetServiceBrowser*   CFNetServiceBrowserRef;

CFN_EXPORT const SInt32 kCFStreamErrorDomainMach;
CFN_EXPORT const SInt32 kCFStreamErrorDomainNetServices;

typedef enum  {
    kCFNetServicesErrorUnknown             = -72000L,
    kCFNetServicesErrorCollision           = -72001L,
    kCFNetServicesErrorNotFound            = -72002L,
    kCFNetServicesErrorInProgress          = -72003L,
    kCFNetServicesErrorBadArgument         = -72004L,
    kCFNetServicesErrorCancel              = -72005L,
    kCFNetServicesErrorInvalid             = -72006L,
    kCFNetServicesErrorTimeout             = -72007L
} CFNetServicesError;

typedef enum {
    kCFNetServiceMonitorTXT                = 1
} CFNetServiceMonitorType;

enum {
    kCFNetServiceFlagNoAutoRename          = 1
};

enum {
    kCFNetServiceFlagMoreComing            = 1,
    kCFNetServiceFlagIsDomain              = 2,
    kCFNetServiceFlagIsDefault             = 4,
    kCFNetServiceFlagIsRegistrationDomain  = 4,
    kCFNetServiceFlagRemove                = 8 
};

struct CFNetServiceClientContext {
    CFIndex version;
    void *info;
    CFAllocatorRetainCallBack retain;
    CFAllocatorReleaseCallBack release;
    CFAllocatorCopyDescriptionCallBack copyDescription;
};
typedef struct CFNetServiceClientContext CFNetServiceClientContext;


extern const SInt32 kCFStreamErrorDomainMach;
extern const SInt32 kCFStreamErrorDomainNetServices;

typedef void (*CFNetServiceClientCallBack)(CFNetServiceRef theService, CFStreamError *error, void *info);
typedef void (*CFNetServiceMonitorClientCallBack)(CFNetServiceMonitorRef theMonitor, CFNetServiceRef theService, CFNetServiceMonitorType typeInfo, CFDataRef rdata, CFStreamError *error, void *info);
typedef void (*CFNetServiceBrowserClientCallBack)(CFNetServiceBrowserRef browser, CFOptionFlags flags, CFTypeRef domainOrService, CFStreamError *error, void *info);
CFN_EXPORT CFTypeID CFNetServiceGetTypeID(void);
CFN_EXPORT CFTypeID CFNetServiceMonitorGetTypeID(void);
CFN_EXPORT CFTypeID CFNetServiceBrowserGetTypeID(void);
CFN_EXPORT CFNetServiceRef CFNetServiceCreate(CFAllocatorRef alloc, CFStringRef domain, CFStringRef serviceType, CFStringRef name, SInt32 port);
CFN_EXPORT CFNetServiceRef CFNetServiceCreateCopy(CFAllocatorRef alloc, CFNetServiceRef service);
CFN_EXPORT CFStringRef CFNetServiceGetDomain(CFNetServiceRef theService);
CFN_EXPORT CFStringRef CFNetServiceGetType(CFNetServiceRef theService);
CFN_EXPORT CFStringRef CFNetServiceGetName(CFNetServiceRef theService);
CFN_EXPORT Boolean CFNetServiceRegisterWithOptions(CFNetServiceRef theService, CFOptionFlags options, CFStreamError * error);
CFN_EXPORT Boolean CFNetServiceResolveWithTimeout(CFNetServiceRef theService, CFTimeInterval timeout, CFStreamError * error);
CFN_EXPORT void CFNetServiceCancel(CFNetServiceRef theService);
CFN_EXPORT CFStringRef CFNetServiceGetTargetHost(CFNetServiceRef theService);
CFN_EXPORT SInt32 CFNetServiceGetPortNumber(CFNetServiceRef theService);
CFN_EXPORT CFArrayRef CFNetServiceGetAddressing(CFNetServiceRef theService);
CFN_EXPORT CFDataRef CFNetServiceGetTXTData(CFNetServiceRef theService);
CFN_EXPORT Boolean CFNetServiceSetTXTData(CFNetServiceRef theService, CFDataRef txtRecord);
CFN_EXPORT CFDictionaryRef CFNetServiceCreateDictionaryWithTXTData(CFAllocatorRef alloc, CFDataRef txtRecord);
CFN_EXPORT CFDataRef CFNetServiceCreateTXTDataWithDictionary(CFAllocatorRef alloc, CFDictionaryRef keyValuePairs);
CFN_EXPORT Boolean CFNetServiceSetClient(CFNetServiceRef theService, CFNetServiceClientCallBack clientCB, CFNetServiceClientContext * clientContext);
CFN_EXPORT void CFNetServiceScheduleWithRunLoop(CFNetServiceRef theService, CFRunLoopRef runLoop, CFStringRef runLoopMode);
CFN_EXPORT void CFNetServiceUnscheduleFromRunLoop(CFNetServiceRef theService, CFRunLoopRef runLoop, CFStringRef runLoopMode);
CFN_EXPORT CFNetServiceMonitorRef CFNetServiceMonitorCreate(CFAllocatorRef alloc, CFNetServiceRef theService, CFNetServiceMonitorClientCallBack clientCB, CFNetServiceClientContext * clientContext);
CFN_EXPORT void CFNetServiceMonitorInvalidate(CFNetServiceMonitorRef monitor);
CFN_EXPORT Boolean CFNetServiceMonitorStart(CFNetServiceMonitorRef monitor, CFNetServiceMonitorType recordType, CFStreamError * error);
CFN_EXPORT void CFNetServiceMonitorStop(CFNetServiceMonitorRef monitor, CFStreamError * error);
CFN_EXPORT void CFNetServiceMonitorScheduleWithRunLoop(CFNetServiceMonitorRef monitor, CFRunLoopRef runLoop, CFStringRef runLoopMode);
CFN_EXPORT void CFNetServiceMonitorUnscheduleFromRunLoop(CFNetServiceMonitorRef monitor, CFRunLoopRef runLoop, CFStringRef runLoopMode);
CFN_EXPORT CFNetServiceBrowserRef CFNetServiceBrowserCreate(CFAllocatorRef alloc, CFNetServiceBrowserClientCallBack clientCB, CFNetServiceClientContext * clientContext);
CFN_EXPORT void CFNetServiceBrowserInvalidate(CFNetServiceBrowserRef browser);
CFN_EXPORT Boolean CFNetServiceBrowserSearchForDomains(CFNetServiceBrowserRef browser, Boolean registrationDomains, CFStreamError * error);
CFN_EXPORT Boolean CFNetServiceBrowserSearchForServices(CFNetServiceBrowserRef browser, CFStringRef domain, CFStringRef serviceType, CFStreamError * error);
CFN_EXPORT void CFNetServiceBrowserStopSearch(CFNetServiceBrowserRef browser, CFStreamError * error);
CFN_EXPORT void CFNetServiceBrowserScheduleWithRunLoop(CFNetServiceBrowserRef browser, CFRunLoopRef runLoop, CFStringRef runLoopMode);
CFN_EXPORT void CFNetServiceBrowserUnscheduleFromRunLoop(CFNetServiceBrowserRef browser, CFRunLoopRef runLoop, CFStringRef runLoopMode);
CFN_EXPORT Boolean CFNetServiceRegister(CFNetServiceRef theService, CFStreamError * error);
CFN_EXPORT Boolean CFNetServiceResolve(CFNetServiceRef theService, CFStreamError * error);
CFN_EXPORT CFStringRef CFNetServiceGetProtocolSpecificInformation(CFNetServiceRef theService);
CFN_EXPORT void CFNetServiceSetProtocolSpecificInformation(CFNetServiceRef theService, CFStringRef theInfo);

__END_DECLS

#endif /* __CFNETSERVICES__ */

