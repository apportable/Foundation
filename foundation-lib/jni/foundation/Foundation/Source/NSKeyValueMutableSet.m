/* Mutable set proxies for GNUstep's KeyValueCoding
   Copyright (C) 2007 Free Software Foundation, Inc.

   Written by:  Chris Farber <chris@chrisfarber.net>

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

   $Date: 2007-06-08 04:04:14 -0400 (Fri, 08 Jun 2007) $ $Revision: 25230 $
 */

#import "common.h"
#import "Foundation/NSInvocation.h"

@interface NSKeyValueMutableSet : NSMutableSet
{
    @protected
    id object;
    NSString *key;
    NSMutableSet *set;
    BOOL changeInProgress;
}

+ (NSKeyValueMutableSet*)setForKey:(NSString*)aKey ofObject:(id)anObject;
- (id)initWithKey:(NSString*)aKey ofObject:(id)anObject;

@end

@interface NSKeyValueFastMutableSet : NSKeyValueMutableSet
{
    @private
    NSInvocation *addObjectInvocation;
    NSInvocation *removeObjectInvocation;
    NSInvocation *addSetInvocation;
    NSInvocation *removeSetInvocation;
    NSInvocation *intersectInvocation;
    NSInvocation *setSetInvocation;
}

+ (id)setForKey:(NSString*)aKey ofObject:(id)anObject
    withCapitalizedKey:(const char *)capitalized;

- (id)initWithKey:(NSString *)aKey ofObject:(id)anObject
    withCapitalizedKey:(const char *)capitalized;

@end

@interface NSKeyValueSlowMutableSet : NSKeyValueMutableSet
{
    @private
    NSInvocation *setSetInvocation;
}

+ (id)setForKey:(NSString *)aKey ofObject:(id)anObject
    withCapitalizedKey:(const char *)capitalized;

- (id)initWithKey:(NSString *)aKey ofObject:(id)anObject
    withCapitalizedKey:(const char *)capitalized;

@end

@interface NSKeyValueIvarMutableSet : NSKeyValueMutableSet
{
    @private
}

+ (id)setForKey:(NSString *)aKey ofObject:(id)anObject;

- (id)initWithKey:(NSString *)aKey ofObject:(id)anObject;

@end


@implementation NSKeyValueMutableSet

+ (NSKeyValueMutableSet *)setForKey:(NSString *)aKey ofObject:(id)anObject
{
    NSKeyValueMutableSet *proxy;
    unsigned size = [aKey maximumLengthOfBytesUsingEncoding:
                     NSUTF8StringEncoding];
    char keybuf[size + 1];

    [aKey getCString:keybuf
     maxLength:size + 1
     encoding:NSUTF8StringEncoding];
    if (islower(*keybuf))
    {
        *keybuf = toupper(*keybuf);
    }


    proxy = [NSKeyValueFastMutableSet setForKey:aKey
             ofObject:anObject
             withCapitalizedKey:keybuf];
    if (proxy == nil)
    {
        proxy = [NSKeyValueSlowMutableSet setForKey:aKey
                 ofObject:anObject
                 withCapitalizedKey:keybuf];

        if (proxy == nil)
        {
            proxy = [NSKeyValueIvarMutableSet setForKey:aKey
                     ofObject:anObject];
        }
    }
    return proxy;
}

- (id)initWithKey:(NSString *)aKey ofObject:(id)anObject
{
    if ((self = [super init]) != nil)
    {
        object = anObject;
        key = [aKey copy];
        changeInProgress = NO;
    }
    return self;
}

- (NSUInteger)count
{
    if (set == nil)
    {
        set = [object valueForKey:key];
    }
    return [set count];
}

- (id)member:(id)anObject
{
    if (set == nil)
    {
        set = [object valueForKey:key];
    }
    return [set member:anObject];
}

- (NSEnumerator *)objectEnumerator
{
    if (set == nil)
    {
        set = [object valueForKey:key];
    }
    return [set objectEnumerator];
}

- (void)removeAllObjects
{
    if (set == nil)
    {
        set = [object valueForKey:key];
    }
    [set removeAllObjects];
}

