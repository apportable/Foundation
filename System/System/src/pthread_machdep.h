/*
 * Copyright (c) 2003-2004, 2008 Apple Inc. All rights reserved.
 *
 * @APPLE_LICENSE_HEADER_START@
 *
 * This file contains Original Code and/or Modifications of Original Code
 * as defined in and that are subject to the Apple Public Source License
 * Version 2.0 (the 'License'). You may not use this file except in
 * compliance with the License. Please obtain a copy of the License at
 * http://www.opensource.apple.com/apsl/ and read it before using this
 * file.
 *
 * The Original Code and all software distributed under the License are
 * distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER
 * EXPRESS OR IMPLIED, AND APPLE HEREBY DISCLAIMS ALL SUCH WARRANTIES,
 * INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT.
 * Please see the License for the specific language governing rights and
 * limitations under the License.
 *
 * @APPLE_LICENSE_HEADER_END@
 */
/*
 * Copyright 1996 1995 by Open Software Foundation, Inc. 1997 1996 1995 1994 1993 1992 1991
 *              All Rights Reserved
 *
 * Permission to use, copy, modify, and distribute this software and
 * its documentation for any purpose and without fee is hereby granted,
 * provided that the above copyright notice appears in all copies and
 * that both the copyright notice and this permission notice appear in
 * supporting documentation.
 *
 * OSF DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE
 * INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE.
 *
 * IN NO EVENT SHALL OSF BE LIABLE FOR ANY SPECIAL, INDIRECT, OR
 * CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
 * LOSS OF USE, DATA OR PROFITS, WHETHER IN ACTION OF CONTRACT,
 * NEGLIGENCE, OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION
 * WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */
/*
 * MkLinux
 */

/* Machine-dependent definitions for pthread internals. */
/* This is based loosly upon the libc implementation of pthread_machdep.h for mac os x/ios
   however it has been modified to be more compliant to the underlying android subsystem */

#ifndef _POSIX_PTHREAD_MACHDEP_H
#define _POSIX_PTHREAD_MACHDEP_H

#include <pthread.h>
#include <errno.h>
#include <libv/libv.h>
#include <assert.h>

#define _PTHREAD_TSD_SLOT_INVALID           0xFFFFFFFF
#define _PTHREAD_TSD_SLOT_PTHREAD_SELF      0
#define _PTHREAD_TSD_SLOT_DYLD_1            1
#define _PTHREAD_TSD_SLOT_DYLD_2            2
#define _PTHREAD_TSD_SLOT_DYLD_3            3
#define _PTHREAD_TSD_RESERVED_SLOT_COUNT    4
#define _PTHREAD_TSD_SLOT_DYLD_8            8

#define __PTK_LIBC_LOCALE_KEY               10
#define __PTK_LIBC_TTYNAME_KEY              11
#define __PTK_LIBC_LOCALTIME_KEY            12
#define __PTK_LIBC_GMTIME_KEY               13
#define __PTK_LIBC_GDTOA_BIGINT_KEY         14
#define __PTK_LIBC_PARSEFLOAT_KEY           15
#define __PTK_LIBC_DYLD_Unwind_SjLj_Key     18

#define __PTK_LIBDISPATCH_KEY0              20
#define __PTK_LIBDISPATCH_KEY1              21
#define __PTK_LIBDISPATCH_KEY2              22
#define __PTK_LIBDISPATCH_KEY3              23
#define __PTK_LIBDISPATCH_KEY4              24
#define __PTK_LIBDISPATCH_KEY5              25

#define _PTHREAD_TSD_SLOT_OPENGL            30
#define __PTK_FRAMEWORK_OPENGL_KEY          30

#define __PTK_FRAMEWORK_GRAPHICS_KEY1       31
#define __PTK_FRAMEWORK_GRAPHICS_KEY2       32
#define __PTK_FRAMEWORK_GRAPHICS_KEY3       33
#define __PTK_FRAMEWORK_GRAPHICS_KEY4       34
#define __PTK_FRAMEWORK_GRAPHICS_KEY5       35
#define __PTK_FRAMEWORK_GRAPHICS_KEY6       36
#define __PTK_FRAMEWORK_GRAPHICS_KEY7       37
#define __PTK_FRAMEWORK_GRAPHICS_KEY8       38
#define __PTK_FRAMEWORK_GRAPHICS_KEY9       39

