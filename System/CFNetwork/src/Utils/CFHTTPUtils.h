#ifndef __CFHTTPUTILS__
#define __CFHTTPUTILS__

#include <CoreFoundation/CoreFoundation.h>

CF_EXTERN_C_BEGIN

CF_EXPORT CFIndex _CFHTTPSkipUntil(const UniChar* string, CFIndex pos, const char* stopChars);
CF_EXPORT CFIndex _CFHTTPSkipWhitespace(const UniChar* string, CFIndex pos, CFIndex delta);

CF_EXPORT CFDictionaryRef _CFHTTPParseCacheControlField(CFStringRef string); // CFRelease() result

CF_EXPORT Boolean _CFHTTPParseSeconds(CFTimeInterval* seconds, CFStringRef string);

CF_EXPORT Boolean _CFHTTPParseContentTypeField(CFStringRef* textEncoding, // CFRelease() textEncoding
                                               CFStringRef* mimeType, // CFRelease() mimeType
                                               CFStringRef string);

CF_EXPORT Boolean _CFHTTPParseDateField(CFAbsoluteTime* date, CFStringRef string);

CF_EXPORT CFArrayRef _CFHTTPParseVaryField(CFStringRef string); // CFRelease() result

CF_EXTERN_C_END

#endif // __CFHTTPUTILS__
