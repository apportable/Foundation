//
//  CFURLResponse.c
//  CFNetwork
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

// Some functions in this file are based on ResponseHeaders.java class from
// okhttp Android project: http://goo.gl/ncNJYI

#include "CFURLResponse.h"
#include <CoreFoundation/CFNumber.h>
#include <dispatch/dispatch.h>
#include <stdlib.h>
#include <libkern/OSAtomic.h>
#include "CFRuntime.h"
#include "CFMiscUtils.h"
#include "CFHTTPUtils.h"
#include "CFRuntimeUtils.h"

typedef struct {
    unsigned noCache: 1;
    unsigned noStore: 1;
    unsigned public: 1;
    unsigned mustRevalidate: 1;
    unsigned onlyIfCached: 1;

    unsigned maxAgeValid: 1;
    unsigned sMaxAgeValid: 1;
    unsigned minFreshValid: 1;
    unsigned maxStaleValid: 1;

    CFTimeInterval maxAge;
    CFTimeInterval sMaxAge;
    CFTimeInterval minFresh;
    CFTimeInterval maxStale;
} CacheControlField;

typedef struct {
    CacheControlField cacheControl;

    unsigned ageValid: 1;
    unsigned dateValid: 1;
    unsigned expiresValid: 1;
    unsigned lastModifiedValid: 1;

    CFTimeInterval age;
    CFAbsoluteTime date;
    CFAbsoluteTime expires;
    CFAbsoluteTime lastModified;
    CFStringRef etag;
    CFArrayRef vary;
} ParsedHeaders;

typedef struct _CFURLResponse {
    CFRuntimeBase _base;
    CFAbsoluteTime creationTime;
    CFURLRef url;
    CFStringRef mimeType;
    int64_t expectedLength;
    CFStringRef textEncoding;
    CFIndex statusCode;
    CFStringRef httpVersion;
    CFDictionaryRef headerFields;
    Boolean isHTTPResponse;

    OSSpinLock parsedHeadersLock;
    ParsedHeaders* parsedHeaders;
} _CFURLResponse;

static _CFURLResponse* allocateResponse(CFAllocatorRef allocator);

static Boolean caseInsensitiveEqual(const void *value1, const void *value2);
static CFHashCode caseInsensitiveHash(const void *value);

static const ParsedHeaders* parseHeaders(CFURLResponseRef response);
static void parsedHeadersDestroy(ParsedHeaders* headers);
static CacheControlField parseCacheControl(CFStringRef string);

static Boolean requestHasAuthorization(CFURLRequestRef request);
static CacheControlField requestGetCacheControl(CFURLRequestRef request);
static Boolean requestHasConditions(CFURLRequestRef request);

static CFTimeInterval computeAge(CFAbsoluteTime now, CFURLResponseRef response);
static CFTimeInterval computeMaxAge(CFURLResponseRef response);


/* Class */

static void responseDeallocate(CFTypeRef cf) {
    CFURLResponseRef response = (CFURLResponseRef)cf;
    if (response->url != NULL) {
        CFRelease(response->url);
    }
    if (response->mimeType) {
        CFRelease(response->mimeType);
    }
    if (response->textEncoding) {
        CFRelease(response->textEncoding);
    }
    if (response->headerFields) {
        CFRelease(response->headerFields);
    }
    if (response->httpVersion) {
        CFRelease(response->httpVersion);
    }
    if (response->parsedHeaders) {
        parsedHeadersDestroy(response->parsedHeaders);
    }
}

static const CFRuntimeClass responseClass = {
    .version = 0,
    .className = "CFURLResponse",
    .finalize = &responseDeallocate
};

static CFTypeID responseTypeID = _kCFRuntimeNotATypeID;

CFTypeID CFURLResponseGetTypeID(void) {
    _CFRuntimeRegisterClassOnce(&responseTypeID, &responseClass);
    return responseTypeID;
}


/* API */

