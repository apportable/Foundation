//
//  NSKeyValueObserving.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/NSKeyValueObserving.h>
#import <Foundation/NSRange.h>
#import <objc/runtime.h>
#import <objc/message.h>
#import <alloca.h>
#import <CoreFoundation/CFSet.h>
#import <CoreFoundation/CFArray.h>
#import <CoreFoundation/CFDictionary.h>
#import "NSKeyValueAccessor.h"
#import "NSKeyValueComputedProperty.h"
#import "NSKeyValueNestedProperty.h"
#import "NSKeyValueUnnestedProperty.h"
#import "NSKeyValueContainerClass.h"
#import "NSKeyValueCodingInternal.h"
#import "NSKeyValueObservingInternal.h"
#import "NSKeyValueObservance.h"
#import "NSKeyValueObservationInfo.h"
#import "NSKeyValueChangeDictionary.h"
#import <Foundation/NSInvocation.h>
#import "NSInvocationInternal.h"
#import <Foundation/NSNull.h>
#import <Foundation/NSString.h>
#import "NSExternals.h"
#import <pthread.h>
#import <dispatch/dispatch.h>
#import <libkern/OSAtomic.h>
#import <Foundation/NSException.h>
#import <Foundation/NSLock.h>
#import <Foundation/NSIndexSet.h>

static void NSKVOForwardInvocation(id self, SEL _cmd, NSInvocation *invocation);
static void NSKVONotifyingSetMethodImplementation(NSKVONotifyingInfo *notifyingInfo, SEL selector, IMP newImplementation, NSString *optionalKey);
static void NSKeyValueObservingTSDDestroy(void *mem);
id __NSKeyValueRetainedObservationInfoForObject(NSObject *object, NSKeyValueContainerClass *containerClass);
NSKVONotifyingInfo *_NSKVONotifyingCreateInfoWithOriginalClass(Class cls);

static OSSpinLock _NSKVONotifyingInfoPropertyKeysSpinLock = OS_SPINLOCK_INIT;
static OSSpinLock _NSKeyValueObservationInfoSpinLock = OS_SPINLOCK_INIT;
static OSSpinLock _NSKeyValueObservationInfoCreationSpinLock = OS_SPINLOCK_INIT;
static NSRecursiveLock *__NSKeyValueObserverRegisterationLock = nil;
static dispatch_once_t __NSKeyValueObserverRegistrationLockCreationToken;

static const char *kOriginalImplementationMethodNamePrefix = "_original_";

static pthread_key_t _NSKVOPthreadKey;

static void _NSKVOMakePthreadKey()
{
    pthread_key_create(&_NSKVOPthreadKey, NSKeyValueObservingTSDDestroy);
}

static pthread_key_t _NSGetKVOPthreadKey()
{
    static pthread_once_t key_once = PTHREAD_ONCE_INIT;
    pthread_once(&key_once, _NSKVOMakePthreadKey);
    return _NSKVOPthreadKey;
}

static inline NSKeyValueObservingTSD *NSGetOrCreateThreadSpecificKVOStruct()
{
    pthread_key_t pthreadKVOKey = _NSGetKVOPthreadKey();
    NSKeyValueObservingTSD *threadSpecificKVOStruct = pthread_getspecific(pthreadKVOKey);
    if (threadSpecificKVOStruct == NULL)
    {
        threadSpecificKVOStruct = calloc(1, sizeof(NSKeyValueObservingTSD));
        pthread_setspecific(pthreadKVOKey, threadSpecificKVOStruct);
    }
    return threadSpecificKVOStruct;
}

static CFArrayCallBacks _NSKVOPendingNotificationArrayCallbacks;

@implementation NSObject (NSKeyValueObserverNotification)

- (void)willChangeValueForKey:(NSString *)key
{
    id observationInfo = __NSKeyValueRetainedObservationInfoForObject(self, nil);
    BOOL infoExists = (observationInfo != nil);
    if (infoExists)
    {
        NSKeyValueObservingTSD *threadSpecificKVOStruct = NSGetOrCreateThreadSpecificKVOStruct();
        ++threadSpecificKVOStruct->recursionLevel;
        if (threadSpecificKVOStruct->pendingNotifications == NULL)
        {
            threadSpecificKVOStruct->pendingNotifications = CFArrayCreateMutable(NULL, 0, &_NSKVOPendingNotificationArrayCallbacks);
        }
        NSKeyValueObservingTSD tsdCopy = *threadSpecificKVOStruct;
        tsdCopy.nextIsObservationInfo = YES;
        tsdCopy.implicitObservanceAdditionInfoOrObservationInfo.observationInfo = observationInfo;
        _NSKeyValueWillChange(self, key, NO, observationInfo, &_NSKeyValueWillChangeBySetting, nil, nil, &tsdCopy, &_NSKeyValuePushPendingNotificationsPerThread);
        [observationInfo release];
        --threadSpecificKVOStruct->recursionLevel;
   }
}

- (void)didChangeValueForKey:(NSString *)key
{
    pthread_key_t pthreadKVOKey = _NSGetKVOPthreadKey();
    NSKeyValueObservingTSD *kvoTSD = pthread_getspecific(pthreadKVOKey);
    if (kvoTSD != NULL && kvoTSD->pendingNotifications != NULL)
    {
        ++kvoTSD->recursionLevel;
        NSInteger pendingCount = CFArrayGetCount(kvoTSD->pendingNotifications);
        if (pendingCount > 0)
        {
            NSKVOPopNotificationResult result = { 
                .pendingNotifications = kvoTSD->pendingNotifications,
                .pendingNotificationCount = pendingCount,
                .relevantNotification = NULL,
                .relevantNotificationIndex = -1,
                .observance = nil,
                .recursionLevel = kvoTSD->recursionLevel
            };
            _NSKeyValueDidChange(self, key, 0, &_NSKeyValueDidChangeBySetting, &_NSKeyValuePopPendingNotificationPerThread, &result);
        }
        --kvoTSD->recursionLevel;
    }
}

- (void)willChange:(NSKeyValueChange)changeKind valuesAtIndexes:(NSIndexSet *)indexes forKey:(NSString *)key
{
    NSKeyValueObservationInfo *observationInfo = __NSKeyValueRetainedObservationInfoForObject(self, nil);
    if (observationInfo)
    {
        NSKeyValueObservingTSD *threadSpecificKVOStruct = NSGetOrCreateThreadSpecificKVOStruct();
        ++threadSpecificKVOStruct->recursionLevel;
        if (threadSpecificKVOStruct->pendingNotifications == NULL)
        {
            threadSpecificKVOStruct->pendingNotifications = CFArrayCreateMutable(NULL, 0, &_NSKVOPendingNotificationArrayCallbacks);
        }
        
        NSKeyValueChangeByOrderedToManyMutation change = {
            ._changeKind = changeKind,
            ._indexes = indexes
        };
        
        NSKeyValueObservingTSD tsdCopy = *threadSpecificKVOStruct;
        tsdCopy.nextIsObservationInfo = YES;
        tsdCopy.implicitObservanceAdditionInfoOrObservationInfo.observationInfo = observationInfo;
        _NSKeyValueWillChange(self, key, NO, observationInfo, &_NSKeyValueWillChangeByOrderedToManyMutation, &change, nil, &tsdCopy, &_NSKeyValuePushPendingNotificationsPerThread);
        [observationInfo release];
        --threadSpecificKVOStruct->recursionLevel;
    }
}

- (void)didChange:(NSKeyValueChange)changeKind valuesAtIndexes:(NSIndexSet *)indexes forKey:(NSString *)key
{
    pthread_key_t pthreadKVOKey = _NSGetKVOPthreadKey();
    NSKeyValueObservingTSD *kvoTSD = pthread_getspecific(pthreadKVOKey);
    if (kvoTSD != NULL && kvoTSD->pendingNotifications != NULL)
    {
        ++kvoTSD->recursionLevel;
        NSInteger pendingCount = CFArrayGetCount(kvoTSD->pendingNotifications);
        if (pendingCount > 0)
        {
            NSKVOPopNotificationResult result = {
                .pendingNotifications = kvoTSD->pendingNotifications,
                .pendingNotificationCount = pendingCount,
                .relevantNotification = NULL,
                .relevantNotificationIndex = -1,
                .observance = nil,
                .recursionLevel = kvoTSD->recursionLevel
            };
            _NSKeyValueDidChange(self, key, 0, &_NSKeyValueDidChangeByOrderedToManyMutation, &_NSKeyValuePopPendingNotificationPerThread, &result);
        }
        --kvoTSD->recursionLevel;
    }
}

- (void)willChangeValueForKey:(NSString *)key withSetMutation:(NSKeyValueSetMutationKind)mutationKind usingObjects:(NSSet *)objects
{
    NSKeyValueObservationInfo *observationInfo = __NSKeyValueRetainedObservationInfoForObject(self, nil);
    if (observationInfo)
    {
        NSKeyValueObservingTSD *threadSpecificKVOStruct = NSGetOrCreateThreadSpecificKVOStruct();
        ++threadSpecificKVOStruct->recursionLevel;
        if (threadSpecificKVOStruct->pendingNotifications == NULL)
        {
            threadSpecificKVOStruct->pendingNotifications = CFArrayCreateMutable(NULL, 0, &_NSKVOPendingNotificationArrayCallbacks);
        }
        
        NSKeyValueChangeBySetMutation change = {
            ._mutationKind = mutationKind,
            ._objects = objects
        };
        
        NSKeyValueObservingTSD tsdCopy = *threadSpecificKVOStruct;
        tsdCopy.nextIsObservationInfo = YES;
        tsdCopy.implicitObservanceAdditionInfoOrObservationInfo.observationInfo = observationInfo;
        _NSKeyValueWillChange(self, key, NO, observationInfo, &_NSKeyValueWillChangeBySetMutation, &change, nil, &tsdCopy, &_NSKeyValuePushPendingNotificationsPerThread);
        [observationInfo release];
        --threadSpecificKVOStruct->recursionLevel;
    }
}

