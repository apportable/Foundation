#import <Foundation/NSObject.h>
#import <Foundation/NSDictionary.h>

@class NSKeyValueContainerClass;
@class NSKeyValueSetter;
@class NSKeyValueObservance;
@class NSKeyValueProperty;
@class NSKeyValueObservationInfo;

#import <CoreFoundation/CFDictionary.h>
#import <CoreFoundation/CFSet.h>
#import <CoreFoundation/CFArray.h>
#import "NSKeyValueChangeDictionary.h" // for NSKeyValueChangeDetails

enum {
    NSKeyValueObservingOptionNestedChain = 0x100
};

typedef struct {
    id _field1;
    NSMutableDictionary *recursedMutableDictionary;
} NSKeyValueForwardingValues;

typedef struct {
    NSKeyValueChange _changeKind;
    NSIndexSet *_indexes;
} NSKeyValueChangeByOrderedToManyMutation;

typedef struct {
    NSKeyValueSetMutationKind _mutationKind;
    NSSet *_objects;
} NSKeyValueChangeBySetMutation;

typedef struct {
    Class _originalClass;
    Class _notifyingClass;
    CFMutableSetRef _field3;
    CFMutableDictionaryRef _cachedKeys;
} NSKVONotifyingInfo;

typedef struct {
    Class alwaysNilFakeIsa;
    NSKeyValueContainerClass *containerClass;
    NSString *keyPath;
} NSKVOFakeProperty;

typedef struct {
    NSObject *originalObservable;
    NSKeyValueObservance *observance;
} NSKeyValueImplicitObservanceAdditionInfo;

typedef struct {
    NSObject *nextObject;
    NSKeyValueObservance *observingObservance;
    NSString *keyPath;
    NSObject *originalObservable;
    NSKeyValueProperty *property;
    BOOL isRecursing; //?
} NSKeyValueImplicitObservanceRemovalInfo;

typedef struct {
    CFMutableArrayRef pendingNotifications;
    BOOL nextIsObservationInfo;
    union {
        NSKeyValueImplicitObservanceAdditionInfo implicitObservanceAdditionInfo;
        NSKeyValueObservationInfo *observationInfo;
    } implicitObservanceAdditionInfoOrObservationInfo;
    NSKeyValueImplicitObservanceRemovalInfo implicitObservanceRemovalInfo;
    NSInteger recursionLevel;
} NSKeyValueObservingTSD;

typedef struct {
    short retainCount;
    BOOL reserved;
    NSObject *originalObservable;
    NSObject *observer;
    id keyOrKeys;
    NSKeyValueObservationInfo *observationInfo;
    NSKeyValueObservance *observance;
    NSKeyValueChangeDetails changeDetails;
    NSKeyValueForwardingValues forwardingValues;
    NSInteger recursionLevel;
} NSKVOPendingNotificationInfo;

typedef struct {
    CFMutableArrayRef pendingNotifications;
    NSInteger pendingNotificationCount;
    NSKVOPendingNotificationInfo *relevantNotification;
    NSInteger relevantNotificationIndex;
    NSKeyValueObservance *observance;
    NSInteger recursionLevel;
} NSKVOPopNotificationResult;


typedef void (*NSKeyValueWillChangeApplyFunction)(NSKeyValueChangeDetails *, id, NSString *, BOOL, NSKeyValueObservingOptions, void *, NSKeyValueForwardingValues, BOOL *);
typedef void (*NSKeyValuePushPendingFunction)(NSObject *, id, NSKeyValueObservance *, NSKeyValueForwardingValues, NSKeyValueObservingTSD *, NSKeyValueChangeDetails);
typedef void (*NSKeyValueDidChangeApplyFunction)(NSKeyValueChangeDetails *, NSObject *, NSString *, BOOL, NSKeyValueObservingOptions, NSKeyValueChangeDetails);
typedef BOOL (*NSKeyValuePopPendingFunction)(NSObject *, NSString *, NSKeyValueObservance **, NSKeyValueChangeDetails *, NSKeyValueForwardingValues *, id *, NSKVOPopNotificationResult *);

