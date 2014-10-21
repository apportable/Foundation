#ifndef CFNetwork_CFHTTPCookie_h
#define CFNetwork_CFHTTPCookie_h


#include <CoreFoundation/CFBase.h>
#include <CoreFoundation/CFDate.h>
#include <CoreFoundation/CFURL.h>
#include <CoreFoundation/CFNumber.h>
#include <CoreFoundation/CFArray.h>

#if PRAGMA_ONCE
#pragma once
#endif

__BEGIN_DECLS

typedef struct __CFHTTPCookie *CFHTTPCookieRef;

CFHTTPCookieRef CFHTTPCookieCreateWithProperties(CFDictionaryRef properties);
CFNumberRef CFHTTPCookieGetVersion(CFHTTPCookieRef cookie);
CFStringRef CFHTTPCookieGetValue(CFHTTPCookieRef cookie);
CFStringRef CFHTTPCookieGetName(CFHTTPCookieRef cookie);
CFStringRef CFHTTPCookieGetDomain(CFHTTPCookieRef cookie);
CFDateRef CFHTTPCookieGetExpirationDate(CFHTTPCookieRef cookie);
CFStringRef CFHTTPCookieGetPath(CFHTTPCookieRef cookie);
CFStringRef CFHTTPCookieGetComment(CFHTTPCookieRef cookie);
CFURLRef CFHTTPCookieGetCommentURL(CFHTTPCookieRef cookie);
CFStringRef CFHTTPCookieGetPath(CFHTTPCookieRef cookie);
CFArrayRef CFHTTPCookieGetPortArray(CFHTTPCookieRef cookie);
Boolean CFHTTPCookieIsHTTPOnly(CFHTTPCookieRef cookie);
Boolean CFHTTPCookieIsSecure(CFHTTPCookieRef cookie);
Boolean CFHTTPCookieIsSessionOnly(CFHTTPCookieRef cookie);
CFDictionaryRef CFHTTPCookieCopyProperties(CFHTTPCookieRef cookie);
CFDictionaryRef CFHTTPCookieCopyRequestHeaderFields(CFArrayRef cookies);
CFArrayRef CFHTTPCookieCreateWithResponseHeaderFields(CFDictionaryRef headerFields, CFURLRef url);

__END_DECLS
#endif