- (id)anyObject
{
    if (set == nil)
    {
        set = [object valueForKey:key];
    }
    return [set anyObject];
}

@end

@implementation NSKeyValueFastMutableSet

+ (id)setForKey:(NSString *)aKey ofObject:(id)anObject
    withCapitalizedKey:(const char *)capitalized
{
    return [[[self alloc] initWithKey:aKey
             ofObject:anObject
             withCapitalizedKey:capitalized] autorelease];
}

- (id)initWithKey:(NSString *)aKey ofObject:(id)anObject
    withCapitalizedKey:(const char *)capitalized
{
    SEL addObject;
    SEL removeObject;
    SEL addSet;
    SEL removeSet;
    SEL intersect;
    SEL setSet;
    BOOL canAdd = NO;
    BOOL canRemove = NO;


    addObject = NSSelectorFromString
                    ([NSString stringWithFormat:@"add%sObject:", capitalized]);
    removeObject = NSSelectorFromString
                       ([NSString stringWithFormat:@"remove%sObject:", capitalized]);
    addSet = NSSelectorFromString
                 ([NSString stringWithFormat:@"add%s:", capitalized]);
    removeSet = NSSelectorFromString
                    ([NSString stringWithFormat:@"remove%s:", capitalized]);

    if ([anObject respondsToSelector:addObject])
    {
        canAdd = YES;
        addObjectInvocation = [[NSInvocation invocationWithMethodSignature:
                                [anObject methodSignatureForSelector:addObject]] retain];
        [addObjectInvocation setTarget:anObject];
        [addObjectInvocation setSelector:addObject];
    }
    if ([anObject respondsToSelector:removeObject])
    {
        canRemove = YES;
        removeObjectInvocation = [[NSInvocation invocationWithMethodSignature:
                                   [anObject methodSignatureForSelector:removeObject]] retain];
        [removeObjectInvocation setTarget:anObject];
        [removeObjectInvocation setSelector:removeObject];
    }
    if ([anObject respondsToSelector:addSet])
    {
        canAdd = YES;
        addSetInvocation = [[NSInvocation invocationWithMethodSignature:
                             [anObject methodSignatureForSelector:addSet]] retain];
        [addSetInvocation setTarget:anObject];
        [addSetInvocation setSelector:addSet];
    }
    if ([anObject respondsToSelector:removeSet])
    {
        canRemove = YES;
        removeSetInvocation = [[NSInvocation invocationWithMethodSignature:
                                [anObject methodSignatureForSelector:removeSet]] retain];
        [removeSetInvocation setTarget:anObject];
        [removeSetInvocation setSelector:removeSet];
    }

    if (!canAdd || !canRemove)
    {
        DESTROY(self);
        return nil;
    }

    if ((self = [super initWithKey:aKey ofObject:anObject]) != nil)
    {
        intersect = NSSelectorFromString
                        ([NSString stringWithFormat:@"intersect%s:", capitalized]);
        setSet = NSSelectorFromString
                     ([NSString stringWithFormat:@"set%s:", capitalized]);

        if ([anObject respondsToSelector:intersect])
        {
            intersectInvocation = [[NSInvocation invocationWithMethodSignature:
                                    [anObject methodSignatureForSelector:intersect]] retain];
            [intersectInvocation setTarget:anObject];
            [intersectInvocation setSelector:intersect];
        }
        if ([anObject respondsToSelector:setSet])
        {
            setSetInvocation = [[NSInvocation invocationWithMethodSignature:
                                 [anObject methodSignatureForSelector:setSet]] retain];
            [setSetInvocation setTarget:anObject];
            [setSetInvocation setSelector:setSet];
        }
    }
    return self;
}

- (void)dealloc
{
    [setSetInvocation release];
    [intersectInvocation release];
    [removeSetInvocation release];
    [addSetInvocation release];
    [removeObjectInvocation release];
    [addObjectInvocation release];
    [super dealloc];
}

