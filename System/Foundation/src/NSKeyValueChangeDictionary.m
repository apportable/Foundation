//
//  NSKeyValueChangeDictionary.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "NSKeyValueChangeDictionary.h"
#import <Foundation/NSArray.h>
#import <Foundation/NSValue.h>
#import <Foundation/NSIndexSet.h>
#import "NSObjectInternal.h"
#import <CoreFoundation/CFNumber.h>
#include <string.h>

// *** FIXME *** move these constants to NSKeyValueObserving.m
NSString * const NSKeyValueChangeKindKey = @"kind";
NSString * const NSKeyValueChangeNewKey = @"new";
NSString * const NSKeyValueChangeOldKey = @"old";
NSString * const NSKeyValueChangeIndexesKey = @"indexes";
NSString * const NSKeyValueChangeOriginalObservableKey = @"originalObservable";
NSString * const NSKeyValueChangeNotificationIsPriorKey = @"notificationIsPrior";

@implementation NSKeyValueChangeDictionary

NSNumber *NSKeyValueChangeDictionaryNumberWithKind(NSKeyValueChangeDetails details);

- (id)initWithDetailsNoCopy:(NSKeyValueChangeDetails)details originalObservable:(id)observable isPriorNotification:(BOOL)yn
{
    self = [super init];
    if (self != nil)
    {
        _details = details;
        _originalObservable = observable;
        _isPriorNotification = yn;
    }
    return self;
}

- (id)keyEnumerator
{
    NSString *keys[6] = {NULL};
    keys[0] = NSKeyValueChangeKindKey;
    int count = 1;
    if (_details.oldValue != nil)
    {
        keys[count] = NSKeyValueChangeOldKey;
        count++;
    }
    if (_details.newValue != nil)
    {
        keys[count] = NSKeyValueChangeNewKey;
        count++;
    }
    if (_details.indexes != nil)
    {
        keys[count] = NSKeyValueChangeIndexesKey;
        count++;
    }
    if (_originalObservable != nil)
    {
        keys[count] = NSKeyValueChangeOriginalObservableKey;
        count++;
    }
    if (_isPriorNotification)
    {
        keys[count] = NSKeyValueChangeNotificationIsPriorKey;
        count++;
    }
    NSArray *enumeratorGenerator = [[NSArray alloc] initWithObjects:keys count:count];
    NSEnumerator *enumerator = [enumeratorGenerator objectEnumerator];
    [enumeratorGenerator release];
    return enumerator;
}

- (id)objectForKey:(id)key
{
    if (![key isNSString__])
    {
        return nil;
    }

    if ([(NSString *)key isEqualToString:NSKeyValueChangeKindKey])
    {
        return [[[NSNumber alloc] initWithUnsignedInt:_details.kind] autorelease];
    }
    if ([(NSString *)key isEqualToString:NSKeyValueChangeOldKey])
    {
        return _details.oldValue;
    }
    if ([(NSString *)key isEqualToString:NSKeyValueChangeNewKey])
    {
        return _details.newValue;
    }
    if ([(NSString *)key isEqualToString:NSKeyValueChangeIndexesKey])
    {
        return _details.indexes;
    }
    if ([(NSString *)key isEqualToString:NSKeyValueChangeOriginalObservableKey])
    {
        return _originalObservable;
    }
    if ([(NSString *)key isEqualToString:NSKeyValueChangeNotificationIsPriorKey])
    {
        return _isPriorNotification ? (id)kCFBooleanTrue : nil; // *shrug*
    }

    return nil;
}

- (NSUInteger)count
{
    return (_isPriorNotification ? 1 : 0) + (_originalObservable ? 1 : 0) + (_details.indexes ? 1 : 0) + (_details.newValue ? 1 : 0) + (_details.oldValue ? 1 : 0) + 1;
}
- (void)dealloc
{
    if (_isRetainingObjects)
    {
        [_details.oldValue release];
        [_details.newValue release];
        [_details.indexes release];
        [_originalObservable release];
        _isRetainingObjects = NO;
    }
    [super dealloc];
}
- (void)retainObjects
{
    if (!_isRetainingObjects)
    {
        [_details.oldValue retain];
        [_details.newValue retain];
        [_details.indexes retain];
        [_originalObservable retain];
        _isRetainingObjects = YES;
    }
}
- (void)setOriginalObservable:(id)observable
{
    if (observable == _originalObservable)
    {
        return;
    }
    if (_isRetainingObjects)
    {
        [observable retain];
        [_originalObservable release];
    }
    _originalObservable = observable;
}
- (void)setDetailsNoCopy:(NSKeyValueChangeDetails)details originalObservable:(id)observable
{
    if (_isRetainingObjects)
    {
        [_details.oldValue release];
        [_details.newValue release];
        [_details.indexes release];
        [_originalObservable release];
        _isRetainingObjects = NO;
    }
    _details = details;
    _originalObservable = observable;
}

@end
