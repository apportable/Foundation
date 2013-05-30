//
//  CFProxySupport.h
// 
//
//  Created by Philippe Hausler on 11/16/11.
//  Copyright (c) 2011 Apportable. All rights reserved.
//

#ifndef _CFPROXYSUPPORT_H_
#define _CFPROXYSUPPORT_H_

#include <CoreFoundation/CFString.h>
#include <CoreFoundation/CFArray.h>
#include <CoreFoundation/CFDictionary.h>
#include <CoreFoundation/CFError.h>
#include <CoreFoundation/CFURL.h>

#ifdef __cplusplus
extern "C" {
#endif

extern const CFStringRef kCFProxyTypeKey;
extern const CFStringRef kCFProxyHostNameKey;
extern const CFStringRef kCFProxyPortNumberKey;
extern const CFStringRef kCFProxyAutoConfigurationURLKey;
extern const CFStringRef kCFProxyAutoConfigurationJavaScriptKey;
extern const CFStringRef kCFProxyUsernameKey;
extern const CFStringRef kCFProxyPasswordKey;
extern const CFStringRef kCFProxyTypeNone;
extern const CFStringRef kCFProxyTypeHTTP;
extern const CFStringRef kCFProxyTypeHTTPS;
extern const CFStringRef kCFProxyTypeSOCKS;
extern const CFStringRef kCFProxyTypeFTP;
extern const CFStringRef kCFProxyTypeAutoConfigurationURL;
extern const CFStringRef kCFProxyTypeAutoConfigurationJavaScript;

    
extern CFDictionaryRef CFNetworkCopySystemProxySettings(void);
extern CFArrayRef CFNetworkCopyProxiesForURL(CFURLRef url, CFDictionaryRef proxySettings);
extern CFArrayRef CFNetworkCopyProxiesForAutoConfigurationScript(CFStringRef proxyAutoConfigurationScript, CFURLRef targetURL, CFErrorRef *error);
#ifdef __cplusplus
}
#endif

#endif /* _CFPROXYSUPPORT_H_ */