//
//  CFError.c
//  CFNetwork
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#include <CoreFoundation/CFError.h>
#include "CFHost.h"
#include "CFHTTPStream.h"
#include "CFFTPStream.h"
#include "CFHTTPAuthentication.h"
#include "CFNetServices.h"
#include "CFSocketStream.h"
#include "CFNetworkInternal.h"

static const CFStringRef CFStreamErrorDomainPOSIX = CFSTR("POSIX");
static const CFStringRef CFStreamErrorDomainFTP = CFSTR("FTP");
static const CFStringRef CFStreamErrorDomainNetDB = CFSTR("NetDB");
static const CFStringRef CFStreamErrorDomainSystemConfiguration = CFSTR("SystemConfiguration");
static const CFStringRef CFStreamErrorDomainHTTP = CFSTR("HTTP");
static const CFStringRef CFStreamErrorDomainMach = CFSTR("Mach");
static const CFStringRef CFStreamErrorDomainNetServices = CFSTR("NetServices");
static const CFStringRef CFStreamErrorDomainSOCKS = CFSTR("SOCKS");
static const CFStringRef CFStreamErrorDomainSSL = CFSTR("SSL");
static const CFStringRef CFStreamErrorDomainMacOSStatus = CFSTR("MacOSStatus");
static const CFStringRef CFStreamErrorDomainCustom = CFSTR("Custom");

extern CFErrorRef _CFErrorCreateWithStreamError(CFAllocatorRef allocator, CFStreamError *err);
CFErrorRef _CFErrorCreateWithStreamError(CFAllocatorRef allocator, CFStreamError *err) {
    CFStringRef domain = NULL;

    if (err->domain == kCFStreamErrorDomainPOSIX) {
        domain = CFStreamErrorDomainPOSIX;
    } else if (err->domain == kCFStreamErrorDomainFTP) {
        domain = CFStreamErrorDomainFTP;
    } else if (err->domain == kCFStreamErrorDomainNetDB) {
        domain = CFStreamErrorDomainNetDB;
    } else if (err->domain == kCFStreamErrorDomainSystemConfiguration) {
        domain = CFStreamErrorDomainSystemConfiguration;
    } else if (err->domain == kCFStreamErrorDomainHTTP) {
        domain = CFStreamErrorDomainHTTP;
    } else if (err->domain == kCFStreamErrorDomainMach) {
        domain = CFStreamErrorDomainMach;
    } else if (err->domain == kCFStreamErrorDomainNetServices) {
        domain = CFStreamErrorDomainNetServices;
    } else if (err->domain == kCFStreamErrorDomainSOCKS) {
        domain = CFStreamErrorDomainSOCKS;
    } else if (err->domain == kCFStreamErrorDomainSSL) {
        domain = CFStreamErrorDomainSSL;
    } else if (err->domain == kCFStreamErrorDomainMacOSStatus) {
        domain = CFStreamErrorDomainMacOSStatus;
    } else if (err->domain == kCFStreamErrorDomainCustom) {
        domain = CFStreamErrorDomainCustom;
    } else {
        domain = CFSTR("Unknown");
    }

    return CFErrorCreate(allocator, domain, err->error, NULL);
}

extern CFStreamError _CFStreamErrorFromCFError(CFErrorRef err);
CFStreamError _CFStreamErrorFromCFError(CFErrorRef err) {
    CFStreamError error = { 0, 0 };
    error.error = CFErrorGetCode(err);
    CFStringRef domain = CFErrorGetDomain(err);
    if (CFStringCompare(domain, CFStreamErrorDomainPOSIX, 0)) {
        error.domain = kCFStreamErrorDomainPOSIX;
    } else if (CFStringCompare(domain, CFStreamErrorDomainFTP, 0)) {
        error.domain = kCFStreamErrorDomainFTP;
    } else if (CFStringCompare(domain, CFStreamErrorDomainNetDB, 0)) {
        error.domain = kCFStreamErrorDomainNetDB;
    } else if (CFStringCompare(domain, CFStreamErrorDomainSystemConfiguration, 0)) {
        error.domain = kCFStreamErrorDomainSystemConfiguration;
    } else if (CFStringCompare(domain, CFStreamErrorDomainHTTP, 0)) {
        error.domain = kCFStreamErrorDomainHTTP;
    } else if (CFStringCompare(domain, CFStreamErrorDomainMach, 0)) {
        error.domain = kCFStreamErrorDomainMach;
    } else if (CFStringCompare(domain, CFStreamErrorDomainNetServices, 0)) {
        error.domain = kCFStreamErrorDomainNetServices;
    } else if (CFStringCompare(domain, CFStreamErrorDomainSOCKS, 0)) {
        error.domain = kCFStreamErrorDomainSOCKS;
    } else if (CFStringCompare(domain, CFStreamErrorDomainSSL, 0)) {
        error.domain = kCFStreamErrorDomainSSL;
    } else if (CFStringCompare(domain, CFStreamErrorDomainMacOSStatus, 0)) {
        error.domain = kCFStreamErrorDomainMacOSStatus;
    } else if (CFStringCompare(domain, CFStreamErrorDomainCustom, 0)) {
        error.domain = kCFStreamErrorDomainCustom;
    }
    return error;
}