- (void)didChangeValueForKey:(NSString *)key withSetMutation:(NSKeyValueSetMutationKind)mutationKind usingObjects:(NSSet *)objects
{
    pthread_key_t pthreadKVOKey = _NSGetKVOPthreadKey();
    NSKeyValueObservingTSD *kvoTSD = pthread_getspecific(pthreadKVOKey);
    if (kvoTSD != NULL && kvoTSD->pendingNotifications != NULL)
    {
        ++kvoTSD->recursionLevel;
        NSInteger pendingCount = CFArrayGetCount(kvoTSD->pendingNotifications);
        if (pendingCount > 0)
        {
            NSKVOPopNotificationResult result = {
                .pendingNotifications = kvoTSD->pendingNotifications,
                .pendingNotificationCount = pendingCount,
                .relevantNotification = NULL,
                .relevantNotificationIndex = -1,
                .observance = nil,
                .recursionLevel = kvoTSD->recursionLevel
            };
            _NSKeyValueDidChange(self, key, 0, &_NSKeyValueDidChangeBySetMutation, &_NSKeyValuePopPendingNotificationPerThread, &result);
        }
        --kvoTSD->recursionLevel;
    }
}

- (BOOL)_isKVOA
{
    return NO;
}

@end

static Boolean _NSKeyValuePropertyIsEqual(const void *value1, const void *value2)
{
    NSKeyValueContainerClass *kvcon1 = nil;
    NSKeyValueContainerClass *kvcon2 = nil;
    NSString *keyPath1 = nil;
    NSString *keyPath2 = nil;
    if (value1 && ((NSKVOFakeProperty *)value1)->alwaysNilFakeIsa == Nil)
    {
        NSKVOFakeProperty *fake = (NSKVOFakeProperty *)value1;
        kvcon1 = fake->containerClass;
        keyPath1 = fake->keyPath;
    }
    else
    {
        NSKeyValueProperty *property = (NSKeyValueProperty *)value1;
        kvcon1 = property.containerClass;
        keyPath1 = property.keyPath;
    }
    if (value2 && ((NSKVOFakeProperty *)value2)->alwaysNilFakeIsa == Nil)
    {
        NSKVOFakeProperty *fake = (NSKVOFakeProperty *)value2;
        kvcon2 = fake->containerClass;
        keyPath2 = fake->keyPath;
    }
    else
    {
        NSKeyValueProperty *property = (NSKeyValueProperty *)value2;
        kvcon2 = property.containerClass;
        keyPath2 = property.keyPath;
    }
    if (kvcon1 == kvcon2)
    {
        if (keyPath1 && keyPath2) // isEqualToString: doesn't like a nil argument
        {
            return [keyPath1 isEqualToString:keyPath2];
        }
    }
    return NO;
}
static CFHashCode _NSKeyValuePropertyHash(const void *value)
{
    if (value != NULL && ((NSKVOFakeProperty *)value)->alwaysNilFakeIsa == Nil) //may our children forgive us
    {
        NSKVOFakeProperty *fakeProp = (NSKVOFakeProperty *)value;
        NSUInteger hash = [fakeProp->keyPath hash];
        hash ^= (NSUInteger)fakeProp->containerClass;
        return hash;
    }
    NSKeyValueProperty *self = (NSKeyValueProperty *)value;
    return [[self keyPath] hash] ^ (NSUInteger)(self.containerClass);
}

@implementation NSObject (NSKeyValueObserverRegistration)

//This will be the _isKVOA method
static BOOL _NSKVOIsAutonotifying(id self, SEL _cmd)
{
    return YES;
}

static Class _NSKVOClass(id self, SEL _cmd)
{
    Class realClass = object_getClass(self);
    Class ret = _NSKVONotifyingOriginalClassForIsa(realClass);
    if (ret != realClass)
    {
        return ret;
    }
    else
    {
        Method originalClassMethod = class_getInstanceMethod(ret, @selector(class));
        return method_invoke(self, originalClassMethod);
    }
}

Class _NSKVONotifyingOriginalClassForIsa(Class isa)
{
    Class ret = isa;
    if (class_getMethodImplementation(isa, @selector(_isKVOA)) == (IMP)&_NSKVOIsAutonotifying)
    {
        NSKVONotifyingInfo *notifyingInfo = object_getIndexedIvars(isa);
        ret = notifyingInfo->_originalClass;
    }
    return ret;
}

Class _NSKVONotifyingNotifyingClassForIsa(Class isa)
{
    Class ret = isa;
    if (class_getMethodImplementation(isa, @selector(_isKVOA)) == (IMP)&_NSKVOIsAutonotifying)
    {
        NSKVONotifyingInfo *notifyingInfo = object_getIndexedIvars(isa);
        ret = notifyingInfo->_notifyingClass;
    }
    return ret;
}

static NSKeyValueContainerClass *__NSKeyValueContainerClassForIsa(Class isa)
{
    static Class isaCacheKey = NULL;
    static NSKeyValueContainerClass *cachedContainerClass = NULL; //a 1-item cache. 
    if (isa == isaCacheKey)
    {
        return cachedContainerClass;
    }
    Class originalClass = _NSKVONotifyingOriginalClassForIsa(isa);
    NSKeyValueContainerClass *kvcon = nil;
    static CFMutableDictionaryRef NSKeyValueContainerClassPerOriginalClass = NULL;
    if (NSKeyValueContainerClassPerOriginalClass == NULL)
    {
        NSKeyValueContainerClassPerOriginalClass = CFDictionaryCreateMutable(NULL, 0, NULL, &kCFTypeDictionaryValueCallBacks);
    }
    kvcon = CFDictionaryGetValue(NSKeyValueContainerClassPerOriginalClass, originalClass);
    if (kvcon == nil)
    {
        kvcon = [[NSKeyValueContainerClass alloc] initWithOriginalClass:originalClass];
        CFDictionarySetValue(NSKeyValueContainerClassPerOriginalClass, originalClass, kvcon);
        [kvcon release];
    }
    kvcon = CFDictionaryGetValue(NSKeyValueContainerClassPerOriginalClass, originalClass);
    isaCacheKey = originalClass;
    cachedContainerClass = kvcon;
    return kvcon;

}
static CFMutableSetRef _NSKeyValueProperties = NULL;

NSKeyValueProperty *_NSKeyValuePropertyForIsaAndKeyPathInner(Class isa, NSString *keyPath, CFMutableSetRef toBeFilled)
{
    NSKeyValueContainerClass *kvcon = __NSKeyValueContainerClassForIsa(isa);
    NSKVOFakeProperty fake = {0};
    fake.containerClass = kvcon;
    fake.keyPath = keyPath;
    id real = CFSetGetValue(toBeFilled, &fake);
    if (real != nil)
    {
        return real;
    }
    if (_NSKeyValueProperties != NULL)
    {
        real = CFSetGetValue(_NSKeyValueProperties, &fake);
        if (real != nil)
        {
            return real;
        }
    }
    NSKeyValueProperty *property = nil;
    if ([keyPath characterAtIndex:0] == '@')
    {
        property = [[NSKeyValueComputedProperty alloc] _initWithContainerClass:kvcon keyPath:keyPath propertiesBeingInitialized:toBeFilled];
    }
    else
    {
        NSRange range = [keyPath rangeOfString:@"."];
        if (range.length == 0)
        {
            property = [[NSKeyValueUnnestedProperty alloc] _initWithContainerClass:kvcon keyPath:keyPath propertiesBeingInitialized:toBeFilled];
        }
        else
        {
            property = [[NSKeyValueNestedProperty alloc] _initWithContainerClass:kvcon keyPath:keyPath firstDotIndex:range.location propertiesBeingInitialized:toBeFilled];
        }
    }
    if (_NSKeyValueProperties == NULL)
    {
        CFSetCallBacks callbacks = kCFTypeSetCallBacks;
        callbacks.equal = &_NSKeyValuePropertyIsEqual;
        callbacks.hash = &_NSKeyValuePropertyHash;
        _NSKeyValueProperties = CFSetCreateMutable(NULL, 0, &callbacks);
    }
    CFSetAddValue(_NSKeyValueProperties, property);
    CFSetRemoveValue(toBeFilled, property);
    [property release];
    return property;
}

