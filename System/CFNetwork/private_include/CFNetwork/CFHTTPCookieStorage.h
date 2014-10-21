#ifndef CFNetwork_CFHTTPCookieStorage_h
#define CFNetwork_CFHTTPCookieStorage_h

#include <CoreFoundation/CFBase.h>
#include "CFHTTPCookie.h"
#if PRAGMA_ONCE
#pragma once
#endif

__BEGIN_DECLS

typedef struct __CFHTTPCookieStorage *CFHTTPCookieStorageRef;


CFHTTPCookieStorageRef CFHTTPCookieStorageGetDefault();
void CFHTTPCookieStorageDeleteCookie(CFHTTPCookieStorageRef storage, CFHTTPCookieRef cookie);
void CFHTTPCookieStorageSetCookie(CFHTTPCookieStorageRef storage, CFHTTPCookieRef cookie);
void CFHTTPCookieStorageSetCookies(CFHTTPCookieStorageRef storage, CFArrayRef cookies);
CFArrayRef CFHTTPCookieStorageCopyCookies(CFHTTPCookieStorageRef storage);
CFArrayRef CFHTTPCookieStorageCopyCookiesForURL(CFHTTPCookieStorageRef storage, CFURLRef url);

void CFHTTPCookieStorageSetCookiesWithResponseHeaderFields(CFHTTPCookieStorageRef storage, CFDictionaryRef headerFields, CFURLRef url);
CFDictionaryRef CFHTTPCookieStorageCopyRequestHeaderFieldsForURL(CFHTTPCookieStorageRef storage, CFURLRef url);


__END_DECLS
#endif
