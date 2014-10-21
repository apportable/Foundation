//
//  CFURLRequest.c
//  CFNetwork
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#include "CFURLRequest.h"
#include <CoreFoundation/CFBundle.h>
#include <CoreFoundation/CFLocale.h>
#include <CoreFoundation/CFNumber.h>
#include <stdio.h>
#include "CFRuntime.h"
#include "CFMiscUtils.h"

#define STACK_BUFFER_SIZE 256

// http://www.w3.org/Protocols/rfc2616/rfc2616-sec9.html
const CFStringRef kCFURLRequestGETMethod = CFSTR("GET");
const CFStringRef kCFURLRequestPOSTMethod = CFSTR("POST");
const CFStringRef kCFURLRequestOPTIONSMethod = CFSTR("OPTIONS");
const CFStringRef kCFURLRequestHEADMethod = CFSTR("HEAD");
const CFStringRef kCFURLRequestPUTMethod = CFSTR("PUT");
const CFStringRef kCFURLRequestDELETEMethod = CFSTR("DELETE");
const CFStringRef kCFURLRequestCONNECTMethod = CFSTR("CONNECT");

struct _CFURLRequest {
    CFRuntimeBase _base;

    CFURLRef _url;
    CFURLRef _mainDocument;
    CFStringRef _method;
    CFStringRef _version;
    CFMutableArrayRef _keys;
    CFMutableArrayRef _values;

    CFDataRef _body;
    CFReadStreamRef _stream;

    CFURLRequestCachePolicy _cachePolicy;
    CFURLRequestNetworkServiceType _serviceType;
    CFTimeInterval _timeout;

    Boolean _allowCellularAccess;
    Boolean _shouldHandleCookies;
    Boolean _shouldUseHTTPPipelining;

    Boolean _mutable;
};

static void __CFURLRequestDeallocate(CFTypeRef cf) {
    CFURLRequestRef request = (CFURLRequestRef)cf;
    if (request->_url) {
        CFRelease(request->_url);
    }
    CFRelease(request->_method);
    CFRelease(request->_version);
    if (request->_mainDocument) {
        CFRelease(request->_mainDocument);
    }
    if (request->_keys) {
        CFRelease(request->_keys);
    }
    if (request->_values) {
        CFRelease(request->_values);
    }
}

static Boolean __CFURLRequestEqual(CFTypeRef cf1, CFTypeRef cf2) {
    CFURLRequestRef request1 = (CFURLRequestRef)cf1;
    CFURLRequestRef request2 = (CFURLRequestRef)cf2;

    if (request1 == request2) {
        return true;
    }

    if (request1->_cachePolicy != request2->_cachePolicy) {
        return false;
    }

    if (request1->_timeout != request2->_timeout) {
        return false;
    }

    if ((request1->_url == NULL && request2->_url != NULL) ||
        (request1->_url != NULL && request2->_url == NULL)) {
        return false;
    }

    if (request1->_url != NULL &&
        request2->_url != NULL &&
        !CFEqual(request1->_url, request2->_url)) {
        return false;
    }

    if (!CFEqual(request1->_method, request2->_method)) {
        return false;
    }

    return true;
}

static CFHashCode __CFURLRequestHash(CFTypeRef cf) {
    CFURLRequestRef request = (CFURLRequestRef)cf;
    return CFHash(request->_method) ^ CFHash(request->_url);
}

static CFTypeID __kCFURLRequestTypeID = _kCFRuntimeNotATypeID;

static const CFRuntimeClass __CFURLRequestClass = {
    _kCFRuntimeScannedObject,
    "CFURLRequest",
    NULL,   // init
    NULL,   // copy
    __CFURLRequestDeallocate,
    __CFURLRequestEqual,
    __CFURLRequestHash,
    NULL,   //
    NULL
};

static void __CFURLRequestInitialize(void) {
    __kCFURLRequestTypeID = _CFRuntimeRegisterClass(&__CFURLRequestClass);
}