static NSKeyValueProperty *_NSKeyValuePropertyForIsaAndKeyPath(Class isa, NSString *keyPath)
{
    NSKeyValueContainerClass *kvcon = __NSKeyValueContainerClassForIsa(isa);
    NSKVOFakeProperty fake = {0};
    fake.containerClass = kvcon;
    fake.keyPath = keyPath;
    CFMutableSetRef toBeFilled = NULL;
    if (_NSKeyValueProperties != NULL)
    {
        id real = CFSetGetValue(_NSKeyValueProperties, &fake);
        if (real != nil)
        {
            return real;
        }
    }
    CFSetCallBacks callbacks = kCFTypeSetCallBacks;
    callbacks.equal = (CFSetEqualCallBack)&_NSKeyValuePropertyIsEqual;
    callbacks.hash = (CFSetHashCallBack)&_NSKeyValuePropertyHash;

    toBeFilled = CFSetCreateMutable(NULL, 0, &callbacks);
    NSKeyValueProperty *property = _NSKeyValuePropertyForIsaAndKeyPathInner(isa, keyPath, toBeFilled);
    CFRelease(toBeFilled);
    return property;
}

/*Boolean _NSKeyValueShareableObservationInfoCFSIsEqual(const void *value1, const void *value2)
{
    if (value1 == value2)
    {
        return TRUE;
    }
    Class firstClass = object_getClass((id)value1); 
    if (firstClass == _NSKeyValueShareableObservationInfoKeyIsa || object_getClass((id)value2) == _NSKeyValueShareableObservationInfoKeyIsa)
    {
        if (firstClass == _NSKeyValueShareableObservationInfoKeyIsa)
        {

        }
    }
}*/

/*NSKeyValueObservationInfo *_NSKeyValueObservationInfoCreateByAdding(NSKeyValueObservationInfo *existing, NSKeyValueObservance *observanceToAdd)
{
    OSSpinLockLock(&_NSKeyValueObservationInfoSpinLock);
    if (_NSKeyValueShareableObservationInfos == nil)
    {
        CFSetCallBacks callbacks = kCFTypeSetCallBacks;
        callbacks.retain = NULL;
        callbacks.release = NULL;
        callbacks.copyDescription = NULL;
        callbacks.equal = &_NSKeyValueShareableObservationInfoCFSIsEqual;
        callbacks.hash = &_NSKeyValueShareableObservationInfoCFSHash;
        _NSKeyValueShareableObservationInfos = CFSetCreateMutable(NULL, 0, callbacks);
    }
    OSSpinLockUnlock(&_NSKeyValueObservationInfoSpinLock);
}*/



id __NSKeyValueRetainedObservationInfoForObject(NSObject *object, NSKeyValueContainerClass *containerClass)
{
    id observationInfo = nil;
    OSSpinLockLock(&_NSKeyValueObservationInfoSpinLock);
    if (containerClass != nil)
    {
        IMP cachedIMP = containerClass.cachedObservationInfoImplementation;
        observationInfo = cachedIMP(object, @selector(observationInfo));
    }
    else
    {
        observationInfo = [object observationInfo];
    }
    if (observationInfo != nil)
    {
        [observationInfo retain];
    }
    OSSpinLockUnlock(&_NSKeyValueObservationInfoSpinLock);
    return observationInfo;
}
- (void)addObserver:(NSObject *)observer forProperty:(NSKeyValueProperty *)property options:(NSKeyValueObservingOptions)options context:(void *)context
{
    NSString *keyPath = property.keyPath;
    if (options & NSKeyValueObservingOptionInitial)
    {
        id newValue = nil;
        if (options & NSKeyValueObservingOptionNew)
        {
            newValue = [self valueForKeyPath:keyPath];
        }
        if (newValue == nil)
        {
            newValue = [NSNull null];
        }
        [__NSKeyValueObserverRegisterationLock unlock];
        NSKeyValueChangeDetails changeDetails = {0};
        changeDetails.kind = NSKeyValueChangeSetting;
        changeDetails.newValue = newValue;
        _NSKeyValueNotifyObserver(observer, self, nil, keyPath, changeDetails, context, NO);
        [__NSKeyValueObserverRegisterationLock lock];
    }
    OSSpinLockLock(&_NSKeyValueObservationInfoCreationSpinLock);
    NSKeyValueObservationInfo *observationInfo = __NSKeyValueRetainedObservationInfoForObject(self, property.containerClass); 
    if (observationInfo == nil)
    {
        observationInfo = [[NSKeyValueObservationInfo alloc] init];
    }
    id targetObject = nil;
    if (options & NSKeyValueObservingOptionNestedChain) 
    {
        NSKeyValueImplicitObservanceAdditionInfo *additionInfoPtr = _NSKeyValueGetImplicitObservanceAdditionInfo();
        if (additionInfoPtr != NULL)
        {
            targetObject = additionInfoPtr->originalObservable;
        }
    }
    NSKeyValueObservance *newObservance = [[NSKeyValueObservance alloc] initWithObserver:observer forProperty:property ofObject:targetObject context:context options:options];
    //TODO: double check we never need to pass self here as the targetObject
    [newObservance setKeyPath:keyPath];
    // TODO: cache/share these to improve performance.
    OSSpinLockLock(&_NSKeyValueObservationInfoSpinLock);
    [observationInfo addObservance:newObservance];
    [self setObservationInfo:observationInfo];
    OSSpinLockUnlock(&_NSKeyValueObservationInfoSpinLock);
    OSSpinLockUnlock(&_NSKeyValueObservationInfoCreationSpinLock);
    [property object:self didAddObservance:newObservance recurse:YES];
    Class autonotifyingClass = [property isaForAutonotifying];
    if (autonotifyingClass != Nil && object_getClass(self) != autonotifyingClass)
    {
        object_setClass(self, autonotifyingClass);
    }
    [observationInfo release];
}

static void _NSKeyValueNotifyObserver(NSObject *observer, NSObject *observable, NSObject *originalObservable, NSString *keyPath, NSKeyValueChangeDetails detailsForDictionary, void *context, BOOL isPriorNotification)
{
    NSKeyValueChangeDictionary *kvChangeDict = [[NSKeyValueChangeDictionary alloc] initWithDetailsNoCopy:detailsForDictionary originalObservable:originalObservable isPriorNotification:isPriorNotification];
    [kvChangeDict retainObjects];
    [observer observeValueForKeyPath:keyPath ofObject:observable change:kvChangeDict context:context];
    [kvChangeDict release];

}

- (void)addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context
{
    dispatch_once(&__NSKeyValueObserverRegistrationLockCreationToken, 
    ^{
        __NSKeyValueObserverRegisterationLock = [[NSRecursiveLock alloc] init];
    });
    [__NSKeyValueObserverRegisterationLock lock];
    Class receiverRealClass = object_getClass(self);
    NSKeyValueProperty *kvProperty = _NSKeyValuePropertyForIsaAndKeyPath(receiverRealClass, keyPath);
    [self addObserver:observer forProperty:kvProperty options:options context:context];
    [__NSKeyValueObserverRegisterationLock unlock];


}

static void NSKeyValueRaiseUnregistered(NSObject *receiver, NSObject *observer, NSString *keyPath, void *context)
{
    [[NSException exceptionWithName:NSRangeException 
                             reason:[NSString stringWithFormat:@"Cannot remove an observer %@ for the key path %@ from %@ because it is not registered as an observer in %@context %p.", 
                                                               observer, 
                                                               keyPath, 
                                                               receiver, 
                                                               (context == @"any ") ? context : @"", 
                                                               context] 
                            userInfo:nil] raise];
}

//Another option would be to
//push the enumeration of the observances down a couple of levels for the purposes of better reuse of observationInfos and
//observances, at the expense of using a TSD to store the context (I can't tell at the moment how that method works at all in some cases*). 
//To reduce complexity while not sacrificing too much speed, I am getting the observance early, and then passing it here, optionally. 
//the behavior should be unchanged from -removeObserver:forProprerty: if you pass nil for the optionalObservance.
//a previous version of the implementations of -removeObserver:forKeyPath: and -removeObserver:forKeyPath:context: did the same work
//without a -_removeObserver:forProperty:, and while it was tempting to leave that as is, this way we can call the property's -object:didRemoveObservance:
//which may be necessary for the nested and computed properties, or differently for index-affecting observations.
//If this proves to not be the case, consider pushing the everything back into those two methods and removing 
//-_removeObserver:forProperty:optionalObservance: entirely. 

// *the hack uses the same CFGetTSD key as the thread-local storage used for storing the observance-value dictionary in -willChangeValueForKey:.
// so it APPEARS that if there has been a -willChangeValueForKey: without a corresponding -didChangeValueForKey: (and that assumes that the implementation of
// -didChangeValueForKey: releases the dictionary and frees and nulls the TSD -- not sure whether that actually happens in any implementation) then
// calling -removeObserver:forKeyPath:context: should remove an arbitrary observance (FIFO) rather than the one with the correct context.
// Additional tests will be needed to confirm this behavior. If this IS the case, we should file a radar, and (ugh) attempt to duplicate the bug. 
- (void)_removeObserver:(NSObject *)observer forProperty:(NSKeyValueProperty *)property optionalObservance:(NSKeyValueObservance *)observance
{
    NSKeyValueContainerClass *containerClass = property.containerClass;
    NSKeyValueObservationInfo *observationInfo = __NSKeyValueRetainedObservationInfoForObject(self, containerClass);
    if (observationInfo == nil)
    {
        NSKeyValueRaiseUnregistered(self, observer, property.keyPath, @"any");
    }
    if (observance == nil)
    {
        for (NSKeyValueObservance *ob in observationInfo.observances)
        {
            if ([ob.property isEqual:property] && [ob.observer isEqual:observer])
            {
                observance = ob;
                break; // yeah, this really looks like we should just push it back into public removeObserver methods.
                // maybe centralize the class reset to some other function. Leaving it like this until we can determine
                // extent of changes required by implementing a more efficient caching/sharing strategy.
            }
        }
    }
    [observationInfo removeObservance:observance];
    [property object:self didRemoveObservance:observance recurse:YES];
    // release to match original allocation of NSKeyValueObservance object
    [observance release];
    if ([observationInfo observances].count == 0)
    {
        if (object_getClass(self) != containerClass.originalClass)
        {
            [self setObservationInfo:nil];
            [observationInfo release];
            object_setClass(self, containerClass.originalClass);
        }
    }

}

