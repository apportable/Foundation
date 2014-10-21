//
//  CFURLAuthChallenge.c
//  CFNetwork
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#include "CFBase.h"
#include "CFRuntime.h"
#include "CFURLAuthChallenge.h"

struct __CFURLAuthChallenge {
    CFRuntimeBase _base;
};

static void __CFURLAuthChallengeDeallocate(CFTypeRef cf) {
    struct __CFURLAuthChallenge *item = (struct __CFURLAuthChallenge *)cf;
}

static CFTypeID __kCFURLAuthChallengeTypeID = _kCFRuntimeNotATypeID;

static const CFRuntimeClass __CFURLAuthChallengeClass = {
    _kCFRuntimeScannedObject,
    "CFURLAuthChallenge",
    NULL,   // init
    NULL,   // copy
    __CFURLAuthChallengeDeallocate,
    NULL,
    NULL,
    NULL,
    NULL
};

static void __CFURLAuthChallengeInitialize(void) {
    __kCFURLAuthChallengeTypeID = _CFRuntimeRegisterClass(&__CFURLAuthChallengeClass);
}

CFTypeID CFURLAuthChallengeGetTypeID(void) {
    if (__kCFURLAuthChallengeTypeID == _kCFRuntimeNotATypeID) {
        __CFURLAuthChallengeInitialize();
    }
    return __kCFURLAuthChallengeTypeID;
}

static struct __CFURLAuthChallenge *_CFURLAuthChallengeCreate(CFAllocatorRef allocator) {
    CFIndex size = sizeof(struct __CFURLAuthChallenge) - sizeof(CFRuntimeBase);
    return (struct __CFURLAuthChallenge *)_CFRuntimeCreateInstance(allocator, CFURLAuthChallengeGetTypeID(), size, NULL);
}

CFURLAuthChallengeRef CFURLAuthChallengeCreateWithCFHTTPAuthentication(CFAllocatorRef allocator, CFHTTPAuthenticationRef auth) {
    struct __CFURLAuthChallenge *object = _CFURLAuthChallengeCreate(allocator);

    return object;
}

CFURLProtectionSpaceRef CFURLAuthChallengeGetProtectionSpace(CFURLAuthChallengeRef challenge) {
    DEBUG_BREAK();
    return NULL;
}

CFURLCredentialRef CFURLAuthChallengeGetCredential(CFURLAuthChallengeRef challenge) {
    DEBUG_BREAK();
    return NULL;
}

CFURLResponseRef CFURLAuthChallengeGetResponse(CFURLAuthChallengeRef challenge) {
    DEBUG_BREAK();
    return NULL;
}

CFIndex CFURLAuthChallengeGetPreviousFailureCount(CFURLAuthChallengeRef challenge) {
    DEBUG_BREAK();
    return 0;
}

CFErrorRef CFURLAuthChallengeGetError(CFURLAuthChallengeRef challenge) {
    DEBUG_BREAK();
    return NULL;
}
