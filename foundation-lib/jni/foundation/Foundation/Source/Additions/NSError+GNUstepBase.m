/* Implementation of extension methods to base additions

   Copyright (C) 2010 Free Software Foundation, Inc.

   Written by:  Richard Frith-Macdonald <rfm@gnu.org>

   This file is part of the GNUstep Base Library.

   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2 of the License, or (at your option) any later version.

   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
   Boston, MA 02111 USA.

 */

/* We must define _XOPEN_SOURCE to 600 in order to get the standard
 * version of strerror_r when using glibc.  Otherwise glibc will give
 * us a version which may not populate the buffer.
 */
#ifndef _XOPEN_SOURCE
#define _XOPEN_SOURCE   600
#endif
#include <string.h>


#import "common.h"
#import "Foundation/NSDictionary.h"
#import "Foundation/NSError.h"
#import "GSPrivate.h"

#include <errno.h>

/**
 * GNUstep specific (non-standard) additions to the NSError class.
 * Possibly to be made public
 */
@implementation NSError (GNUstepBase)


#if !defined(HAVE_STRERROR_R)
#if defined(HAVE_STRERROR)
static int
strerror_r(int eno, char *buf, int len)
{
    const char *ptr;
    int result;

    [gnustep_global_lock lock];
    ptr = strerror(eno);
    if (ptr == 0)
    {
        strncpy(buf, "unknown error number", len);
        result = -1;
    }
    else
    {
        strncpy(buf, strerror(eno), len);
        result = 0;
    }
    [gnustep_global_lock unlock];
    return result;
}
#else
static int
strerror_r(int eno, char *buf, int len)
{
    extern char  *sys_errlist[];
    extern int sys_nerr;

    if (eno < 0 || eno >= sys_nerr)
    {
        strncpy(buf, "unknown error number", len);
        return -1;
    }
    strncpy(buf, sys_errlist[eno], len);
    return 0;
}
#endif
#endif

/*
 * Returns an NSError instance encapsulating the last system error.
 * The user info dictionary of this object will be mutable, so that
 * additional information can be placed in it by higher level code.
 */
+ (NSError*)_last
{
    int eno;
    eno = errno;
    return [self _systemError:eno];
}

+ (NSError*)_systemError:(long)code
{
    NSError   *error;
    NSString  *domain;
    NSDictionary  *info;
    NSString  *message;
    char buf[BUFSIZ];

    /* FIXME ... not all are POSIX, should we use NSMachErrorDomain for some? */
    domain = NSPOSIXErrorDomain;
    sprintf(buf, "%ld", code);
    message = [NSString stringWithCString:buf
               encoding:[NSString defaultCStringEncoding]];
    /* FIXME ... can we do better localisation? */
    info = [NSMutableDictionary dictionaryWithObjectsAndKeys:
            message, NSLocalizedDescriptionKey,
            nil];

    /* NB we use a mutable dictionary so that calling code can add extra
     * information to the dictionary before passing it up to higher level
     * code.
     */
    error = [self errorWithDomain:domain code:code userInfo:info];
    return error;
}

+ (NSError*)_unimplementedError
{
    return [self _systemError:ENOSYS];
}

@end