CFURLResponseRef CFURLResponseCreate(CFAllocatorRef allocator,
                                     CFURLRef url,
                                     CFStringRef mimeType,
                                     int64_t length,
                                     CFStringRef textEncoding)
{
    _CFURLResponse* response = allocateResponse(allocator);
    response->creationTime = CFAbsoluteTimeGetCurrent();

    if (url != NULL) {
        response->url = (CFURLRef)CFRetain(url);
    } else {
        response->url = NULL;
    }
    if (mimeType != NULL) {
        response->mimeType = CFStringCreateCopy(allocator, mimeType);
    } else {
        response->mimeType = NULL; // is this right? or does it get a default type?
    }
    response->expectedLength = length;
    if (textEncoding != NULL) {
        response->textEncoding = CFStringCreateCopy(allocator, textEncoding);
    } else {
        response->textEncoding = NULL;
    }
    response->httpVersion = NULL;
    return response;
}

CFURLResponseRef CFURLResponseCreateWithCFHTTPMessage(CFAllocatorRef allocator,
                                                      CFURLRef request,
                                                      CFHTTPMessageRef responseMessage)
{
    _CFURLResponse* response = allocateResponse(allocator);
    response->creationTime = CFAbsoluteTimeGetCurrent();

    response->url = (CFURLRef)CFRetain(request); // this is incomplete and should also check the response for redirect etc
    response->isHTTPResponse = true;

    CFDictionaryRef messageHeaderFields = CFHTTPMessageCopyAllHeaderFields(responseMessage);
    CFIndex count = CFDictionaryGetCount(messageHeaderFields);
    const void **keys = malloc(sizeof(void *) * count);
    const void **values = malloc(sizeof(void *) * count);

    const CFDictionaryKeyCallBacks fieldKeyCallbacks = {
        .version = 0,
        .retain = kCFCopyStringDictionaryKeyCallBacks.retain,
        .release = kCFCopyStringDictionaryKeyCallBacks.release,
        .copyDescription = kCFCopyStringDictionaryKeyCallBacks.copyDescription,
        .equal = &caseInsensitiveEqual,
        .hash = &caseInsensitiveHash
    };
    CFDictionaryGetKeysAndValues(messageHeaderFields, keys, values);
    response->headerFields = CFDictionaryCreate(allocator, keys, values, count, &fieldKeyCallbacks, &kCFTypeDictionaryValueCallBacks);
    free(keys);
    free(values);

    response->httpVersion = NULL;

    response->mimeType = NULL;
    response->textEncoding = NULL;
    _CFHTTPParseContentTypeField(
        &response->textEncoding,
        &response->mimeType,
        (CFStringRef)CFDictionaryGetValue(response->headerFields, CFSTR("Content-Type")));

    CFStringRef content_length = (CFStringRef)CFDictionaryGetValue(response->headerFields, CFSTR("Content-Length"));
    if (content_length != NULL) {
        response->expectedLength = CFStringGetIntValue(content_length);
    } else {
        response->expectedLength = 0;
    }

    response->statusCode = CFHTTPMessageGetResponseStatusCode(responseMessage);

    return response;
}

CFURLResponseRef CFURLResponseCreateCopy(CFAllocatorRef allocator, CFURLResponseRef response) {
    // CFURLResponse is immutable, so there is no point in copying it
    return (CFURLResponseRef)CFRetain(response);
}

CFAbsoluteTime CFURLResponseGetCreationTime(CFURLResponseRef response) {
    return response->creationTime;
}

CFURLRef CFURLResponseGetURL(CFURLResponseRef response) {
    return response->url;
}

CFStringRef CFURLResponseGetTextEncodingName(CFURLResponseRef response) {
    return response->textEncoding;
}

CFStringRef CFURLResponseGetMIMEType(CFURLResponseRef response) {
    return response->mimeType;
}

int64_t CFURLResponseGetExpectedContentLength(CFURLResponseRef response) {
    return response->expectedLength;
}