- (void)addObject:(id)anObject {
    if (addObjectInvocation) {
        if (changeInProgress) {
            [addObjectInvocation setArgument:&anObject atIndex:2];
            [addObjectInvocation invoke];
        } else {
            changeInProgress = YES;
            NSSet *objectSet = [NSSet setWithObject:anObject];
            [object willChangeValueForKey:key
             withSetMutation:NSKeyValueUnionSetMutation
             usingObjects:objectSet];
            [addObjectInvocation setArgument:&anObject atIndex:2];
            [addObjectInvocation invoke];
            [object didChangeValueForKey:key
             withSetMutation:NSKeyValueUnionSetMutation
             usingObjects:objectSet];
            changeInProgress = NO;
        }
    } else {
        [self unionSet:[NSSet setWithObject:anObject]];
    }
}

- (void)unionSet:(NSSet *)aSet {
    if (changeInProgress) {
        if (addSetInvocation) {
            [addSetInvocation setArgument:&aSet atIndex:2];
            [addSetInvocation invoke];
        } else {
            [super unionSet:aSet];
        }
    } else {
        changeInProgress = YES;
        [object willChangeValueForKey:key
         withSetMutation:NSKeyValueUnionSetMutation
         usingObjects:aSet];
        if (addSetInvocation) {
            [addSetInvocation setArgument:&aSet atIndex:2];
            [addSetInvocation invoke];
        } else {
            [super unionSet:aSet];
        }
        [object didChangeValueForKey:key
         withSetMutation:NSKeyValueUnionSetMutation
         usingObjects:aSet];
        changeInProgress = NO;
    }
}

- (void)removeObject:(id)anObject {
    NSSet *objectSet = [NSSet setWithObject:anObject];
    if (removeObjectInvocation) {
        if (changeInProgress) {
            [removeObjectInvocation setArgument:&anObject atIndex:2];
            [removeObjectInvocation invoke];
        } else {
            changeInProgress = YES;
            [object willChangeValueForKey:key
             withSetMutation:NSKeyValueMinusSetMutation
             usingObjects:objectSet];
            [removeObjectInvocation setArgument:&anObject atIndex:2];
            [removeObjectInvocation invoke];
            [object didChangeValueForKey:key
             withSetMutation:NSKeyValueMinusSetMutation
             usingObjects:objectSet];
            changeInProgress = NO;
        }
    } else {
        [self minusSet:objectSet];
    }
}

- (void)removeAllObjects {
    [self intersectSet:[NSSet set]];
}

- (void)minusSet:(NSSet *)aSet {
    if (changeInProgress) {
        if (removeSetInvocation) {
            [removeSetInvocation setArgument:&aSet atIndex:2];
            [removeSetInvocation invoke];
        } else {
            [super minusSet:aSet];
        }
    } else {
        changeInProgress = YES;
        [object willChangeValueForKey:key
         withSetMutation:NSKeyValueMinusSetMutation
         usingObjects:aSet];
        if (removeSetInvocation) {
            [removeSetInvocation setArgument:&aSet atIndex:2];
            [removeSetInvocation invoke];
        } else {
            [super minusSet:aSet];
        }
        [object didChangeValueForKey:key
         withSetMutation:NSKeyValueMinusSetMutation
         usingObjects:aSet];
        changeInProgress = NO;
    }
}

- (void)intersectSet:(NSSet *)aSet {
    if (changeInProgress) {
        if (intersectInvocation) {
            [intersectInvocation setArgument:&aSet atIndex:2];
            [intersectInvocation invoke];
        } else {
            [super intersectSet:aSet];
        }
    } else {
        changeInProgress = YES;
        [object willChangeValueForKey:key
         withSetMutation:NSKeyValueIntersectSetMutation
         usingObjects:aSet];
        if (intersectInvocation) {
            [intersectInvocation setArgument:&aSet atIndex:2];
            [intersectInvocation invoke];
        } else {
            [super intersectSet:aSet];
        }
        [object didChangeValueForKey:key
         withSetMutation:NSKeyValueIntersectSetMutation
         usingObjects:aSet];
        changeInProgress = NO;
    }
}

