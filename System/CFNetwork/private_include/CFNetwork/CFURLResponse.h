#ifndef __CFURLRESPONSE__
#define __CFURLRESPONSE__

#include <CoreFoundation/CFData.h>
#include <CoreFoundation/CFString.h>
#include <CoreFoundation/CFURL.h>
#include <CoreFoundation/CFStream.h>
#include <CoreFoundation/CFArray.h>
#include <CFNetwork/CFHTTPMessage.h>
#include "CFURLRequest.h"

CF_EXTERN_C_BEGIN

typedef enum {
    kCFURLResponseSourceNetwork,
    kCFURLResponseSourceCache,
#ifdef TODO_CONDITIONAL_CACHE
    kCFURLResponseSourceConditionalCache
#endif
} CFURLResponseSource;

typedef const struct _CFURLResponse* CFURLResponseRef;

CF_EXPORT
CFURLResponseRef CFURLResponseCreate(CFAllocatorRef allocator,
                                     CFURLRef url,
                                     CFStringRef mimeType,
                                     int64_t length,
                                     CFStringRef textEncoding);

CF_EXPORT
CFURLResponseRef CFURLResponseCreateWithCFHTTPMessage(CFAllocatorRef allocator,
                                                      CFURLRef request,
                                                      CFHTTPMessageRef responseMessage);

CF_EXPORT
CFURLResponseRef CFURLResponseCreateCopy(CFAllocatorRef allocator,
                                         CFURLResponseRef response);

CF_EXPORT
CFAbsoluteTime CFURLResponseGetCreationTime(CFURLResponseRef response);

CF_EXPORT
CFURLRef CFURLResponseGetURL(CFURLResponseRef response);

CF_EXPORT
CFStringRef CFURLResponseGetMIMEType(CFURLResponseRef response);

CF_EXPORT
int64_t CFURLResponseGetExpectedContentLength(CFURLResponseRef response);

CF_EXPORT
CFStringRef CFURLResponseGetTextEncodingName(CFURLResponseRef response);

CF_EXPORT
CFStringRef CFURLResponseCopySuggestedFilename(CFURLResponseRef response);

CF_EXPORT
CFIndex CFURLResponseGetStatusCode(CFURLResponseRef response);

CF_EXPORT
CFDictionaryRef CFURLResponseGetHeaderFields(CFURLResponseRef response);

CF_EXPORT
Boolean CFURLResponseIsHTTPResponse(CFURLResponseRef response);

CF_EXPORT
CFURLResponseRef _CFURLResponseCreateFromParcel(CFAllocatorRef allocator, CFPropertyListRef parcel);

CF_EXPORT
CFPropertyListRef _CFURLResponseCreateParcel(CFURLResponseRef response);

CF_EXPORT
Boolean _CFURLResponseIsCacheableWithRequest(CFURLResponseRef response, CFURLRequestRef request);

CF_EXPORT
CFURLResponseSource _CFURLResponseChooseSourceWithRequest(CFURLResponseRef response,
                                                          CFURLRequestRef request,
                                                          CFAbsoluteTime now);

CF_EXTERN_C_END

#endif // __CFURLRESPONSE__