CFStringRef CFURLResponseCopySuggestedFilename(CFURLResponseRef response) {
    if (response->url == NULL) {
        return NULL;
    }
    CFStringRef str = CFURLCopyLastPathComponent(response->url);
    if (str == NULL || CFStringGetLength(str) == 0) {
        if (str != NULL) {
            CFRelease(str);
        }
        return CFSTR("index.html");
    } else {
        return str;
    }
}

CFIndex CFURLResponseGetStatusCode(CFURLResponseRef response) {
    return response->statusCode;
}

CFDictionaryRef CFURLResponseGetHeaderFields(CFURLResponseRef response) {
    return response->headerFields;
}

Boolean CFURLResponseIsHTTPResponse(CFURLResponseRef response) {
    return response->isHTTPResponse;
}

CFURLResponseRef _CFURLResponseCreateFromParcel(CFAllocatorRef allocator, CFPropertyListRef rawParcel) {
    if (!rawParcel || CFGetTypeID(rawParcel) != CFDictionaryGetTypeID()) {
        return NULL;
    }
    CFDictionaryRef parcel = (CFDictionaryRef)rawParcel;

    _CFURLResponse* response = allocateResponse(allocator);

    PARCEL_GET_NUMBER(parcel, Double, CFAbsoluteTime, response->creationTime, "creationTime");
    PARCEL_GET_URL(parcel, response->url, "url");
    PARCEL_GET_RETAINED_OBJECT(parcel, CFString, response->mimeType, "mimeType");
    PARCEL_GET_RETAINED_OBJECT(parcel, CFString, response->textEncoding, "textEncoding");
    PARCEL_GET_RETAINED_OBJECT(parcel, CFString, response->httpVersion, "httpVersion");
    PARCEL_GET_RETAINED_OBJECT(parcel, CFDictionary, response->headerFields, "headerFields");
    PARCEL_GET_NUMBER(parcel, LongLong, long long, response->expectedLength, "expectedLength");
    PARCEL_GET_CFINDEX(parcel, response->statusCode, "statusCode");
    PARCEL_GET_BOOL(parcel, response->isHTTPResponse, "isHTTPResponse");

    return response;
}

CFPropertyListRef _CFURLResponseCreateParcel(CFURLResponseRef response) {
    CFMutableDictionaryRef parcel = CFDictionaryCreateMutable(
        kCFAllocatorDefault,
        0,
        &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);

    PARCEL_SET_NUMBER(parcel, Double, CFAbsoluteTime, response->creationTime, "creationTime");
    PARCEL_SET_URL(parcel, response->url, "url");
    PARCEL_SET_OBJECT(parcel, response->mimeType, "mimeType");
    PARCEL_SET_OBJECT(parcel, response->textEncoding, "textEncoding");
    PARCEL_SET_OBJECT(parcel, response->httpVersion, "httpVersion");
    PARCEL_SET_OBJECT(parcel, response->headerFields, "headerFields");
    PARCEL_SET_NUMBER(parcel, LongLong, long long, response->expectedLength, "expectedLength");
    PARCEL_SET_CFINDEX(parcel, response->statusCode, "statusCode");
    PARCEL_SET_BOOL(parcel, response->isHTTPResponse, "isHTTPResponse");

    return parcel;
}

// Based on isCacheable() from ResponseHeaders.java (http://goo.gl/ncNJYI)
Boolean _CFURLResponseIsCacheableWithRequest(CFURLResponseRef response, CFURLRequestRef request) {
    CFStringRef method = CFURLRequestCopyHTTPMethod(request);
    Boolean getMethod = CFEqual(CFSTR("GET"), method);
    if (method) {
        CFRelease(method);
    }
    if (!getMethod) {
        // Only cache GET requests
        return false;
    }

    // Check uncacheable response codes (RFC 2616, 13.4)
    if (response->statusCode != 200 /* OK */ &&
        response->statusCode != 203 /* Not authoritative */ &&
        response->statusCode != 300 /* Multiple choices */ &&
        response->statusCode != 301 /* Moved permanently */ &&
        response->statusCode != 410 /* Gone */)
    {
        return false;
    }

    const ParsedHeaders* headers = parseHeaders(response);

    // Responses to authorized requests aren't cacheable unless they include
    // a 'public', 'must-revalidate' or 's-maxage' directive.
    if (requestHasAuthorization(request) &&
        !headers->cacheControl.public &&
        !headers->cacheControl.mustRevalidate &&
        !headers->cacheControl.sMaxAgeValid)
    {
        return false;
    }

    if (headers->cacheControl.noStore) {
        return false;
    }

    if (headers->vary && CFArrayContainsValue(
            headers->vary,
            CFRangeMake(0, CFArrayGetCount(headers->vary)),
            CFSTR("*")))
    {
        return false;
    }

#ifndef TODO_CONDITIONAL_CACHE
    if (headers->cacheControl.noCache) {
        return false;
    }
#endif

    return true;
}

