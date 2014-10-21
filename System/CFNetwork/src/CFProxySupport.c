//
//  CFProxySupport.c
//  CFNetwork
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#include "CFProxySupport.h"

static CFDictionaryRef copyEmptySystemProxySettings(void) {
    return CFDictionaryCreate(NULL, NULL, NULL, 0, &kCFCopyStringDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
}

static CFDictionaryRef (*copySystemProxySettingsCallback)(void) = &copyEmptySystemProxySettings;

void _CFNetworkSetCopySystemProxySettingsCallback(CFDictionaryRef (*callback)(void)) {
    copySystemProxySettingsCallback = callback;
}

CFDictionaryRef CFNetworkCopySystemProxySettings(void) {
    return copySystemProxySettingsCallback();
}

CFArrayRef CFNetworkCopyProxiesForURL(CFURLRef url, CFDictionaryRef proxySettings) {
    CFDictionaryRef noSettings = CFDictionaryCreate(NULL,
        (CFTypeRef*)&kCFProxyTypeKey, (CFTypeRef*)&kCFProxyTypeNone, 1,
        &kCFCopyStringDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    CFArrayRef proxies = CFArrayCreate(NULL, (CFTypeRef*)&noSettings, 1, &kCFTypeArrayCallBacks);
    CFRelease(noSettings);
    return proxies;
}

CFArrayRef CFNetworkCopyProxiesForAutoConfigurationScript(CFStringRef proxyAutoConfigurationScript, CFURLRef targetURL, CFErrorRef *error) {
    DEBUG_BREAK();
    return NULL;
}

CFRunLoopSourceRef CFNetworkExecuteProxyAutoConfigurationScript(CFStringRef proxyAutoConfigurationScript, CFURLRef targetURL, CFProxyAutoConfigurationResultCallback cb, CFStreamClientContext *clientContext) {
    DEBUG_BREAK();
    return NULL;
}

CFRunLoopSourceRef CFNetworkExecuteProxyAutoConfigurationURL(CFURLRef proxyAutoConfigURL, CFURLRef targetURL, CFProxyAutoConfigurationResultCallback cb, CFStreamClientContext *clientContext) {
    DEBUG_BREAK();
    return NULL;
}

const CFStringRef kCFProxyTypeKey = CFSTR("kCFProxyTypeKey");
const CFStringRef kCFProxyPortNumberKey = CFSTR("kCFProxyPortNumberKey");
const CFStringRef kCFProxyAutoConfigurationURLKey = CFSTR("kCFProxyAutoConfigurationURLKey");
const CFStringRef kCFProxyAutoConfigurationJavaScriptKey = CFSTR("kCFProxyAutoConfigurationJavaScriptKey");
const CFStringRef kCFProxyUsernameKey = CFSTR("kCFProxyUsernameKey");
const CFStringRef kCFProxyPasswordKey = CFSTR("kCFProxyPasswordKey");
const CFStringRef kCFProxyHostNameKey = CFSTR("kCFProxyHostNameKey");
const CFStringRef kCFProxyTypeNone = CFSTR("kCFProxyTypeNone");
const CFStringRef kCFProxyTypeHTTP = CFSTR("kCFProxyTypeHTTP");
const CFStringRef kCFProxyTypeHTTPS = CFSTR("kCFProxyTypeHTTPS");
const CFStringRef kCFProxyTypeSOCKS = CFSTR("kCFProxyTypeSOCKS");
const CFStringRef kCFProxyTypeFTP = CFSTR("kCFProxyTypeFTP");
const CFStringRef kCFProxyTypeAutoConfigurationURL = CFSTR("kCFProxyTypeAutoConfigurationURL");
const CFStringRef kCFProxyTypeAutoConfigurationJavaScript = CFSTR("kCFProxyTypeAutoConfigurationJavaScript");
const CFStringRef kCFNetworkProxiesExceptionsList = CFSTR("ExceptionsList");
const CFStringRef kCFNetworkProxiesExcludeSimpleHostnames = CFSTR("ExcludeSimpleHostnames");
const CFStringRef kCFNetworkProxiesFTPEnable = CFSTR("FTPEnable");
const CFStringRef kCFNetworkProxiesFTPPassive = CFSTR("FTPPassive");
const CFStringRef kCFNetworkProxiesFTPPort = CFSTR("FTPPort");
const CFStringRef kCFNetworkProxiesFTPProxy = CFSTR("FTPProxy");
const CFStringRef kCFNetworkProxiesGopherEnable = CFSTR("GopherEnable");
const CFStringRef kCFNetworkProxiesGopherPort = CFSTR("GopherPort");
const CFStringRef kCFNetworkProxiesGopherProxy = CFSTR("GopherProxy");
const CFStringRef kCFNetworkProxiesHTTPEnable = CFSTR("HTTPEnable");
const CFStringRef kCFNetworkProxiesHTTPPort = CFSTR("HTTPPort");
const CFStringRef kCFNetworkProxiesHTTPProxy = CFSTR("HTTPProxy");
const CFStringRef kCFNetworkProxiesHTTPSEnable = CFSTR("HTTPSEnable");
const CFStringRef kCFNetworkProxiesHTTPSPort = CFSTR("HTTPSPort");
const CFStringRef kCFNetworkProxiesHTTPSProxy = CFSTR("HTTPSProxy");
const CFStringRef kCFNetworkProxiesRTSPEnable = CFSTR("RTSPEnable");
const CFStringRef kCFNetworkProxiesRTSPPort = CFSTR("RTSPPort");
const CFStringRef kCFNetworkProxiesRTSPProxy = CFSTR("RTSPProxy");
const CFStringRef kCFNetworkProxiesSOCKSEnable = CFSTR("SOCKSEnable");
const CFStringRef kCFNetworkProxiesSOCKSPort = CFSTR("SOCKSPort");
const CFStringRef kCFNetworkProxiesSOCKSProxy = CFSTR("SOCKSProxy");
const CFStringRef kCFNetworkProxiesProxyAutoConfigEnable = CFSTR("ProxyAutoConfigEnable");
const CFStringRef kCFNetworkProxiesProxyAutoConfigURLString = CFSTR("ProxyAutoConfigURLString");
const CFStringRef kCFNetworkProxiesProxyAutoDiscoveryEnable = CFSTR("ProxyAutoDiscoveryEnable");
