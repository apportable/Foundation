#import <Foundation/NSDictionary.h>
#import "NSObjectInternal.h"
#import "NSFastEnumerationEnumerator.h"
#import "CFInternal.h"
#import <CoreFoundation/CFPropertyList.h>
#import <CoreFoundation/CFData.h>

CF_EXPORT Boolean _CFDictionaryIsMutable(CFDictionaryRef ref);
CF_EXPORT void _CFDictionarySetKVOBit(CFDictionaryRef hc, CFIndex bit);
CF_EXPORT NSUInteger _CFDictionaryFastEnumeration(CFDictionaryRef hc, NSFastEnumerationState *state, id __unsafe_unretained stackbuffer[], NSUInteger count);
CF_EXPORT CFTypeRef _CFPropertyListCreateFromXMLData(CFAllocatorRef allocator, CFDataRef xmlData, CFOptionFlags option, CFStringRef *errorString, Boolean allowNewTypes, CFPropertyListFormat *format);
CF_EXPORT CFDataRef _CFPropertyListCreateXMLData(CFAllocatorRef allocator, CFPropertyListRef propertyList, Boolean checkValidPlist);

@interface NSDictionary (Internal)
+ (id)newWithContentsOf:(id)source immutable:(BOOL)immutable;
@end

__attribute__((visibility("hidden")))
@interface __NSPlaceholderDictionary : NSMutableDictionary

+ (id)mutablePlaceholder;
+ (id)immutablePlaceholder;
+ (void)initialize;
- (void)removeObjectForKey:(id)key;
- (void)setObject:(id)obj forKey:(id)key;
- (NSEnumerator *)keyEnumerator;
- (id)objectForKey:(id)key;
- (NSUInteger)count;
- (void)dealloc;
- (NSUInteger)retainCount;
- (oneway void)release;
- (id)retain;
- (id)initWithContentsOfURL:(NSURL *)url;
- (id)initWithContentsOfFile:(NSString *)path;
- (id)init;
- (id)initWithCapacity:(NSUInteger)capacity;
- (id)initWithObjects:(const id [])objects forKeys:(const id <NSCopying> [])keys count:(NSUInteger)cnt;

@end

__attribute__((visibility("hidden")))
@interface __NSDictionaryObjectEnumerator : __NSFastEnumerationEnumerator

- (id)nextObject;

@end

__attribute__((visibility("hidden")))
@interface __NSCFDictionary : NSMutableDictionary {
    unsigned char _cfinfo[4];
    unsigned int _bits[4];
    void *_callbacks;
    id *_values;
    id *_keys;
}

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key;
- (void)setObservationInfo:(void *)info;
- (void)removeAllObjects;
- (void)removeObjectForKey:(id)key;
- (void)setObject:(id)obj forKey:(id)key;
- (NSEnumerator *)keyEnumerator;
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])buffer count:(NSUInteger)len;
- (id)objectForKey:(id)key;
- (NSUInteger)count;
- (id)mutableCopyWithZone:(NSZone *)zone;
- (id)copyWithZone:(NSZone *)zone;
- (Class)classForCoder;
- (NSUInteger)retainCount;
- (BOOL)_isDeallocating;
- (BOOL)_tryRetain;
- (oneway void)release;
- (id)retain;
- (NSUInteger)hash;
- (BOOL)isEqual:(id)obj;

@end

__attribute__((visibility("hidden")))
@interface __NSDictionaryI : NSDictionary {
    unsigned int _used:26;
    unsigned int _szidx:6;
}

+ (id)allocWithZone:(NSZone *)zone;
+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key;
+ (id)__new:(const id *)objects  :(const id *)keys :(NSUInteger)count :(BOOL)immutable :(BOOL)copyKeys;
- (id)mutableCopyWithZone:(NSZone *)zone;
- (void)dealloc;
- (id)copyWithZone:(NSZone *)zone;
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])buffer count:(NSUInteger)len;
- (void)getObjects:(id __unsafe_unretained [])objects andKeys:(id __unsafe_unretained [])keys;
- (NSEnumerator *)keyEnumerator;
- (id)objectForKey:(id)key;
- (NSUInteger)count;

@end