// Based on chooseResponseSource() from ResponseHeaders.java (http://goo.gl/ncNJYI)
CFURLResponseSource _CFURLResponseChooseSourceWithRequest(CFURLResponseRef response,
                                                          CFURLRequestRef request,
                                                          CFAbsoluteTime now)
{
    if (!_CFURLResponseIsCacheableWithRequest(response, request)) {
        return kCFURLResponseSourceNetwork;
    }

    const ParsedHeaders* headers = parseHeaders(response);

    CacheControlField requestCacheControl = requestGetCacheControl(request);
    Boolean requestIsConditional = requestHasConditions(request);

    if (requestCacheControl.noCache || requestIsConditional) {
        return kCFURLResponseSourceNetwork;
    }

    if (!headers->cacheControl.noCache) {
        CFTimeInterval age = computeAge(now, response);
        CFTimeInterval maxAge = computeMaxAge(response);

        if (requestCacheControl.maxAgeValid && maxAge > requestCacheControl.maxAge) {
            maxAge = requestCacheControl.maxAge;
        }

        CFTimeInterval minFresh = 0;
        if (requestCacheControl.minFreshValid) {
            minFresh = requestCacheControl.minFresh;
        }

        CFTimeInterval maxStale = 0;
        if (!headers->cacheControl.mustRevalidate && requestCacheControl.maxStaleValid) {
            maxStale = requestCacheControl.maxStale;
        }

        if (age + minFresh < maxAge + maxStale) {
            return kCFURLResponseSourceCache;
        }
    }

#ifdef TODO_CONDITIONAL_CACHE

    if (headers->lastModifiedValid) {
        requestIsConditional = true;
        CFURLRequestSetHTTPHeaderFieldValue(
            request,
            CFSTR("If-Modified-Since"), _CFHTTPFormatDateField(lastModified));
    } else if (headers->dateValid) {
        requestIsConditional = true;
        CFURLRequestSetHTTPHeaderFieldValue(
            request,
            CFSTR("If-Modified-Since"), _CFHTTPFormatDateField(headers->date));
    }

    if (headers->etag) {
        requestIsConditional = true;
        CFURLRequestSetHTTPHeaderFieldValue(
            request,
            CFSTR("If-None-Match"), headers->etag);
    }

    return requestIsConditional ?
        kCFURLResponseSourceConditionalCache :
        kCFURLResponseSourceNetwork;

#else

    return kCFURLResponseSourceNetwork;

#endif
}


/* Private */

static _CFURLResponse* allocateResponse(CFAllocatorRef allocator) {
    return (_CFURLResponse*)_CFRuntimeCreateInstance(
        allocator,
        CFURLResponseGetTypeID(),
        sizeof(_CFURLResponse) - sizeof(CFRuntimeBase),
        NULL);
}

static Boolean caseInsensitiveEqual(const void *value1, const void *value2) {
    return (CFStringCompare((CFStringRef)value1, (CFStringRef)value2, kCFCompareCaseInsensitive) == kCFCompareEqualTo);
}