static CFStringRef CFURLRequestDefaultUserAgent() {
    static CFStringRef agent = NULL;
    static dispatch_once_t once = 0L;
    dispatch_once(&once, ^{
        CFBundleRef bundle = CFBundleGetMainBundle();
        CFStringRef name = CFBundleGetValueForInfoDictionaryKey(bundle, kCFBundleExecutableKey);
        CFStringRef ver = CFBundleGetValueForInfoDictionaryKey(bundle, CFSTR("CFBundleShortVersionString"));
#if DEVELOPERS_CAN_BE_TRUSTED_TO_NOT_SNIFF_USER_AGENTS // too bad this is not reality..
        agent = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("%@/%@ CFNetwork/129.20 Apportable/1.0"), name, ver);
#else
        agent = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("%@/%@ CFNetwork/672.0.2 Darwin/13.0.0"), name, ver);
#endif
    });
    return agent;
}

CFStringRef CFURLRequestCopyDebugDescription(CFURLRequestRef req) {
    CFMutableStringRef string = CFStringCreateMutable(kCFAllocatorDefault, 0);

    CFStringAppend(string, CFSTR("curl -k -i "));

    struct _CFURLRequest* reqStruct = (struct _CFURLRequest*)req;
    if (CFEqual(CFSTR("POST"), reqStruct->_method) && reqStruct->_body != NULL) {

        const UInt8* bodyBytes = CFDataGetBytePtr(reqStruct->_body);
        size_t len = CFDataGetLength(reqStruct->_body);
        CFStringRef params = CFStringCreateWithBytes(kCFAllocatorDefault, bodyBytes, len, kCFStringEncodingUTF8, true);
        CFStringAppendFormat(string, NULL, CFSTR("-d \"%@\" "), params);
        CFRelease(params);
    }

    for (CFIndex i = 0; i < CFArrayGetCount(reqStruct->_keys); i++) {
        CFStringRef key = (CFStringRef)CFArrayGetValueAtIndex(reqStruct->_keys, i);
        CFStringRef val = (CFStringRef)CFArrayGetValueAtIndex(reqStruct->_values, i);
        CFStringAppendFormat(string, NULL, CFSTR("-H \"%@\":\"%@\" "), key, val);
    }

    CFStringRef accept_encoding = CFURLRequestGetHeaderFieldValue(req, CFSTR("Accept-Encoding"));
    if (accept_encoding == NULL) {
        CFStringAppend(string, CFSTR("-H \"Accept-Encoding\":\"gzip, deflate\" "));
    }

    CFStringRef connection = CFURLRequestGetHeaderFieldValue(req, CFSTR("Connection"));
    if (connection == NULL) {
        CFStringAppend(string, CFSTR("-H \"Connection\":\"keep-alive\" "));
    }

    CFStringRef user_agent = CFURLRequestGetHeaderFieldValue(req, CFSTR("User-Agent"));
    if (user_agent == NULL) {
        CFStringRef agent = CFURLRequestDefaultUserAgent();
        CFStringAppendFormat(string, NULL, CFSTR("-H \"User-Agent\":\"%@\" "), agent);
    }

    CFStringRef accept_language = CFURLRequestGetHeaderFieldValue(req, CFSTR("Accept-Language"));
    if (accept_language == NULL) {
        CFLocaleRef locale = CFLocaleCopyCurrent();
        CFStringAppendFormat(string, NULL, CFSTR("-H \"Accept-Language\":\"%@\" "), CFLocaleGetIdentifier(locale));
        CFRelease(locale);
    }

    CFStringRef accept = CFURLRequestGetHeaderFieldValue(req, CFSTR("Accept"));
    if (accept == NULL) {
        CFStringAppend(string, CFSTR("-H \"Accept\":\"*/*\" "));
    }

    CFURLRef url = CFURLCopyAbsoluteURL(reqStruct->_url);
    CFStringAppendFormat(string, NULL, CFSTR("\"%@\""), CFURLGetString(url));
    CFRelease(url);

    return string;
}

#ifdef APPORTABLE_CFURLREQUEST_LOGGING
int __CFURLRequestLogging = 1;
#else
int __CFURLRequestLogging = 0;
#endif

void __CFURLRequestLog(CFURLRequestRef req) {
    if (__CFURLRequestLogging) {
        CFStringRef string = CFURLRequestCopyDebugDescription(req);
        RELEASE_LOG("%s\n", CFStringGetCStringPtr(string, kCFStringEncodingUTF8));
        CFRelease(string);
    }
}

CFTypeID CFURLRequestGetTypeID(void) {
    if (__kCFURLRequestTypeID == _kCFRuntimeNotATypeID) {
        __CFURLRequestInitialize();
    }
    return __kCFURLRequestTypeID;
}