- (void)removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(void *)context
{
    [__NSKeyValueObserverRegisterationLock lock];
    NSKeyValueProperty *property = _NSKeyValuePropertyForIsaAndKeyPath(object_getClass(self), keyPath);
    NSKeyValueObservationInfo *observationInfo = [self observationInfo];
    NSArray *observances = [observationInfo observances];
    NSKeyValueObservance *observance = nil;
    for (NSKeyValueObservance *ob in observances)
    {
        if ([ob.property isEqual:property] && [ob.observer isEqual:observer] && ob.context == context)
        {
            observance = ob;  
            break;
        }
    }
    if (observance == nil)
    {
        NSKeyValueRaiseUnregistered(self, observer, keyPath, context);
    }
    [self _removeObserver:observer forProperty:property optionalObservance:observance];
    [__NSKeyValueObserverRegisterationLock unlock];
}

- (void)removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath
{
    [__NSKeyValueObserverRegisterationLock lock];
    NSKeyValueProperty *property = _NSKeyValuePropertyForIsaAndKeyPath(object_getClass(self), keyPath);
    [self _removeObserver:observer forProperty:property optionalObservance:nil];
    [__NSKeyValueObserverRegisterationLock unlock];

}
static NSString *__NSKVOKeyForSelectorSlow(id self, SEL _cmd)
{
    NSString *key = nil;
    NSKeyValueObservationInfo *observationInfo = [self observationInfo];
    NSArray *observances = [observationInfo observances];
    for (NSKeyValueObservance *observance in observances)
    {
        if (_cmd == observance.setter.selector)
        {
            key = observance.setter.key;
        }
    }
    return key;
}

#define __NSSetAndNotify(funcNameType, valueType) static void __NSSet ##funcNameType## ValueAndNotify(id self, SEL _cmd, valueType value) \
{ \
    Class realClass = object_getClass(self); \
    NSKVONotifyingInfo *notifyingInfo = object_getIndexedIvars(realClass); \
    NSString *key = nil; \
    OSSpinLockLock(&_NSKVONotifyingInfoPropertyKeysSpinLock); \
    key = [(NSString *)CFDictionaryGetValue(notifyingInfo->_cachedKeys, _cmd) retain]; \
    OSSpinLockUnlock(&_NSKVONotifyingInfoPropertyKeysSpinLock); \
    if (key == nil) \
    { \
        key = [__NSKVOKeyForSelectorSlow(self, _cmd) retain]; \
    } \
    [self willChangeValueForKey:key]; \
    IMP originalSetter = class_getMethodImplementation(notifyingInfo->_originalClass, _cmd); \
    ((void (*)(id, SEL, valueType))originalSetter)(self, _cmd, value); \
    [self didChangeValueForKey:key]; \
    [key release]; \
}
__NSSetAndNotify(Bool, BOOL)
__NSSetAndNotify(Char, char)
__NSSetAndNotify(Double, double)
__NSSetAndNotify(Float, float)
__NSSetAndNotify(Int, int)
__NSSetAndNotify(LongLong, long long)
__NSSetAndNotify(Long, long)
__NSSetAndNotify(Object, id)
__NSSetAndNotify(Point, CGPoint)
__NSSetAndNotify(Range, NSRange)
__NSSetAndNotify(Rect, CGRect)
__NSSetAndNotify(Short, short)
__NSSetAndNotify(Size, CGSize)
__NSSetAndNotify(UnsignedChar, unsigned char)
__NSSetAndNotify(UnsignedInt, unsigned int)
__NSSetAndNotify(UnsignedLongLong, unsigned long long)
__NSSetAndNotify(UnsignedLong, unsigned long)
__NSSetAndNotify(UnsignedShort, unsigned short)


static void NSKVODeallocateBreak(id self, const char *name)
{
    NSLog(@"An instance %p of class %s was deallocated while key value observers were still registered with it. Observation Info was leaked and may even become mistakenly attached to some other object.\nSet a breakpoint on NSKVODeallocateBreak to stop here in the debugger.", self, name);
}

static void NSKVODeallocate(id self, SEL _cmd)
{
    NSKeyValueObservationInfo *observationInfo = [self observationInfo];
    NSArray *observances = [[observationInfo observances] retain];
    struct objc_super super = {self, class_getSuperclass(object_getClass(self))};
    const char *name = object_getClassName(self);
    (void)(void (*)(id, SEL))objc_msgSendSuper(&super, _cmd);
    if (observances.count > 0)
    {
        NSKVODeallocateBreak(self, name);
    }
    [observances release];
}

@end

#pragma mark Collection KVO categories

@implementation NSArray (NSKeyValueObserving) // This is ugly, having this here, but perhaps not as ugly as exposing global variables. 

- (void)addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context
{
    [NSException raise:NSInvalidArgumentException format:@"%@: %p does not support -addObserver:forKeyPath:options:context:. Key path: %@. Use -addObserver:toObjectsAtIndexes:options:context: instead.", [self class], self, keyPath];
}
- (void)removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath
{
    [NSException raise:NSInvalidArgumentException format:@"%@: %p does not support -removeObserver:forKeyPath:. Key path: %@. Use -removeObserver:fromObjectsAtIndexes:options:context: instead.", [self class], self, keyPath];
}
- (void)removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(void *)context
{
    [NSException raise:NSInvalidArgumentException format:@"%@: %p does not support -removeObserver:forKeyPath:context:. Key path: %@. Use -removeObserver:fromObjectsAtIndexes:options:context: instead.", [self class], self, keyPath];
}

- (void)addObserver:(NSObject *)observer toObjectsAtIndexes:(NSIndexSet *)indexes forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context
{
    dispatch_once(&__NSKeyValueObserverRegistrationLockCreationToken, 
    ^{
        __NSKeyValueObserverRegisterationLock = [[NSRecursiveLock alloc] init];
    });
    NSUInteger index = [indexes firstIndex];
    if (index == NSNotFound)
    {
        return; //early bail. no need to lock if we're just going to unlock immediately
    }
    [__NSKeyValueObserverRegisterationLock lock];
    while (index != NSNotFound)
    {
        NSKeyValueProperty *property = _NSKeyValuePropertyForIsaAndKeyPath(object_getClass(self[index]), keyPath);
        [self[index] addObserver:observer forProperty:property options:options context:context];
        index = [indexes indexGreaterThanIndex:index];
    }
    [__NSKeyValueObserverRegisterationLock unlock];
}

- (void)removeObserver:(NSObject *)observer fromObjectsAtIndexes:(NSIndexSet *)indexes forKeyPath:(NSString *)keyPath
{
    NSUInteger index = [indexes firstIndex];
    if (index == NSNotFound)
    {
        return;
    }
    [__NSKeyValueObserverRegisterationLock lock];
    while (index != NSNotFound)
    {
        NSKeyValueProperty *property = _NSKeyValuePropertyForIsaAndKeyPath(object_getClass(self[index]), keyPath);
        [self[index] _removeObserver:observer forProperty:property optionalObservance:nil]; 
        index = [indexes indexGreaterThanIndex:index];  // for some reason, this deregisters in the same order as it registers, instead of reverse order. 
    }
    [__NSKeyValueObserverRegisterationLock unlock];
}

- (void)removeObserver:(NSObject *)observer fromObjectsAtIndexes:(NSIndexSet *)indexes forKeyPath:(NSString *)keyPath context:(void *)context
{
    NSUInteger index = [indexes firstIndex];
    if (index == NSNotFound)
    {
        return;
    }
    [__NSKeyValueObserverRegisterationLock lock];
    while (index != NSNotFound)
    {
        [self[index] removeObserver:observer forKeyPath:keyPath context:context];
        index = [indexes indexGreaterThanIndex:index];
    }
    [__NSKeyValueObserverRegisterationLock unlock];
}

@end

@implementation NSSet (NSKeyValueObserving)

- (void)addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context
{
    [NSException raise:NSInvalidArgumentException format:@"%@: %p does not support -addObserver:forKeyPath:options:context:. Key path: %@.", [self class], self, keyPath];
}

- (void)removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath
{
    [NSException raise:NSInvalidArgumentException format:@"%@: %p does not support -removeObserver:forKeyPath:. Key path: %@.", [self class], self, keyPath];
}

- (void)removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(void *)context
{
    [NSException raise:NSInvalidArgumentException format:@"%@: %p does not support -removeObserver:forKeyPath:context:. Key path: %@.", [self class], self, keyPath];
}

@end

@implementation NSOrderedSet (NSKeyValueObserving)

- (void)addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context
{
    [NSException raise:NSInvalidArgumentException format:@"%@: %p does not support -addObserver:forKeyPath:options:context:. Key path: %@.", [self class], self, keyPath];
}

