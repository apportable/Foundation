//
//  CFNetServices.c
//  CFNetwork
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#include "CFBase.h"
#include "CFRuntime.h"
#include "CFNetServices.h"
#include "dns_sd.h"
#include <libkern/OSAtomic.h>

/* extern */ const SInt32 kCFStreamErrorDomainNetServices = 10;
/* extern */ const SInt32 kCFStreamErrorDomainMach = 11;

struct __CFNetService {
    CFRuntimeBase _base;
    CFStringRef domain;
    CFStringRef serviceType;
    CFStringRef name;
    UInt32 port;
    CFDataRef txtData;
    DNSServiceRef service;
    DNSServiceRef resolver;
};

struct __CFNetServiceMonitor {
    CFRuntimeBase _base;
};

struct __CFNetServiceBrowser {
    CFRuntimeBase _base;
};

static void __CFNetServiceDeallocate(CFTypeRef cf) {
    struct __CFNetService *service = (struct __CFNetService *)cf;
    if (service->domain != NULL) {
        CFRelease(service->domain);
    }
    if (service->serviceType != NULL) {
        CFRelease(service->serviceType);
    }
    if (service->name != NULL) {
        CFRelease(service->name);
    }
}

static void __CFNetServiceMonitorDeallocate(CFTypeRef cf) {
    struct __CFNetServiceMonitor *monitor = (struct __CFNetServiceMonitor *)cf;
}

static void __CFNetServiceBrowserDeallocate(CFTypeRef cf) {
    struct __CFNetServiceBrowser *browser = (struct __CFNetServiceBrowser *)cf;
}

static CFTypeID __kCFNetServiceTypeID = _kCFRuntimeNotATypeID;
static CFTypeID __kCFNetServiceMonitorTypeID = _kCFRuntimeNotATypeID;
static CFTypeID __kCFNetServiceBrowserTypeID = _kCFRuntimeNotATypeID;

static const CFRuntimeClass __CFNetServiceClass = {
    _kCFRuntimeScannedObject,
    "CFNetService",
    NULL,
    NULL,
    __CFNetServiceDeallocate,
    NULL,
    NULL,
    NULL,
    NULL
};

static const CFRuntimeClass __CFNetServiceMonitorClass = {
    _kCFRuntimeScannedObject,
    "CFNetServiceMonitor",
    NULL,
    NULL,
    __CFNetServiceMonitorDeallocate,
    NULL,
    NULL,
    NULL,
    NULL
};

static const CFRuntimeClass __CFNetServiceBrowserClass = {
    _kCFRuntimeScannedObject,
    "CFNetServiceBrowser",
    NULL,
    NULL,
    __CFNetServiceBrowserDeallocate,
    NULL,
    NULL,
    NULL,
    NULL
};


static void __CFNetServiceInitialize(void) {
    __kCFNetServiceTypeID = _CFRuntimeRegisterClass(&__CFNetServiceClass);
}

static void __CFNetServiceMonitorInitialize(void) {
    __kCFNetServiceMonitorTypeID = _CFRuntimeRegisterClass(&__CFNetServiceMonitorClass);
}

static void __CFNetServiceBrowserInitialize(void) {
    __kCFNetServiceBrowserTypeID = _CFRuntimeRegisterClass(&__CFNetServiceBrowserClass);
}

CFTypeID CFNetServiceGetTypeID(void) {
    if (__kCFNetServiceTypeID == _kCFRuntimeNotATypeID) {
        __CFNetServiceInitialize();
    }
    return __kCFNetServiceTypeID;
}

CFTypeID CFNetServiceMonitorGetTypeID(void) {
    if (__kCFNetServiceMonitorTypeID == _kCFRuntimeNotATypeID) {
        __CFNetServiceMonitorInitialize();
    }
    return __kCFNetServiceMonitorTypeID;
}

