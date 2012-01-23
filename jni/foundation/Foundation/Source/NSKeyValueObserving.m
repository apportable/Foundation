//
//  NSKeyValueObserving.m
//  Foundation
//
//  Created by Philippe Hausler on 12/31/11.
//

#import "GNUstepBase/GSObjCRuntime.h"
#import "Foundation/NSObject.h"
#import "Foundation/NSException.h"
#import "Foundation/NSDictionary.h"
#import "Foundation/NSSet.h"
#import "Foundation/NSString.h"
#import "Foundation/NSKeyValueObserving.h"
#import "Foundation/NSValue.h"
#import <objc/runtime.h>

NSString *const NSKeyValueChangeKindKey = @"kind";
NSString *const NSKeyValueChangeNewKey = @"new";
NSString *const NSKeyValueChangeOldKey = @"old";
NSString *const NSKeyValueChangeIndexesKey = @"indexes";
NSString *const NSKeyValueChangeNotificationIsPriorKey = @"prior";

static const void *NSKVOObserversKey = "NSKVOObserversKey";

@interface _NSKVOObserver : NSObject {
    NSObject *_observer;
    NSString *_keyPath;
    NSKeyValueObservingOptions _options;
    void *_context;
    NSObject *_subject;
    id _pvalue;
}
@property (nonatomic, readonly) NSObject *observer;
@property (nonatomic, readonly) NSString *keyPath;
@property (nonatomic, readonly) NSKeyValueObservingOptions options;
@property (nonatomic, readonly) void *context;
@property (nonatomic, readonly) NSObject *subject;
- (id)initWithObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context object:(NSObject *)subject;
- (id)initWithObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(void *)context object:(NSObject *)subject;
- (void)willChangeValueForKey:(NSString *)key;
- (void)didChangeValueForKey:(NSString *)key;
- (void)notify:(NSKeyValueObservingOptions)kind;
@end

@implementation _NSKVOObserver

@synthesize observer = _observer;
@synthesize keyPath = _keyPath;
@synthesize options = _options;
@synthesize context = _context;
@synthesize subject = _subject;

- (id)initWithObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context object:(NSObject *)subject
{
    self = [super init];
    _observer = observer;
    _keyPath = [keyPath copy];
    _options = options;
    _context = context;
    _subject = subject;
    _pvalue = NULL;
    return self;
}

- (id)initWithObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(void *)context object:(NSObject *)subject
{
    self = [super init];
    _observer = observer;
    _keyPath = [keyPath copy];
    _context = context;
    _subject = subject;
    _pvalue = NULL;
    return self;
}

- (NSUInteger)hash
{
    return [_observer hash] ^ [_keyPath hash] ^ [_subject hash];
}

- (BOOL)isEqual:(id)object
{
    if([object isKindOfClass:[_NSKVOObserver class]])
    {
        return self.observer == [object observer] && self.subject == [object subject] && [self.keyPath isEqualToString:[object keyPath]];
    }
    return NO;
}

- (void)notify:(NSKeyValueObservingOptions)kind
{
    NSMutableDictionary *change = [NSMutableDictionary dictionary];
    if(self.options & NSKeyValueObservingOptionNew)
        [change setObject:[self.subject valueForKey:self.keyPath] forKey:NSKeyValueChangeNewKey];
    if(self.options & NSKeyValueObservingOptionOld)
        [change setObject:_pvalue forKey:NSKeyValueChangeOldKey];
    [change setObject:[NSNumber numberWithUnsignedInteger:kind] forKey:NSKeyValueChangeKindKey];
    [self.observer observeValueForKeyPath:self.keyPath ofObject:self.subject change:change context:self.context];
}

- (void)willChangeValueForKey:(NSString *)key
{
    if(self.options & NSKeyValueObservingOptionPrior)
        [self notify:NSKeyValueObservingOptionPrior];
    _pvalue = [[self.subject valueForKey:key] retain];
}

- (void)didChangeValueForKey:(NSString *)key
{
    if(self.options != 0)
        [self notify:NSKeyValueObservingOptionNew];
    [_pvalue release];
    _pvalue = NULL;
}

