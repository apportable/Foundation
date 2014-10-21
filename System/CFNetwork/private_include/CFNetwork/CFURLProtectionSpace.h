#ifndef __CFURLPROTECTIONSPACE__
#define __CFURLPROTECTIONSPACE__

#include <CoreFoundation/CFArray.h>
#include <CoreFoundation/CFString.h>
#include <Security/Security.h>

#if PRAGMA_ONCE
#pragma once
#endif

typedef CF_ENUM(UInt32, CFURLProtectionSpaceServerType) {
    kCFURLProtectionSpaceServerHTTP,
    kCFURLProtectionSpaceServerHTTPS,
    kCFURLProtectionSpaceServerFTP,
    kCFURLProtectionSpaceProxyHTTP,
    kCFURLProtectionSpaceProxyHTTPS,
    kCFURLProtectionSpaceProxyFTP,
    kCFURLProtectionSpaceProxySOCKS,
};

typedef CF_ENUM(UInt32, CFURLProtectionSpaceAuthenticationSchemeType) {
    kCFURLProtectionSpaceAuthenticationSchemeDefault,
    kCFURLProtectionSpaceAuthenticationSchemeHTTPBasic,
    kCFURLProtectionSpaceAuthenticationSchemeHTTPDigest,
    kCFURLProtectionSpaceAuthenticationSchemeHTMLForm,
    kCFURLProtectionSpaceAuthenticationSchemeNTLM,
    kCFURLProtectionSpaceAuthenticationSchemeNegotiate,
    kCFURLProtectionSpaceAuthenticationSchemeServerTrustEvaluationRequested,
    kCFURLProtectionSpaceAuthenticationSchemeClientCertificateRequested,
};

__BEGIN_DECLS

typedef const struct _CFURLProtectionSpace *CFURLProtectionSpaceRef;

CFURLProtectionSpaceRef CFURLProtectionSpaceCreate(CFAllocatorRef allocator, CFStringRef host, CFIndex port, CFURLProtectionSpaceServerType serverType, CFStringRef realm, CFURLProtectionSpaceAuthenticationSchemeType scheme);
CFURLProtectionSpaceAuthenticationSchemeType CFURLProtectionSpaceGetAuthenticationScheme(CFURLProtectionSpaceRef space);
CFArrayRef CFURLProtectionSpaceGetDistinguishedNames(CFURLProtectionSpaceRef space);
CFStringRef CFURLProtectionSpaceGetHost(CFURLProtectionSpaceRef space);
CFIndex CFURLProtectionSpaceGetPort(CFURLProtectionSpaceRef space);
CFStringRef CFURLProtectionSpaceGetRealm(CFURLProtectionSpaceRef space);
SecTrustRef CFURLProtectionSpaceGetServerTrust(CFURLProtectionSpaceRef space);
CFURLProtectionSpaceServerType CFURLProtectionSpaceGetServerType(CFURLProtectionSpaceRef space);
Boolean CFURLProtectionSpaceIsProxy(CFURLProtectionSpaceRef space);
Boolean CFURLProtectionSpaceReceivesCredentialSecurely(CFURLProtectionSpaceRef space);

__END_DECLS

#endif