CFTypeID CFNetServiceBrowserGetTypeID(void) {
    if (__kCFNetServiceBrowserTypeID == _kCFRuntimeNotATypeID) {
        __CFNetServiceBrowserInitialize();
    }
    return __kCFNetServiceBrowserTypeID;
}

static struct __CFNetService *_CFNetServiceCreate(CFAllocatorRef allocator) {
    CFIndex size = sizeof(struct __CFNetService) - sizeof(CFRuntimeBase);
    return (struct __CFNetService *)_CFRuntimeCreateInstance(allocator, CFNetServiceGetTypeID(), size, NULL);
}

static struct __CFNetServiceMonitor *_CFNetServiceMonitorCreate(CFAllocatorRef allocator) {
    CFIndex size = sizeof(struct __CFNetServiceMonitor) - sizeof(CFRuntimeBase);
    return (struct __CFNetServiceMonitor *)_CFRuntimeCreateInstance(allocator, CFNetServiceMonitorGetTypeID(), size, NULL);
}

static struct __CFNetServiceBrowser *_CFNetServiceBrowserCreate(CFAllocatorRef allocator) {
    CFIndex size = sizeof(struct __CFNetServiceBrowser) - sizeof(CFRuntimeBase);
    return (struct __CFNetServiceBrowser *)_CFRuntimeCreateInstance(allocator, CFNetServiceBrowserGetTypeID(), size, NULL);
}

static void (*multicastLock)() = NULL;
static void (*multicastUnlock)() = NULL;
static int32_t lockState = 0;

static void _CFNetServiceMulticastAquire() {
    if (OSAtomicIncrement32(&lockState) == 1) {
        if (multicastLock != NULL) {
            multicastLock();
        }
    }
}

static void _CFNetServiceMulticastRelinquish() {
    if (OSAtomicDecrement32(&lockState) == 0) {
        if (multicastUnlock != NULL) {
            multicastUnlock();
        }
    }
}

void _CFNetServiceRegisterMulticastLock(void (*lock)(), void (*unlock)()) {
    multicastLock = lock;
    multicastUnlock = unlock;
}

CFNetServiceRef CFNetServiceCreate(CFAllocatorRef alloc, CFStringRef domain, CFStringRef serviceType, CFStringRef name, UInt32 port) {
    struct __CFNetService *service = _CFNetServiceCreate(alloc);
    if (domain != NULL) {
        service->domain = CFStringCreateCopy(alloc, domain);
    }
    if (serviceType != NULL) {
        service->serviceType = CFStringCreateCopy(alloc, serviceType);
    }
    if (name != NULL) {
        service->name = CFStringCreateCopy(alloc, name);
    }
    service->port = port;
    return service;
}

CFNetServiceRef CFNetServiceCreateCopy(CFAllocatorRef alloc, CFNetServiceRef service) {
    return CFNetServiceCreate(alloc, service->domain, service->serviceType, service->name, service->port);
}

CFStringRef CFNetServiceGetDomain(CFNetServiceRef theService) {
    return theService->domain;
}

CFStringRef CFNetServiceGetType(CFNetServiceRef theService) {
    return theService->serviceType;
}

CFStringRef CFNetServiceGetName(CFNetServiceRef theService) {
    return theService->name;
}

static inline Boolean _CFUTF8String(const char **str, char *buffer, size_t sz, CFStringRef string) {
    if (string == NULL) {
        *str = NULL;
        return true;
    }
    *str = CFStringGetCStringPtr(string, kCFStringEncodingUTF8);
    if (*str == NULL) {
        if (CFStringGetCString(string, buffer, sz, kCFStringEncodingUTF8)) {
            *str = buffer;
        }
        if (*str == NULL) {
            
            return false;
        }
    }
    return true;
}

#define BUFSIZE 256

static void _CFNetServiceRegistered(DNSServiceRef sdRef, DNSServiceFlags flags, DNSServiceErrorType errorCode, const char *name, const char *regtype, const char *domain, void *context) {
    CFNetServiceRef theService = (CFNetServiceRef)context;

    CFRelease(theService); // balance registration
}

