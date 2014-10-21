#ifndef __CFFSUTILS__
#define __CFFSUTILS__

#include <CoreFoundation/CoreFoundation.h>
#include <sys/stat.h>

CF_EXTERN_C_BEGIN

/*
 * All functions set errno on failure.
 */

/* Wrappers */

CF_EXPORT int _CFFSOpen(CFStringRef path, int flags, int mode);
CF_EXPORT int _CFFSUnlink(CFStringRef path);
CF_EXPORT CFStringRef _CFFSRealpath(CFStringRef path); // CFRelease() result
CF_EXPORT int _CFFSStat(CFStringRef path, struct stat* st);

/* Helpers */

CF_EXPORT char* _CFFSCreateRepresentation(CFStringRef path); // free() result
CF_EXPORT Boolean _CFFSIsSamePath(CFStringRef path1, CFStringRef path2);
CF_EXPORT void _CFFSAppendPathComponent(CFStringRef* result, // CFRelease() result
                                        CFStringRef path,
                                        CFStringRef component);
CF_EXPORT void _CFFSGetLastPathComponent(CFStringRef* result, // CFRelease() result
                                         CFStringRef path);
CF_EXPORT Boolean _CFFSCheckCreateDirectory(CFStringRef path);

CF_EXPORT Boolean _CFFSWriteDataToFile(CFDataRef data, CFStringRef filePath);
CF_EXPORT Boolean _CFFSCreateDataFromFile(CFDataRef* data, // CFRelease() data
                                          CFStringRef filePath);
CF_EXPORT Boolean _CFFSWritePropertyListToFile(CFPropertyListRef plist, CFStringRef filePath);
CF_EXPORT Boolean _CFFSCreatePropertyListFromFile(CFPropertyListRef* plist, // CFRelease() plist
                                                  CFStringRef filePath);

CF_EXPORT Boolean _CFFSListPathContents(CFStringRef path,
                                        CFMutableArrayRef* files, // CFRelease() files
                                        CFMutableArrayRef* directories); // CFRelease() directories

CF_EXTERN_C_END

#endif // __CFFSUTILS__
