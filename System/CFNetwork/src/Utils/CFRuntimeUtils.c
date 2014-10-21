//
//  CFRuntimeUtils.c
//  CFNetwork
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#include "CFRuntimeUtils.h"
#include <libkern/OSAtomic.h>

static OSSpinLock registerClassOnceLock = OS_SPINLOCK_INIT;


/* API */

void _CFRuntimeRegisterClassOnce(CFTypeID* typeID, const CFRuntimeClass* cls) {
    OSSpinLockLock(&registerClassOnceLock);
    {
        if (*typeID == _kCFRuntimeNotATypeID) {
            *typeID = _CFRuntimeRegisterClass(cls);
        }
    }
    OSSpinLockUnlock(&registerClassOnceLock);
}