#define __PTK_FRAMEWORK_OBJC_KEY0           40
#define __PTK_FRAMEWORK_OBJC_KEY1           41
#define __PTK_FRAMEWORK_OBJC_KEY2           42
#define __PTK_FRAMEWORK_OBJC_KEY3           43
#define __PTK_FRAMEWORK_OBJC_KEY4           44
#define __PTK_FRAMEWORK_OBJC_KEY5           45
#define __PTK_FRAMEWORK_OBJC_KEY6           46
#define __PTK_FRAMEWORK_OBJC_KEY7           47
#define __PTK_FRAMEWORK_OBJC_KEY8           48
#define __PTK_FRAMEWORK_OBJC_KEY9           49

#define __PTK_FRAMEWORK_COREFOUNDATION_KEY0 50
#define __PTK_FRAMEWORK_COREFOUNDATION_KEY1 51
#define __PTK_FRAMEWORK_COREFOUNDATION_KEY2 52
#define __PTK_FRAMEWORK_COREFOUNDATION_KEY3 53
#define __PTK_FRAMEWORK_COREFOUNDATION_KEY4 54
#define __PTK_FRAMEWORK_COREFOUNDATION_KEY5 55
#define __PTK_FRAMEWORK_COREFOUNDATION_KEY6 56
#define __PTK_FRAMEWORK_COREFOUNDATION_KEY7 57
#define __PTK_FRAMEWORK_COREFOUNDATION_KEY8 58
#define __PTK_FRAMEWORK_COREFOUNDATION_KEY9 59

#define __PTK_FRAMEWORK_FOUNDATION_KEY0     60
#define __PTK_FRAMEWORK_FOUNDATION_KEY1     61
#define __PTK_FRAMEWORK_FOUNDATION_KEY2     62
#define __PTK_FRAMEWORK_FOUNDATION_KEY3     63
#define __PTK_FRAMEWORK_FOUNDATION_KEY4     64
#define __PTK_FRAMEWORK_FOUNDATION_KEY5     65
#define __PTK_FRAMEWORK_FOUNDATION_KEY6     66
#define __PTK_FRAMEWORK_FOUNDATION_KEY7     67
#define __PTK_FRAMEWORK_FOUNDATION_KEY8     68
#define __PTK_FRAMEWORK_FOUNDATION_KEY9     69

#define __PTK_FRAMEWORK_QUARTZCORE_KEY0     70
#define __PTK_FRAMEWORK_QUARTZCORE_KEY1     71
#define __PTK_FRAMEWORK_QUARTZCORE_KEY2     72
#define __PTK_FRAMEWORK_QUARTZCORE_KEY3     73
#define __PTK_FRAMEWORK_QUARTZCORE_KEY4     74
#define __PTK_FRAMEWORK_QUARTZCORE_KEY5     75
#define __PTK_FRAMEWORK_QUARTZCORE_KEY6     76
#define __PTK_FRAMEWORK_QUARTZCORE_KEY7     77
#define __PTK_FRAMEWORK_QUARTZCORE_KEY8     78
#define __PTK_FRAMEWORK_QUARTZCORE_KEY9     79

#define __PTK_FRAMEWORK_OLDGC_KEY0          80
#define __PTK_FRAMEWORK_OLDGC_KEY1          81
#define __PTK_FRAMEWORK_OLDGC_KEY2          82
#define __PTK_FRAMEWORK_OLDGC_KEY3          83
#define __PTK_FRAMEWORK_OLDGC_KEY4          84
#define __PTK_FRAMEWORK_OLDGC_KEY5          85
#define __PTK_FRAMEWORK_OLDGC_KEY6          86
#define __PTK_FRAMEWORK_OLDGC_KEY7          87
#define __PTK_FRAMEWORK_OLDGC_KEY8          88
#define __PTK_FRAMEWORK_OLDGC_KEY9          89

#define __PTK_FRAMEWORK_JAVASCRIPTCORE_KEY0 90
#define __PTK_FRAMEWORK_JAVASCRIPTCORE_KEY1 91
#define __PTK_FRAMEWORK_JAVASCRIPTCORE_KEY2 92
#define __PTK_FRAMEWORK_JAVASCRIPTCORE_KEY3 93
#define __PTK_FRAMEWORK_JAVASCRIPTCORE_KEY4 94

#define __PTK_FRAMEWORK_GC_KEY0             110
#define __PTK_FRAMEWORK_GC_KEY1             111
#define __PTK_FRAMEWORK_GC_KEY2             112
#define __PTK_FRAMEWORK_GC_KEY3             113
#define __PTK_FRAMEWORK_GC_KEY4             114
#define __PTK_FRAMEWORK_GC_KEY5             115
#define __PTK_FRAMEWORK_GC_KEY6             116
#define __PTK_FRAMEWORK_GC_KEY7             117
#define __PTK_FRAMEWORK_GC_KEY8             118
#define __PTK_FRAMEWORK_GC_KEY9             119