CFURLRequestRef CFURLRequestCreate(CFAllocatorRef allocator, CFURLRef url, CFURLRequestCachePolicy policy, CFTimeInterval timeout) {
    CFIndex size = sizeof(struct _CFURLRequest) - sizeof(CFRuntimeBase);
    struct _CFURLRequest *request = (struct _CFURLRequest *)_CFRuntimeCreateInstance(allocator, CFURLRequestGetTypeID(), size, NULL);
    if (url == NULL) {
        request->_url = NULL;
    } else {
        request->_url = (CFURLRef)CFRetain(url);
    }
    request->_method = kCFURLRequestGETMethod;
    request->_version = kCFHTTPVersion1_1;
    request->_cachePolicy = policy;
    request->_timeout = timeout;
    request->_mutable = false;
    request->_serviceType = CFURLNetworkServiceTypeDefault;
    request->_allowCellularAccess = true;
    request->_shouldHandleCookies = true;
    request->_keys = CFArrayCreateMutable(allocator, 0, &kCFTypeArrayCallBacks);
    request->_values = CFArrayCreateMutable(allocator, 0, &kCFTypeArrayCallBacks);
    request->_shouldUseHTTPPipelining = false;
    return (CFURLRequestRef)request;
}

CFURLRequestRef CFURLRequestCreateCopy(CFAllocatorRef allocator, CFURLRequestRef originalRequest) {
    if (!originalRequest->_mutable &&
        CFGetAllocator(originalRequest) == (allocator ? allocator : CFAllocatorGetDefault()))
    {
        return (CFURLRequestRef)CFRetain(originalRequest);
    }

    CFMutableURLRequestRef request = CFURLRequestCreateMutableCopy(allocator, originalRequest);
    request->_mutable = false;
    return request;
}

CFURLRef CFURLRequestGetURL(CFURLRequestRef request) {
    return request->_url;
}

CFURLRequestCachePolicy CFURLRequestGetCachePolicy(CFURLRequestRef request) {
    return request->_cachePolicy;
}

CFTimeInterval CFURLRequestGetTimeout(CFURLRequestRef request) {
    return request->_timeout;
}

CFURLRef CFURLRequestCopyMainDocumentURL(CFURLRequestRef request) {
    if (request->_mainDocument == NULL) {
        return NULL;
    } else {
        return CFRetain(request->_mainDocument);
    }
}

CFURLRequestNetworkServiceType CFURLRequestGetServiceType(CFURLRequestRef request) {
    return request->_serviceType;
}

Boolean CFURLRequestAllowsCellularAccess(CFURLRequestRef request) {
    return request->_allowCellularAccess;
}

CFStringRef CFURLRequestCopyHTTPMethod(CFURLRequestRef request) {
    return CFStringCreateCopy(kCFAllocatorDefault, request->_method);
}

CFStringRef CFURLRequestCopyHTTPVersion(CFURLRequestRef request) {
    return CFStringCreateCopy(kCFAllocatorDefault, request->_version);
}

CFStringRef CFURLRequestCopyValueForHTTPField(CFURLRequestRef request, CFStringRef field) {
    CFIndex idx = CFURLRequestFirstFieldIndex(request, field, 0);
    if (idx != kCFNotFound) {
        return (CFStringRef)CFRetain((CFTypeRef)CFArrayGetValueAtIndex(request->_values, idx));
    } else {
        return NULL;
    }
}

CFArrayRef CFURLRequestCopyHTTPFields(CFURLRequestRef request) {
    return CFArrayCreateCopy(kCFAllocatorDefault, request->_keys);
}

CFArrayRef CFURLRequestCopyHTTPValues(CFURLRequestRef request) {
    return CFArrayCreateCopy(kCFAllocatorDefault, request->_values);
}

