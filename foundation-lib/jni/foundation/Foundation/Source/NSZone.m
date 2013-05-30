/** Zone memory management. -*- Mode: ObjC -*-
   Copyright (C) 1997,1998 Free Software Foundation, Inc.

   Written by: Yoo C. Chung <wacko@laplace.snu.ac.kr>
   Date: January 1997
   Rewrite by: Richard Frith-Macdonald <richard@brainstrom.co.uk>

   This file is part of the GNUstep Base Library.

   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public License
   as published by the Free Software Foundation; either
   version 2 of the License, or (at your option) any later version.

   This library is distributed in the hope that it will be useful, but
   WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with this library; if not, write to the Free Software
   Foundation, Inc., 51 Franklin Street, Fifth Floor,
   Boston, MA 02111 USA.

   <title>NSZone class reference</title>
   $Date: 2010-06-12 00:19:26 -0700 (Sat, 12 Jun 2010) $ $Revision: 30692 $
 */

/*  Design goals:

    - Allocation and deallocation should be reasonably efficient.
    - We want to catch code that writes outside it's permitted area.

 */


/* Actual design:

   - The default zone uses objc_malloc() and friends.  We assume that
   they're thread safe and that they return NULL if we're out of
   memory (glibc malloc does this, what about other mallocs? FIXME).

    - The OpenStep spec says that when a zone is recycled, any memory in
   use is returned to the default zone.
   Since, in general, we have no control over the system malloc, we can't
   possibly do this.  Instead, we move the recycled zone to a list of
   'dead' zones, and as soon as all memory used in it is released, we
   destroy it and remove it from that list.  In the meantime, we release
   any blocks of memory we can (ie those that don't contain unfreed chunks).

   - For freeable zones, a small linear buffer is used for
   deallocating and allocating.  Anything that can't go into the
   buffer then uses a more general purpose segregated fit algorithm
   after flushing the buffer.

   - For memory chunks in freeable zones, the pointer to the chunk is
   preceded by the a chunk header which contains the size of the chunk
   (plus a couple of flags) and a pointer to the end of the memory
   requested.  This adds 8 bytes for freeable zones, which is usually
   what we need for alignment purposes anyway (assuming we're on a
   32 bit machine).  The granularity for allocation of chunks is quite
   large - a chunk must be big enough to hold the chunk header plus a
   couple of pointers and an unsigned size value.
   The actual memory allocated will be the size of the chunk header plus
   the size of memory requested plus one (a guard byte), all rounded up
   to a multiple of the granularity.

   - For nonfreeable zones, worst-like fit is used.  This is OK since
   we don't have to worry about memory fragmentation. */

/* Other information:

   - This uses some GCC specific extensions.  But since the library is
   supposed to compile on GCC 2.7.2.1 (patched) or higher, and the
   only other Objective-C compiler I know of (other than NeXT's, which
   is based on GCC as far as I know) is the StepStone compiler, which
   I haven't the foggiest idea why anyone would prefer it to GCC ;),
   it should be OK.

   - These functions should be thread safe, but I haven't really
   tested them extensively in multithreaded cases. */


/* Define to turn off NSAssertions. */
#define NS_BLOCK_ASSERTIONS 1

#define IN_NSZONE_M 1

#import "common.h"
#include <stddef.h>
#include <string.h>
#import "Foundation/NSException.h"
#import "Foundation/NSLock.h"
#import "GSPrivate.h"
#import "GSPThread.h"

/**
 * Try to get more memory - the normal process has failed.
 * If we can't do anything, just return a null pointer.
 * Try to do some logging if possible.
 */
void *
GSOutOfMemory(NSUInteger size, BOOL retry)
{
    DEBUG_LOG("GSOutOfMemory ... wanting %lu bytes",
              (unsigned long)size);
    return 0;
}

struct _NSZone { };

static NSZone default_zone = {};

/*
 * For backward compatibility.
 */

NSString*
NSZoneName (NSZone *zone)
{
    return @"default";
}


GS_DECLARE NSZone*
NSZoneFromPointer(void *ptr)
{
    return NSDefaultMallocZone();
}

NSZone*
NSCreateZone (NSUInteger start, NSUInteger gran, BOOL canFree)
{
    return NSDefaultMallocZone();
}

void*
NSZoneCalloc (NSZone *zone, NSUInteger elems, NSUInteger bytes)
{
    return memset(NSZoneMalloc(zone, elems*bytes), 0, elems*bytes);
}

void *
NSAllocateCollectable(NSUInteger size, NSUInteger options)
{
    return calloc(1, (size_t)size);
}

void *
NSReallocateCollectable(void *ptr, NSUInteger size, NSUInteger options)
{
    return realloc(ptr, (size_t)size);
}

NSZone*
NSDefaultMallocZone (void)
{
    return &default_zone;
}

NSZone*
GSAtomicMallocZone (void)
{
    return &default_zone;
}

void
GSMakeWeakPointer(Class theClass, const char *iVarName)
{
    return;
}

BOOL
GSAssignZeroingWeakPointer(void **destination, void *source)
{
    if (destination == 0)
    {
        return NO;
    }
    *destination = source;
    return YES;
}

void*
NSZoneMalloc (NSZone *zone, NSUInteger size)
{
    return malloc((size_t)size);
}

void*
NSZoneRealloc (NSZone *zone, void *ptr, NSUInteger size)
{
    return realloc(ptr, size);
}

void
NSRecycleZone (NSZone *zone)
{
    DEBUG_LOG("NSRecycleZone is Deprecated.");
}

void
NSZoneFree (NSZone *zone, void *ptr)
{
    free(ptr);
}

BOOL
GSPrivateIsCollectable(const void *ptr)
{
    return NO;
}

id NSMakeCollectable(CFTypeRef obj)
{
    DEBUG_LOG("Stop calling NSMakeCollectable.");
    return obj;
}
