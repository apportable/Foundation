#import <Foundation/NSURL.h>
#import "CFPriv.h"
#import <CoreFoundation/CFURL.h>

CF_EXPORT CFURLRef _CFURLAlloc(CFAllocatorRef allocator);
CF_EXPORT void _CFURLInitWithString(CFURLRef url, CFStringRef string, CFURLRef baseURL);
CF_EXPORT void _CFURLInitFSPath(CFURLRef url, CFStringRef path);
CF_EXPORT Boolean _CFStringIsLegalURLString(CFStringRef string);
CF_EXPORT void *__CFURLReservedPtr(CFURLRef  url);
CF_EXPORT void __CFURLSetReservedPtr(CFURLRef  url, void *ptr);
CF_EXPORT CFStringEncoding _CFURLGetEncoding(CFURLRef url);
CF_EXPORT Boolean _CFURLIsFileReferenceURL(CFURLRef url);
CF_EXPORT Boolean _CFURLCopyComponents(CFURLRef url, CFURLComponentDecomposition decompositionType, void *components);
CF_EXPORT Boolean _CFURLIsFileURL(CFURLRef url);
CF_EXPORT void *__CFURLResourceInfoPtr(CFURLRef url);
CF_EXPORT void __CFURLSetResourceInfoPtr(CFURLRef url, void *ptr);
@interface NSURL (Internal)
- (CFURLRef)_cfurl;
@end
