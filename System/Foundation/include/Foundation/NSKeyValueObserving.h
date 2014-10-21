#import <Foundation/NSArray.h>
#import <Foundation/NSOrderedSet.h>
#import <Foundation/NSSet.h>

@class NSIndexSet, NSString;

typedef NS_OPTIONS(NSUInteger, NSKeyValueObservingOptions) {
    NSKeyValueObservingOptionNew     = 0x01,
    NSKeyValueObservingOptionOld     = 0x02,
    NSKeyValueObservingOptionInitial = 0x04,
    NSKeyValueObservingOptionPrior   = 0x08
};

typedef NS_OPTIONS(NSUInteger, NSKeyValueChange) {
    NSKeyValueChangeSetting     = 1,
    NSKeyValueChangeInsertion   = 2,
    NSKeyValueChangeRemoval     = 3,
    NSKeyValueChangeReplacement = 4
};

typedef NS_OPTIONS(NSUInteger, NSKeyValueSetMutationKind) {
    NSKeyValueUnionSetMutation     = 1,
    NSKeyValueMinusSetMutation     = 2,
    NSKeyValueIntersectSetMutation = 3,
    NSKeyValueSetSetMutation       = 4
};

FOUNDATION_EXPORT NSString *const NSKeyValueChangeKindKey;
FOUNDATION_EXPORT NSString *const NSKeyValueChangeNewKey;
FOUNDATION_EXPORT NSString *const NSKeyValueChangeOldKey;
FOUNDATION_EXPORT NSString *const NSKeyValueChangeIndexesKey;
FOUNDATION_EXPORT NSString *const NSKeyValueChangeNotificationIsPriorKey;

@interface NSObject (NSKeyValueObserving)

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;

@end

@interface NSObject (NSKeyValueObserverRegistration)

- (void)addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context;
- (void)removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(void *)context;
- (void)removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath;

@end

@interface NSArray (NSKeyValueObserverRegistration)

- (void)addObserver:(NSObject *)observer toObjectsAtIndexes:(NSIndexSet *)indexes forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context;
- (void)removeObserver:(NSObject *)observer fromObjectsAtIndexes:(NSIndexSet *)indexes forKeyPath:(NSString *)keyPath context:(void *)context;
- (void)removeObserver:(NSObject *)observer fromObjectsAtIndexes:(NSIndexSet *)indexes forKeyPath:(NSString *)keyPath;
- (void)addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context;
- (void)removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(void *)context;
- (void)removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath;

@end

@interface NSOrderedSet(NSKeyValueObserverRegistration)

- (void)addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context;
- (void)removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(void *)context;
- (void)removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath;

@end

@interface NSSet (NSKeyValueObserverRegistration)

- (void)addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context;
- (void)removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(void *)context;
- (void)removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath;

@end

@interface NSObject (NSKeyValueObserverNotification)

- (void)willChangeValueForKey:(NSString *)key;
- (void)didChangeValueForKey:(NSString *)key;
- (void)willChange:(NSKeyValueChange)changeKind valuesAtIndexes:(NSIndexSet *)indexes forKey:(NSString *)key;
- (void)didChange:(NSKeyValueChange)changeKind valuesAtIndexes:(NSIndexSet *)indexes forKey:(NSString *)key;
- (void)willChangeValueForKey:(NSString *)key withSetMutation:(NSKeyValueSetMutationKind)mutationKind usingObjects:(NSSet *)objects;
- (void)didChangeValueForKey:(NSString *)key withSetMutation:(NSKeyValueSetMutationKind)mutationKind usingObjects:(NSSet *)objects;

@end

@interface NSObject (NSKeyValueObservingCustomization)

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key;
+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key;
- (void)setObservationInfo:(void *)observationInfo;
- (void *)observationInfo NS_RETURNS_INNER_POINTER;

@end