- (void)setSet:(NSSet *)aSet {
    if (changeInProgress) {
        if (setSetInvocation) {
            [setSetInvocation setArgument:&aSet atIndex:2];
            [setSetInvocation invoke];
        } else {
            [super setSet:aSet];
        }
    } else {
        changeInProgress = YES;
        [object willChangeValueForKey:key
         withSetMutation:NSKeyValueSetSetMutation
         usingObjects:aSet];
        if (setSetInvocation) {
            [setSetInvocation setArgument:&aSet atIndex:2];
            [setSetInvocation invoke];
        } else {
            [super setSet:aSet];
        }
        [object didChangeValueForKey:key
         withSetMutation:NSKeyValueSetSetMutation
         usingObjects:aSet];
        changeInProgress = NO;
    }
}

@end

@implementation NSKeyValueSlowMutableSet

+ (id)setForKey:(NSString *)aKey ofObject:(id)anObject
    withCapitalizedKey:(const char *)capitalized
{
    return [[[self alloc] initWithKey:aKey ofObject:anObject
             withCapitalizedKey:capitalized] autorelease];
}

- (id)initWithKey:(NSString *)aKey ofObject:(id)anObject
    withCapitalizedKey:(const char *)capitalized;

{
    SEL setSelector = NSSelectorFromString([NSString stringWithFormat:
                                            @"set%s:", capitalized]);

    if (![anObject respondsToSelector:setSelector])
    {
        DESTROY(self);
        return nil;
    }

    if ((self = [super initWithKey:aKey ofObject:anObject]) != nil)
    {
        setSetInvocation = [[NSInvocation invocationWithMethodSignature:
                             [anObject methodSignatureForSelector:setSelector]] retain];
        [setSetInvocation setSelector:setSelector];
        [setSetInvocation setTarget:anObject];
    }
    return self;
}

- (void)setSet:(id)otherSet {
    // object.key = copy(otherSet)
    NSSet *newSet = [NSSet setWithSet:otherSet];
    NSMutableSet *temp = [NSMutableSet setWithSet:otherSet];
    [object willChangeValueForKey:key
     withSetMutation:NSKeyValueSetSetMutation
     usingObjects:newSet];
    [setSetInvocation setArgument:&temp atIndex:2];
    [setSetInvocation invoke];
    [object didChangeValueForKey:key
     withSetMutation:NSKeyValueSetSetMutation
     usingObjects:newSet];
}

- (void)removeAllObjects {
    // remove all is equivalent to intersecting with nothing, so we do that for
    // simplicity
    // object.key I= <emptySet>
    NSMutableSet *temp = [NSMutableSet set];
    NSSet *nothing = [NSSet set];
    [object willChangeValueForKey:key
     withSetMutation:NSKeyValueIntersectSetMutation
     usingObjects:nothing];
    [setSetInvocation setArgument:&temp atIndex:2];
    [setSetInvocation invoke];
    [object didChangeValueForKey:key
     withSetMutation:NSKeyValueIntersectSetMutation
     usingObjects:nothing];
}

- (void)addObject:(id)addedObj {
    // object.key U= setWithObject(addedObj)
    NSSet *addedSet = [NSSet setWithObject:addedObj];
    NSMutableSet *temp;
    [object willChangeValueForKey:key
     withSetMutation:NSKeyValueUnionSetMutation
     usingObjects:addedSet];
    temp = [NSMutableSet setWithSet:[object valueForKey:key]];
    [temp addObject:addedObj];
    [setSetInvocation setArgument:&temp atIndex:2];
    [setSetInvocation invoke];
    [object didChangeValueForKey:key
     withSetMutation:NSKeyValueUnionSetMutation
     usingObjects:addedSet];
}

- (void)removeObject:(id)removedObj {
    // object.key -= setWithObject(removedObj)
    NSSet *removedSet = [NSSet setWithObject:removedObj];
    NSMutableSet *temp;
    [object willChangeValueForKey:key
     withSetMutation:NSKeyValueMinusSetMutation
     usingObjects:removedSet];
    temp = [NSMutableSet setWithSet:[object valueForKey:key]];
    [temp removeObject:removedObj];
    [setSetInvocation setArgument:&temp atIndex:2];
    [setSetInvocation invoke];
    [object didChangeValueForKey:key
     withSetMutation:NSKeyValueMinusSetMutation
     usingObjects:removedSet];
}