- (void)removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath
{
    [NSException raise:NSInvalidArgumentException format:@"%@: %p does not support -removeObserver:forKeyPath:. Key path: %@.", [self class], self, keyPath];
}

- (void)removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(void *)context
{
    [NSException raise:NSInvalidArgumentException format:@"%@: %p does not support -removeObserver:forKeyPath:context:. Key path: %@.", [self class], self, keyPath];
}

@end

@implementation NSObject (NSKeyValueObservingCustomization)

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key
{
    NSString *methodPrefix = @"keyPathsForValuesAffecting";
    NSString *firstChar = [key substringToIndex:1];
    firstChar = [firstChar uppercaseString];
    NSString *capKey = [[NSString alloc] initWithFormat:@"%@%@", firstChar, [key substringFromIndex:1]];
    NSString *methodName = [[NSString alloc] initWithFormat:@"%@%@", methodPrefix, capKey];
    SEL action = NSSelectorFromString(methodName);
    [capKey release];
    [methodName release];
    if ([self respondsToSelector:action])
    {
        return (NSSet *)((NSSet * (*)(id, SEL))objc_msgSend(self, action));
    }
    return [NSSet set];
}

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key
{
    NSString *methodPrefix = @"automaticallyNotifiesObserversOf";
    NSString *firstChar = [[key substringToIndex:1] uppercaseString];
    NSString *methodName = [[NSString alloc] initWithFormat:@"%@%@%@", methodPrefix, firstChar, [key substringFromIndex:1]];
    SEL notifiesSelector = NSSelectorFromString(methodName);
    [methodName release];
    
    if ([self respondsToSelector:notifiesSelector])
    {
        return ((BOOL (*)(id, SEL))objc_msgSend)(self, notifiesSelector);
    }
    
    return YES;
}

static CFMutableDictionaryRef _NSKeyValueGlobalObservationInfo = NULL;

- (void *)observationInfo NS_RETURNS_INNER_POINTER
{
    if (_NSKeyValueGlobalObservationInfo == NULL)
    {
        return nil;
    }
    return (void *)CFDictionaryGetValue(_NSKeyValueGlobalObservationInfo, self);
}

- (void)setObservationInfo:(void *)observationInfo
{
    static dispatch_once_t once;
    if (_NSKeyValueGlobalObservationInfo == NULL)
    {
        dispatch_once(&once, 
        ^{
            _NSKeyValueGlobalObservationInfo = CFDictionaryCreateMutable(NULL, 0, NULL, &kCFTypeDictionaryValueCallBacks);
        });        
    }
    NSKeyValueObservationInfo *realInfoPtr = (NSKeyValueObservationInfo *)observationInfo;
    if (observationInfo == nil)
    {
        CFDictionaryRemoveValue(_NSKeyValueGlobalObservationInfo, self);
    }
    else
    {
        CFDictionarySetValue(_NSKeyValueGlobalObservationInfo, self, (CFTypeRef)realInfoPtr);
    }
}

@end

BOOL _NSKVONotifyingMutatorsShouldNotifyForIsaAndKey(Class isa, NSString *key)
{
    BOOL shouldNotify = NO;
    if (class_getMethodImplementation(isa, @selector(_isKVOA)) == (IMP)&_NSKVOIsAutonotifying)
    {
        NSKVONotifyingInfo *notifyingInfo = object_getIndexedIvars(isa);
        OSSpinLockLock(&_NSKVONotifyingInfoPropertyKeysSpinLock);
        shouldNotify = CFSetContainsValue(notifyingInfo->_field3, key);
        OSSpinLockUnlock(&_NSKVONotifyingInfoPropertyKeysSpinLock);
    }
    return shouldNotify;
}

NSKVONotifyingInfo *_NSKeyValueContainerClassGetNotifyingInfo(NSKeyValueContainerClass *kvcon)
{
    if ([kvcon notifyingInfo] == NULL)
    {
        if (!class_isMetaClass([kvcon originalClass]))
        {
            NSKVONotifyingInfo *notifyingInfo = _NSKVONotifyingCreateInfoWithOriginalClass([kvcon originalClass]);
            [kvcon setNotifyingInfo:notifyingInfo];
        }
    }
    return [kvcon notifyingInfo];
}

NSKVONotifyingInfo *_NSKVONotifyingCreateInfoWithOriginalClass(Class cls)
{
    const char *className = class_getName(cls);
    int len = strlen(className) + 16; // strlen("NSKVONotifying_")+1
    char *newName = malloc(len);
    strlcpy(newName, "NSKVONotifying_", len);
    strlcat(newName, className, len);
    Class newClass = objc_allocateClassPair(cls, newName, sizeof(NSKVONotifyingInfo));
    objc_registerClassPair(newClass); // we will use the 32 extra bytes as indexed ivars.
    free(newName);
    void *indexedIvars = object_getIndexedIvars(newClass); // interesting.
    NSKVONotifyingInfo notifyingInfo;
    notifyingInfo._originalClass = cls;
    notifyingInfo._notifyingClass = newClass; 
    notifyingInfo._field3 = CFSetCreateMutable(NULL, 0, &kCFCopyStringSetCallBacks);
    notifyingInfo._cachedKeys = CFDictionaryCreateMutable(NULL, 0, NULL, &kCFTypeDictionaryValueCallBacks);
    *(NSKVONotifyingInfo *)indexedIvars = notifyingInfo;
    NSKVONotifyingSetMethodImplementation(indexedIvars, @selector(_isKVOA), (IMP)&_NSKVOIsAutonotifying, nil);
    NSKVONotifyingSetMethodImplementation(indexedIvars, @selector(dealloc), (IMP)&NSKVODeallocate, nil);
    NSKVONotifyingSetMethodImplementation(indexedIvars, @selector(class), (IMP)&_NSKVOClass, nil);
    return (NSKVONotifyingInfo *)indexedIvars;
}

void _NSKVONotifyingEnableForInfoAndKey(NSKVONotifyingInfo *notifyingInfo, NSString *key)
{
    OSSpinLockLock(&_NSKVONotifyingInfoPropertyKeysSpinLock);
    CFSetAddValue(notifyingInfo->_field3, key);
    OSSpinLockUnlock(&_NSKVONotifyingInfoPropertyKeysSpinLock);
    NSKeyValueSetter *setter = [notifyingInfo->_originalClass _createValueSetterWithContainerClassID:notifyingInfo->_originalClass key:key];
    if ([setter isKindOfClass:[NSKeyValueMethodSetter class]])
    {
        Method m = [(NSKeyValueMethodSetter *)setter method];
        const char *typeEncoding = method_getTypeEncoding(m);
        if (typeEncoding[0] != 'v')
        {
            NSLog(@"KVO only supports -set<Key>: methods that return void. Autonotifying will not be done for invocations of -[%@ %s].", notifyingInfo->_originalClass, sel_getName(method_getName(m)));
        }
        else
        {
            char *argtype = method_copyArgumentType(m, 2);
            IMP replacementSetter = (IMP)&__NSSetObjectValueAndNotify;
            if (argtype[0] <= '?' && argtype[0] != '#')
            {
                NSLog(@"KVO only supports -set<Key>: methods that take id, NSNumber-supported scalar types, and some structure types. Autonotifying will not be done for invocations of -[%@ %s].", notifyingInfo->_originalClass, sel_getName(method_getName(m)));
                //TODO: I'm not sure this is actually true anymore, but this is clearly a code path that exists.
            }
            else
            {
                if (argtype[0] == '{')
                {
                    if (strcmp(argtype, @encode(CGPoint)) == 0)
                    {
                        replacementSetter = (IMP)&__NSSetPointValueAndNotify;
                    }
                    else if (strcmp(argtype, @encode(NSRange)) == 0)
                    {
                        replacementSetter = (IMP)&__NSSetRangeValueAndNotify;
                    }
                    else if (strcmp(argtype, @encode(CGRect)) == 0)
                    {
                        replacementSetter = (IMP)&__NSSetRectValueAndNotify;
                    }
                    else if (strcmp(argtype, @encode(CGSize)) == 0)
                    {
                        replacementSetter = (IMP)&__NSSetSizeValueAndNotify;
                    }
                    else
                    {
                        replacementSetter = (IMP)&_CF_forwarding_prep_0; // aha - this is how other structs work.
                    }
                }
                else
                {
                    switch (argtype[0])
                    {
                        case _C_CHR:
                            replacementSetter = (IMP)&__NSSetCharValueAndNotify;
                            break;
                        case _C_INT:
                            replacementSetter = (IMP)&__NSSetIntValueAndNotify; 
                            break;
                        case _C_SHT:
                            replacementSetter = (IMP)&__NSSetShortValueAndNotify;
                            break;
                        case _C_LNG:
                            replacementSetter = (IMP)&__NSSetLongValueAndNotify;
                            break;
                        case _C_LNG_LNG:
                            replacementSetter = (IMP)&__NSSetLongLongValueAndNotify;
                            break;
                        case _C_UCHR:
                            replacementSetter = (IMP)&__NSSetUnsignedCharValueAndNotify;
                            break;
                        case _C_UINT:
                            replacementSetter = (IMP)&__NSSetUnsignedIntValueAndNotify;
                            break;
                        case _C_USHT:
                            replacementSetter = (IMP)&__NSSetUnsignedShortValueAndNotify;
                            break;
                        case _C_ULNG:
                            replacementSetter = (IMP)&__NSSetUnsignedLongValueAndNotify;
                            break;
                        case _C_ULNG_LNG:
                            replacementSetter = (IMP)&__NSSetUnsignedLongLongValueAndNotify;
                            break;
                        case _C_FLT:
                            replacementSetter = (IMP)&__NSSetFloatValueAndNotify;
                            break;
                        case _C_DBL:
                            replacementSetter = (IMP)&__NSSetDoubleValueAndNotify;
                            break;
                        case _C_BOOL:
                            replacementSetter = (IMP)&__NSSetBoolValueAndNotify;
                            break;
                        // case '#': replacementSetter = (IMP)&__NSSetObjectValueAndNotify; break; // not actually necessary, since it's set above.
                        // case '@': replacementSetter = (IMP)&__NSSetObjectValueAndNotify; break; // still good to have it for documentation purposes
                    }
                }
                free(argtype);
                SEL selector = method_getName(m);
                NSKVONotifyingSetMethodImplementation(notifyingInfo, selector, replacementSetter, key);

                // Ensuring that the setValue:forKey: for the notifying object point to the correct
                // method implementation
                NSKeyValueSetter *notifyingSetter = [NSObject _createValueSetterWithContainerClassID:notifyingInfo->_notifyingClass key:key];
                [notifyingSetter setMethod:class_getInstanceMethod(notifyingInfo->_notifyingClass, selector)];

                if (replacementSetter == (IMP)&_CF_forwarding_prep_0)
                {
                    NSKVONotifyingSetMethodImplementation(notifyingInfo, @selector(forwardInvocation:), (IMP)&NSKVOForwardInvocation, nil);
                    Class otherClass= notifyingInfo->_notifyingClass;
                    const char *methodName = sel_getName(selector);
                    int nameLength = strlen(methodName);
                    const char *prefix = kOriginalImplementationMethodNamePrefix;
                    char buffer[29] = {0};
                    strlcpy(buffer, prefix, nameLength+strlen(prefix));
                    strlcat(buffer, methodName, nameLength+strlen(prefix));
                    SEL newForwardingSelector = sel_registerName(buffer);
                    IMP originalIMP = method_getImplementation(m);
                    const char *originalTypeEncoding = method_getTypeEncoding(m);
                    class_addMethod(otherClass, newForwardingSelector, originalIMP, originalTypeEncoding);
                }
            }
        }
    }
    else if ([setter isKindOfClass:[NSKeyValueIvarSetter class]])
    {
        NSKeyValueSetter *notifyingSetter = [NSObject _createValueSetterWithContainerClassID:notifyingInfo->_notifyingClass key:key];
        [(NSKeyValueIvarSetter *)notifyingSetter makeNSKVONotifying];
    }
    // id ret = _NSKeyValueMutableArrayGetterForIsaAndKey(notifyingInfo->_originalClass, key);
    // the above is not required for NSOperation. I don't think. There are 2 further calls (and associated chunks of NSKVONotifyintSetMethodImplementation) for sets and ordered sets.
#warning observation in an array may not work without the above.
    return;
}

