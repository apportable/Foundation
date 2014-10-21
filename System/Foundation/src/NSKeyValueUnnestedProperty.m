//
//  NSKeyValueUnnestedProperty.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "NSKeyValueUnnestedProperty.h"
#import "NSKeyValueContainerClass.h"
#import <Foundation/NSKeyValueObserving.h>
#import "NSKeyValueObservingInternal.h"
#import <Foundation/NSKeyValueCoding.h>

#import <Foundation/NSArray.h>
#import <Foundation/NSSet.h>
#import <Foundation/NSString.h>
#import <Foundation/NSException.h>
#import <Foundation/NSDictionary.h>
#import "NSObjectInternal.h"

@interface NSKeyValueUnnestedProperty ()
@property (nonatomic, retain) NSArray *affectingProperties;
@property (nonatomic, assign) Class cachedIsaForAutonotifying;
@property (nonatomic, assign) BOOL cachedIsaForAutonotifyingIsValid;
@end

@implementation NSKeyValueUnnestedProperty

- (instancetype)_initWithContainerClass:(NSKeyValueContainerClass *)containerClass keyPath:(NSString *)key propertiesBeingInitialized:(CFMutableSetRef)propertiesBeingInitialized
{
    self = [super _initWithContainerClass:containerClass keyPath:key propertiesBeingInitialized:propertiesBeingInitialized];
    if (self != nil)
    {
        NSMutableArray *temp = [[NSMutableArray alloc] init];

        [self _givenPropertiesBeingInitialized:propertiesBeingInitialized getAffectingProperties:temp];
        [temp removeObject:self];
        if ([temp count] > 0)
        {
            self.affectingProperties = [temp copy];
        }
        [temp release];
        for (NSKeyValueProperty *dependentProperty in self.affectingProperties)
        {
            [dependentProperty _addDependentValueKey:key];
        }
    }
    return self;
}

- (void)dealloc
{
    [_affectingProperties release];
    [super dealloc];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: container class: %@, key: %@, isa for autonotifiying: %@, key paths of affecting properties: %@>", [self class], self.containerClass, self.keyPath, self.cachedIsaForAutonotifying, [self.affectingProperties valueForKey:@"keyPath"]];
}

- (void)_givenPropertiesBeingInitialized:(CFMutableSetRef)propertiesBeingInitialized getAffectingProperties:(NSMutableArray *)toBeFilled
{
    if (self.affectingProperties != nil)
    {
        [toBeFilled addObjectsFromArray:self.affectingProperties];
    }
    else
    {
        NSSet *affectingKeyPaths = [self.containerClass.originalClass keyPathsForValuesAffectingValueForKey:self.keyPath];
        for (NSString *keyPath in affectingKeyPaths)
        {
            if ([keyPath isEqualToString:self.keyPath])
            {
                [NSException raise:NSInternalInconsistencyException format:@"%@: A +keyPathsForValuesAffectingValueForKey: message returned a set that includes the same key that was passed in, which is not valid.\nPassed in key: %@\nReturned keypath set: %@", self, self.keyPath, affectingKeyPaths];
            }
            if ([self.keyPath hasPrefix:[keyPath stringByAppendingString:@"."]])
            {
                [NSException raise:NSInternalInconsistencyException format:@"%@: A +keyPathsForValuesAffectingValueForKey: message returned a set that includes a key path that starts with the same key that was passed in, which is not valid. The property identified by the key path already depends on the property identified by the key path.\n Passed in key: %@\nReturned keypath set: %@", self, self.keyPath, affectingKeyPaths];
            }
            NSKeyValueProperty *affectingProperty = _NSKeyValuePropertyForIsaAndKeyPathInner(self.containerClass.originalClass, keyPath, propertiesBeingInitialized);
            if (![toBeFilled containsObject:affectingProperty])
            {
                [toBeFilled addObject:affectingProperty];
                [(NSKeyValueUnnestedProperty *)affectingProperty _givenPropertiesBeingInitialized:propertiesBeingInitialized getAffectingProperties:toBeFilled]; //it may not be an unnested property, but anything it could be responds to that selector
            }
        }
    }
}
- (void)_addDependentValueKey:(NSString *)key
{
    //nothing to do for unnested.
}
- (Class)isaForAutonotifying
{
    if (!self.cachedIsaForAutonotifyingIsValid)
    {
        self.cachedIsaForAutonotifying = [self _isaForAutonotifying];
        for (NSKeyValueProperty *property in _affectingProperties)
        {
            property.cachedIsaForAutonotifying = [(NSKeyValueUnnestedProperty *)property _isaForAutonotifying]; //not actually unnested, but the superclass doesn't respond to _isaForAutonotifying.
        }
        self.cachedIsaForAutonotifyingIsValid = YES;
    }
    return self.cachedIsaForAutonotifying;
}
- (Class)_isaForAutonotifying
{
    Class ret = Nil;
    if ([[_containerClass originalClass] automaticallyNotifiesObserversForKey:_keyPath])
    {
        NSKVONotifyingInfo *notifyingInfo = _NSKeyValueContainerClassGetNotifyingInfo(_containerClass);
        if (notifyingInfo != NULL)
        {
            _NSKVONotifyingEnableForInfoAndKey(notifyingInfo, _keyPath);
            ret = notifyingInfo->_notifyingClass;
        }
    }
    return ret;
}
- (BOOL)matchesWithoutOperatorComponentsKeyPath:(id)keyPath
{
    return CFEqual(_keyPath, keyPath);
}
- (void)object:(NSObject *)observable didAddObservance:(NSKeyValueObservance *)observance recurse:(BOOL)shouldRecurse
{
    if (shouldRecurse && self.affectingProperties != nil)
    {
        for (NSKeyValueProperty *affectingProperty in self.affectingProperties)
        {
            [affectingProperty object:observable didAddObservance:observance recurse:NO];
        }
    }
}
- (void)object:(NSObject *)observable didRemoveObservance:(NSKeyValueObservance *)observance recurse:(BOOL)shouldRecurse
{
    if (shouldRecurse && self.affectingProperties != nil)
    {
        for (NSKeyValueProperty *affectingProperty in self.affectingProperties)
        {
            [affectingProperty object:observable didRemoveObservance:observance recurse:NO];
        }
    }
}
- (BOOL)object:(NSObject *)object withObservance:(NSKeyValueObservance *)observance willChangeValueForKeyOrKeys:(id)keyOrKeys recurse:(BOOL)shouldRecurse forwardingValues:(NSKeyValueForwardingValues *)forwardingValues
{
    //TODO: double check this is right. 
    NSMutableDictionary *dict = nil;
    if (shouldRecurse)
    {
        BOOL isKeys = [keyOrKeys isNSSet__];
        for (NSKeyValueProperty *affectingProperty in self.affectingProperties)
        {
            NSString *relevantKeyPath = nil;
            if (isKeys)
            {
                relevantKeyPath = [affectingProperty keyPathIfAffectedByValueForMemberOfKeys:keyOrKeys];
            }
            else
            {
                relevantKeyPath = [affectingProperty keyPathIfAffectedByValueForKey:keyOrKeys exactMatch:NULL];
            }
            if (relevantKeyPath != nil)
            {
                if ([affectingProperty object:object withObservance:observance willChangeValueForKeyOrKeys:keyOrKeys recurse:NO forwardingValues:forwardingValues])
                {
                    if (forwardingValues->_field1 != nil)
                    {
                        if (dict == nil)
                        {
                            dict = [NSMutableDictionary dictionaryWithObject:forwardingValues->_field1 forKey:relevantKeyPath];
                        }
                        else
                        {
                            [dict setObject:forwardingValues->_field1 forKey:relevantKeyPath]; //This in particular looks a bit suspicious. TODO: cross-check it with the nested version.
                            // In the only case we've ever seen of this being used, _field1 is an observance, and the key is the nested observable. 
                        }
                    }
                    if (forwardingValues->recursedMutableDictionary != nil)
                    {
                        if (dict == nil)
                        {
                            dict = forwardingValues->recursedMutableDictionary; // !!
                        }
                        else
                        {
                            [dict addEntriesFromDictionary:forwardingValues->recursedMutableDictionary];
                        }
                    }
                }
            }
        }
    }
    forwardingValues->_field1 = nil;
    forwardingValues->recursedMutableDictionary = dict;
    //the lack of retain/release mangagement here is because the ownership of these objects is managed by NSKVOPendingNotificationInfo. 
    return YES;
}

