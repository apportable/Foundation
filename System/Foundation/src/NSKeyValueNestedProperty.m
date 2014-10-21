//
//  NSKeyValueNestedProperty.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "NSKeyValueNestedProperty.h"

#import "NSKeyValueUnnestedProperty.h"
#import "NSKeyValueObservance.h"
#import <Foundation/NSNull.h>
#import <Foundation/NSKeyValueCoding.h>
#import <Foundation/NSString.h>

@interface NSKeyValueNestedProperty ()
@property (copy, nonatomic) NSString *relationshipKey;
@property (copy, nonatomic) NSString *keyPathFromRelatedObject;
@property (retain, nonatomic) NSKeyValueProperty *relationshipProperty;
@property (copy, nonatomic) NSString *keyPathWithoutOperatorComponents;
@property (assign, nonatomic) BOOL isAllowedToResultInForwarding;
@property (retain, nonatomic) id dependentValueKeyOrKeys; 
@property (assign, nonatomic) BOOL dependentValueKeyOrKeysIsASet; // TODO: this is dumb. Make it always a set.
@end

@implementation NSKeyValueNestedProperty

- (BOOL)matchesWithoutOperatorComponentsKeyPath:(NSString *)keyPath
{
    NSString *toCompare = self.keyPathWithoutOperatorComponents;
    if (toCompare == nil)
    {
        toCompare = self.keyPath;
    }
    return CFEqual(toCompare, keyPath);

}

- (id)dependentValueKeyOrKeysIsASet:(BOOL *)isASet
{
    *isASet = self.dependentValueKeyOrKeysIsASet;
    return self.dependentValueKeyOrKeys;
}

- (void)object:(NSObject *)object withObservance:(NSKeyValueObservance *)observance didChangeValueForKeyOrKeys:(id)keyOrKeys recurse:(BOOL)shouldRecurse forwardingValues:(NSKeyValueForwardingValues)forwardingValues
{
    if (self.isAllowedToResultInForwarding)
    {
        NSKeyValueObservingOptions newOptions;
        void *newContext = nil;
        if (observance.property == self)
        {
            newOptions = NSKeyValueObservingOptionNestedChain | observance.options;
        }
        else
        {
            newOptions = NSKeyValueObservingOptionNestedChain | NSKeyValueObservingOptionPrior;
            newContext = self;
        }
        NSObject *nextObject = nil;
        if (forwardingValues._field1 != [NSNull null])
        {
            nextObject = forwardingValues._field1;
        }
        NSKeyValueImplicitObservanceRemovalInfo *lastImplicitRemovalInfo = _NSKeyValueGetImplicitObservanceRemovalInfo();
        NSKeyValueImplicitObservanceRemovalInfo saved = *lastImplicitRemovalInfo;
        lastImplicitRemovalInfo->nextObject = nextObject;
        lastImplicitRemovalInfo->observingObservance = observance;
        lastImplicitRemovalInfo->keyPath = self.keyPathFromRelatedObject;
        lastImplicitRemovalInfo->originalObservable = object;
        lastImplicitRemovalInfo->isRecursing = YES;
        [nextObject removeObserver:observance forKeyPath:self.keyPathFromRelatedObject];
        *lastImplicitRemovalInfo = saved;

        NSKeyValueImplicitObservanceAdditionInfo *additionInfoPtr = _NSKeyValueGetImplicitObservanceAdditionInfo();
        NSKeyValueImplicitObservanceAdditionInfo savedAddtionInfo = *additionInfoPtr;
        additionInfoPtr->originalObservable = object;
        additionInfoPtr->observance = observance;
        NSObject *firstLevel = [object valueForKey:self.relationshipKey];
        [firstLevel addObserver:observance forKeyPath:self.keyPathFromRelatedObject options:newOptions context:newContext]; //this is the scariest line of code I think I've written yet
        *additionInfoPtr = savedAddtionInfo;
    }
    if (forwardingValues.recursedMutableDictionary != nil)
    {
        [self.relationshipProperty object:object withObservance:observance didChangeValueForKeyOrKeys:keyOrKeys recurse:shouldRecurse forwardingValues:forwardingValues];
    }
}

