/*
   NSEnumerator.h

   Copyright (C) 1998 Free Software Foundation, Inc.

   Author:  Scott Christley <scottc@net-community.com>
   Date: January 1998

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

#ifndef __NSEnumerator_h_GNUSTEP_BASE_INCLUDE
#define __NSEnumerator_h_GNUSTEP_BASE_INCLUDE
#import <GNUstepBase/GSVersionMacros.h>

#import <Foundation/NSObject.h>

#if defined(__cplusplus)
extern "C" {
#endif

typedef struct
{
    unsigned long state;
#if defined(__has_feature) && __has_feature(objc_arc)
    id __unsafe_unretained *itemsPtr;
#else
    id *itemsPtr;
#endif
    unsigned long *mutationsPtr;
    unsigned long extra[5];
} NSFastEnumerationState;

@protocol NSFastEnumeration
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state
#if defined(__has_feature) && __has_feature(objc_arc)
    objects:(id __unsafe_unretained [])stackbuf
#else
    objects:(id [])stackbuf
#endif
    count:(NSUInteger)len;
@end

@interface NSEnumerator : NSObject <NSFastEnumeration>
- (id)nextObject;
@end

@interface NSEnumerator (NSEnumeratorExtended)
- (NSArray *)allObjects;
@end

#if defined(__cplusplus)
}
#endif

#endif /* __NSEnumerator_h_GNUSTEP_BASE_INCLUDE */