__BEGIN_DECLS

#define REALFN(f) __real_##f

#define TSD_MAX_KEYS 256

extern void *REALFN(pthread_getspecific)(pthread_key_t key);
extern int REALFN(pthread_setspecific)(pthread_key_t key, const void *value);
extern int REALFN(pthread_key_create)(pthread_key_t *key, void (*destructor_function)(void *));

extern pthread_key_t _pthread_tsd;

extern int pthread_key_init_np(int, void (*)(void *));

#ifdef NDEBUG
#define TSD_ASSERT(...)
#else

static inline unsigned long _pthread_direct_slot(unsigned long slot) {
    switch (slot) {
        case _PTHREAD_TSD_SLOT_PTHREAD_SELF:
        case _PTHREAD_TSD_SLOT_DYLD_1:
        case _PTHREAD_TSD_SLOT_DYLD_2:
        case _PTHREAD_TSD_SLOT_DYLD_3:
        case _PTHREAD_TSD_RESERVED_SLOT_COUNT:
        case _PTHREAD_TSD_SLOT_DYLD_8:
        case __PTK_LIBC_LOCALE_KEY:
        case __PTK_LIBC_TTYNAME_KEY:
        case __PTK_LIBC_LOCALTIME_KEY:
        case __PTK_LIBC_GMTIME_KEY:
        case __PTK_LIBC_GDTOA_BIGINT_KEY:
        case __PTK_LIBC_PARSEFLOAT_KEY:
        case __PTK_LIBC_DYLD_Unwind_SjLj_Key:
        case __PTK_LIBDISPATCH_KEY0:
        case __PTK_LIBDISPATCH_KEY1:
        case __PTK_LIBDISPATCH_KEY2:
        case __PTK_LIBDISPATCH_KEY3:
        case __PTK_LIBDISPATCH_KEY4:
        case __PTK_LIBDISPATCH_KEY5:
        case __PTK_FRAMEWORK_OPENGL_KEY:
        case __PTK_FRAMEWORK_GRAPHICS_KEY1:
        case __PTK_FRAMEWORK_GRAPHICS_KEY2:
        case __PTK_FRAMEWORK_GRAPHICS_KEY3:
        case __PTK_FRAMEWORK_GRAPHICS_KEY4:
        case __PTK_FRAMEWORK_GRAPHICS_KEY5:
        case __PTK_FRAMEWORK_GRAPHICS_KEY6:
        case __PTK_FRAMEWORK_GRAPHICS_KEY7:
        case __PTK_FRAMEWORK_GRAPHICS_KEY8:
        case __PTK_FRAMEWORK_GRAPHICS_KEY9:
        case __PTK_FRAMEWORK_OBJC_KEY0:
        case __PTK_FRAMEWORK_OBJC_KEY1:
        case __PTK_FRAMEWORK_OBJC_KEY2:
        case __PTK_FRAMEWORK_OBJC_KEY3:
        case __PTK_FRAMEWORK_OBJC_KEY4:
        case __PTK_FRAMEWORK_OBJC_KEY5:
        case __PTK_FRAMEWORK_OBJC_KEY6:
        case __PTK_FRAMEWORK_OBJC_KEY7:
        case __PTK_FRAMEWORK_OBJC_KEY8:
        case __PTK_FRAMEWORK_OBJC_KEY9:
        case __PTK_FRAMEWORK_COREFOUNDATION_KEY0:
        case __PTK_FRAMEWORK_COREFOUNDATION_KEY1:
        case __PTK_FRAMEWORK_COREFOUNDATION_KEY2:
        case __PTK_FRAMEWORK_COREFOUNDATION_KEY3:
        case __PTK_FRAMEWORK_COREFOUNDATION_KEY4:
        case __PTK_FRAMEWORK_COREFOUNDATION_KEY5:
        case __PTK_FRAMEWORK_COREFOUNDATION_KEY6:
        case __PTK_FRAMEWORK_COREFOUNDATION_KEY7:
        case __PTK_FRAMEWORK_COREFOUNDATION_KEY8:
        case __PTK_FRAMEWORK_COREFOUNDATION_KEY9:
        case __PTK_FRAMEWORK_FOUNDATION_KEY0:
        case __PTK_FRAMEWORK_FOUNDATION_KEY1:
        case __PTK_FRAMEWORK_FOUNDATION_KEY2:
        case __PTK_FRAMEWORK_FOUNDATION_KEY3:
        case __PTK_FRAMEWORK_FOUNDATION_KEY4:
        case __PTK_FRAMEWORK_FOUNDATION_KEY5:
        case __PTK_FRAMEWORK_FOUNDATION_KEY6:
        case __PTK_FRAMEWORK_FOUNDATION_KEY7:
        case __PTK_FRAMEWORK_FOUNDATION_KEY8:
        case __PTK_FRAMEWORK_FOUNDATION_KEY9:
        case __PTK_FRAMEWORK_QUARTZCORE_KEY0:
        case __PTK_FRAMEWORK_QUARTZCORE_KEY1:
        case __PTK_FRAMEWORK_QUARTZCORE_KEY2:
        case __PTK_FRAMEWORK_QUARTZCORE_KEY3:
        case __PTK_FRAMEWORK_QUARTZCORE_KEY4:
        case __PTK_FRAMEWORK_QUARTZCORE_KEY5:
        case __PTK_FRAMEWORK_QUARTZCORE_KEY6:
        case __PTK_FRAMEWORK_QUARTZCORE_KEY7:
        case __PTK_FRAMEWORK_QUARTZCORE_KEY8:
        case __PTK_FRAMEWORK_QUARTZCORE_KEY9:
        case __PTK_FRAMEWORK_OLDGC_KEY0:
        case __PTK_FRAMEWORK_OLDGC_KEY1:
        case __PTK_FRAMEWORK_OLDGC_KEY2:
        case __PTK_FRAMEWORK_OLDGC_KEY3:
        case __PTK_FRAMEWORK_OLDGC_KEY4:
        case __PTK_FRAMEWORK_OLDGC_KEY5:
        case __PTK_FRAMEWORK_OLDGC_KEY6:
        case __PTK_FRAMEWORK_OLDGC_KEY7:
        case __PTK_FRAMEWORK_OLDGC_KEY8:
        case __PTK_FRAMEWORK_OLDGC_KEY9:
        case __PTK_FRAMEWORK_JAVASCRIPTCORE_KEY0:
        case __PTK_FRAMEWORK_JAVASCRIPTCORE_KEY1:
        case __PTK_FRAMEWORK_JAVASCRIPTCORE_KEY2:
        case __PTK_FRAMEWORK_JAVASCRIPTCORE_KEY3:
        case __PTK_FRAMEWORK_JAVASCRIPTCORE_KEY4:
        case __PTK_FRAMEWORK_GC_KEY0:
        case __PTK_FRAMEWORK_GC_KEY1:
        case __PTK_FRAMEWORK_GC_KEY2:
        case __PTK_FRAMEWORK_GC_KEY3:
        case __PTK_FRAMEWORK_GC_KEY4:
        case __PTK_FRAMEWORK_GC_KEY5:
        case __PTK_FRAMEWORK_GC_KEY6:
        case __PTK_FRAMEWORK_GC_KEY7:
        case __PTK_FRAMEWORK_GC_KEY8:
        case __PTK_FRAMEWORK_GC_KEY9:
            return slot;
        default:
            return _PTHREAD_TSD_SLOT_INVALID;
    }
}