CFDictionaryRef CFURLRequestCopyAllHTTPFields(CFURLRequestRef request) {
    CFDictionaryRef allFields = NULL;

    void *stack_keys[STACK_BUFFER_SIZE];
    void *stack_values[STACK_BUFFER_SIZE];

    void **keys = &stack_keys[0];
    void **values = &stack_values[0];

    do {
        CFIndex count = CFArrayGetCount(request->_keys);
        if (count == 0) {
            break;
        }
        if (count > STACK_BUFFER_SIZE) {
            keys = malloc(sizeof(void *) * count);
            if (keys == NULL) {
                break;
            }
            values = malloc(sizeof(void *) * count);
            if (values == NULL) {
                break;
            }
        }
        CFArrayGetValues(request->_keys, CFRangeMake(0, count), (const void **)keys);
        CFArrayGetValues(request->_values, CFRangeMake(0, count), (const void **)values);
        allFields = CFDictionaryCreate(kCFAllocatorDefault, (const void **)keys, (const void **)values, count, &kCFCopyStringDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    } while (0);
    if (keys != stack_keys && keys != NULL) {
        free(keys);
    }
    if (values != stack_values && values != NULL) {
        free(values);
    }

    return allFields;
}

CFDataRef CFURLRequestGetHTTPBody(CFURLRequestRef request) {
    return request->_body;
}

CFReadStreamRef CFURLRequestGetHTTPBodyStream(CFURLRequestRef request) {
    return request->_stream;
}

Boolean CFURLRequestShouldHandleCookes(CFURLRequestRef request) {
    return request->_shouldHandleCookies;
}

Boolean CFURLRequestShouldUseHTTPPipelining(CFURLRequestRef request) {
    return request->_shouldUseHTTPPipelining;
}

CFIndex CFURLRequestFirstFieldIndex(CFURLRequestRef request, CFStringRef key, CFIndex start) {
    return CFArrayGetFirstIndexOfValue(request->_keys, CFRangeMake(start, CFArrayGetCount(request->_keys) - start), key);
}

CFStringRef CFURLRequestGetHeaderFieldValue(CFURLRequestRef request, CFStringRef key) {
    CFIndex found = CFArrayGetFirstIndexOfValue(request->_keys, CFRangeMake(0, CFArrayGetCount(request->_keys)), key);
    if (found != kCFNotFound) {
        return CFArrayGetValueAtIndex(request->_values, found);
    } else {
        return NULL;
    }
}

void _CFURLSetMutable(CFURLRequestRef request, Boolean canMutate) {
    struct _CFURLRequest *req = (struct _CFURLRequest *)request;
    req->_mutable = canMutate;
}

CFMutableURLRequestRef CFURLRequestCreateMutableCopy(CFAllocatorRef allocator, CFURLRequestRef request) {
    CFIndex size = sizeof(struct _CFURLRequest) - sizeof(CFRuntimeBase);
    struct _CFURLRequest *newReq = (struct _CFURLRequest *)_CFRuntimeCreateInstance(allocator, __kCFURLRequestTypeID, size, NULL);
    
    if (request->_url == NULL) {
        newReq->_url = NULL;
    } else {
        newReq->_url = (CFURLRef)CFRetain(request->_url);
    }
    
    if (request->_mainDocument == NULL) {
        newReq->_mainDocument = NULL;
    } else {
        newReq->_mainDocument = (CFURLRef)CFRetain(request->_mainDocument);   
    }
    
    newReq->_method = CFRetain(request->_method);
    newReq->_version = CFStringCreateCopy(allocator, request->_version);
    newReq->_keys = CFArrayCreateMutableCopy(allocator, 0, request->_keys);
    newReq->_values = CFArrayCreateMutableCopy(allocator, 0, request->_values);
    
    if (request->_body == NULL) {
        newReq->_body = NULL;
    } else {
        newReq->_body = CFDataCreateCopy(kCFAllocatorDefault, request->_body);
    }
    
    if (request->_stream == NULL) {
        newReq->_stream = NULL;
    } else {
        newReq->_stream = (CFReadStreamRef)CFRetain(request->_stream);
    }

    newReq->_cachePolicy = request->_cachePolicy;
    newReq->_serviceType = request->_serviceType;
    newReq->_timeout = request->_timeout;

    newReq->_allowCellularAccess = request->_allowCellularAccess;
    newReq->_shouldHandleCookies = request->_shouldHandleCookies;
    newReq->_shouldUseHTTPPipelining = request->_shouldUseHTTPPipelining;

    newReq->_mutable = true;

    return (CFMutableURLRequestRef)newReq;
}

Boolean CFURLRequestSetURL(CFMutableURLRequestRef request, CFURLRef url) {
    if (request->_mutable == false) {
        return false;
    }
    if (url == NULL) {
        return false;
    }
    if (request->_url != url) {
        if (request->_url != NULL) {
            CFRelease(request->_url);
        }
        request->_url = (CFURLRef)CFRetain(url);
    }
    return true;
}

Boolean CFURLRequestSetCachePolicy(CFMutableURLRequestRef request, CFURLRequestCachePolicy policy) {
    if (request->_mutable == false) {
        return false;
    }
    request->_cachePolicy = policy;
    return true;
}

Boolean CFURLRequestSetTimeout(CFMutableURLRequestRef request, CFTimeInterval timeout) {
    if (request->_mutable == false) {
        return false;
    }
    request->_timeout = timeout;
    return true;
}

Boolean CFURLRequestSetMainDocumentURL(CFMutableURLRequestRef request, CFURLRef url) {
    if (request->_mutable == false) {
        return false;
    }
    if (request->_mainDocument != url) {
        if (url) {
            if (request->_mainDocument) {
                CFRelease(request->_mainDocument);
            }
            request->_mainDocument = (CFURLRef)CFRetain(url);
        } else {
            request = NULL;
        }
    }
    return true;
}

Boolean CFURLRequestSetNetworkServiceType(CFMutableURLRequestRef request, CFURLRequestNetworkServiceType type) {
    if (request->_mutable == false) {
        return false;
    }
    request->_serviceType = type;
    return true;
}

Boolean CFURLRequestSetAllowsCellularAccess(CFMutableURLRequestRef request, Boolean allowed) {
    if (request->_mutable == false) {
        return false;
    }
    request->_allowCellularAccess = allowed;
    return true;
}

Boolean CFURLRequestSetHTTPMethod(CFMutableURLRequestRef request, CFStringRef method) {
    if (request->_mutable == false) {
        return false;
    }
    if (method == NULL) {
        return false;
    }
    if (request->_method != method) {
        CFRelease(request->_method);
        request->_method = CFStringCreateCopy(kCFAllocatorDefault, method);
    }
    return true;
}

CFIndex CFURLRequestAddValueForHTTPField(CFMutableURLRequestRef request, CFStringRef field, CFStringRef value) {
    if (request->_mutable == false) {
        return kCFNotFound;
    }

    CFIndex idx = CFURLRequestFirstFieldIndex(request, field, 0);
    if (idx != kCFNotFound) {
        if (value == NULL) {
            CFArrayRemoveValueAtIndex(request->_keys, idx);
            CFArrayRemoveValueAtIndex(request->_values, idx);
        } else {
            // if the key already exists, append.
            // the http delimiter is a comma.
            CFStringRef oldValue = CFArrayGetValueAtIndex(request->_values, idx);
            CFStringRef newValue = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("%@,%@"), oldValue, value);
            CFArraySetValueAtIndex(request->_values, idx, newValue);
            CFRelease(newValue);
        }
    } else {
        CFArrayAppendValue(request->_keys, field);
        CFArrayAppendValue(request->_values, value);
    }


    return CFArrayGetCount(request->_keys) - 1;
}

