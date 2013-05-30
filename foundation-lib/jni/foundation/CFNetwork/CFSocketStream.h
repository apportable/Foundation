//
//  CFSocketStream.h
// 
//
//  Created by Philippe Hausler on 11/16/11.
//  Copyright (c) 2011 Apportable. All rights reserved.
//

#ifndef _CFSOCKETSTREAM_H_
#define _CFSOCKETSTREAM_H_

#include <CoreFoundation/CFString.h>
#include <CoreFoundation/CFStream.h>

#ifdef __cplusplus
extern "C" {
#endif

extern const int kCFStreamErrorDomainSSL;

extern const int kCFStreamErrorDomainSOCKS;

extern const CFIndex kCFStreamErrorDomainWinSock;

extern const CFStringRef kCFStreamPropertySSLContext;
extern const CFStringRef kCFStreamPropertySSLPeerTrust;
extern const CFStringRef kCFStreamSSLValidatesCertificateChain;
extern const CFStringRef kCFStreamPropertySSLSettings;
extern const CFStringRef kCFStreamSSLLevel;
extern const CFStringRef kCFStreamSSLPeerName;
extern const CFStringRef kCFStreamSSLCertificates;
extern const CFStringRef kCFStreamSSLIsServer;
extern const CFStringRef kCFStreamPropertySSLPeerCertificates;
extern const CFStringRef kCFStreamSSLAllowsExpiredCertificates;
extern const CFStringRef kCFStreamSSLAllowsExpiredRoots;
extern const CFStringRef kCFStreamSSLAllowsAnyRoot;

extern const CFStringRef kCFStreamPropertySocketSecurityLevel;
extern const CFStringRef kCFStreamSocketSecurityLevelNone;
extern const CFStringRef kCFStreamSocketSecurityLevelSSLv2;
extern const CFStringRef kCFStreamSocketSecurityLevelSSLv3;
extern const CFStringRef kCFStreamSocketSecurityLevelTLSv1;
extern const CFStringRef kCFStreamSocketSecurityLevelNegotiatedSSL;

extern const CFStringRef kCFStreamNetworkServiceType;
extern const CFStringRef kCFStreamNetworkServiceTypeVoIP;
extern const CFStringRef kCFStreamNetworkServiceTypeVideo;
extern const CFStringRef kCFStreamNetworkServiceTypeBackground;
extern const CFStringRef kCFStreamNetworkServiceTypeVoice;

extern const CFStringRef kCFStreamPropertySOCKSProxy;
extern const CFStringRef kCFStreamPropertySOCKSProxyHost;
extern const CFStringRef kCFStreamPropertySOCKSProxyPort;
extern const CFStringRef kCFStreamPropertySOCKSVersion;
extern const CFStringRef kCFStreamSocketSOCKSVersion4;
extern const CFStringRef kCFStreamSocketSOCKSVersion5;
extern const CFStringRef kCFStreamPropertySOCKSUser;
extern const CFStringRef kCFStreamPropertySOCKSPassword;

extern const CFStringRef kCFStreamPropertyShouldCloseNativeSocket;
extern const CFStringRef kCFStreamPropertySocketRemoteHost;
extern const CFStringRef kCFStreamPropertySocketRemoteNetService;

inline SInt32 CFSocketStreamSOCKSGetErrorSubdomain(const CFStreamError* error) {
	return ((error->error >> 16) & 0x0000FFFF);
}

inline SInt32 CFSocketStreamSOCKSGetError(const CFStreamError* error) {
	return (error->error & 0x0000FFFF);
}

enum {
    kCFStreamErrorSOCKSSubDomainNone = 0, 
    kCFStreamErrorSOCKSSubDomainVersionCode = 1, 
    kCFStreamErrorSOCKS4SubDomainResponse = 2, 
    kCFStreamErrorSOCKS5SubDomainUserPass = 3, 
    kCFStreamErrorSOCKS5SubDomainMethod = 4, 
    kCFStreamErrorSOCKS5SubDomainResponse = 5 
};

enum {
    kCFStreamErrorSOCKS5BadResponseAddr = 1,
    kCFStreamErrorSOCKS5BadState = 2,
    kCFStreamErrorSOCKSUnknownClientVersion = 3
};

enum {
    kCFStreamErrorSOCKS4RequestFailed = 91, 
    kCFStreamErrorSOCKS4IdentdFailed = 92, 
    kCFStreamErrorSOCKS4IdConflict = 93   
};

enum {
    kSOCKS5NoAcceptableMethod = 0xFF  
};
    
#ifdef __cplusplus
}
#endif

#endif /* _CFSOCKETSTREAM_H_ */

