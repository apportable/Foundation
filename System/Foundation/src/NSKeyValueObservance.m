//
//  NSKeyValueObservance.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "NSKeyValueObservance.h"
#import "NSKeyValueAccessor.h"
#import <Foundation/NSString.h>
#import "NSKeyValueProperty.h"

@implementation NSKeyValueObservance
- (instancetype)initWithObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath ofObject:(NSObject *)object withContext:(void *)context options:(NSKeyValueObservingOptions)options
{
    self = [super init];
    if (self != nil)
    {
        self.observer = observer;
        self.keyPath = keyPath;
        self.originalObservable = object;
        self.context = context;
        self.options = options & ~NSKeyValueObservingOptionInitial; //remove initial
    }
    return self;
}

- (instancetype)initWithObserver:(NSObject *)observer forProperty:(NSKeyValueProperty *)property ofObject:(NSObject *)object context:(void *)context options:(NSKeyValueObservingOptions)options
{
    self = [super init];
    if (self != nil)
    {
        self.observer = observer;
        self.property = property;
        self.originalObservable = object;
        self.context = context;
        self.options = options & ~NSKeyValueObservingOptionInitial;
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@ %p: Observer: %p, Key path: %@, Options: <New:%@, Old: %@, Prior:%@> Context: %p Property: %p>\n", 
        [self class], 
        self, 
        self.observer, 
        self.keyPath, 
        self.options & NSKeyValueObservingOptionNew ? @"YES" : @"NO",
        self.options & NSKeyValueObservingOptionOld ? @"YES" : @"NO",
        self.options & NSKeyValueObservingOptionPrior ? @"YES" : @"NO",
        self.context,
        self.property];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSObject *originalObservable = change[NSKeyValueChangeOriginalObservableKey];
    if (originalObservable != nil)
    {
        BOOL isASet;
        NSDictionary *dictToPass = change;
        if (context != NULL)
        {
            NSKeyValueProperty *ctxProperty = (NSKeyValueProperty *)context;
            id dependentValueKeyOrKeys = [ctxProperty dependentValueKeyOrKeysIsASet:&isASet];
            if ([change[NSKeyValueChangeNotificationIsPriorKey] boolValue])
            {
                _NSKeyValueWillChangeForObservance(originalObservable, dependentValueKeyOrKeys, isASet, self);
            }
            else
            {
                _NSKeyValueDidChangeForObservance(originalObservable, dependentValueKeyOrKeys, isASet, self);
            }
        }
        else
        {
            if ([change isKindOfClass:[NSKeyValueChangeDictionary class]])
            {
                [(NSKeyValueChangeDictionary *)change setOriginalObservable:self.originalObservable];
            }
            else
            {
                NSMutableDictionary *mutableChange = [change mutableCopy];
                if (self.originalObservable != nil)
                {
                    mutableChange[NSKeyValueChangeOriginalObservableKey] = self.originalObservable;
                }
                else
                {
                    [mutableChange removeObjectForKey:NSKeyValueChangeOriginalObservableKey];
                }
                dictToPass = mutableChange;
            }
            [self.observer observeValueForKeyPath:self.property.keyPath ofObject:originalObservable change:dictToPass context:self.context];
            if (change != dictToPass)
            {
                [dictToPass release];
            }
        }
    }
}

- (void)dealloc
{
    [_setter release];
    [_keyPath release];
    [_property release];
    [super dealloc];
}

@end