- (void)object:(NSObject *)object withObservance:(NSKeyValueObservance *)observance didChangeValueForKeyOrKeys:(id)keyOrKeys recurse:(BOOL)shouldRecurse forwardingValues:(NSKeyValueForwardingValues)forwardingValues
{

    for (NSString *key in forwardingValues.recursedMutableDictionary)
    {
        NSKeyValueProperty *value = forwardingValues.recursedMutableDictionary[key];
        NSKeyValueForwardingValues newValues = { ._field1 = value, .recursedMutableDictionary = nil}; // this makes no sense except in the context of the leaf of a nested key path depended on by an unnested key. Yeesh. 
                                                                                                      // there has GOT to be a more elegant way to do this. 
        [value object:object withObservance:observance didChangeValueForKeyOrKeys:keyOrKeys recurse:NO forwardingValues:newValues];
    }
}

- (NSString *)keyPathIfAffectedByValueForMemberOfKeys:(NSSet *)keys
{
    NSString *keyPath = [self _keyPathIfAffectedByValueForMemberOfKeys:keys];
    if (keyPath != nil)
    {
        return keyPath;
    }
    for (NSKeyValueProperty *affectingProperty in self.affectingProperties)
    {
        keyPath = [(NSKeyValueUnnestedProperty *)affectingProperty _keyPathIfAffectedByValueForMemberOfKeys:keys]; // silence spurious may not respond to selector warning
        if (keyPath != nil)
        {
            return self.keyPath; // could just return keyPath in the unnested case, dunno about the others. 
        }
    }
    return nil;
}

- (NSString *)_keyPathIfAffectedByValueForMemberOfKeys:(NSSet *)keys
{
    return [keys member:self.keyPath];
}

- (NSString *)keyPathIfAffectedByValueForKey:(NSString *)key exactMatch:(BOOL *)exactMatch
{
    NSString *keyPath = [self _keyPathIfAffectedByValueForKey:key exactMatch:exactMatch];
    if (keyPath)
    {
        return keyPath;
    }
    for (NSKeyValueProperty *affectingProperty in self.affectingProperties)
    {
        keyPath = [(NSKeyValueUnnestedProperty *)affectingProperty _keyPathIfAffectedByValueForKey:key exactMatch:NULL]; //probably not unnested, but nothing concrete fails to respond to it. 
        if (keyPath != nil)
        {
            if (exactMatch != NULL)
            {
                *exactMatch = NO;
            }
            return self.keyPath;
        }
    }
    return nil;
}

- (NSString *)_keyPathIfAffectedByValueForKey:(NSString *)key exactMatch:(BOOL *)exactMatch
{
    if ([self.keyPath isEqualToString:key])
    {
        if (exactMatch != NULL)
        {
            *exactMatch = YES;
        }
        return self.keyPath;
    }
    return nil;
}

@end
