//
//  CFHTTPCookieStorage.c
//  CFNetwork
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#include "CFBase.h"
#include "CFRuntime.h"
#include "CFHTTPCookieStorage.h"
#include "CFHTTPCookie.h"
#include "CFArray.h"
#include <dispatch/dispatch.h>

struct __CFHTTPCookieStorage {
    CFRuntimeBase _base;
    CFMutableArrayRef _cookies;
};

static void __CFHTTPCookieStorageDeallocate(CFTypeRef cf) {
    struct __CFHTTPCookieStorage *item = (struct __CFHTTPCookieStorage *)cf;
    CFRelease(item->_cookies);
}

static CFTypeID __kCFHTTPCookieStorageTypeID = _kCFRuntimeNotATypeID;

static const CFRuntimeClass __CFHTTPCookieStorageClass = {
    _kCFRuntimeScannedObject,
    "CFHTTPCookieStorage",
    NULL,   // init
    NULL,   // copy
    __CFHTTPCookieStorageDeallocate,
    NULL,
    NULL,
    NULL,
    NULL
};

static void __CFHTTPCookieStorageInitialize(void) {
    __kCFHTTPCookieStorageTypeID = _CFRuntimeRegisterClass(&__CFHTTPCookieStorageClass);
}

CFTypeID CFHTTPCookieStorageGetTypeID(void) {
    if (__kCFHTTPCookieStorageTypeID == _kCFRuntimeNotATypeID) {
        __CFHTTPCookieStorageInitialize();
    }
    return __kCFHTTPCookieStorageTypeID;
}

static struct __CFHTTPCookieStorage *_CFHTTPCookieStorageCreate(CFAllocatorRef allocator) {
    CFIndex size = sizeof(struct __CFHTTPCookieStorage) - sizeof(CFRuntimeBase);
    struct __CFHTTPCookieStorage *cookieStorage = (struct __CFHTTPCookieStorage *)_CFRuntimeCreateInstance(allocator, CFHTTPCookieStorageGetTypeID(), size, NULL);
    
    cookieStorage->_cookies = (CFMutableArrayRef)CFRetain(CFArrayCreateMutable(allocator, 0, &kCFTypeArrayCallBacks));
    
    
    return cookieStorage;
}



CFHTTPCookieStorageRef CFHTTPCookieStorageGetDefault() {
    static struct __CFHTTPCookieStorage *sharedStorage = NULL;
    static dispatch_once_t once = 0L;
    dispatch_once(&once, ^{
        sharedStorage = _CFHTTPCookieStorageCreate(kCFAllocatorDefault);
    });
    return (CFHTTPCookieStorageRef)sharedStorage;

}

void CFHTTPCookieStorageDeleteCookie(CFHTTPCookieStorageRef storage, CFHTTPCookieRef cookie) {
    CFMutableArrayRef cookies = storage->_cookies;
    CFIndex i = CFArrayGetFirstIndexOfValue(cookies,
                                            CFRangeMake(0, CFArrayGetCount(cookies)),
                                            cookie);
    if (i != kCFNotFound)
        CFArrayRemoveValueAtIndex(cookies, i);
}

void CFHTTPCookieStorageSetCookie(CFHTTPCookieStorageRef storage, CFHTTPCookieRef cookie) {
    CFIndex existingCookieIndex = kCFNotFound;
    for (int j=0; j<CFArrayGetCount(storage->_cookies); j++) {
        CFHTTPCookieRef existingCookie = (CFHTTPCookieRef)CFArrayGetValueAtIndex(storage->_cookies, j);
        if (CFStringCompare(CFHTTPCookieGetName(existingCookie), CFHTTPCookieGetName(cookie), kCFCompareCaseInsensitive)==kCFCompareEqualTo) {
            existingCookieIndex = j;
            break;
        }
    }
    if (existingCookieIndex == kCFNotFound) {
        CFArrayAppendValue(storage->_cookies, cookie);
    } else {
        CFArrayReplaceValues(storage->_cookies, CFRangeMake(existingCookieIndex, 1), (CFTypeRef*)&cookie, 1);
    }
}

CFArrayRef CFHTTPCookieStorageCopyCookies(CFHTTPCookieStorageRef storage) {
    return CFArrayCreateCopy(kCFAllocatorDefault, storage->_cookies);
}

CFArrayRef CFHTTPCookieStorageCopyCookiesForURL(CFHTTPCookieStorageRef storage, CFURLRef url) {
    //fixme respect the url
    return CFHTTPCookieStorageCopyCookies(storage);
}


void CFHTTPCookieStorageSetCookies(CFHTTPCookieStorageRef storage, CFArrayRef cookies) {
    //fixme bad big O.
    for (int i=0; i<CFArrayGetCount(cookies); i++) {
        CFHTTPCookieRef cookie = (CFHTTPCookieRef)CFArrayGetValueAtIndex(cookies, i);
        CFHTTPCookieStorageSetCookie(storage, cookie);        
    }
}


void CFHTTPCookieStorageSetCookiesWithResponseHeaderFields(CFHTTPCookieStorageRef storage, CFDictionaryRef headerFields, CFURLRef url) {
    CFArrayRef cookies = CFHTTPCookieCreateWithResponseHeaderFields(headerFields, url);
    if (cookies != NULL) {
        CFHTTPCookieStorageSetCookies(storage, cookies);
        CFRelease(cookies);
    }
}
CFDictionaryRef CFHTTPCookieStorageCopyRequestHeaderFieldsForURL(CFHTTPCookieStorageRef storage, CFURLRef url) {
    return CFHTTPCookieCopyRequestHeaderFields(storage->_cookies);
}