#define TSD_ASSERT(...) assert(__VA_ARGS__)
#endif

static int
_pthread_has_direct_tsd(void) {
    return 1;
}

inline static void *
_pthread_getspecific_direct(unsigned long slot) {
    TSD_ASSERT(_pthread_direct_slot(slot) != _PTHREAD_TSD_SLOT_INVALID);
    void **tsd = (void **)REALFN(pthread_getspecific)(_pthread_tsd);
    if (tsd == NULL) {
        tsd = (void **)calloc(TSD_MAX_KEYS, sizeof(void *));
        TSD_ASSERT(tsd != NULL);
        REALFN(pthread_setspecific)(_pthread_tsd, tsd);
    }
    return tsd[slot];
}

inline static int
_pthread_setspecific_direct(unsigned long slot, void * val) {
    TSD_ASSERT(_pthread_direct_slot(slot) != _PTHREAD_TSD_SLOT_INVALID);
    int retval = 0;
    void **tsd = (void **)REALFN(pthread_getspecific)(_pthread_tsd);
    if (tsd == NULL) {
        tsd = (void **)calloc(TSD_MAX_KEYS, sizeof(void *));
        TSD_ASSERT(tsd != NULL);
        retval = REALFN(pthread_setspecific)(_pthread_tsd, tsd);
    }
    tsd[slot] = val;
    return retval;
}

__END_DECLS

#endif