@end

@implementation NSObject (LameKVO)

- (void)addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context
{
    NSAssert(keyPath != NULL, @"Invalid observation, path cannot be NULL");
    NSArray *comps = [keyPath componentsSeparatedByString:@"."];
    if([comps count] > 1)
    {
        NSObject *target = [self valueForKey:[comps objectAtIndex:0]];
        if(target != NULL)
        {
            NSString *subPath = [[comps subarrayWithRange:NSMakeRange(1, [comps count] - 1)] componentsJoinedByString:@"."];
            [target addObserver:observer forKeyPath:subPath options:options context:context];
        }
        else
        {
            NSAssert(target != NULL, @"Pending observers not yet supported");
        }
    }
    else
    {
        NSMutableDictionary *NSKVOObservers = objc_getAssociatedObject(self, NSKVOObserversKey);
        if(NSKVOObservers == NULL)
        {
            NSKVOObservers = [[NSMutableDictionary alloc] init];
            objc_setAssociatedObject(self, NSKVOObserversKey, NSKVOObservers, OBJC_ASSOCIATION_RETAIN);
            [NSKVOObservers release];
        }
        NSMutableSet *observers = [NSKVOObservers objectForKey:keyPath];
        if(observers == NULL)
        {
            observers = [NSMutableSet set];
            [NSKVOObservers setObject:observers forKey:keyPath];
        }
        _NSKVOObserver *watcher = [[_NSKVOObserver alloc] initWithObserver:observer forKeyPath:keyPath options:options context:context object:self];
        [observers addObject:watcher];
        if(watcher.options & NSKeyValueObservingOptionInitial)
            [watcher notify:NSKeyValueObservingOptionInitial];
        [watcher release];
    }
}

- (void)removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(void *)context
{
    NSArray *comps = [keyPath componentsSeparatedByString:@"."];
    if([comps count] > 1)
    {
        NSObject *target = [self valueForKey:[comps objectAtIndex:0]];
        if(target != NULL)
        {
            NSString *subPath = [[comps subarrayWithRange:NSMakeRange(1, [comps count] - 1)] componentsJoinedByString:@"."];
            [target removeObserver:observer forKeyPath:subPath context:context];
        }
    }
    else
    {
        NSMutableDictionary *NSKVOObservers = objc_getAssociatedObject(self, NSKVOObserversKey);
        if(NSKVOObservers == NULL)
        {
            NSKVOObservers = [[NSMutableDictionary alloc] init];
            objc_setAssociatedObject(self, NSKVOObserversKey, NSKVOObservers, OBJC_ASSOCIATION_RETAIN);
            [NSKVOObservers release];
        }
        NSMutableSet *observers = [NSKVOObservers objectForKey:keyPath];
        _NSKVOObserver *watcher = [[_NSKVOObserver alloc] initWithObserver:observer forKeyPath:keyPath context:context object:self];
        _NSKVOObserver *member = [observers member:watcher];
        if(member)
            [observers removeObject:member];
        [watcher release];
    }
}

- (void)removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath
{
    [self removeObserver:observer forKeyPath:keyPath context:NULL];
}

- (void)willChangeValueForKey:(NSString *)key
{
    NSMutableDictionary *NSKVOObservers = objc_getAssociatedObject(self, NSKVOObserversKey);
    if(NSKVOObservers)
    {
        NSMutableSet *observers = [NSKVOObservers objectForKey:key];
        if(observers)
            [observers makeObjectsPerformSelector:@selector(willChangeValueForKey:) withObject:key];
    }
}

- (void)didChangeValueForKey:(NSString *)key
{
    NSMutableDictionary *NSKVOObservers = objc_getAssociatedObject(self, NSKVOObserversKey);
    if(NSKVOObservers)
    {
        NSMutableSet *observers = [NSKVOObservers objectForKey:key];
        if(observers)
            [observers makeObjectsPerformSelector:@selector(didChangeValueForKey:) withObject:key];
    }
}
@end