BOOL _NSKVONotifyingMutatorsShouldNotifyForIsaAndKey(Class isa, NSString *key);
NSKVONotifyingInfo *_NSKeyValueContainerClassGetNotifyingInfo(NSKeyValueContainerClass *kvcon);
void _NSKVONotifyingEnableForInfoAndKey(NSKVONotifyingInfo *notifyingInfo, NSString *key);
Class _NSKVONotifyingOriginalClassForIsa(Class isa);
Class _NSKVONotifyingNotifyingClassForIsa(Class isa);
NSKeyValueProperty *_NSKeyValuePropertyForIsaAndKeyPathInner(Class isa, NSString *keyPath, CFMutableSetRef toBeFilled);
void _NSKeyValueWillChangeForObservance(NSObject *originalObservable, id dependentValueKeyOrKeys, BOOL dependentValueKeyOrKeysIsASet, NSObject *observer);
void _NSKeyValueDidChangeForObservance(NSObject *originalObservable, id dependentValueKeyOrKeys, BOOL dependentValueKeyOrKeysIsASet, NSObject *observer);
void _NSKeyValueDidChangeBySetting(NSKeyValueChangeDetails *outDetails, NSObject *observable, NSString *keyPath, BOOL hasDependentKeys, NSKeyValueObservingOptions options, NSKeyValueChangeDetails inDetails);
void _NSKeyValueDidChangeByOrderedToManyMutation(NSKeyValueChangeDetails *outDetails, NSObject *observable, NSString *keyPath, BOOL hasDependentKeys, NSKeyValueObservingOptions options, NSKeyValueChangeDetails inDetails);
void _NSKeyValueDidChangeBySetMutation(NSKeyValueChangeDetails *outDetails, NSObject *observable, NSString *keyPath, BOOL hasDependentKeys, NSKeyValueObservingOptions options, NSKeyValueChangeDetails inDetails);
void _NSKeyValueWillChangeBySetting(NSKeyValueChangeDetails *changeDetails, id self, NSString *relevantKeyPath, BOOL wasExactMatch, NSKeyValueObservingOptions options, void *reserved, NSKeyValueForwardingValues forwardingValues, BOOL *reatinedDetails);
void _NSKeyValueWillChangeByOrderedToManyMutation(NSKeyValueChangeDetails *changeDetails, id self, NSString *keyPath, BOOL wasExactMatch, NSKeyValueObservingOptions options, void *reserved, NSKeyValueForwardingValues forwardingValues, BOOL *reatinedDetails);
void _NSKeyValueWillChangeBySetMutation(NSKeyValueChangeDetails *changeDetails, id self, NSString *keyPath, BOOL wasExactMatch, NSKeyValueObservingOptions options, void *reserved, NSKeyValueForwardingValues forwardingValues, BOOL *reatinedDetails);
void _NSKeyValueWillChange(id self, id keyOrKeys, BOOL keyOrKeysIsASet, NSKeyValueObservationInfo *observationInfo, NSKeyValueWillChangeApplyFunction apply, void *reserved2, NSObject *observer, NSKeyValueObservingTSD *kvoTSD, NSKeyValuePushPendingFunction pushFn);
void _NSKeyValueDidChange(NSObject *observable, id keyOrKeys, BOOL keyOrKeysIsASet, NSKeyValueDidChangeApplyFunction apply, NSKeyValuePopPendingFunction popFn, NSKVOPopNotificationResult *result);
void _NSKeyValuePushPendingNotificationsPerThread(NSObject *originalObservable, id keyOrKeys, NSKeyValueObservance *observance, NSKeyValueForwardingValues forwardingValues, NSKeyValueObservingTSD *kvoTSD, NSKeyValueChangeDetails changeDetails);
BOOL _NSKeyValuePopPendingNotificationPerThread(NSObject *observable, NSString *key, NSKeyValueObservance **outObservance, NSKeyValueChangeDetails *outChangeDetails, NSKeyValueForwardingValues *outForwardingValues, id *outKeyOrKeys, NSKVOPopNotificationResult *result);
NSKeyValueImplicitObservanceAdditionInfo *_NSKeyValueGetImplicitObservanceAdditionInfo(void);
NSKeyValueImplicitObservanceRemovalInfo *_NSKeyValueGetImplicitObservanceRemovalInfo(void);
