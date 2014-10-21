#import <Foundation/NSLocale.h>
#import <Foundation/NSCoder.h>

extern CFDictionaryRef __CFLocaleGetPrefs(CFLocaleRef locale);

@interface NSLocale ()
- (id)_prefs;
@end

__attribute__((visibility("hidden")))
@interface __NSCFLocale : NSLocale

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key;
- (id)_prefs;
- (id)initWithLocaleIdentifier:(NSString *)identifier;
- (NSString *)displayNameForKey:(id)key value:(id)value;
- (id)objectForKey:(id)key;
- (NSUInteger)retainCount;
- (BOOL)_isDeallocating;
- (BOOL)_tryRetain;
- (oneway void)release;
- (id)retain;
- (NSUInteger)hash;
- (BOOL)isEqual:(id)other;

@end

__attribute__((visibility("hidden")))
@interface NSAutoLocale : NSLocale {
    NSLocale *loc;
}

+ (BOOL)supportsSecureCoding;
- (Class)classForCoder;
- (id)initWithCoder:(NSCoder *)coder;
- (void)encodeWithCoder:(NSCoder *)coder;
- (id)copyWithZone:(NSZone *)zone;
- (id)description;
- (id)_prefs;
- (NSString *)displayNameForKey:(id)key value:(id)value;
- (id)objectForKey:(id)key;
- (void)dealloc;
- (id)initWithLocaleIdentifier:(NSString *)identifier;
- (id)_init;

@end