- (void)unionSet:(id)otherSet {
    // object.key U= copy(aSet)
    NSSet *otherCopy = [NSSet setWithSet:otherSet];
    NSMutableSet *temp;
    [object willChangeValueForKey:key
     withSetMutation:NSKeyValueUnionSetMutation
     usingObjects:otherCopy];
    temp = [NSMutableSet setWithSet:[object valueForKey:key]];
    [temp unionSet:otherSet];
    [setSetInvocation setArgument:&temp atIndex:2];
    [setSetInvocation invoke];
    [object didChangeValueForKey:key
     withSetMutation:NSKeyValueUnionSetMutation
     usingObjects:otherCopy];
}

- (void)minusSet:(id)otherSet {
    // object.key -= copy(aSet)
    NSSet *otherCopy = [NSSet setWithSet:otherSet];
    NSMutableSet *temp;
    [object willChangeValueForKey:key
     withSetMutation:NSKeyValueMinusSetMutation
     usingObjects:otherCopy];
    temp = [NSMutableSet setWithSet:[object valueForKey:key]];
    [temp minusSet:otherSet];
    [setSetInvocation setArgument:&temp atIndex:2];
    [setSetInvocation invoke];
    [object didChangeValueForKey:key
     withSetMutation:NSKeyValueMinusSetMutation
     usingObjects:otherCopy];
}

- (void)intersectSet:(id)otherSet {
    // object.key I= copy(otherSet)
    NSSet *otherCopy = [NSSet setWithSet:otherSet];
    NSMutableSet *temp;
    [object willChangeValueForKey:key
     withSetMutation:NSKeyValueIntersectSetMutation
     usingObjects:otherCopy];
    temp = [NSMutableSet setWithSet:[object valueForKey:key]];
    [temp intersectSet:otherSet];
    [setSetInvocation setArgument:&temp atIndex:2];
    [setSetInvocation invoke];
    [object didChangeValueForKey:key
     withSetMutation:NSKeyValueIntersectSetMutation
     usingObjects:otherCopy];
}

- (NSUInteger)count
{
    return [[object valueForKey:key] count];
}

- (id)member:(id)anObject
{
    return [[object valueForKey:key] member:anObject];
}

- (NSEnumerator *)objectEnumerator
{
    return [[object valueForKey:key] objectEnumerator];
}

- (id)anyObject
{
    return [[object valueForKey:key] anyObject];
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)len
{
    return [[object valueForKey:key] countByEnumeratingWithState:state objects:stackbuf count:len];
}

@end


@implementation NSKeyValueIvarMutableSet

+ (id)setForKey:(NSString *)aKey ofObject:(id)anObject
{
    return [[[self alloc] initWithKey:aKey ofObject:anObject] autorelease];
}

- (id)initWithKey:(NSString *)aKey ofObject:(id)anObject
{
    if ((self = [super initWithKey:aKey ofObject:anObject]) != nil)
    {
        unsigned size = [aKey maximumLengthOfBytesUsingEncoding:
                         NSUTF8StringEncoding];
        char cKey[size + 2];
        char *cKeyPtr = &cKey[0];
        const char *type = 0;

        int offset;


        cKey[0] = '_';
        [aKey getCString:cKeyPtr + 1
         maxLength:size + 1
         encoding:NSUTF8StringEncoding];
        if (!GSObjCFindVariable (anObject, cKeyPtr, &type, &size, &offset))
        {
            GSObjCFindVariable (anObject, ++cKeyPtr, &type, &size, &offset);
        }
        set = GSObjCGetVal (anObject, cKeyPtr, NULL, type, size, offset);
    }
    return self;
}

- (NSUInteger)count
{
    return [set count];
}

- (NSArray *)allObjects
{
    return [set allObjects];
}