Boolean CFNetServiceRegisterWithOptions(CFNetServiceRef theService, CFOptionFlags options, CFStreamError *error) {
    char nameBuffer[BUFSIZE];
    char typeBuffer[BUFSIZE];
    char domainBuffer[BUFSIZE];

    const char *name = NULL;
    const char *type = NULL;
    const char *domain = NULL;

    if (!_CFUTF8String(&name, (char *)nameBuffer, BUFSIZE, theService->name)) {
        // TODO: populate error here
        return false;
    }
    if (!_CFUTF8String(&type, (char *)typeBuffer, BUFSIZE, theService->serviceType)) {
        // TODO: populate error here
        return false;
    }
    if (!_CFUTF8String(&domain, (char *)domainBuffer, BUFSIZE, theService->domain)) {
        // TODO: populate error here
        return false;
    }
    
    uint16_t txtLen = 0;
    const void *txtRecord = NULL;
    if (theService->txtData != NULL) {
        txtRecord = CFDataGetBytePtr(theService->txtData);
        txtLen = CFDataGetLength(theService->txtData);
    }
    CFRetain(theService); // retain across registration
    _CFNetServiceMulticastAquire();
    DNSServiceErrorType err = DNSServiceRegister(&theService->service, 0, kDNSServiceInterfaceIndexAny, name, type, domain, NULL,
                                                 htons(theService->port), txtLen, txtRecord, &_CFNetServiceRegistered, theService);

    return err == kDNSServiceErr_NoError;
}

static void _CFNetServiceResolved(DNSServiceRef sdRef, DNSServiceFlags flags, uint32_t interfaceIndex, DNSServiceErrorType errorCode,
                                  const char *fullname, const char *hosttarget, uint16_t port, uint16_t txtLen,
                                  const unsigned char *txtRecord, void *context) {
    CFNetServiceRef theService = (CFNetServiceRef)context;
    CFRelease(theService); // balance resolve
}

Boolean CFNetServiceResolveWithTimeout(CFNetServiceRef theService, CFTimeInterval timeout, CFStreamError *error) {
    char nameBuffer[BUFSIZE];
    char typeBuffer[BUFSIZE];
    char domainBuffer[BUFSIZE];

    const char *name = NULL;
    const char *type = NULL;
    const char *domain = NULL;

    if (!_CFUTF8String(&name, (char *)nameBuffer, BUFSIZE, theService->name)) {
        // TODO: populate error here
        return false;
    }
    if (!_CFUTF8String(&type, (char *)typeBuffer, BUFSIZE, theService->serviceType)) {
        // TODO: populate error here
        return false;
    }
    if (!_CFUTF8String(&domain, (char *)domainBuffer, BUFSIZE, theService->domain)) {
        // TODO: populate error here
        return false;
    }

    CFRetain(theService); // retain across resolution
    _CFNetServiceMulticastAquire();
    DNSServiceErrorType err = DNSServiceResolve(&theService->resolver, 0, kDNSServiceInterfaceIndexAny,
                                                name, type, domain, &_CFNetServiceResolved, theService);
    return err == kDNSServiceErr_NoError;
}

void CFNetServiceCancel(CFNetServiceRef theService) {
    _CFNetServiceMulticastRelinquish();
}

CFStringRef CFNetServiceGetTargetHost(CFNetServiceRef theService) {
    return NULL;
}

SInt32 CFNetServiceGetPortNumber(CFNetServiceRef theService) {
    return -1;
}

CFArrayRef CFNetServiceGetAddressing(CFNetServiceRef theService) {
    return NULL;
}

CFDataRef CFNetServiceGetTXTData(CFNetServiceRef theService) {
    return theService->txtData;
}

Boolean CFNetServiceSetTXTData(CFNetServiceRef theService, CFDataRef txtRecord) {
    return false;
}

CFDictionaryRef CFNetServiceCreateDictionaryWithTXTData(CFAllocatorRef alloc, CFDataRef txtRecord) {
    return NULL;
}

