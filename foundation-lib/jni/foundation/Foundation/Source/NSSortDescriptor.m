/* Implementation for NSSortDescriptor for GNUStep
   Copyright (C) 2005 Free Software Foundation, Inc.

   Written by:  Saso Kiselkov <diablos@manga.sk>
   Date: 2005

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

#import "common.h"

#define EXPOSE_NSSortDescriptor_IVARS   1
#import "Foundation/NSSortDescriptor.h"

#import "Foundation/NSBundle.h"
#import "Foundation/NSCoder.h"
#import "Foundation/NSException.h"
#import "Foundation/NSKeyValueCoding.h"

#import "CoreFoundation/CFPriv.h"

#import "GNUstepBase/GSObjCRuntime.h"
#import "GNUstepBase/NSObject+GNUstepBase.h"
#import "GSPrivate.h"

@implementation NSSortDescriptor


+ (NSSortDescriptor *)sortDescriptorWithKey:(NSString *)key ascending:(BOOL)ascending selector:(SEL)selector
{
    return [[[self alloc] initWithKey:key ascending:ascending selector:selector] autorelease];
}

+ (NSSortDescriptor *)sortDescriptorWithKey:(NSString *)key ascending:(BOOL)ascending
{
    return [[[self alloc] initWithKey:key ascending:ascending selector:NULL] autorelease];
}

- (BOOL)ascending
{
    return _ascending;
}

- (NSComparator)comparator
{
    return [[^(id o1, id o2) 
        {
            return [self compareObject:o1 toObject:o2];
        } copy] autorelease];
}

- (NSComparisonResult)compareObject:(id)object1 toObject:(id)object2
{
    NSComparisonResult result;
    id comparedKey1 = [object1 valueForKeyPath:_key];
    id comparedKey2 = [object2 valueForKeyPath:_key];

    result = (NSComparisonResult) [comparedKey1 performSelector : _selector
                                   withObject : comparedKey2];
    if (_ascending == NO)
    {
        if (result == NSOrderedAscending)
        {
            result = NSOrderedDescending;
        }
        else if (result == NSOrderedDescending)
        {
            result = NSOrderedAscending;
        }
    }

    return result;
}

- (id)copyWithZone:(NSZone*)zone
{
    if (NSShouldRetainWithZone(self, zone))
    {
        return RETAIN(self);
    }
    return [[NSSortDescriptor allocWithZone:zone]
            initWithKey:_key ascending:_ascending selector:_selector];
}

- (void)dealloc
{
    TEST_RELEASE(_key);
    [super dealloc];
}

- (NSUInteger)hash
{
    const char    *sel = sel_getName(_selector);

    return _ascending + GSPrivateHash(sel, strlen(sel), 16, YES) + [_key hash];
}

- (id)initWithKey:(NSString *)key ascending:(BOOL)ascending
{
    return [self initWithKey:key ascending:ascending selector:NULL];
}

- (id)initWithKey:(NSString *)key
    ascending:(BOOL)ascending
    selector:(SEL)selector
{
    if ([self init])
    {
        if (key == nil)
        {
            // we emulate iOS's behavior in case key is nil
            key = @"self";
        }
        if (selector == NULL)
        {
            selector = @selector(compare:);
        }

        ASSIGN(_key, key);
        _ascending = ascending;
        _selector = selector;

        return self;
    }
    else
    {
        return nil;
    }
}

- (BOOL)isEqual:(id)other
{
    if (other == self)
    {
        return YES;
    }
    if ([other isKindOfClass:[NSSortDescriptor class]] == NO)
    {
        return NO;
    }
    if (((NSSortDescriptor*)other)->_ascending != _ascending)
    {
        return NO;
    }
    if (!sel_isEqual(((NSSortDescriptor*)other)->_selector, _selector))
    {
        return NO;
    }
    return [((NSSortDescriptor*)other)->_key isEqualToString : _key];
}

- (NSString *)key
{
    return _key;
}

- (id)reversedSortDescriptor
{
    return AUTORELEASE([[NSSortDescriptor alloc]
                        initWithKey:_key ascending:!_ascending selector:_selector]);
}

- (SEL)selector
{
    return _selector;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    if ([coder allowsKeyedCoding])
    {
        [coder encodeObject:_key forKey:@"Key"];
        [coder encodeBool:_ascending forKey:@"Ascending"];
        [coder encodeObject:NSStringFromSelector(_selector)
         forKey:@"Selector"];
    }
    else
    {
        [coder encodeObject:_key];
        [coder encodeValueOfObjCType:@encode(BOOL) at:&_ascending];
        [coder encodeValueOfObjCType:@encode(SEL) at:&_selector];
    }
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if ((self = [super init]) != nil)
    {
        if ([decoder allowsKeyedCoding])
        {
            ASSIGN(_key, [decoder decodeObjectForKey:@"Key"]);
            _ascending = [decoder decodeBoolForKey:@"Ascending"];
            _selector = NSSelectorFromString([decoder
                                              decodeObjectForKey:@"Selector"]);
        }
        else
        {
            ASSIGN(_key, [decoder decodeObject]);
            [decoder decodeValueOfObjCType:@encode(BOOL) at:&_ascending];
            [decoder decodeValueOfObjCType:@encode(SEL) at:&_selector];
        }
    }
    return self;
}

@end


@implementation NSArray (NSSortDescriptorSorting)

- (NSArray *)sortedArrayUsingDescriptors:(NSArray *)sortDescriptors
{
    NSMutableArray *sortedArray = [GSMutableArray arrayWithArray:self];

    [sortedArray sortUsingDescriptors:sortDescriptors];

    return [sortedArray makeImmutableCopyOnFail:NO];
}

@end



@implementation NSMutableArray (NSSortDescriptorSorting)

- (void)sortUsingDescriptors:(NSArray *)sortDescriptors
{
    unsigned count = [self count];
    unsigned numDescriptors = [sortDescriptors count];

    if (count > 1 && numDescriptors > 0)
    {
        id descriptors[numDescriptors];
        NSArray   *a;
        GS_BEGINIDBUF(objects, count);

        [self getObjects:objects];
        if ([sortDescriptors isProxy])
        {
            unsigned i;

            for (i = 0; i < numDescriptors; i++)
            {
                descriptors[i] = [sortDescriptors objectAtIndex:i];
            }
        }
        else
        {
            [sortDescriptors getObjects:descriptors];
        }
        [self _sort:objects count:count descriptors:descriptors numDescriptors:numDescriptors];
        a = [[NSArray alloc] initWithObjects:objects count:count];
        [self setArray:a];
        RELEASE(a);
        GS_ENDIDBUF();
    }
}

@end