static void NSKVONotifyingSetMethodImplementation(NSKVONotifyingInfo *notifyingInfo, SEL selector, IMP newImplementation, NSString *optionalKey)
{
    Method originalMethod = class_getInstanceMethod(notifyingInfo->_originalClass, selector);
    if (originalMethod == NULL)
    {
        return;
    }
    const char *typeEncoding = method_getTypeEncoding(originalMethod);
    if (optionalKey != nil)
    {
        OSSpinLockLock(&_NSKVONotifyingInfoPropertyKeysSpinLock);
        CFDictionarySetValue(notifyingInfo->_cachedKeys, selector, optionalKey);
        OSSpinLockUnlock(&_NSKVONotifyingInfoPropertyKeysSpinLock);
    }
    class_addMethod(notifyingInfo->_notifyingClass, selector, newImplementation, typeEncoding);
}

static void NSKVOForwardInvocation(id self, SEL _cmd, NSInvocation *invocation)
{
    Class realClass = object_getClass(self);
    NSKVONotifyingInfo *indexedIvars = object_getIndexedIvars(realClass);
    SEL selector = [invocation selector];
    OSSpinLockLock(&_NSKVONotifyingInfoPropertyKeysSpinLock);
    NSString *key = [(NSString *)CFDictionaryGetValue(indexedIvars->_cachedKeys, selector) retain]; // apparently you can put a SEL in a CFDictionary. Who knew?
    OSSpinLockUnlock(&_NSKVONotifyingInfoPropertyKeysSpinLock);
    if (key != nil)
    {
        [self willChangeValueForKey:key];
        const char *methodName = sel_getName(selector);
        int nameLength = strlen(methodName);
        char buffer[29] = {0};
        strlcpy(buffer, kOriginalImplementationMethodNamePrefix, nameLength+strlen(kOriginalImplementationMethodNamePrefix));
        strlcat(buffer, methodName, nameLength+strlen(kOriginalImplementationMethodNamePrefix));
        SEL newForwardingSelector = sel_registerName(buffer);
        [invocation setSelector:newForwardingSelector];
        [invocation invoke];
        [self didChangeValueForKey:key];
        [key release];
    }
    else
    {
        struct objc_super super = {
            .receiver = self,
            .super_class = class_getSuperclass(object_getClass(self))
        };
        (void)(void (*)(id, SEL))objc_msgSendSuper(&super, _cmd);
    }
}

void _NSKeyValueWillChange(id self, id keyOrKeys, BOOL keyOrKeysIsASet, NSKeyValueObservationInfo *observationInfo, NSKeyValueWillChangeApplyFunction apply, void *reserved2, NSObject *observer, NSKeyValueObservingTSD *kvoTSD, NSKeyValuePushPendingFunction pushFn)
{
    NSArray *observances = [observationInfo observances];
    NSUInteger observancesCount = [observances count];
    NSKeyValueObservance **observancesCArray = alloca(observancesCount * sizeof(NSKeyValueObservance *));
    [observances getObjects:observancesCArray range:NSMakeRange(0, observancesCount)];
    if (observancesCount != 0)
    {
        for (int observanceIndex=0; observanceIndex<observancesCount; ++observanceIndex)
        {
            NSKeyValueObservance *observance = observancesCArray[observanceIndex];
            NSString *relevantKeyPath = nil;
            BOOL exactMatch = NO;
            NSKeyValueChangeDetails changeResult = {0};
            if (observer == nil || observer == observance)
            {
                NSKeyValueProperty *property = observance.property;
                if (keyOrKeysIsASet)
                {
                    relevantKeyPath = [property keyPathIfAffectedByValueForMemberOfKeys:keyOrKeys];
                }
                else
                {
                    relevantKeyPath = [property keyPathIfAffectedByValueForKey:keyOrKeys exactMatch:&exactMatch];
                }
                if (relevantKeyPath != nil)
                {
                    NSKeyValueForwardingValues forwardingValues = {0};
                    if ([property object:self withObservance:observance willChangeValueForKeyOrKeys:keyOrKeys recurse:YES forwardingValues:&forwardingValues])
                    {
                        BOOL reatinedDetails = NO;
                        apply(&changeResult, self, relevantKeyPath, exactMatch, observance.options, reserved2, forwardingValues, &reatinedDetails);
                        pushFn(self, keyOrKeys, observance, forwardingValues, kvoTSD, changeResult);
                        if (observance.options & NSKeyValueObservingOptionPrior)
                        {
                            _NSKeyValueNotifyObserver(observance.observer, self, observance.originalObservable, relevantKeyPath, changeResult, observance.context, YES);
                        }
                        if (reatinedDetails)
                        {
                            [changeResult.oldValue release];
                            [changeResult.newValue release];
                            [changeResult.indexes release];
                            [changeResult.extraData release];
                        }
                    }
                }

            }
        }
    }
}

static void NSKeyValueObservingTSDDestroy(void *mem)
{
    free(mem);
}

void _NSKeyValueWillChangeBySetting(NSKeyValueChangeDetails *changeDetails, id self, NSString *keyPath, BOOL wasExactMatch, NSKeyValueObservingOptions options, void *reserved, NSKeyValueForwardingValues forwardingValues, BOOL *reatinedDetails)
{
    id oldValue = nil;
    if (options & NSKeyValueObservingOptionOld)
    {
        oldValue = [self valueForKeyPath:keyPath];
        if (oldValue == nil)
        {
            oldValue = [NSNull null];
        }
    }
    changeDetails->kind = NSKeyValueChangeSetting;
    changeDetails->oldValue = [oldValue retain];
    changeDetails->newValue = nil;
    changeDetails->indexes = nil;
    changeDetails->extraData = nil;
    if (reatinedDetails)
    {
        *reatinedDetails = YES; 
    }
}

