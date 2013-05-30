//
//  CFHTTPMessage.h
// 
//
//  Created by Philippe Hausler on 11/16/11.
//  Copyright (c) 2011 Apportable. All rights reserved.
//

#ifndef _CFHTTPMESSAGE_H_
#define _CFHTTPMESSAGE_H_

#include <CoreFoundation/CFString.h>

#ifdef __cplusplus
extern "C" {
#endif
    
typedef struct __CFHTTPMessage *CFHTTPMessageRef;

extern const CFStringRef kCFHTTPVersion1_0;
extern const CFStringRef kCFHTTPVersion1_1;

extern CFHTTPMessageRef CFHTTPMessageCreateRequest(CFAllocatorRef allocator, CFStringRef method, CFURLRef url, CFStringRef version);
extern void CFHTTPMessageSetHeaderFieldValue(CFHTTPMessageRef message, CFStringRef field, CFStringRef value);
extern Boolean CFHTTPMessageIsHeaderComplete(CFHTTPMessageRef message);
extern CFStringRef CFHTTPMessageCopyVersion(CFHTTPMessageRef message);
extern CFDictionaryRef CFHTTPMessageCopyAllHeaderFields(CFHTTPMessageRef message);
extern CFIndex CFHTTPMessageGetResponseStatusCode(CFHTTPMessageRef response);
extern CFStringRef CFHTTPMessageCopyResponseStatusLine(CFHTTPMessageRef response);

#ifdef __cplusplus
}
#endif
    
#endif /* _CFHTTPMESSAGE_H_ */