- (BOOL)containsObject:(id)anObject
{
    return [set containsObject:anObject];
}

- (id)member:(id)anObject
{
    return [set member:anObject];
}

- (void)addObject:(id)anObject {
    if (changeInProgress) {
        [set addObject:anObject];
    } else {
        changeInProgress = YES;
        NSSet *objectSet = [NSSet setWithObject:anObject];
        [object willChangeValueForKey:key
         withSetMutation:NSKeyValueUnionSetMutation
         usingObjects:objectSet];
        [set addObject:anObject];
        [object didChangeValueForKey:key
         withSetMutation:NSKeyValueUnionSetMutation
         usingObjects:objectSet];
        changeInProgress = NO;
    }
}

- (void)removeObject:(id)anObject {
    if (changeInProgress) {
        [set removeObject:anObject];
    } else {
        changeInProgress = YES;
        NSSet *objectSet = [NSSet setWithObject:anObject];
        [object willChangeValueForKey:key
         withSetMutation:NSKeyValueMinusSetMutation
         usingObjects:objectSet];
        [set removeObject:anObject];
        [object didChangeValueForKey:key
         withSetMutation:NSKeyValueMinusSetMutation
         usingObjects:objectSet];
        changeInProgress = NO;
    }
}

- (void)removeAllObjects {
    if (changeInProgress) {
        [set removeAllObjects];
    } else {
        changeInProgress = YES;
        NSSet *objectSet = [NSSet set];
        [object willChangeValueForKey:key
         withSetMutation:NSKeyValueIntersectSetMutation
         usingObjects:objectSet];
        [set removeAllObjects];
        [object didChangeValueForKey:key
         withSetMutation:NSKeyValueIntersectSetMutation
         usingObjects:objectSet];
        changeInProgress = NO;
    }
}

- (void)unionSet:(id)otherSet {
    if (changeInProgress) {
        [set unionSet:otherSet];
    } else {
        changeInProgress = YES;
        NSSet *otherCopy = [NSSet setWithSet:otherSet];
        [object willChangeValueForKey:key
         withSetMutation:NSKeyValueUnionSetMutation
         usingObjects:otherCopy];
        [set unionSet:otherSet];
        [object didChangeValueForKey:key
         withSetMutation:NSKeyValueUnionSetMutation
         usingObjects:otherCopy];
        changeInProgress = NO;
    }
}

- (void)minusSet:(id)otherSet {
    if (changeInProgress) {
        [set minusSet:otherSet];
    } else {
        changeInProgress = YES;
        NSSet *otherCopy = [NSSet setWithSet:otherSet];
        [object willChangeValueForKey:key
         withSetMutation:NSKeyValueMinusSetMutation
         usingObjects:otherCopy];
        [set minusSet:otherSet];
        [object didChangeValueForKey:key
         withSetMutation:NSKeyValueMinusSetMutation
         usingObjects:otherCopy];
        changeInProgress = NO;
    }
}

- (void)intersectSet:(id)otherSet {
    if (changeInProgress) {
        [set intersectSet:otherSet];
    } else {
        changeInProgress = YES;
        NSSet *otherCopy = [NSSet setWithSet:otherSet];
        [object willChangeValueForKey:key
         withSetMutation:NSKeyValueIntersectSetMutation
         usingObjects:otherCopy];
        [set intersectSet:otherSet];
        [object didChangeValueForKey:key
         withSetMutation:NSKeyValueIntersectSetMutation
         usingObjects:otherCopy];
        changeInProgress = NO;
    }
}

- (void)setSet:(id)otherSet {
    if (changeInProgress) {
        [set setSet:otherSet];
    } else {
        changeInProgress = YES;
        NSSet *otherCopy = [NSSet setWithSet:otherSet];
        [object willChangeValueForKey:key
         withSetMutation:NSKeyValueSetSetMutation
         usingObjects:otherCopy];
        [set setSet:otherSet];
        [object didChangeValueForKey:key
         withSetMutation:NSKeyValueSetSetMutation
         usingObjects:otherCopy];
        changeInProgress = NO;
    }
}
@end