// TODO: make this function compare lower cased characters instead of lower cased malloced strings
static CFHashCode caseInsensitiveHash(const void *value) {
    CFMutableStringRef str = CFStringCreateMutable(kCFAllocatorDefault, 0);
    CFStringReplaceAll(str, (CFStringRef)value);
    CFStringLowercase(str, NULL);
    CFHashCode hc = CFHash(str);
    CFRelease(str);
    return hc;
}

static const ParsedHeaders* parseHeaders(CFURLResponseRef response) {
    _CFURLResponse* mutableResponse = (_CFURLResponse*)response;
    OSSpinLockLock(&mutableResponse->parsedHeadersLock);
    if (!mutableResponse->parsedHeaders) {
        ParsedHeaders* headers = CFAllocatorAllocate(kCFAllocatorDefault, sizeof(ParsedHeaders), 0);
        bzero(headers, sizeof(*headers));

        CFDictionaryRef headerFields = response->headerFields;
        if (headerFields) {
            headers->cacheControl = parseCacheControl(
                (CFStringRef)CFDictionaryGetValue(headerFields, CFSTR("Cache-Control")));

            headers->dateValid = _CFHTTPParseDateField(
                &headers->date,
                (CFStringRef)CFDictionaryGetValue(headerFields, CFSTR("Date")));

            headers->expiresValid = _CFHTTPParseDateField(
                &headers->expires,
                (CFStringRef)CFDictionaryGetValue(headerFields, CFSTR("Expires")));

            headers->lastModifiedValid = _CFHTTPParseDateField(
                &headers->lastModified,
                (CFStringRef)CFDictionaryGetValue(headerFields, CFSTR("Last-Modified")));

            headers->ageValid = _CFHTTPParseSeconds(
                &headers->age,
                (CFStringRef)CFDictionaryGetValue(headerFields, CFSTR("Age")));

            CFTypeRef etag = CFDictionaryGetValue(headerFields, CFSTR("ETag"));
            headers->etag = etag ? (CFStringRef)CFRetain(etag) : NULL;

            headers->vary = _CFHTTPParseVaryField(
                (CFStringRef)CFDictionaryGetValue(headerFields, CFSTR("Vary")));
        }

        mutableResponse->parsedHeaders = headers;
    }
    OSSpinLockUnlock(&mutableResponse->parsedHeadersLock);
    return response->parsedHeaders;
}

static void parsedHeadersDestroy(ParsedHeaders* headers) {
    if (headers->etag) {
        CFRelease(headers->etag);
    }
    if (headers->vary) {
        CFRelease(headers->vary);
    }
    CFAllocatorDeallocate(kCFAllocatorDefault, headers);
}

static CacheControlField parseCacheControl(CFStringRef string) {
    CacheControlField cacheControl = {0};
    if (!string) {
        return cacheControl;
    }

    CFDictionaryRef tokens;
    {
        CFMutableStringRef lowercaseString = CFStringCreateMutableCopy(kCFAllocatorDefault, 0, string);
        CFStringLowercase(lowercaseString, NULL);
        tokens = _CFHTTPParseCacheControlField(lowercaseString);
        CFRelease(lowercaseString);
    }
    if (!tokens) {
        return cacheControl;
    }

    if (CFDictionaryGetValue(tokens, CFSTR("no-cache"))) {
        cacheControl.noCache = true;
    }
    if (CFDictionaryGetValue(tokens, CFSTR("no-store"))) {
        cacheControl.noStore = true;
    }
    if (CFDictionaryGetValue(tokens, CFSTR("public"))) {
        cacheControl.public = true;
    }
    if (CFDictionaryGetValue(tokens, CFSTR("must-revalidate"))) {
        cacheControl.mustRevalidate = true;
    }
    if (CFDictionaryGetValue(tokens, CFSTR("only-if-cached"))) {
        cacheControl.onlyIfCached = true;
    }

    CFTypeRef maxAge = CFDictionaryGetValue(tokens, CFSTR("max-age"));
    if (maxAge && CFGetTypeID(maxAge) == CFStringGetTypeID()) {
        cacheControl.maxAgeValid = _CFHTTPParseSeconds(&cacheControl.maxAge, (CFStringRef)maxAge);
    }

    CFTypeRef sMaxAge = CFDictionaryGetValue(tokens, CFSTR("s-maxage"));
    if (sMaxAge && CFGetTypeID(sMaxAge) == CFStringGetTypeID()) {
        cacheControl.sMaxAgeValid = _CFHTTPParseSeconds(&cacheControl.sMaxAge, (CFStringRef)sMaxAge);
    }

    CFTypeRef minFresh = CFDictionaryGetValue(tokens, CFSTR("min-fresh"));
    if (minFresh && CFGetTypeID(minFresh) == CFStringGetTypeID()) {
        cacheControl.minFreshValid = _CFHTTPParseSeconds(&cacheControl.minFresh, (CFStringRef)minFresh);
    }

    CFTypeRef maxStale = CFDictionaryGetValue(tokens, CFSTR("max-stale"));
    if (maxStale && CFGetTypeID(maxStale) == CFStringGetTypeID()) {
        cacheControl.maxStaleValid = _CFHTTPParseSeconds(&cacheControl.maxStale, (CFStringRef)maxStale);
    }

    CFRelease(tokens);
    return cacheControl;
}

