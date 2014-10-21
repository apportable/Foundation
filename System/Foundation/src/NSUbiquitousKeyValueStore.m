//
//  NSUbiquitousKeyValueStore.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "NSUbiquitousKeyValueStoreInternal.h"
#import "NSObjectInternal.h"
#import <Foundation/NSDictionary.h>
#import <Foundation/NSThread.h>
#import <Foundation/NSRunLoop.h>
#import <Foundation/NSData.h>
#import <Foundation/NSString.h>
#import <Foundation/NSValue.h>
#import <Foundation/NSException.h>

NSString * const NSUbiquitousKeyValueStoreDidChangeExternallyNotification = @"NSUbiquitousKeyValueStoreDidChangeExternallyNotification";
NSString * const NSUbiquitousKeyValueStoreChangeReasonKey = @"NSUbiquitousKeyValueStoreChangeReasonKey";
NSString * const NSUbiquitousKeyValueStoreChangedKeysKey = @"NSUbiquitousKeyValueStoreChangedKeysKey";

@implementation NSUbiquitousKeyValueStore {
    id<_NSUbiquitousKeyValueStoreProvider> _provider;
    dispatch_queue_t _providerQueue;
}

+ (NSUbiquitousKeyValueStore *)defaultStore
{
    static NSUbiquitousKeyValueStore *defaultStore = nil;
    static dispatch_once_t once = 0L;
    dispatch_once(&once, ^{
        defaultStore = [[NSUbiquitousKeyValueStore alloc] init];
    });
    return defaultStore;
}

- (id)init
{
    NSMutableDictionary<_NSUbiquitousKeyValueStoreProvider> *provider = (NSMutableDictionary<_NSUbiquitousKeyValueStoreProvider> *)[[NSMutableDictionary alloc] init];
    id obj = [self _initWithProvider:provider];
    [provider release];
    return obj;
}

- (id)_initWithProvider:(id<_NSUbiquitousKeyValueStoreProvider>)provider
{
    self = [super init];
    if (self)
    {
        _providerQueue = dispatch_queue_create("com.apportable.ubiquity", NULL);
        _provider = [provider retain];
    }
    return self;
}

- (void)dealloc
{
    dispatch_release(_providerQueue);
    [_provider release];
    [super dealloc];
}

- (void)_setKeyValueStoreProvider:(id<_NSUbiquitousKeyValueStoreProvider>)provider
{
    if (_provider != provider)
    {
        dispatch_sync(_providerQueue, ^{
            [_provider release];
            _provider = [provider retain];
        });
    }
}

- (id)objectForKey:(NSString *)aKey
{
    __block id obj = nil;
    dispatch_sync(_providerQueue, ^{
        obj = [[_provider objectForKey:aKey] retain];
    });
    return [obj autorelease];
}

static BOOL validateObject(id obj)
{
    if ([obj isNSString__] ||
        [obj isNSNumber__] ||
        [obj isNSData__])
    {
        return YES;
    }
    else if ([obj isNSDictionary__])
    {
        for (id key in obj)
        {
            if (!validateObject(key) ||
                !validateObject([obj objectForKey:key]))
            {
                return NO;
            }
        }
        return YES;
    }
    else if ([obj isNSArray__])
    {
        for (id item in obj)
        {
            if (!validateObject(item))
            {
                return NO;
            }
        }
        return YES;
    }
    else
    {
        return NO;
    }
}

- (void)_adjustTimerForAutosync
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(synchronize) object:nil];
    [self performSelector:@selector(synchronize) withObject:nil afterDelay:1.0];
}

static inline void readjustTimer(NSUbiquitousKeyValueStore *self)
{
    if ([NSThread isMainThread])
    {
        [self _adjustTimerForAutosync];
    }
    else
    {
        [self performSelectorOnMainThread:@selector(_adjustTimerForAutosync) withObject:nil waitUntilDone:NO];
    }
}

- (void)setObject:(id)anObject forKey:(NSString *)aKey
{
    if (!validateObject(anObject))
    {
        [NSException raise:NSInvalidArgumentException format:@"object is invalid or contains an invalid type %@", anObject];
    }
    dispatch_async(_providerQueue, ^{
        [_provider setObject:anObject forKey:aKey];
    });
    readjustTimer(self);
}