CFDataRef CFNetServiceCreateTXTDataWithDictionary(CFAllocatorRef alloc, CFDictionaryRef keyValuePairs) {
    return NULL;
}

Boolean CFNetServiceSetClient(CFNetServiceRef theService, CFNetServiceClientCallBack clientCB, CFNetServiceClientContext *clientContext) {
    return false;
}

void CFNetServiceScheduleWithRunLoop(CFNetServiceRef theService, CFRunLoopRef runLoop, CFStringRef runLoopMode) {
    _CFNetServiceMulticastAquire();
}

void CFNetServiceUnscheduleFromRunLoop(CFNetServiceRef theService, CFRunLoopRef runLoop, CFStringRef runLoopMode) {
    _CFNetServiceMulticastRelinquish();
}

CFNetServiceMonitorRef CFNetServiceMonitorCreate(CFAllocatorRef alloc, CFNetServiceRef theService, CFNetServiceMonitorClientCallBack clientCB, CFNetServiceClientContext *clientContext) {
    return NULL;
}

void CFNetServiceMonitorInvalidate(CFNetServiceMonitorRef monitor) {

}

Boolean CFNetServiceMonitorStart(CFNetServiceMonitorRef monitor, CFNetServiceMonitorType recordType, CFStreamError *error) {
    _CFNetServiceMulticastAquire();
    return false;
}

void CFNetServiceMonitorStop(CFNetServiceMonitorRef monitor, CFStreamError *error) {
    _CFNetServiceMulticastRelinquish();
}

void CFNetServiceMonitorScheduleWithRunLoop(CFNetServiceMonitorRef monitor, CFRunLoopRef runLoop, CFStringRef runLoopMode) {
    _CFNetServiceMulticastAquire();
}

void CFNetServiceMonitorUnscheduleFromRunLoop(CFNetServiceMonitorRef monitor, CFRunLoopRef runLoop, CFStringRef runLoopMode) {
    _CFNetServiceMulticastRelinquish();
}

CFNetServiceBrowserRef CFNetServiceBrowserCreate(CFAllocatorRef alloc, CFNetServiceBrowserClientCallBack clientCB, CFNetServiceClientContext *clientContext) {
    return NULL;
}

void CFNetServiceBrowserInvalidate(CFNetServiceBrowserRef browser) {

}

Boolean CFNetServiceBrowserSearchForDomains(CFNetServiceBrowserRef browser, Boolean registrationDomains, CFStreamError *error) {
    _CFNetServiceMulticastAquire();
    return false;
}

Boolean CFNetServiceBrowserSearchForServices(CFNetServiceBrowserRef browser, CFStringRef domain, CFStringRef serviceType, CFStreamError *error) {
    _CFNetServiceMulticastAquire();
    return false;
}

void CFNetServiceBrowserStopSearch(CFNetServiceBrowserRef browser, CFStreamError *error) {
    _CFNetServiceMulticastRelinquish();
}

void CFNetServiceBrowserScheduleWithRunLoop(CFNetServiceBrowserRef browser, CFRunLoopRef runLoop, CFStringRef runLoopMode) {
    _CFNetServiceMulticastAquire();
}

void CFNetServiceBrowserUnscheduleFromRunLoop(CFNetServiceBrowserRef browser, CFRunLoopRef runLoop, CFStringRef runLoopMode) {
    _CFNetServiceMulticastRelinquish();
}

Boolean CFNetServiceRegister(CFNetServiceRef theService, CFStreamError *error) {
    return false;
}

Boolean CFNetServiceResolve(CFNetServiceRef theService, CFStreamError *error) {
    return false;
}

CFStringRef CFNetServiceGetProtocolSpecificInformation(CFNetServiceRef theService) {
    return NULL;
}

void CFNetServiceSetProtocolSpecificInformation(CFNetServiceRef theService, CFStringRef theInfo) {

}