- (BOOL)object:(NSObject *)object withObservance:(NSKeyValueObservance *)observance willChangeValueForKeyOrKeys:(id)keyOrKeys recurse:(BOOL)shouldRecurse forwardingValues:(NSKeyValueForwardingValues *)forwardingValues
{
    NSKeyValueImplicitObservanceAdditionInfo *additionInfoPtr = _NSKeyValueGetImplicitObservanceAdditionInfo();
    if (additionInfoPtr->originalObservable == object && additionInfoPtr->observance == observance)
    {
        return NO;
    }
    forwardingValues->_field1 = nil;
    forwardingValues->recursedMutableDictionary = nil;
    if (self.isAllowedToResultInForwarding)
    {
        forwardingValues->_field1 = [object valueForKey:self.relationshipKey] ?: [NSNull null];
    }
    NSKeyValueForwardingValues tempValues = {0};
    if ([self.relationshipProperty object:object withObservance:observance willChangeValueForKeyOrKeys:keyOrKeys recurse:shouldRecurse forwardingValues:&tempValues])
    {
        forwardingValues->recursedMutableDictionary = tempValues.recursedMutableDictionary;
    }
    return YES;
}

- (void)object:(NSObject *)object didRemoveObservance:(NSKeyValueObservance *)observance recurse:(BOOL)shouldRecurse
{
    if (self.isAllowedToResultInForwarding)
    {
        NSObject *nextObject = [object valueForKey:self.relationshipKey];
        NSKeyValueImplicitObservanceRemovalInfo* lastImplicitRemovalInfo = _NSKeyValueGetImplicitObservanceRemovalInfo(); // load it.
        NSKeyValueImplicitObservanceRemovalInfo saved = *lastImplicitRemovalInfo; // save it.
        lastImplicitRemovalInfo->nextObject = nextObject; //quick-rewrite it.
        lastImplicitRemovalInfo->observingObservance = observance;
        lastImplicitRemovalInfo->keyPath = self.keyPathFromRelatedObject;
        lastImplicitRemovalInfo->originalObservable = object;
        lastImplicitRemovalInfo->isRecursing = YES;
        if ([observance.property isEqual:self])
        {
            lastImplicitRemovalInfo->property = nil; // prevent infinite loop
        }
        else
        {
            lastImplicitRemovalInfo->property = self;
        }
        [nextObject removeObserver:observance forKeyPath:self.keyPathFromRelatedObject];
        *lastImplicitRemovalInfo = saved;
    }
    [self.relationshipProperty object:object didRemoveObservance:observance recurse:shouldRecurse];
}

- (void)object:(NSObject *)object didAddObservance:(NSKeyValueObservance *)observance recurse:(BOOL)shouldRecurse
{
    if (self.isAllowedToResultInForwarding)
    {
        void *newContext = nil;
        NSKeyValueObservingOptions newOptions;
        if ([observance.property isEqual:self])
        {
            newOptions = observance.options | NSKeyValueObservingOptionNestedChain; // This hack is seriously wacky. 
        }
        else
        {
            newOptions = NSKeyValueObservingOptionNestedChain | NSKeyValueObservingOptionPrior;
            newContext = self;
        }
        NSKeyValueImplicitObservanceAdditionInfo *additionInfoPtr = _NSKeyValueGetImplicitObservanceAdditionInfo();
        NSKeyValueImplicitObservanceAdditionInfo saved = *additionInfoPtr;
        additionInfoPtr->originalObservable = object;
        additionInfoPtr->observance = observance;

        NSObject *nextObject = [object valueForKey:self.relationshipKey];
        [nextObject addObserver:observance forKeyPath:self.keyPathFromRelatedObject options:newOptions context:newContext];
        *additionInfoPtr = saved;
    }
    [self.relationshipProperty object:object didAddObservance:observance recurse:shouldRecurse];
}

- (NSString *)_keyPathIfAffectedByValueForMemberOfKeys:(NSSet *)keys
{
    if ([self.relationshipProperty keyPathIfAffectedByValueForMemberOfKeys:keys])
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
    if ([self.relationshipProperty keyPathIfAffectedByValueForKey:key exactMatch:NULL] != nil)
    {
        return self.keyPath;
    }
    return nil;
}