Boolean CFURLRequestSetHTTPFields(CFMutableURLRequestRef request, CFArrayRef keys, CFArrayRef values) {
    if (request->_mutable == false) {
        return false;
    }
    if (keys == NULL && values == NULL) {
        CFArrayRemoveAllValues(request->_keys);
        CFArrayRemoveAllValues(request->_values);
        return true;
    } else if (keys == NULL || values == NULL) {
        return false;
    }
    if (CFArrayGetCount(keys) != CFArrayGetCount(values)) {
        return false; // probably should be a bit sterner than just failing silently
    }
    if (request->_keys != keys) {
        CFRelease(request->_keys);
        request->_keys = CFArrayCreateMutableCopy(kCFAllocatorDefault, 0, keys);
    }
    if (request->_values != values) {
        CFRelease(request->_values);
        request->_values = CFArrayCreateMutableCopy(kCFAllocatorDefault, 0, values);
    }
    return true;
}

Boolean CFURLRequestRemoveHTTPField(CFMutableURLRequestRef request, CFIndex index) {
    if (request->_mutable == false) {
        return false;
    }
    CFArrayRemoveValueAtIndex(request->_keys, index);
    CFArrayRemoveValueAtIndex(request->_values, index);
    return true;
}

Boolean CFURLRequestReplaceHTTPField(CFMutableURLRequestRef request, CFIndex index, CFStringRef value) {
    if (request->_mutable == false) {
        return false;
    }
    CFArraySetValueAtIndex(request->_values, index, value);
    return true;
}

