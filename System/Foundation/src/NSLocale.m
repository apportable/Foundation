//
//  NSLocale.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/NSLocale.h>

#import <Foundation/NSCoder.h>
#import <Foundation/NSException.h>
#import <Foundation/NSNotification.h>

CF_PRIVATE
@interface NSAutoLocale : NSLocale
- (id)_init;
@end

@interface NSLocale (Internal)
- (id)_prefs;
@end


@implementation NSLocale (NSLocale)

- (Class)classForCoder
{
    return [NSLocale self];
}

+ (id)autoupdatingCurrentLocale
{
    return [[[NSAutoLocale alloc] _init] autorelease];
}

@end


@implementation NSAutoLocale {
    NSLocale *loc;
}

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (Class)classForCoder
{
    return [NSAutoLocale self];
}

- (id)initWithCoder:(NSCoder *)coder
{
    if (![coder allowsKeyedCoding])
    {
        [self release];
        [NSException raise:NSInvalidArgumentException format:@"NSLocale does not support non keyed coders"];
        return nil;
    }
    return [self _init];
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    if (![coder allowsKeyedCoding])
    {
        [NSException raise:NSInvalidArgumentException format:@"NSLocale does not support non keyed coders"];
        return;
    }
}

- (id)copyWithZone:(NSZone *)zone
{
    return [self retain];
}

- (id)description
{
    return [loc description];
}

- (id)_prefs
{
    return [loc _prefs];
}

- (NSString *)displayNameForKey:(id)key value:(id)value
{
    return [loc displayNameForKey:key value:value];
}

- (id)objectForKey:(id)key
{
    return [loc objectForKey:key];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (id)initWithLocaleIdentifier:(NSString *)identifier
{
    return [self _init];
}

- (id)_init
{
    self = [super init];
    if (self)
    {
        loc = [[NSLocale currentLocale] retain];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_update:) name:(NSString *)kCFLocaleCurrentLocaleDidChangeNotification object:nil];
    }
    return self;
}

- (void)_update:(NSNotification *)notif
{
    [loc release];
    loc = [[NSLocale currentLocale] retain];
}


@end