- (void)removeObjectForKey:(NSString *)aKey
{
    dispatch_async(_providerQueue, ^{
        [_provider removeObjectForKey:aKey];
    });
    readjustTimer(self);
}

- (NSString *)stringForKey:(NSString *)aKey
{
    id obj = [self objectForKey:aKey];

    if ([obj isNSString__])
    {
        return (NSString *)obj;
    }

    return nil;
}

- (NSArray *)arrayForKey:(NSString *)aKey
{
    id obj = [self objectForKey:aKey];

    if ([obj isNSArray__])
    {
        return (NSArray *)obj;
    }
    
    return nil;
}

- (NSDictionary *)dictionaryForKey:(NSString *)aKey
{
    id obj = [self objectForKey:aKey];

    if ([obj isNSDictionary__])
    {
        return (NSDictionary *)obj;
    }
    
    return nil;
}

- (NSData *)dataForKey:(NSString *)aKey
{
    id obj = [self objectForKey:aKey];

    if ([obj isNSData__])
    {
        return (NSData *)obj;
    }
    
    return nil;
}

- (long long)longLongForKey:(NSString *)aKey
{
    id obj = [self objectForKey:aKey];

    if ([obj isNSString__] ||
        [obj isNSNumber__])
    {
        return [(NSString *)obj longLongValue];
    }
    return 0LL;
}

- (double)doubleForKey:(NSString *)aKey
{
    id obj = [self objectForKey:aKey];

    if ([obj isNSString__] ||
        [obj isNSNumber__])
    {
        return [(NSString *)obj doubleValue];
    }
    return 0.0;
}

- (BOOL)boolForKey:(NSString *)aKey
{
    id obj = [self objectForKey:aKey];

    if ([obj isNSString__] ||
        [obj isNSNumber__])
    {
        return [(NSString *)obj boolValue];
    }
    return NO;
}

- (void)setString:(NSString *)aString forKey:(NSString *)aKey
{
    if (![aString isNSString__])
    {
        [NSException raise:NSInvalidArgumentException format:@"%@ is not a string", aString];
        return;
    }

    [self setObject:aString forKey:aKey];
}

- (void)setData:(NSData *)aData forKey:(NSString *)aKey
{
    if (![aData isNSData__])
    {
        [NSException raise:NSInvalidArgumentException format:@"%@ is not data", aData];
        return;
    }

    [self setObject:aData forKey:aKey];
}

- (void)setArray:(NSArray *)anArray forKey:(NSString *)aKey
{
    if (![anArray isNSArray__])
    {
        [NSException raise:NSInvalidArgumentException format:@"%@ is not an array", anArray];
        return;
    }

    [self setObject:anArray forKey:aKey];
}

- (void)setDictionary:(NSDictionary *)aDictionary forKey:(NSString *)aKey
{
    if (![aDictionary isNSDictionary__])
    {
        [NSException raise:NSInvalidArgumentException format:@"%@ is not a dictionary", aDictionary];
        return;
    }

    [self setObject:aDictionary forKey:aKey];
}

- (void)setLongLong:(long long)value forKey:(NSString *)aKey
{
    [self setObject:@(value) forKey:aKey];
}

- (void)setDouble:(double)value forKey:(NSString *)aKey
{
    [self setObject:@(value) forKey:aKey];
}

- (void)setBool:(BOOL)value forKey:(NSString *)aKey
{
    [self setObject:@(value) forKey:aKey];
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *rep = [[NSMutableDictionary alloc] init];
    dispatch_sync(_providerQueue, ^{
        for (NSString *key in [_provider keyEnumerator])
        {
            [rep setObject:[_provider objectForKey:key] forKey:key];
        }
    });
    return [rep autorelease];
}

- (BOOL)synchronize
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(synchronize) object:nil];
    __block BOOL synced = NO;
    if ([_provider respondsToSelector:@selector(synchronize)])
    {
        dispatch_sync(_providerQueue, ^{
            synced = [_provider synchronize];
        });
    }
    return synced;
}

@end