void _NSKeyValueWillChangeByOrderedToManyMutation(NSKeyValueChangeDetails *changeDetails, id self, NSString *keyPath, BOOL wasExactMatch, NSKeyValueObservingOptions options, void *reserved, NSKeyValueForwardingValues forwardingValues, BOOL *reatinedDetails)
{
    if (!wasExactMatch)
    {
        _NSKeyValueWillChangeBySetting(changeDetails, self, keyPath, NO, options, NULL, forwardingValues, reatinedDetails);
        return;
    }
    
    NSKeyValueChangeByOrderedToManyMutation *change = (NSKeyValueChangeByOrderedToManyMutation*)reserved;
    NSKeyValueChange kind = change->_changeKind;
    NSIndexSet *indexes = change->_indexes;
    
    id oldValue = nil;
    if (options & NSKeyValueObservingOptionOld)
    {
        if (kind == NSKeyValueChangeSetting)
        {
            oldValue = [[self valueForKeyPath:keyPath] copy];
        }
        else if (kind == NSKeyValueChangeRemoval || kind == NSKeyValueChangeReplacement)
        {
            id container = [self valueForKeyPath:keyPath];
            oldValue = [[container objectsAtIndexes:indexes] retain];
        }
    }
    
    changeDetails->kind = kind;
    changeDetails->oldValue = oldValue;
    changeDetails->newValue = nil;
    changeDetails->indexes = kind == NSKeyValueChangeSetting ? nil : [indexes retain];
    changeDetails->extraData = nil;
    if (reatinedDetails)
    {
        *reatinedDetails = YES;
    }
}

void _NSKeyValueWillChangeBySetMutation(NSKeyValueChangeDetails *changeDetails, id self, NSString *keyPath, BOOL wasExactMatch, NSKeyValueObservingOptions options, void *reserved, NSKeyValueForwardingValues forwardingValues, BOOL *reatinedDetails)
{
    if (!wasExactMatch)
    {
        _NSKeyValueWillChangeBySetting(changeDetails, self, keyPath, NO, options, NULL, forwardingValues, reatinedDetails);
        return;
    }
    
    NSKeyValueChangeBySetMutation *change = (NSKeyValueChangeBySetMutation*)reserved;
    NSKeyValueSetMutationKind mutationKind = change->_mutationKind;
    NSSet *objects = change->_objects;
    
    NSKeyValueChange kind = NSKeyValueChangeReplacement;
    id newValue = nil;
    id oldValue = nil;
    
    if (mutationKind == NSKeyValueUnionSetMutation)
    {
        kind = NSKeyValueChangeInsertion;
        
        if (options & NSKeyValueObservingOptionNew)
        {
            NSSet *currentSet = [self valueForKeyPath:keyPath];
            newValue = [objects mutableCopy];
            [newValue minusSet:currentSet];
        }
    }
    else if (mutationKind == NSKeyValueMinusSetMutation)
    {
        kind = NSKeyValueChangeRemoval;
        
        if (options & NSKeyValueObservingOptionOld)
        {
            NSSet *currentSet = [self valueForKeyPath:keyPath];
            oldValue = [currentSet mutableCopy];
            [oldValue intersectSet:objects];
        }
    }
    else if (mutationKind == NSKeyValueIntersectSetMutation)
    {
        kind = NSKeyValueChangeRemoval;
        
        if (options & NSKeyValueObservingOptionOld)
        {
            NSSet *currentSet = [self valueForKeyPath:keyPath];
            oldValue = [currentSet mutableCopy];
            [oldValue minusSet:objects];
        }
    }
    else if (mutationKind == NSKeyValueSetSetMutation)
    {
        kind = NSKeyValueChangeReplacement;
        
        if (options & NSKeyValueObservingOptionNew)
        {
            NSSet *currentSet = [self valueForKeyPath:keyPath];
            newValue = [objects mutableCopy];
            [newValue minusSet:currentSet];
        }
        
        if (options & NSKeyValueObservingOptionOld)
        {
            NSSet *currentSet = [self valueForKeyPath:keyPath];
            oldValue = [currentSet mutableCopy];
            [oldValue minusSet:objects];
        }
    }
    
    changeDetails->kind = kind;
    changeDetails->oldValue = oldValue;
    changeDetails->newValue = newValue;
    changeDetails->indexes = nil;
    changeDetails->extraData = nil;
    if (reatinedDetails)
    {
        *reatinedDetails = YES;
    }
}

static inline const void *_NSKVOPendingNotificationRetain(CFAllocatorRef allocator, const void *value)
{
    NSKVOPendingNotificationInfo *pendingNotification = (NSKVOPendingNotificationInfo *)value;
    pendingNotification->retainCount += 1;
    return pendingNotification;
}

static inline void _NSKVOPendingNotificationRelease(CFAllocatorRef allocator, const void *value)
{
    NSKVOPendingNotificationInfo *pendingNotification = (NSKVOPendingNotificationInfo *)value;
    if (--(pendingNotification->retainCount) > 0)
    {
        return;
    }
    [pendingNotification->originalObservable release];
    [pendingNotification->observer release];
    [pendingNotification->keyOrKeys release];
    [pendingNotification->observance release];
    [pendingNotification->observationInfo release];
    [pendingNotification->changeDetails.oldValue release];
    [pendingNotification->changeDetails.newValue release];
    [pendingNotification->changeDetails.indexes release];
    [pendingNotification->changeDetails.extraData release];
    [pendingNotification->forwardingValues._field1 release];
    [pendingNotification->forwardingValues.recursedMutableDictionary release];
    free(pendingNotification);
}


static CFArrayCallBacks _NSKVOPendingNotificationArrayCallbacks = {
    .version = 0,
    .retain = &_NSKVOPendingNotificationRetain,
    .release = &_NSKVOPendingNotificationRelease,
    .copyDescription = NULL,
    .equal = NULL
};

void _NSKeyValueWillChangeForObservance(NSObject *originalObservable, id dependentValueKeyOrKeys, BOOL dependentValueKeyOrKeysIsASet, NSObject *observer)
{

    NSKeyValueObservationInfo *observationInfo = __NSKeyValueRetainedObservationInfoForObject(originalObservable, nil);
    if (observationInfo != nil)
    {
        NSKeyValueObservingTSD *threadSpecificKVOStruct = NSGetOrCreateThreadSpecificKVOStruct();
        ++threadSpecificKVOStruct->recursionLevel;
        if (threadSpecificKVOStruct->pendingNotifications == NULL)
        {
            threadSpecificKVOStruct->pendingNotifications = CFArrayCreateMutable(NULL, 0, &_NSKVOPendingNotificationArrayCallbacks);
        }
        NSKeyValueObservingTSD tsdCopy = *threadSpecificKVOStruct;
        tsdCopy.nextIsObservationInfo = YES;
        tsdCopy.implicitObservanceAdditionInfoOrObservationInfo.observationInfo = observationInfo;
        _NSKeyValueWillChange(originalObservable, dependentValueKeyOrKeys, dependentValueKeyOrKeysIsASet, observationInfo, &_NSKeyValueWillChangeBySetting, nil, observer, &tsdCopy, &_NSKeyValuePushPendingNotificationsPerThread);
        --threadSpecificKVOStruct->recursionLevel;
    }
    [observationInfo release];
}

void _NSKeyValueDidChangeForObservance(NSObject *originalObservable, id dependentValueKeyOrKeys, BOOL dependentValueKeyOrKeysIsASet, NSKeyValueObservance *observance)
{
    pthread_key_t pthreadKVOKey = _NSGetKVOPthreadKey();
    NSKeyValueObservingTSD *threadSpecificKVOStruct = pthread_getspecific(pthreadKVOKey);
    if (threadSpecificKVOStruct != NULL && threadSpecificKVOStruct->pendingNotifications != NULL)
    {
        ++threadSpecificKVOStruct->recursionLevel;
        NSUInteger pendingNotificationCount = CFArrayGetCount(threadSpecificKVOStruct->pendingNotifications);
        if (pendingNotificationCount > 0)
        {
            NSKVOPopNotificationResult popResult = {
                .pendingNotifications = threadSpecificKVOStruct->pendingNotifications,
                .pendingNotificationCount = pendingNotificationCount,
                .relevantNotification = NULL,
                .relevantNotificationIndex = -1,
                .observance = observance,
                .recursionLevel = threadSpecificKVOStruct->recursionLevel
            };
            _NSKeyValueDidChange(originalObservable, dependentValueKeyOrKeys, dependentValueKeyOrKeysIsASet, &_NSKeyValueDidChangeBySetting, &_NSKeyValuePopPendingNotificationPerThread, &popResult);
        }
        --threadSpecificKVOStruct->recursionLevel;
    }
}

void _NSKeyValuePushPendingNotificationsPerThread(NSObject *originalObservable, id keyOrKeys, NSKeyValueObservance *observance, NSKeyValueForwardingValues forwardingValues, NSKeyValueObservingTSD *kvoTSD, NSKeyValueChangeDetails changeDetails)
{
    NSKVOPendingNotificationInfo *pendingNotification = calloc(1, sizeof(NSKVOPendingNotificationInfo));
    pendingNotification->retainCount = 1;
    pendingNotification->originalObservable = [originalObservable retain];
    pendingNotification->observer = [observance.observer retain];
    pendingNotification->keyOrKeys = [keyOrKeys copy]; //even if it is a set we want to avoid it being mutated out from under us, so copy. 
    pendingNotification->reserved = kvoTSD->nextIsObservationInfo;
    pendingNotification->observance = [observance retain];
    pendingNotification->observationInfo = [kvoTSD->implicitObservanceAdditionInfoOrObservationInfo.observationInfo retain];
    pendingNotification->changeDetails.kind = changeDetails.kind;
    pendingNotification->changeDetails.oldValue = [changeDetails.oldValue retain];
    pendingNotification->changeDetails.newValue = [changeDetails.newValue retain];
    pendingNotification->changeDetails.indexes = [changeDetails.indexes retain];
    pendingNotification->changeDetails.extraData = [changeDetails.extraData retain];
    pendingNotification->forwardingValues._field1 = [forwardingValues._field1 retain];
    pendingNotification->forwardingValues.recursedMutableDictionary = [forwardingValues.recursedMutableDictionary retain];
    pendingNotification->recursionLevel = kvoTSD->recursionLevel;
    CFArrayAppendValue(kvoTSD->pendingNotifications, pendingNotification);
    _NSKVOPendingNotificationRelease(NULL, pendingNotification);
}

