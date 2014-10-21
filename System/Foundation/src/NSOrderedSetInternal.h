#import <Foundation/NSOrderedSet.h>

#import <Foundation/NSArray.h>
#import <Foundation/NSEnumerator.h>
#import <Foundation/NSSet.h>

#import "CFBasicHash.h"

@interface __NSPlaceholderOrderedSet : NSMutableOrderedSet
+ (id)mutablePlaceholder;
+ (id)immutablePlaceholder;
@end

@interface __NSOrderedSetI : NSOrderedSet
+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key;
+ (id)__new:(const id *)addr :(NSUInteger)count :(BOOL)tbd;
@end

@interface __NSOrderedSetM : NSMutableOrderedSet
+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key;
+ (id)__new:(const id *)addr :(NSUInteger)count :(BOOL)tbd;
- (void)_mutate;
@end

@interface __NSOrderedSetArrayProxy : NSArray
- (id)initWithOrderedSet:(NSOrderedSet *)orderedSet;
@end

@interface __NSOrderedSetSetProxy : NSSet
- (id)initWithOrderedSet:(NSOrderedSet *)orderedSet;
@end

@interface __NSOrderedSetReversed : NSOrderedSet
@end

@interface __NSOrderedSetReverseEnumerator : NSEnumerator
- (id)initWithObject:(id)object;
@end

@interface NSOrderedSet (NSKeyValueInternalCoding)

- (id)_minForKeyPath:(id)keyPath;
- (id)_maxForKeyPath:(id)keyPath;
- (id)_avgForKeyPath:(id)keyPath;
- (id)_sumForKeyPath:(id)keyPath;
- (id)_countForKeyPath:(id)keyPath;

@end
