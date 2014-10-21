//
//  NSKeyValueProperty.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "NSKeyValueProperty.h"

#import <Foundation/NSString.h>

@implementation NSKeyValueProperty

- (instancetype)_initWithContainerClass:(NSKeyValueContainerClass *)containerClass keyPath:(NSString *)key propertiesBeingInitialized:(CFMutableSetRef)properties
{
    self = [super init];
    if (self != nil)
    {
        self.containerClass = containerClass;
        self.keyPath = key;
        CFSetAddValue(properties, self);
    }
    return self;
}

- (void)dealloc
{
    [_containerClass release];
    [_keyPath release];
    [super dealloc];
}

- (NSString *)restOfKeyPathIfContainedByValueForKeyPath:(NSString *)keyPath
{
    if (self.keyPath == keyPath || CFEqual(self.keyPath, keyPath))
    {
        return @"";
    }
    if (![self.keyPath hasPrefix:keyPath] || [self.keyPath characterAtIndex:keyPath.length] != '.')
    {
        return nil;
    }
    return [self.keyPath substringFromIndex:keyPath.length + 1];
}

- (Class)isaForAutonotifying
{
    return Nil; //TODO: this MUST be overridden
}
- (BOOL)matchesWithoutOperatorComponentsKeyPath:(id)keyPath
{
    return NO; //overridden in subclasses
}
- (id)dependentValueKeyOrKeysIsASet:(BOOL *)isASet
{
    return nil; // overridden in subclasses
}
- (void)object:(id)object withObservance:(id)observance didChangeValueForKeyOrKeys:(id)keyOrKeys recurse:(BOOL)shouldRecurse forwardingValues:(NSKeyValueForwardingValues)forwardingValues
{
    return; // overridden in subclasses
}
- (BOOL)object:(NSObject *)object withObservance:(NSKeyValueObservance *)observance willChangeValueForKeyOrKeys:(id)keyOrKeys recurse:(BOOL)shouldRecurse forwardingValues:(NSKeyValueForwardingValues *)forwardingValues
{
    if (forwardingValues != nil)
    {
        forwardingValues->_field1 = nil;
        forwardingValues->recursedMutableDictionary = nil;
    }
    return YES; // TODO: see if we can get a better implementation here.
}
- (void)object:(id)object didRemoveObservance:(id)observance recurse:(BOOL)recurse
{
    return; //overridden in subclasses
}
- (void)object:(NSObject *)observable didAddObservance:(NSKeyValueObservance *)observance recurse:(BOOL)shouldRecurse
{
    return; //overridden in subclasses
}
- (NSString *)keyPathIfAffectedByValueForMemberOfKeys:(NSSet *)keys
{
    return nil; // TODO: this MUST be overridden
}
- (NSString *)keyPathIfAffectedByValueForKey:(NSString *)key exactMatch:(BOOL *)exactMatch
{
    return nil; // TODO: this MUST be overridden
}
- (id)copyWithZone:(NSZone *)zone
{
    return [self retain];
}

@end
