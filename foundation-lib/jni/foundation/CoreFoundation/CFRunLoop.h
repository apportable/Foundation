//
// CFRunLoop.h
//
// Copyright Apportable Inc. All rights reserved.
//

#ifndef _CFRUNLOOP_H_
#define _CFRUNLOOP_H_

#include <CoreFoundation/CFBase.h>
#include <CoreFoundation/CFString.h>
#include <CoreFoundation/CFDate.h>

__BEGIN_DECLS

enum {
    kCFRunLoopRunFinished      = 1,
    kCFRunLoopRunStopped       = 2,
    kCFRunLoopRunTimedOut      = 3,
    kCFRunLoopRunHandledSource = 4,
};

CF_EXPORT const CFStringRef kCFRunLoopDefaultMode;
CF_EXPORT const CFStringRef kCFRunLoopCommonModes;

typedef struct __CFRunLoop *CFRunLoopRef;
typedef struct __CFRunLoopSource *CFRunLoopSourceRef;
typedef struct __CFRunLoopTimer *CFRunLoopTimerRef;

typedef struct {
    CFIndex version;
    void *info;
    const void *(*retain)(const void *info);
    void (*release)(const void *info);
    CFStringRef (*copyDescription)(const void *info);
    Boolean (*equal)(const void *info1, const void *info2);
    CFHashCode (*hash)(const void *info);
    void (*schedule)(void *info, CFRunLoopRef rl, CFStringRef mode);
    void (*cancel)(void *info, CFRunLoopRef rl, CFStringRef mode);
    void (*perform)(void *info);
} CFRunLoopSourceContext;


CF_EXPORT CFRunLoopRef CFRunLoopGetCurrent(void);
CF_EXPORT CFRunLoopRef CFRunLoopGetMain(void);

CF_EXPORT void CFRunLoopRun(void);
CF_EXPORT void CFRunLoopStop(CFRunLoopRef rl);

CF_EXPORT SInt32 CFRunLoopRunInMode(CFStringRef mode, CFTimeInterval seconds, Boolean returnAfterSourceHandled);

CF_EXPORT void CFRunLoopAddTimer(CFRunLoopRef rl, CFRunLoopTimerRef timer, CFStringRef mode);
CF_EXPORT void CFRunLoopRemoveTimer(CFRunLoopRef rl, CFRunLoopTimerRef timer, CFStringRef mode);

CF_EXPORT void CFRunLoopAddSource(CFRunLoopRef rl, CFRunLoopSourceRef source, CFStringRef mode);
CF_EXPORT void CFRunLoopRemoveSource(CFRunLoopRef rl, CFRunLoopSourceRef source, CFStringRef mode);

CF_EXPORT CFRunLoopSourceRef CFRunLoopSourceCreate(CFAllocatorRef allocator, CFIndex order, CFRunLoopSourceContext *context);
CF_EXPORT void CFRunLoopWakeUp(CFRunLoopRef rl);
CF_EXPORT void CFRunLoopSourceSignal(CFRunLoopSourceRef source);
CF_EXPORT void CFRunLoopSourceInvalidate(CFRunLoopSourceRef source);

void CFRunLoopPerformBlock(CFRunLoopRef rl, CFTypeRef mode, void (^block)(void));

__END_DECLS

#endif /* _CFRUNLOOP_H_ */
