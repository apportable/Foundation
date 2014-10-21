#ifndef __CFURLREQUEST__
#define __CFURLREQUEST__

#include <CoreFoundation/CFData.h>
#include <CoreFoundation/CFString.h>
#include <CoreFoundation/CFURL.h>
#include <CoreFoundation/CFStream.h>
#include <CoreFoundation/CFArray.h>
#include <CFNetwork/CFHTTPMessage.h>
#include <stdlib.h>

#if PRAGMA_ONCE
#pragma once
#endif

typedef CF_ENUM(UInt32, CFURLRequestCachePolicy) {
    CFURLRequestUseProtocolCachePolicy                = 0,
    CFURLRequestReloadIgnoringLocalCacheData          = 1,
    CFURLRequestReloadIgnoringLocalAndRemoteCacheData = 4,
    CFURLRequestReloadIgnoringCacheData               = CFURLRequestReloadIgnoringLocalCacheData,
    CFURLRequestReturnCacheDataElseLoad               = 2,
    CFURLRequestReturnCacheDataDontLoad               = 3,
    CFURLRequestReloadRevalidatingCacheData           = 5,
};

typedef CF_ENUM(UInt32, CFURLRequestNetworkServiceType) {
    CFURLNetworkServiceTypeDefault    = 0,
    CFURLNetworkServiceTypeVoIP       = 1,
    CFURLNetworkServiceTypeVideo      = 2,
    CFURLNetworkServiceTypeBackground = 3,
    CFURLNetworkServiceTypeVoice      = 4
};

__BEGIN_DECLS

typedef const struct _CFURLRequest *CFURLRequestRef;
typedef struct _CFURLRequest *CFMutableURLRequestRef;

CFStringRef CFURLRequestCopyDebugDescription(CFURLRequestRef req);
void __CFURLRequestLog(CFURLRequestRef req);
extern int __CFURLRequestLogging;

CFURLRequestRef CFURLRequestCreate(CFAllocatorRef allocator, CFURLRef url, CFURLRequestCachePolicy policy, CFTimeInterval timeout);
CFURLRequestRef CFURLRequestCreateCopy(CFAllocatorRef allocator, CFURLRequestRef request);
CFURLRef CFURLRequestGetURL(CFURLRequestRef request);
CFURLRequestCachePolicy CFURLRequestGetCachePolicy(CFURLRequestRef request);
CFTimeInterval CFURLRequestGetTimeout(CFURLRequestRef request);
CFURLRef CFURLRequestCopyMainDocumentURL(CFURLRequestRef request);
CFURLRequestNetworkServiceType CFURLRequestGetServiceType(CFURLRequestRef request);
Boolean CFURLRequestAllowsCellularAccess(CFURLRequestRef request);
CFStringRef CFURLRequestCopyHTTPMethod(CFURLRequestRef request);
CFStringRef CFURLRequestCopyHTTPVersion(CFURLRequestRef request);
CFStringRef CFURLRequestCopyValueForHTTPField(CFURLRequestRef request, CFStringRef field);
CFArrayRef CFURLRequestCopyHTTPFields(CFURLRequestRef request);
CFArrayRef CFURLRequestCopyHTTPValues(CFURLRequestRef request);
CFDictionaryRef CFURLRequestCopyAllHTTPFields(CFURLRequestRef request);
CFDataRef CFURLRequestGetHTTPBody(CFURLRequestRef request);
CFReadStreamRef CFURLRequestGetHTTPBodyStream(CFURLRequestRef request);
Boolean CFURLRequestShouldHandleCookes(CFURLRequestRef request);
Boolean CFURLRequestShouldUseHTTPPipelining(CFURLRequestRef request);
CFIndex CFURLRequestFirstFieldIndex(CFURLRequestRef request, CFStringRef key, CFIndex start);
CFStringRef CFURLRequestGetHeaderFieldValue(CFURLRequestRef request, CFStringRef key);

void _CFURLSetMutable(CFURLRequestRef request, Boolean canMutate);

CFMutableURLRequestRef CFURLRequestCreateMutableCopy(CFAllocatorRef allocator, CFURLRequestRef request);
Boolean CFURLRequestSetURL(CFMutableURLRequestRef request, CFURLRef url);
Boolean CFURLRequestSetCachePolicy(CFMutableURLRequestRef request, CFURLRequestCachePolicy policy);
Boolean CFURLRequestSetTimeout(CFMutableURLRequestRef request, CFTimeInterval timeout);
Boolean CFURLRequestSetMainDocumentURL(CFMutableURLRequestRef request, CFURLRef url);
Boolean CFURLRequestSetNetworkServiceType(CFMutableURLRequestRef request, CFURLRequestNetworkServiceType type);
Boolean CFURLRequestSetAllowsCellularAccess(CFMutableURLRequestRef request, Boolean allowed);
Boolean CFURLRequestSetHTTPMethod(CFMutableURLRequestRef request, CFStringRef method);
CFIndex CFURLRequestAddValueForHTTPField(CFMutableURLRequestRef request, CFStringRef field, CFStringRef value);
Boolean CFURLRequestSetHTTPFields(CFMutableURLRequestRef request, CFArrayRef keys, CFArrayRef values);
Boolean CFURLRequestRemoveHTTPField(CFMutableURLRequestRef request, CFIndex index);
Boolean CFURLRequestReplaceHTTPField(CFMutableURLRequestRef request, CFIndex index, CFStringRef value);
Boolean CFURLRequestSetHTTPBody(CFMutableURLRequestRef request, CFDataRef data);
Boolean CFURLRequestSetHTTPBodyStream(CFMutableURLRequestRef request, CFReadStreamRef stream);
Boolean CFURLRequestHandleCookies(CFMutableURLRequestRef request, Boolean enabled);
Boolean CFURLRequestUseHTTPPipelining(CFMutableURLRequestRef request, Boolean enabled);

CFHTTPMessageRef CFHTTPMessageCreateRequestFromURLRequest(CFAllocatorRef allocator, CFURLRequestRef request);

CFURLRequestRef _CFURLRequestCreateFromParcel(CFAllocatorRef allocator, CFPropertyListRef parcel);
CFPropertyListRef _CFURLRequestCreateParcel(CFURLRequestRef request);

__END_DECLS


#endif
