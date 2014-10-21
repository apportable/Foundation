//
//  NSKeyValueComputedProperty.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "NSKeyValueComputedProperty.h"
#import <Foundation/NSString.h>

@interface NSKeyValueComputedProperty ()
@property (nonatomic, retain) NSKeyValueProperty *operationArgumentProperty;
@property (nonatomic, copy) NSString *operationArgumentKeyPath;
@property (nonatomic, copy) NSString *operationName;
@end

@implementation NSKeyValueComputedProperty
- (instancetype)_initWithContainerClass:(NSKeyValueContainerClass *)containerClass keyPath:(NSString *)keyPath propertiesBeingInitialized:(CFMutableSetRef)propertiesBeingInitialized
{
    self = [super _initWithContainerClass:containerClass keyPath:keyPath propertiesBeingInitialized:propertiesBeingInitialized];
    if (self != nil)
    {
        NSRange firstDot = [keyPath rangeOfString:@"."];
        if (firstDot.length != 0)
        {
            self.operationName = [keyPath substringWithRange:NSMakeRange(1, firstDot.location-1)];
            self.operationArgumentKeyPath = [keyPath substringFromIndex:firstDot.location+1];
            self.operationArgumentProperty = _NSKeyValuePropertyForIsaAndKeyPathInner(self.containerClass.originalClass, _operationArgumentKeyPath, propertiesBeingInitialized);
        }
        else
        {
            self.operationName = keyPath; //it appears that in the case of @count and the like, that the '@' is retained in the _operationName
        }
    }
    return self;
}

- (void)dealloc
{
    [_operationArgumentProperty release];
    [_operationName release];
    [_operationArgumentKeyPath release];
    [super dealloc];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: container class: %@, operation name: %@, operation argument property: %@> via key path: %@", 
        [self class], 
        self.containerClass, 
        self.operationName, 
        self.operationArgumentProperty, 
        self.operationArgumentKeyPath];
}

- (void)_givenPropertiesBeingInitialized:(CFMutableSetRef)propertiesBeingInitialized getAffectingProperties:(NSMutableArray *)toBeFilled
{
    return; //NOP
}

- (void)_addDependentValueKey:(NSString *)key
{
    [(NSKeyValueComputedProperty *)self.operationArgumentProperty _addDependentValueKey:key];
}
- (id)isaForAutonotifying
{
    return [self _isaForAutonotifying];
}

- (id)_isaForAutonotifying
{
    return [self.operationArgumentProperty isaForAutonotifying];
}

- (BOOL)matchesWithoutOperatorComponentsKeyPath:(NSString *)keyPath
{
    NSString *toCompare = self.operationArgumentKeyPath;
    if (toCompare == nil)
    {
        toCompare = self.keyPath;
    }
    return CFEqual(toCompare, keyPath);
}

- (NSString *)keyPathIfAffectedByValueForMemberOfKeys:(NSSet *)keys
{
    return [self _keyPathIfAffectedByValueForMemberOfKeys:keys];
}

- (NSString *)keyPathIfAffectedByValueForKey:(NSString *)key exactMatch:(BOOL *)exactMatch
{
    return [self _keyPathIfAffectedByValueForKey:key exactMatch:exactMatch];
}

- (NSString *)_keyPathIfAffectedByValueForMemberOfKeys:(NSSet *)keys
{
    if ([self.operationArgumentProperty keyPathIfAffectedByValueForMemberOfKeys:keys])
    {
        return self.keyPath;
    }
    return nil;
}

- (NSString *)_keyPathIfAffectedByValueForKey:(NSString *)key exactMatch:(BOOL *)exactMatch
{
    if (exactMatch != NULL)
    {
        *exactMatch = NO;
    }
    if ([self.operationArgumentProperty keyPathIfAffectedByValueForKey:key exactMatch:NULL])
    {
        return self.keyPath;
    }
    return nil;
}

- (void)object:(NSObject *)object withObservance:(NSKeyValueObservance *)observance didChangeValueForKeyOrKeys:(id)keyOrKeys recurse:(BOOL)shouldRecurse forwardingValues:(NSKeyValueForwardingValues)forwardingValues
{
    [self.operationArgumentProperty object:object withObservance:observance didChangeValueForKeyOrKeys:keyOrKeys recurse:shouldRecurse forwardingValues:forwardingValues];
}

- (BOOL)object:(NSObject *)object withObservance:(NSKeyValueObservance *)observance willChangeValueForKeyOrKeys:(id)keyOrKeys recurse:(BOOL)shouldRecurse forwardingValues:(NSKeyValueForwardingValues *)forwardingValues
{
    return [self.operationArgumentProperty object:object withObservance:observance willChangeValueForKeyOrKeys:keyOrKeys recurse:shouldRecurse forwardingValues:forwardingValues];
}

- (void)object:(NSObject *)object didRemoveObservance:(NSKeyValueObservance *)observance recurse:(BOOL)shouldRecurse
{
    [self.operationArgumentProperty object:object didAddObservance:observance recurse:shouldRecurse];
}

- (void)object:(NSObject *)object didAddObservance:(NSKeyValueObservance *)observance recurse:(BOOL)shouldRecurse
{
    [self.operationArgumentProperty object:object didAddObservance:observance recurse:shouldRecurse];
}

@end