static Boolean requestHasAuthorization(CFURLRequestRef request) {
    CFStringRef value = CFURLRequestCopyValueForHTTPField(request, CFSTR("Authorization"));
    if (value) {
        CFRelease(value);
        return true;
    } else {
        return false;
    }
}

static CacheControlField requestGetCacheControl(CFURLRequestRef request) {
    CFStringRef value = CFURLRequestCopyValueForHTTPField(request, CFSTR("Cache-Control"));
    CacheControlField result = parseCacheControl(value);
    if (value) {
        CFRelease(value);
    }
    return result;
}

static Boolean requestHasConditions(CFURLRequestRef request) {
    CFStringRef ifModifiedSince = CFURLRequestCopyValueForHTTPField(request, CFSTR("If-Modified-Since"));
    CFStringRef ifNoneMatch = CFURLRequestCopyValueForHTTPField(request, CFSTR("If-None-Match"));
    Boolean hasConditions = (ifModifiedSince || ifNoneMatch);
    if (ifModifiedSince) {
        CFRelease(ifModifiedSince);
    }
    if (ifNoneMatch) {
        CFRelease(ifNoneMatch);
    }
    return hasConditions;
}

// Based on computeAge() from ResponseHeaders.java (http://goo.gl/ncNJYI)
static CFTimeInterval computeAge(CFAbsoluteTime now, CFURLResponseRef response) {
    const ParsedHeaders* headers = parseHeaders(response);

    CFTimeInterval age = 0;
    if (headers->dateValid && response->creationTime > headers->date) {
        age = response->creationTime - headers->date;
    }

    if (headers->ageValid && headers->age > age) {
        age = headers->age;
    }

    return age + (now - response->creationTime);
}

// Based on computeFreshnessLifetime() from ResponseHeaders.java (http://goo.gl/ncNJYI)
static CFTimeInterval computeMaxAge(CFURLResponseRef response) {
    const ParsedHeaders* headers = parseHeaders(response);

    if (headers->cacheControl.maxAgeValid) {
        return headers->cacheControl.maxAge;
    }

    CFAbsoluteTime served = (headers->dateValid ? headers->date : response->creationTime);

    if (headers->expiresValid) {
        if (headers->expires > served) {
            return headers->expires - served;
        } else {
            return 0;
        }
    }

    if (headers->lastModifiedValid) {
        CFRange query = CFURLGetByteRangeForComponent(response->url, kCFURLComponentQuery, NULL);
        if (query.location == kCFNotFound) {
            // As recommended by the HTTP RFC and implemented in Firefox, the
            // max age of a document should be defaulted to 10% of the
            // document's age at the time it was served. Default expiration
            // dates aren't used for URIs containing a query.
            if (served > headers->lastModified) {
                return (served - headers->lastModified) / 10;
            } else {
                return 0;
            }
        }
    }

    return 0;
}