- (NSString *)keyPathIfAffectedByValueForMemberOfKeys:(NSSet *)keys
{
    return [self _keyPathIfAffectedByValueForMemberOfKeys:keys];
}

- (NSString *)keyPathIfAffectedByValueForKey:(NSString *)key exactMatch:(BOOL *)exactMatch
{
    return [self _keyPathIfAffectedByValueForKey:key exactMatch:exactMatch];
}

- (Class)isaForAutonotifying
{
    return [self _isaForAutonotifying];
}

- (Class)_isaForAutonotifying
{
    return [(NSKeyValueNestedProperty *)self.relationshipProperty _isaForAutonotifying]; //it's not always nested, but it always responds to _isaForAutonotifying
}

- (void)_addDependentValueKey:(NSString *)key
{
    if (self.dependentValueKeyOrKeys != nil)
    {
        if (self.dependentValueKeyOrKeysIsASet)
        {
            self.dependentValueKeyOrKeys = [self.dependentValueKeyOrKeys setByAddingObject:key];
        }
        else
        {
            self.dependentValueKeyOrKeys = [[[NSSet alloc] initWithObjects:self.dependentValueKeyOrKeys, key, nil] autorelease];
            self.dependentValueKeyOrKeysIsASet = YES;
        }
    }
    else
    {
        self.dependentValueKeyOrKeys = key;
    }
}

- (void)_givenPropertiesBeingInitialized:(CFMutableSetRef)propertiesBeingInitialized getAffectingProperties:(NSMutableArray *)toBeFilled
{
    [(NSKeyValueNestedProperty *)self.relationshipProperty _givenPropertiesBeingInitialized:propertiesBeingInitialized getAffectingProperties:toBeFilled]; //same as _isaForAutonotifying 
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: Container Class: %@, Relationship Property: %@, Key Path From Related Object:%@>", 
        [self class], 
        self.containerClass, 
        self.relationshipProperty, 
        self.keyPathFromRelatedObject];
}

- (void)dealloc
{
    [_dependentValueKeyOrKeys release];
    [_keyPathWithoutOperatorComponents release];
    [_relationshipProperty release];
    [_keyPathFromRelatedObject release];
    [_relationshipKey release];
    [super dealloc];
}

- (instancetype)_initWithContainerClass:(NSKeyValueContainerClass *)containerClass keyPath:(NSString *)keyPath firstDotIndex:(NSUInteger)firstDotIndex propertiesBeingInitialized:(CFMutableSetRef)propertiesBeingInitialized
{
    self = [super _initWithContainerClass:containerClass keyPath:keyPath propertiesBeingInitialized:propertiesBeingInitialized];
    if (self != nil)
    {
        self.relationshipKey = [keyPath substringToIndex:firstDotIndex];
        self.keyPathFromRelatedObject = [keyPath substringFromIndex:firstDotIndex+1];
        self.relationshipProperty = _NSKeyValuePropertyForIsaAndKeyPathInner(self.containerClass.originalClass, self.relationshipKey, propertiesBeingInitialized); 
        NSRange dotAt = [keyPath rangeOfString:@".@"]; // this looks like a bug. Seems like it should check for a starting @ as well.
                                                    // seems like it would also miss multiple operations in a keypath as well. 
        if (dotAt.length != 0)
        {
            NSString *prePath = [keyPath substringToIndex:dotAt.location];
            NSUInteger keyPathLength = [keyPath length];
            NSUInteger exclude = dotAt.location+dotAt.length;
            NSRange dot = [keyPath rangeOfString:@"." options:0 range:NSMakeRange(exclude, keyPathLength-exclude)];
            if (dot.length != 0)
            {
                NSString *postPath = [keyPath substringFromIndex:dot.location];
                self.keyPathWithoutOperatorComponents = [prePath stringByAppendingString:postPath];
            }
            else
            {
                self.keyPathWithoutOperatorComponents = prePath;
            }
        }
        _isAllowedToResultInForwarding = YES;
        if ([self.keyPathFromRelatedObject hasPrefix:@"@"] && [self.keyPathFromRelatedObject rangeOfString:@"."].location == NSNotFound)
        {
            self.isAllowedToResultInForwarding = NO;
        }
    }
    return self;
}

@end
