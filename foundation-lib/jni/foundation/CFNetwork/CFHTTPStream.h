//
//  CFHTTPStream.h
// 
//
//  Created by Philippe Hausler on 11/16/11.
//  Copyright (c) 2011 Apportable. All rights reserved.
//

#ifndef _CFHTTPSTREAM_H_
#define _CFHTTPSTREAM_H_

#include <CoreFoundation/CFString.h>
#include <CoreFoundation/CFStream.h>
#include <CFNetwork/CFHTTPMessage.h>

#ifdef __cplusplus
extern "C" {
#endif


extern const SInt32 kCFStreamErrorDomainHTTP;

typedef enum {
    kCFStreamErrorHTTPParseFailure = -1,
    kCFStreamErrorHTTPRedirectionLoop = -2,
    kCFStreamErrorHTTPBadURL	  = -3
} CFStreamErrorHTTP;

extern const CFStringRef kCFStreamPropertyHTTPResponseHeader;
extern const CFStringRef kCFStreamPropertyHTTPFinalURL;
extern const CFStringRef kCFStreamPropertyHTTPFinalRequest;
extern const CFStringRef kCFStreamPropertyHTTPProxy;
extern const CFStringRef kCFStreamPropertyHTTPProxyHost;
extern const CFStringRef kCFStreamPropertyHTTPProxyPort;
extern const CFStringRef kCFStreamPropertyHTTPSProxyHost;
extern const CFStringRef kCFStreamPropertyHTTPSProxyPort;
extern const CFStringRef kCFStreamPropertyHTTPShouldAutoredirect;
extern const CFStringRef kCFStreamPropertyHTTPAttemptPersistentConnection;
extern const CFStringRef kCFStreamPropertyHTTPRequestBytesWrittenCount;

extern CFReadStreamRef CFReadStreamCreateForHTTPRequest(CFAllocatorRef alloc, CFHTTPMessageRef request);
    
extern CFReadStreamRef CFReadStreamCreateForStreamedHTTPRequest(CFAllocatorRef alloc, CFHTTPMessageRef requestHeaders, CFReadStreamRef requestBody);
    
#ifdef __cplusplus
}
#endif

#endif /* _CFHTTPSTREAM_H_ */