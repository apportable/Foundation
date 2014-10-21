#import <Foundation/NSArray.h>
#import "NSObjectInternal.h"
#import "NSFastEnumerationEnumerator.h"
#import <CoreFoundation/CFPropertyList.h>
#import <CoreFoundation/CFData.h>

CF_EXPORT Boolean _CFArrayIsMutable(CFArrayRef array);
CF_EXPORT NSUInteger _CFArrayFastEnumeration(CFArrayRef array, NSFastEnumerationState *state, id __unsafe_unretained stackbuffer[], NSUInteger count);
CF_EXPORT const void *_CFArrayCheckAndGetValueAtIndex(CFArrayRef array, CFIndex idx);
CF_EXPORT CFTypeRef _CFPropertyListCreateFromXMLData(CFAllocatorRef allocator, CFDataRef xmlData, CFOptionFlags option, CFStringRef *errorString, Boolean allowNewTypes, CFPropertyListFormat *format);
CF_EXPORT CFDataRef _CFPropertyListCreateXMLData(CFAllocatorRef allocator, CFPropertyListRef propertyList, Boolean checkValidPlist);

@interface NSArray (Internal)
+ (id)newWithContentsOf:(id)pathOrURL immutable:(BOOL)immutable;
- (void)getObjects:(id *)objects count:(NSUInteger)count;
@end

@interface NSMutableArray (Internal)
- (void)_mutate;
@end

__attribute__((visibility("hidden")))
@interface __NSPlaceholderArray : NSMutableArray

+ (id)mutablePlaceholder;
+ (id)immutablePlaceholder;
- (void)dealloc;
- (NSUInteger)retainCount;
- (oneway void)release;
- (id)retain;
- (id)initWithContentsOfURL:(NSURL *)url;
- (id)initWithContentsOfFile:(NSString *)path;
- (id)init;
- (id)initWithCapacity:(NSUInteger)capacity;
- (id)initWithObjects:(const id [])objects count:(NSUInteger)cnt;

@end

__attribute__((visibility("hidden")))
@interface __NSCFArray : NSMutableArray

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key;
- (void)getObjects:(id __unsafe_unretained [])objs range:(NSRange)range;
- (void)removeObjectAtIndex:(NSUInteger)index;
- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)obj;
- (void)insertObject:(id)obj atIndex:(NSUInteger)index;
- (void)removeLastObject;
- (void)addObject:(id)object;
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])buffer count:(NSUInteger)len;
- (id)objectAtIndex:(NSUInteger)index;
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
@interface __NSArrayI : NSArray {
    NSUInteger _used;
}

+ (id)allocWithZone:(NSZone *)zone;
+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key;
+ (id)__new:(const id *)objects :(NSUInteger)count :(BOOL)immutable;
- (void)dealloc;
- (id)copyWithZone:(NSZone *)zone;
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])buffer count:(NSUInteger)len;
- (void)getObjects:(id __unsafe_unretained [])objs range:(NSRange)range;
- (id)objectAtIndex:(NSUInteger)index;
- (NSUInteger)count;

@end

__attribute__((visibility("hidden")))
@interface __NSArrayM : NSMutableArray {
    unsigned int _used;
    unsigned int _doHardRetain:1;
    unsigned int _doWeakAccess:1;
    unsigned int _size:30;
    unsigned int _hasObjects:1;
    unsigned int _hasStrongReferences:1;
    unsigned int _offset:30;
    unsigned long _mutations;
    id *_list;
}

+ (id)allocWithZone:(NSZone *)zone;
+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key;
+ (id)__new:(const id *)arg1 :(unsigned int)arg2 :(BOOL)arg3 :(BOOL)arg4 :(BOOL)arg5;
- (void)removeLastObject;
- (void)addObject:(id)object;
- (id)copyWithZone:(NSZone *)zone;
- (void)dealloc;
- (unsigned int)indexOfObjectIdenticalTo:(id)obj;
- (void)setObject:(id)obj atIndex:(NSUInteger)index;
- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)obj;
- (void)removeObjectAtIndex:(NSUInteger)index;
- (void)insertObject:(id)obj atIndex:(NSUInteger)index;
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])buffer count:(NSUInteger)len;
- (void)getObjects:(id __unsafe_unretained [])objs range:(NSRange)range;
- (id)objectAtIndex:(NSUInteger)index;
- (NSUInteger)count;
- (BOOL)_hasStrongReferences;
- (BOOL)_hasObjects;

@end

__attribute__((visibility("hidden")))
@interface __NSArrayReverseEnumerator : NSEnumerator {
    NSArray *_obj;
    NSUInteger _idx;
}

- (id)initWithObject:(NSArray *)object;
- (void)dealloc;
- (id)nextObject;

@end

@interface NSArray (NSKeyValueInternalCoding)

- (id)_minForKeyPath:(id)keyPath;
- (id)_maxForKeyPath:(id)keyPath;
- (id)_avgForKeyPath:(id)keyPath;
- (id)_sumForKeyPath:(id)keyPath;
- (id)_countForKeyPath:(id)keyPath;
- (id)_distinctUnionOfSetsForKeyPath:(id)keyPath;
- (id)_distinctUnionOfObjectsForKeyPath:(id)keyPath;
- (id)_distinctUnionOfArraysForKeyPath:(id)keyPath;
- (id)_unionOfSetsForKeyPath:(id)keyPath;
- (id)_unionOfArraysForKeyPath:(id)keyPath;
- (id)_unionOfObjectsForKeyPath:(id)keyPath;

@end