Boolean CFURLRequestSetHTTPBody(CFMutableURLRequestRef request, CFDataRef data) {
    if (request->_mutable == false) {
        return false;
    }
    if (request->_body != data) {
        if (request->_body != NULL) {
            CFRelease(request->_body);
        }
        request->_body = CFRetain(data);
    }
    return true;
}

Boolean CFURLRequestSetHTTPBodyStream(CFMutableURLRequestRef request, CFReadStreamRef stream) {
    if (request->_mutable == false) {
        return false;
    }
    if (request->_stream != stream) {
        if (request->_stream != NULL) {
            CFRelease(request->_stream);
        }
        request->_stream = (CFReadStreamRef)CFRetain(stream);
    }
    return true;
}

Boolean CFURLRequestHandleCookies(CFMutableURLRequestRef request, Boolean enabled) {
    if (request->_mutable == false) {
        return false;
    }
    request->_shouldHandleCookies = enabled;
    return true;
}

Boolean CFURLRequestUseHTTPPipelining(CFMutableURLRequestRef request, Boolean enabled) {
    if (request->_mutable == false) {
        return false;
    }
    request->_shouldUseHTTPPipelining = enabled;
    return true;
}

CFHTTPMessageRef CFHTTPMessageCreateRequestFromURLRequest(CFAllocatorRef allocator, CFURLRequestRef request) {
    CFHTTPMessageRef message = CFHTTPMessageCreateRequest(allocator, request->_method, request->_url, request->_version);
    
    if (message == NULL) {
        return NULL;
    }
    
    CFIndex count = CFArrayGetCount(request->_keys);
    for (CFIndex idx = 0; idx < count; idx++) {
        CFStringRef headerField = (CFStringRef)CFArrayGetValueAtIndex(request->_keys, idx);
        CFStringRef value = (CFStringRef)CFArrayGetValueAtIndex(request->_values, idx);
        CFHTTPMessageSetHeaderFieldValue(message, headerField, value);
    }

    CFStringRef accept_encoding = CFHTTPMessageCopyHeaderFieldValue(message, CFSTR("Accept-Encoding"));
    if (accept_encoding == NULL) {
        CFHTTPMessageSetHeaderFieldValue(message, CFSTR("Accept-Encoding"), CFSTR("gzip, deflate"));
    } else {
        CFRelease(accept_encoding);
    }

    CFStringRef connection = CFHTTPMessageCopyHeaderFieldValue(message, CFSTR("Connection"));
    if (connection == NULL) {
        CFHTTPMessageSetHeaderFieldValue(message, CFSTR("Connection"), CFSTR("keep-alive"));
    } else {
        CFRelease(connection);
    }

    CFStringRef user_agent = CFHTTPMessageCopyHeaderFieldValue(message, CFSTR("User-Agent"));
    if (user_agent == NULL) {
        CFStringRef agent = CFURLRequestDefaultUserAgent();
        CFHTTPMessageSetHeaderFieldValue(message, CFSTR("User-Agent"), agent);
    } else {
        CFRelease(user_agent);
    }

    CFStringRef accept_language = CFHTTPMessageCopyHeaderFieldValue(message, CFSTR("Accept-Language"));
    if (accept_language == NULL) {
        CFLocaleRef locale = CFLocaleCopyCurrent();
        CFHTTPMessageSetHeaderFieldValue(message, CFSTR("Accept-Language"), CFLocaleGetIdentifier(locale));
        CFRelease(locale);
    } else {
        CFRelease(accept_language);
    }

    CFStringRef accept = CFHTTPMessageCopyHeaderFieldValue(message, CFSTR("Accept"));
    if (accept == NULL) {
        CFHTTPMessageSetHeaderFieldValue(message, CFSTR("Accept"), CFSTR("*/*"));
    } else {
        CFRelease(accept);
    }

    if (request->_body) {
        //Set default content type to application/x-www-form-urlencoded if the method is POST
        CFStringRef requestMethod = CFHTTPMessageCopyRequestMethod(message);
        static CFStringRef contentType = CFSTR("Content-Type");
        CFStringRef contentTypeValue = CFHTTPMessageCopyHeaderFieldValue(message, contentType);
        if (contentTypeValue == NULL && CFStringCompare(requestMethod, kCFURLRequestPOSTMethod, kCFCompareCaseInsensitive) == kCFCompareEqualTo) {
            CFHTTPMessageSetHeaderFieldValue(message, contentType, CFSTR("application/x-www-form-urlencoded"));
        }
        if (contentTypeValue != NULL) {
            CFRelease(contentTypeValue);
        }
        if (requestMethod != NULL) {
            CFRelease(requestMethod);
        }
        CFHTTPMessageSetBody(message, request->_body);
    } else if (request->_stream) {
        // TOOD: Body streams are not yet supported for serialization
    }
    return message;
}

