//
//  NSNotification.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/NSNotification.h>
#import "NSNotificationInternal.h"
#import <Foundation/NSCoder.h>
#import <Foundation/NSDictionary.h>
#import "NSObjectInternal.h"
#import <Foundation/NSSet.h>
#import <libkern/OSAtomic.h>

@implementation NSNotification

static NSString * const NSNameKey = @"NS.name";
static NSString * const NSObjectKey = @"NS.object";
static NSString * const NSUserInfoKey = @"NS.userinfo";

+ (id)allocWithZone:(NSZone *)zone
{
    if (self == [NSConcreteNotification class])
    {
        return [super allocWithZone:zone];
    }
    else
    {
        return [NSConcreteNotification allocWithZone:zone];
    }
}

- (id)initWithName:(NSString *)name object:(id)anObject userInfo:(NSDictionary *)aUserInfo
{
    NSRequestConcreteImplementation();
    [self release];
    return nil;
}

- (NSString *)name
{
    NSRequestConcreteImplementation();
    return nil;
}

- (id)object
{
    NSRequestConcreteImplementation();
    return nil;
}

- (NSDictionary *)userInfo
{
    NSRequestConcreteImplementation();
    return nil;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    NSString *name = [self name];
    id object = [self object];
    NSDictionary *userInfo = [self userInfo];

    if ([aCoder allowsKeyedCoding])
    {
        [aCoder encodeObject:name forKey:NSNameKey];
        [aCoder encodeObject:object forKey:NSObjectKey];
        [aCoder encodeObject:userInfo forKey:NSUserInfoKey];
    }
    else
    {
        [aCoder encodeObject:name];
        [aCoder encodeObject:object];
        [aCoder encodeObject:userInfo];
    }
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    NSString *name = nil;
    id object = nil;
    NSDictionary *userInfo = nil;

    if ([aDecoder allowsKeyedCoding])
    {
        name = [aDecoder decodeObjectForKey:NSNameKey];
        object = [aDecoder decodeObjectForKey:NSObjectKey];
        userInfo = [aDecoder decodeObjectForKey:NSUserInfoKey];
    }
    else
    {
        name = [aDecoder decodeObject];
        object = [aDecoder decodeObject];
        userInfo = [aDecoder decodeObject];
    }

    return [self initWithName:name object:object userInfo:userInfo];
}

- (Class)classForCoder
{
    return [NSNotification self];
}

- (id)copyWithZone:(NSZone *)zone
{
    return [[NSNotification alloc] initWithName:[self name] object:[self object] userInfo:[self userInfo]];
}

@end

@implementation NSNotification (NSNotificationCreation)

+ (id)notificationWithName:(NSString *)aName object:(id)anObject
{
    return [[[self alloc] initWithName:aName object:anObject userInfo:nil] autorelease];
}

+ (id)notificationWithName:(NSString *)aName object:(id)anObject userInfo:(NSDictionary *)aUserInfo
{
    return [[[self alloc] initWithName:aName object:anObject userInfo:aUserInfo] autorelease];
}

@end

@implementation NSConcreteNotification {
    NSString *name;
    id object;
    NSDictionary *userInfo;
    BOOL dyingObject;
}

static OSSpinLock notificationPoolLock = OS_SPINLOCK_INIT;
static NSMutableSet *notificationPool = nil;

+ (id)newTempNotificationWithName:(NSString *)name object:(id)anObject userInfo:(NSDictionary *)aUserInfo
{
    static dispatch_once_t once = 0L;
    dispatch_once(&once, ^{
        notificationPool = [[NSMutableSet alloc] init];
    });
    OSSpinLockLock(&notificationPoolLock);
    NSConcreteNotification *notif = [[notificationPool anyObject] retain];
    if (notif == nil) 
    {
        notif = [[NSConcreteNotification alloc] initWithName:name object:anObject userInfo:aUserInfo];
    }
    else
    {
        [notificationPool removeObject:notif];
        notif->name = [name copy];
        notif->object = [anObject retain];
        notif->userInfo = [aUserInfo retain];
    }
    OSSpinLockUnlock(&notificationPoolLock);
    return notif;
}

- (id)initWithName:(NSString *)aName object:(id)anObject userInfo:(NSDictionary *)aUserInfo
{
    self = [super init];
    if (self)
    {
        if (aName == nil)
        {
            [self release];
            return nil;
        }
        name = [aName copy];
        object = [anObject retain];
        userInfo = [aUserInfo retain]; // Tests show that this is retained not copied! Bug?
    }
    return self;
}

- (void)dealloc
{
    [name release];
    [object release];
    [userInfo release];
    [super dealloc];
}

- (NSString *)name
{
    return name;
}

- (id)object
{
    return object;
}

- (NSDictionary *)userInfo
{
    return userInfo;
}

- (void)recycle
{
    OSSpinLockLock(&notificationPoolLock);
    [notificationPool addObject:self];
    [name release];
    name = nil;
    [object release];
    object = nil;
    [userInfo release];
    userInfo = nil;
    [self release];
    OSSpinLockUnlock(&notificationPoolLock);
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"%@ {name: %@, object: %@, userInfo: %@}", [super description], name, object, userInfo];
}

@end
