//
//  CFHTTPAuthentication.h
// 
//
//  Created by Philippe Hausler on 11/16/11.
//  Copyright (c) 2011 Apportable. All rights reserved.
//

#ifndef _CFHTTPAUTHENTICATION_H_
#define _CFHTTPAUTHENTICATION_H_

#include <CFNetwork/CFHTTPMessage.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef struct __CFHTTPAuthentication *CFHTTPAuthenticationRef;

typedef enum {
    kCFStreamErrorHTTPAuthenticationTypeUnsupported = -1000,
    kCFStreamErrorHTTPAuthenticationBadUserName = -1001,
    kCFStreamErrorHTTPAuthenticationBadPassword = -1002
} CFStreamErrorHTTPAuthentication;
    
extern const CFStringRef kCFHTTPAuthenticationSchemeBasic;
extern const CFStringRef kCFHTTPAuthenticationSchemeDigest;
extern const CFStringRef kCFHTTPAuthenticationSchemeNTLM;
extern const CFStringRef kCFHTTPAuthenticationSchemeNegotiate;
extern const CFStringRef kCFHTTPAuthenticationSchemeNegotiate2;
extern const CFStringRef kCFHTTPAuthenticationSchemeXMobileMeAuthToken;


extern const CFStringRef kCFHTTPAuthenticationUsername;
extern const CFStringRef kCFHTTPAuthenticationPassword;
extern const CFStringRef kCFHTTPAuthenticationAccountDomain;
    
extern CFHTTPAuthenticationRef CFHTTPAuthenticationCreateFromResponse(CFAllocatorRef alloc, CFHTTPMessageRef response);
extern Boolean CFHTTPAuthenticationIsValid(CFHTTPAuthenticationRef auth, CFStreamError *error);
extern Boolean CFHTTPAuthenticationAppliesToRequest(CFHTTPAuthenticationRef auth, CFHTTPMessageRef request);
extern Boolean CFHTTPAuthenticationRequiresOrderedRequests(CFHTTPAuthenticationRef auth);
extern Boolean CFHTTPMessageApplyCredentials(CFHTTPMessageRef request, CFHTTPAuthenticationRef auth, CFStringRef username, CFStringRef password, CFStreamError *error);
extern Boolean CFHTTPMessageApplyCredentialDictionary(CFHTTPMessageRef request, CFHTTPAuthenticationRef auth, CFDictionaryRef dict, CFStreamError *error);
extern CFStringRef CFHTTPAuthenticationCopyRealm(CFHTTPAuthenticationRef auth);
extern CFArrayRef CFHTTPAuthenticationCopyDomains(CFHTTPAuthenticationRef auth);
extern CFStringRef CFHTTPAuthenticationCopyMethod(CFHTTPAuthenticationRef auth);
extern Boolean CFHTTPAuthenticationRequiresUserNameAndPassword(CFHTTPAuthenticationRef auth);
extern Boolean CFHTTPAuthenticationRequiresAccountDomain(CFHTTPAuthenticationRef auth);
#ifdef __cplusplus
}
#endif
    
#endif