CFURLRequestRef _CFURLRequestCreateFromParcel(CFAllocatorRef allocator, CFPropertyListRef rawParcel) {
    if (!rawParcel || CFGetTypeID(rawParcel) != CFDictionaryGetTypeID()) {
        return NULL;
    }
    CFDictionaryRef parcel = (CFDictionaryRef)rawParcel;

    struct _CFURLRequest* request = (struct _CFURLRequest*)_CFRuntimeCreateInstance(
        allocator,
        CFURLRequestGetTypeID(),
        sizeof(struct _CFURLRequest) - sizeof(CFRuntimeBase),
        NULL);
    
    request->_version = kCFHTTPVersion1_1;
    request->_keys = CFArrayCreateMutable(allocator, 0, &kCFTypeArrayCallBacks);
    request->_values = CFArrayCreateMutable(allocator, 0, &kCFTypeArrayCallBacks);

    PARCEL_GET_URL(parcel, request->_url, "url");
    PARCEL_GET_URL(parcel, request->_mainDocument, "mainDocument");
    PARCEL_GET_RETAINED_OBJECT(parcel, CFString, request->_method, "method");
    PARCEL_GET_RETAINED_OBJECT(parcel, CFData, request->_body, "body");
    PARCEL_GET_BOOL(parcel, request->_allowCellularAccess, "allowCellularAccess");
    PARCEL_GET_BOOL(parcel, request->_shouldHandleCookies, "shouldHandleCookies");
    PARCEL_GET_BOOL(parcel, request->_shouldUseHTTPPipelining, "shouldUseHTTPPipelining");
    PARCEL_GET_NUMBER(parcel, Double, double, request->_timeout, "timeout");
    PARCEL_GET_ENUM(parcel, request->_cachePolicy, "cachePolicy");
    PARCEL_GET_ENUM(parcel, request->_serviceType, "serviceType");

    CFArrayRef keys = NULL;
    PARCEL_GET_RETAINED_OBJECT(parcel, CFArray, keys, "keys");
    if (keys) {
        CFArrayAppendArray(request->_keys, keys, CFRangeMake(0, CFArrayGetCount(keys)));
        CFRelease(keys);
    }

    CFArrayRef values = NULL;
    PARCEL_GET_RETAINED_OBJECT(parcel, CFArray, values, "values");
    if (values) {
        CFArrayAppendArray(request->_values, values, CFRangeMake(0, CFArrayGetCount(values)));
        CFRelease(values);
    }

    return request;
}

CFPropertyListRef _CFURLRequestCreateParcel(CFURLRequestRef request) {
    if (request->_stream) {
        // Don't know how to serialize stream
        return NULL;
    }

    CFMutableDictionaryRef parcel = CFDictionaryCreateMutable(
        kCFAllocatorDefault,
        0,
        &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);

    PARCEL_SET_URL(parcel, request->_url, "url");
    PARCEL_SET_URL(parcel, request->_mainDocument, "mainDocument");
    PARCEL_SET_OBJECT(parcel, request->_method, "method");
    PARCEL_SET_OBJECT(parcel, request->_keys, "keys");
    PARCEL_SET_OBJECT(parcel, request->_values, "values");
    PARCEL_SET_OBJECT(parcel, request->_body, "body");
    PARCEL_SET_BOOL(parcel, request->_allowCellularAccess, "allowCellularAccess");
    PARCEL_SET_BOOL(parcel, request->_shouldHandleCookies, "shouldHandleCookies");
    PARCEL_SET_BOOL(parcel, request->_shouldUseHTTPPipelining, "shouldUseHTTPPipelining");
    PARCEL_SET_NUMBER(parcel, Double, double, request->_timeout, "timeout");
    PARCEL_SET_ENUM(parcel, request->_cachePolicy, "cachePolicy");
    PARCEL_SET_ENUM(parcel, request->_serviceType, "serviceType");

    return parcel;
}
