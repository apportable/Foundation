//
//  CFURLProtectionSpace.c
//  CFNetwork
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#include "CFBase.h"
#include "CFRuntime.h"
#include "CFURLProtectionSpace.h"

struct _CFURLProtectionSpace {
    CFRuntimeBase _base;
    CFStringRef host;
    CFIndex port;
    CFURLProtectionSpaceServerType serverType;
    CFStringRef realm;
    CFURLProtectionSpaceAuthenticationSchemeType scheme;
    CFArrayRef distinguishedNames;
};

static void __CFURLProtectionSpaceDeallocate(CFTypeRef cf) {
    struct _CFURLProtectionSpace *item = (struct _CFURLProtectionSpace *)cf;
    if (item->host != NULL) {
        CFRelease(item->host);
    }
    if (item->realm != NULL) {
        CFRelease(item->realm);
    }
    if (item->distinguishedNames != NULL) {
        CFRelease(item->distinguishedNames);
    }
}

static CFTypeID __kCFURLProtectionSpaceTypeID = _kCFRuntimeNotATypeID;

static const CFRuntimeClass __CFURLProtectionSpaceClass = {
    _kCFRuntimeScannedObject,
    "CFURLProtectionSpace",
    NULL,
    NULL,
    __CFURLProtectionSpaceDeallocate,
    NULL,
    NULL,
    NULL,
    NULL
};

static void __CFURLProtectionSpaceInitialize(void) {
    __kCFURLProtectionSpaceTypeID = _CFRuntimeRegisterClass(&__CFURLProtectionSpaceClass);
}

CFTypeID CFURLProtectionSpaceGetTypeID(void) {
    if (__kCFURLProtectionSpaceTypeID == _kCFRuntimeNotATypeID) {
        __CFURLProtectionSpaceInitialize();
    }
    return __kCFURLProtectionSpaceTypeID;
}

static struct _CFURLProtectionSpace *_CFURLProtectionSpaceCreate(CFAllocatorRef allocator) {
    CFIndex size = sizeof(struct _CFURLProtectionSpace) - sizeof(CFRuntimeBase);
    return (struct _CFURLProtectionSpace *)_CFRuntimeCreateInstance(allocator, CFURLProtectionSpaceGetTypeID(), size, NULL);
}


CFURLProtectionSpaceRef CFURLProtectionSpaceCreate(CFAllocatorRef allocator, 
                                                   CFStringRef host,
                                                   CFIndex port, 
                                                   CFURLProtectionSpaceServerType serverType, 
                                                   CFStringRef realm, 
                                                   CFURLProtectionSpaceAuthenticationSchemeType scheme) {
    struct _CFURLProtectionSpace *space = _CFURLProtectionSpaceCreate(allocator);
    if (host != NULL) {
        space->host = CFStringCreateCopy(allocator, host);
    } else {
        space->host = NULL; // exception/crash?
    }
    space->port = port;
    space->serverType = serverType;
    if (realm != NULL) {
        space->realm = CFStringCreateCopy(allocator, realm);
    } else {
        space->realm = NULL;
    }

    space->scheme = scheme;

    return (CFURLProtectionSpaceRef)space;
}

CFURLProtectionSpaceAuthenticationSchemeType CFURLProtectionSpaceGetAuthenticationScheme(CFURLProtectionSpaceRef space) {
    return space->scheme;
}

static void resolveDistinguishedNames(CFURLProtectionSpaceRef space) {
    DEBUG_BREAK();
}

CFArrayRef CFURLProtectionSpaceGetDistinguishedNames(CFURLProtectionSpaceRef space) {
    if (space->distinguishedNames == NULL) {
        resolveDistinguishedNames(space);
    }
    return space->distinguishedNames;
}

CFStringRef CFURLProtectionSpaceGetHost(CFURLProtectionSpaceRef space) {
    return space->host;
}

CFIndex CFURLProtectionSpaceGetPort(CFURLProtectionSpaceRef space) {
    return space->port;
}

CFStringRef CFURLProtectionSpaceGetRealm(CFURLProtectionSpaceRef space) {
    return space->realm;
}

SecTrustRef CFURLProtectionSpaceGetServerTrust(CFURLProtectionSpaceRef space) {
    DEBUG_BREAK();
    return NULL;
}

CFURLProtectionSpaceServerType CFURLProtectionSpaceGetServerType(CFURLProtectionSpaceRef space) {
    return space->serverType;
}

Boolean CFURLProtectionSpaceIsProxy(CFURLProtectionSpaceRef space) {
    DEBUG_BREAK();
    return false;
}

Boolean CFURLProtectionSpaceReceivesCredentialSecurely(CFURLProtectionSpaceRef space) {
    DEBUG_BREAK();
    return false;
}