void _NSKeyValueDidChange(NSObject *observable, id keyOrKeys, BOOL keyOrKeysIsASet, NSKeyValueDidChangeApplyFunction apply, NSKeyValuePopPendingFunction popFn, NSKVOPopNotificationResult *result)
{
    NSKeyValueObservance *outObservance = nil;
    NSKeyValueChangeDetails fillDetails = {0};
    NSKeyValueForwardingValues forwardingValues = {0};
    id outKeyOrKeys = nil;
    while (popFn(observable, keyOrKeys, &outObservance, &fillDetails, &forwardingValues, &outKeyOrKeys, result))
    {
        [outObservance.property object:observable withObservance:outObservance didChangeValueForKeyOrKeys:outKeyOrKeys recurse:YES forwardingValues:forwardingValues];
        NSString *keyPath = [outObservance.property keyPath];
        BOOL isDifferent = NO;
        if (keyOrKeysIsASet == NO)
        {
            isDifferent = !CFEqual(keyPath, outKeyOrKeys);
        }
        NSKeyValueChangeDetails appliedDetails = {0}; // possibly the wrong struct here. 
        apply(&appliedDetails, observable, keyPath, isDifferent, outObservance.options, fillDetails);
        _NSKeyValueNotifyObserver(outObservance.observer, observable, outObservance.originalObservable, keyPath, appliedDetails, outObservance.context, NO);
    }
}

static BOOL __NSKeyValueCheckObservationInfoForPendingNotification(NSObject *originalObservable, NSKeyValueObservance *observance, NSUInteger relevantNotificationIndex)
{
    OSSpinLockLock(&_NSKeyValueObservationInfoSpinLock);
    NSKeyValueObservationInfo *observationInfo = nil;
    NSKeyValueContainerClass *kvcon = observance.property.containerClass;
    if (kvcon != nil)
    {
        observationInfo = kvcon.cachedObservationInfoImplementation(originalObservable, @selector(observationInfo));
    }
    else
    {
        observationInfo = [originalObservable observationInfo];
    }
    BOOL result = NO;
    if (observationInfo != nil)
    {
        result = YES;
        if ((NSUInteger)observationInfo != relevantNotificationIndex) // So this is a little bizarre. It is in fact what it looks like. This is necessary to make -testMidCycleReregister pass.
        {                                                             // the pending notification sticks around, and the "observationInfo" becomes an index into the not-yet-deallocated NSKVOChangeResult pendingNotifications array
            result = [observationInfo.observances containsObject:observance]; // the key is that the pending notification doesn't just disappear just because the last observer was unregistered.
        }                                                                     // what this does mean, however, is that in order to solve this bug, KVO gets put into a weird state, particularly if an object is an observer multiple times
    }                                                                         // in different contexts. NSKVODeallocateBreak is sometimes not called on deallocation with one of those observances still registered, for instance.
    OSSpinLockUnlock(&_NSKeyValueObservationInfoSpinLock);                    // TODO: contemplate deliberately failing -testMidCycleReregister in exchange for some sanity in implementation and other correct behavior,
                                                                              // such as in -testMidCycleReregisterPartialWithContext, particularly if setting that index proves troublesome.
    return result;                                                            // Also this is probably why observationInfo is opaque (other than because there's no user-useful methods on it besides -description).
}

BOOL _NSKeyValuePopPendingNotificationPerThread(NSObject *observable, NSString *key, NSKeyValueObservance **outObservance, NSKeyValueChangeDetails *outChangeDetails, NSKeyValueForwardingValues *outForwardingValues, id *outKeyOrKeys, NSKVOPopNotificationResult *result)
{
    NSInteger cursor = result->pendingNotificationCount;
    if (result->relevantNotification == NULL)
    {
        result->relevantNotificationIndex = cursor;
    }
    else
    {
        BOOL temp = result->relevantNotification->reserved;
        CFArrayRemoveValueAtIndex(result->pendingNotifications, result->relevantNotificationIndex);
        if (temp)
        {
            #warning TODO: This return breaks having multiple observers of the same object & key. Work out what it's meant to do!
            // AFAICT, _NSKeyValuePushPendingNotificationsPerThread is currently always setting reserved to YES.
            // The second call to this function within the same _NSKeyValueDidChange call would always return NO.
            // This seems broken as ultimately all NSKVOPendingNotificationInfo objects should get popped.
            //return NO;
        }
        cursor = result->relevantNotificationIndex;
    }
    BOOL success = NO;
    while (cursor-- > 0)
    {
        NSKVOPendingNotificationInfo *pendingNotification = (NSKVOPendingNotificationInfo *)CFArrayGetValueAtIndex(result->pendingNotifications, cursor);
        if (pendingNotification->recursionLevel < result->recursionLevel)
        {
            // pendingNotification was pushed higher up call chain.
            continue;
        }
        if (pendingNotification->originalObservable != observable)
        {
            continue;
        }
        if ([pendingNotification->keyOrKeys isEqual:key] && (result->observance == nil || pendingNotification->observance == result->observance))
        {
            if (result->relevantNotificationIndex == 0 || __NSKeyValueCheckObservationInfoForPendingNotification(pendingNotification->originalObservable, pendingNotification->observance, result->relevantNotificationIndex)) 
            { // TODO: make sure the last parameter above is not supposed to be pendingNotification-> reserved2
                *outObservance = pendingNotification->observance;
                *outChangeDetails = pendingNotification->changeDetails;
                *outKeyOrKeys = key;
                *outForwardingValues = pendingNotification->forwardingValues;
                result->relevantNotification = pendingNotification; //this seems unlikely. 
                result->relevantNotificationIndex = cursor;
                success = YES;
                break;
            }
            else
            {
                CFArrayRemoveValueAtIndex(result->pendingNotifications, cursor);
                if (pendingNotification->retainCount == 0)
                {
                    continue;
                }
                break;
            }
        }
    }
    return success;
}


void _NSKeyValueDidChangeBySetting(NSKeyValueChangeDetails *outDetails, NSObject *observable, NSString *keyPath, BOOL hasDependentKeys, NSKeyValueObservingOptions options, NSKeyValueChangeDetails inDetails)
{
    id newValue = nil;
    if (options & NSKeyValueObservingOptionNew)
    {
        newValue = [observable valueForKeyPath:keyPath];
        if (newValue == nil)
        {
            newValue = [NSNull null];
        }
    }
    *outDetails = inDetails;
    outDetails->newValue = newValue;
}

void _NSKeyValueDidChangeByOrderedToManyMutation(NSKeyValueChangeDetails *outDetails, NSObject *observable, NSString *keyPath, BOOL hasDependentKeys, NSKeyValueObservingOptions options, NSKeyValueChangeDetails inDetails)
{
    if (hasDependentKeys)
    {
        _NSKeyValueDidChangeBySetting(outDetails, observable, keyPath, hasDependentKeys, options, inDetails);
        return;
    }
    
    NSKeyValueChange kind = inDetails.kind;
    
#warning TODO: This function should validate which indexes have actually been changed.
    id newValue = nil;
    if (options & NSKeyValueObservingOptionNew)
    {
        if (kind == NSKeyValueChangeSetting)
        {
            newValue = [observable valueForKeyPath:keyPath];
        }
        else if (kind == NSKeyValueChangeInsertion || kind == NSKeyValueChangeReplacement)
        {
            id container = [observable valueForKeyPath:keyPath];
            newValue = [container objectsAtIndexes:inDetails.indexes];
        }
    }
    *outDetails = inDetails;
    outDetails->newValue = newValue;
}

void _NSKeyValueDidChangeBySetMutation(NSKeyValueChangeDetails *outDetails, NSObject *observable, NSString *keyPath, BOOL hasDependentKeys, NSKeyValueObservingOptions options, NSKeyValueChangeDetails inDetails)
{
    if (hasDependentKeys)
    {
        _NSKeyValueDidChangeBySetting(outDetails, observable, keyPath, hasDependentKeys, options, inDetails);
        return;
    }
    
    *outDetails = inDetails;
}

NSKeyValueImplicitObservanceAdditionInfo *_NSKeyValueGetImplicitObservanceAdditionInfo(void)
{
    NSKeyValueObservingTSD *threadSpecificKVOStruct = NSGetOrCreateThreadSpecificKVOStruct();
    return &(threadSpecificKVOStruct->implicitObservanceAdditionInfoOrObservationInfo.implicitObservanceAdditionInfo);
}

NSKeyValueImplicitObservanceRemovalInfo *_NSKeyValueGetImplicitObservanceRemovalInfo(void)
{
    NSKeyValueObservingTSD *threadSpecificKVOStruct = NSGetOrCreateThreadSpecificKVOStruct();
    return &(threadSpecificKVOStruct->implicitObservanceRemovalInfo);
}
