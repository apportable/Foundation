#ifndef __CFPROXYSUPPORT__
#define __CFPROXYSUPPORT__

#ifndef __CFNETWORKDEFS__
#include <CFNetwork/CFNetworkDefs.h>
#endif

#ifndef __CFARRAY__
#include <CoreFoundation/CFArray.h>
#endif

#ifndef __CFSTRING__
#include <CoreFoundation/CFString.h>
#endif

#ifndef __CFURL__
#include <CoreFoundation/CFURL.h>
#endif

#ifndef __CFERROR__
#include <CoreFoundation/CFError.h>
#endif

#ifndef __CFRUNLOOP__
#include <CoreFoundation/CFRunLoop.h>
#endif

#ifndef __CFSTREAM__
#include <CoreFoundation/CFStream.h>
#endif

#include <Availability.h>

#if PRAGMA_ONCE
#pragma once
#endif

__BEGIN_DECLS

typedef CALLBACK_API_C( void , CFProxyAutoConfigurationResultCallback )(void *client, CFArrayRef proxyList, CFErrorRef error);

CFN_EXPORT CFDictionaryRef CFNetworkCopySystemProxySettings(void);
CFN_EXPORT CFArrayRef CFNetworkCopyProxiesForURL(CFURLRef url, CFDictionaryRef proxySettings);
CFN_EXPORT CFArrayRef CFNetworkCopyProxiesForAutoConfigurationScript(CFStringRef proxyAutoConfigurationScript, CFURLRef targetURL, CFErrorRef *error);
CFN_EXPORT CFRunLoopSourceRef CFNetworkExecuteProxyAutoConfigurationScript(CFStringRef proxyAutoConfigurationScript, CFURLRef targetURL, CFProxyAutoConfigurationResultCallback cb, CFStreamClientContext *clientContext);
CFN_EXPORT CFRunLoopSourceRef CFNetworkExecuteProxyAutoConfigurationURL(CFURLRef proxyAutoConfigURL, CFURLRef targetURL, CFProxyAutoConfigurationResultCallback cb, CFStreamClientContext *clientContext);

CFN_EXPORT const CFStringRef kCFProxyTypeKey;
CFN_EXPORT const CFStringRef kCFProxyPortNumberKey;
CFN_EXPORT const CFStringRef kCFProxyAutoConfigurationURLKey;
CFN_EXPORT const CFStringRef kCFProxyAutoConfigurationJavaScriptKey;
CFN_EXPORT const CFStringRef kCFProxyUsernameKey;
CFN_EXPORT const CFStringRef kCFProxyPasswordKey;
CFN_EXPORT const CFStringRef kCFProxyHostNameKey;
CFN_EXPORT const CFStringRef kCFProxyTypeNone;
CFN_EXPORT const CFStringRef kCFProxyTypeHTTP;
CFN_EXPORT const CFStringRef kCFProxyTypeHTTPS;
CFN_EXPORT const CFStringRef kCFProxyTypeSOCKS;
CFN_EXPORT const CFStringRef kCFProxyTypeFTP;
CFN_EXPORT const CFStringRef kCFProxyTypeAutoConfigurationURL;
CFN_EXPORT const CFStringRef kCFProxyTypeAutoConfigurationJavaScript;
CFN_EXPORT const CFStringRef kCFProxyAutoConfigurationHTTPResponseKey;
CFN_EXPORT const CFStringRef kCFNetworkProxiesExceptionsList;
CFN_EXPORT const CFStringRef kCFNetworkProxiesExcludeSimpleHostnames;
CFN_EXPORT const CFStringRef kCFNetworkProxiesFTPEnable;
CFN_EXPORT const CFStringRef kCFNetworkProxiesFTPPassive;
CFN_EXPORT const CFStringRef kCFNetworkProxiesFTPPort;
CFN_EXPORT const CFStringRef kCFNetworkProxiesFTPProxy;
CFN_EXPORT const CFStringRef kCFNetworkProxiesGopherEnable;
CFN_EXPORT const CFStringRef kCFNetworkProxiesGopherPort;
CFN_EXPORT const CFStringRef kCFNetworkProxiesGopherProxy;
CFN_EXPORT const CFStringRef kCFNetworkProxiesHTTPEnable;
CFN_EXPORT const CFStringRef kCFNetworkProxiesHTTPPort;
CFN_EXPORT const CFStringRef kCFNetworkProxiesHTTPProxy;
CFN_EXPORT const CFStringRef kCFNetworkProxiesHTTPSEnable;
CFN_EXPORT const CFStringRef kCFNetworkProxiesHTTPSPort;
CFN_EXPORT const CFStringRef kCFNetworkProxiesHTTPSProxy;
CFN_EXPORT const CFStringRef kCFNetworkProxiesRTSPEnable;
CFN_EXPORT const CFStringRef kCFNetworkProxiesRTSPPort;
CFN_EXPORT const CFStringRef kCFNetworkProxiesRTSPProxy;
CFN_EXPORT const CFStringRef kCFNetworkProxiesSOCKSEnable;
CFN_EXPORT const CFStringRef kCFNetworkProxiesSOCKSPort;
CFN_EXPORT const CFStringRef kCFNetworkProxiesSOCKSProxy;
CFN_EXPORT const CFStringRef kCFNetworkProxiesProxyAutoConfigEnable;
CFN_EXPORT const CFStringRef kCFNetworkProxiesProxyAutoConfigURLString;
CFN_EXPORT const CFStringRef kCFNetworkProxiesProxyAutoConfigJavaScript;
CFN_EXPORT const CFStringRef kCFNetworkProxiesProxyAutoDiscoveryEnable;

__END_DECLS

#endif
