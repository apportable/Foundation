//
//  NSKVOTests.m
//  FoundationTests
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "FoundationTests.h"
#import <objc/runtime.h>

@interface Observer : NSObject
@end

@implementation Observer
{
    NSMutableDictionary *_observationCounts;
    NSMutableSet *_priorNotificationValues;
    void (^_block)(Observer* observer, NSString* string, id object, NSDictionary* change);
}

+ (instancetype)observer
{
    return [[[self alloc] init] autorelease];
}

+ (instancetype)observerWithBlock:(void (^)(Observer* observer, NSString* string, id object, NSDictionary* change))block
{
    return [[(Observer*)[self alloc] initWithBlock:block] autorelease];
}

- (id)initWithBlock:(void (^)(Observer* observer, NSString* string, id object, NSDictionary* change))block
{
    if ((self = [self init]))
    {
        _block = [block copy];
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        _observationCounts = [[NSMutableDictionary alloc] init];
        _priorNotificationValues = [[NSMutableSet alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [_observationCounts release];
    [_priorNotificationValues release];
    [_block release];
    
    [super dealloc];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSNumber *count = [_observationCounts objectForKey:keyPath];
    if (count == nil)
    {
        count = @(0);
    }
    [_observationCounts setObject:@([count integerValue] + 1) forKey:keyPath];

    if ([change objectForKey:NSKeyValueChangeNotificationIsPriorKey] != nil)
    {
        [_priorNotificationValues addObject:keyPath];
    }
    
    if (_block)
    {
        _block(self, keyPath, object, change);
    }
}

- (NSUInteger)observationCountForKeyPath:(NSString *)keyPath
{
    NSNumber *count = [_observationCounts objectForKey:keyPath];
    if (count == nil)
    {
        count = @(0);
    }

    return [count unsignedIntegerValue];
}

- (BOOL)priorObservationMadeForKeyPath:(NSString *)keyPath
{
    return [_priorNotificationValues containsObject:keyPath];
}

@end

@interface Observable : NSObject {
    int _anInt;
}
@property int anInt;
@end

@implementation Observable
@synthesize anInt=_anInt;
+ (instancetype)observable
{
    return [[[self alloc] init] autorelease];
}
@end

@interface ReallyBadObservable : Observable
@end

@implementation ReallyBadObservable
- (void)setAnInt:(int)anInt
{
    _anInt = anInt;
}
+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key
{
    return NO;
}
@end

@interface BadObservable : Observable
@end

@implementation BadObservable
- (void)setAnInt:(int)anInt
{
    _anInt = anInt;
    [self didChangeValueForKey:@"anInt"];
}
@end

@interface DependentObservable : Observable
@property (readonly) float aFloat;
@end

@implementation DependentObservable
- (float)aFloat
{
    return _anInt;
}

- (void)setAFloat:(float)aFloat
{
    _anInt = aFloat;
}

+ (NSSet *)keyPathsForValuesAffectingAFloat
{
    return [NSSet setWithObject:@"anInt"];
}
@end

@interface ManualDepedentObservable : Observable
@property (readonly) NSString *stringOfAnInt;
@end

@implementation ManualDepedentObservable

- (void)setAnInt:(int)anInt
{
    [self willChangeValueForKey:@"anInt"];
    [self willChangeValueForKey:@"stringOfAnInt"];
    
    _anInt = anInt;
    
    [self didChangeValueForKey:@"anInt"];
    [self didChangeValueForKey:@"stringOfAnInt"];
}

- (NSString *)stringOfAnInt
{
    return [NSString stringWithFormat:@"%d", _anInt];
}

+ (BOOL)automaticallyNotifiesObserversOfAnInt
{
    return NO;
}

@end

@interface NestedObservable : Observable
@property (nonatomic, strong) NestedObservable *nested;
@end
@implementation NestedObservable
@end

@interface NameClass : NSObject
@property (nonatomic, copy) NSString *firstName;
@property (nonatomic, copy) NSString *lastName;
@end

@implementation NameClass
@end

@interface NestedDependentObservable : Observable
@property (nonatomic, copy) NSString *fullName;
@property (nonatomic, strong) NameClass *nameObject;
@end

@implementation NestedDependentObservable
+ (NSSet *)keyPathsForValuesAffectingFullName
{
    return [NSSet setWithObjects:@"nameObject.firstName", @"nameObject.lastName", nil];
}
@end

// -----------------------------

@interface ObjectWithInternalObserver : NSObject
@end

@implementation ObjectWithInternalObserver {
    NSObject *_internal;
}

- (id)init
{
    self = [super init];
    if (self) {
        _internal = [[NSObject alloc] init];
        [self addObserver:_internal
               forKeyPath:@"fooKeyPath"
                  options:(NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew)
                  context:NULL];
        [self addObserver:_internal
               forKeyPath:@"barKeyPath"
                  options:(NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew)
                  context:NULL];
    }
    return self;
}

- (void)dealloc
{
    [self removeObserver:_internal forKeyPath:@"barKeyPath"];
    [self removeObserver:_internal forKeyPath:@"fooKeyPath"];
    [_internal release];
    _internal = nil;
    [super dealloc];
}

@end

@testcase(NSKVO)

#define OBSERVER_PROLOGUE(_Observable, _keyPath, _options, _context) \
    @autoreleasepool { \
        NSString *keyPath = (_keyPath); \
        Observer *observer = [Observer observer]; \
        _Observable *observable = [_Observable observable];               \
        [observable addObserver:observer forKeyPath:keyPath options:(_options) context:(_context)]; \
        BOOL result = YES;

#define OBSERVER_EPILOGUE() \
        [observable removeObserver:observer forKeyPath:keyPath]; \
        return result; \
    }

test(BasicNotifyingInstanceCharacteristics)
{
    @autoreleasepool
    {
        Observable *observable = [Observable observable];
        Observer *observer = [Observer observer];
        Class originalObservableClass = object_getClass(observable);
        IMP originalClassIMP = class_getMethodImplementation(originalObservableClass, @selector(class));
        IMP originalDeallocIMP = class_getMethodImplementation(originalObservableClass, @selector(dealloc));
        IMP original_isKVOAIMP = class_getMethodImplementation(originalObservableClass, @selector(_isKVOA)); // this should be NULL.
        IMP originalSetterIMP = class_getMethodImplementation(originalObservableClass, @selector(setAnInt:));
        id originalObservationInfo = [observable observationInfo];
        [observable addObserver:observer forKeyPath:@"anInt" options:0 context:NULL];
        id notifyingObservationInfo = [observable observationInfo];
        Class notifyingObservableClass = object_getClass(observable);
        IMP notifyingClassIMP = class_getMethodImplementation(notifyingObservableClass, @selector(class));
        IMP notifyingDeallocIMP = class_getMethodImplementation(notifyingObservableClass, @selector(dealloc));
        IMP notifying_isKVOAIMP = class_getMethodImplementation(notifyingObservableClass, @selector(_isKVOA));
        IMP notifyingSetterIMP = class_getMethodImplementation(notifyingObservableClass, @selector(setAnInt:));
        testassert([observable class] == [Observable class]);
        testassert(object_getClass(observable) == NSClassFromString(@"NSKVONotifying_Observable"));
        testassert([observable class] != object_getClass(observable));
        testassert(originalObservableClass != notifyingObservableClass);
        testassert(originalClassIMP != notifyingClassIMP);
        testassert(originalDeallocIMP != notifyingDeallocIMP);
        testassert(original_isKVOAIMP != notifying_isKVOAIMP);
        testassert(originalSetterIMP != notifyingSetterIMP);
        testassert(originalObservationInfo != notifyingObservationInfo);
        [observable removeObserver:observer forKeyPath:@"anInt"];
        id postRemoveObservationInfo = [observable observationInfo];
        testassert(originalObservableClass == object_getClass(observable));
        testassert(postRemoveObservationInfo == originalObservationInfo);
        return YES;
    }
}

test(ZeroObservances)
{
    OBSERVER_PROLOGUE(Observable, @"anInt", 0, NULL);

    testassert([observer observationCountForKeyPath:keyPath] == 0);

    OBSERVER_EPILOGUE();
}

test(SingleObservance)
{
    OBSERVER_PROLOGUE(Observable, @"anInt", 0, NULL);

    [observable setAnInt:42];

    testassert([observer observationCountForKeyPath:keyPath] == 1);

    OBSERVER_EPILOGUE();
}

test(ManyObservances)
{
    static const NSUInteger iterations = 10;

    OBSERVER_PROLOGUE(Observable, @"anInt", 0, NULL);

    for (NSUInteger i = 0; i < iterations; i++)
    {
        [observable setAnInt:i];
    }

    testassert([observer observationCountForKeyPath:keyPath] == iterations);

    OBSERVER_EPILOGUE();
}

test(ManyObservers)
{
    @autoreleasepool
    {
        Observable *observable = [Observable observable];
        NSString *keyPath = @"anInt";
        
        NSMutableArray *observers = [NSMutableArray array];
        
        for (int i=0; i<5; ++i)
        {
            Observer *observer = [Observer observer];
            [observers addObject:observer];
            [observable addObserver:observer forKeyPath:keyPath options:0 context:NULL];
        }
        
        [observable setAnInt:42];
        
        for (Observer *observer in observers)
        {
            [observable removeObserver:observer forKeyPath:keyPath];
        }
        
        // testassert after removeObserver to avoid false negative in other tests
        // in the case this test fails.
        for (Observer *observer in observers)
        {
            testassert([observer observationCountForKeyPath:keyPath] == 1);
        }
        
        return YES;
    }
}

test(ManyObserversOrdering)
{
    @autoreleasepool
    {
        Observable *observable = [Observable observable];
        NSString *keyPath = @"anInt";
        
        NSMutableArray *observers = [NSMutableArray array];
        __block NSMutableArray *observersFired = [NSMutableArray array];
        
        for (int i=0; i<5; ++i)
        {
            Observer *observer = [Observer observerWithBlock:
                ^(Observer* observer, NSString* string, id object, NSDictionary* change) {
                    [observersFired addObject:observer];
                }
            ];
            [observers addObject:observer];
            [observable addObserver:observer forKeyPath:keyPath options:0 context:NULL];
        }

        [observable setAnInt:42];
        
        for (Observer *observer in observers)
        {
            [observable removeObserver:observer forKeyPath:keyPath];
        }
        
        NSArray *reversedObservers = [[observers reverseObjectEnumerator] allObjects];
        testassert([reversedObservers isEqualToArray:observersFired]);
        
        return YES;
    }
}

test(RemoveObserverOnChange)
{
    @autoreleasepool
    {
        Observable *observable = [Observable observable];
        NSString *keyPath = @"anInt";
        
        __block BOOL didRelease = NO;
        __block BOOL didDealloc = NO;
        
        Observer *badObserver = [[Observer alloc] initWithBlock:
            ^(Observer *observer, NSString *string, id object, NSDictionary *change) {
                [observable removeObserver:observer forKeyPath:keyPath];
                int retainCount = [observer retainCount];
                [observer release];
                didRelease = YES;
                didDealloc = retainCount == 1;
            }
        ];
        [observable addObserver:badObserver forKeyPath:keyPath options:0 context:NULL];
        
        [observable setAnInt:42];
        
        testassert(didRelease == YES);
        // Observer should be retained within NSKeyValuePushPendingNotificationPerThread and
        // released (and dealloced) within NSKeyValuePopPendingNotificationPerThread.
        testassert(didDealloc == NO);
        
        return YES;
    }
}

test(ChangeOnChangeObserver)
{
    @autoreleasepool
    {
        Observable *observable = [Observable observable];
        NSString *keyPath = @"anInt";
        
        NSMutableArray *observedChanges = [NSMutableArray array];
        
        Observer *observer = [[Observer alloc] initWithBlock:
            ^(Observer *observer, NSString *string, id object, NSDictionary *change) {
                [observedChanges addObject:@">>"];
                [observedChanges addObject:@([object anInt])];
                if ([object anInt] != 2)
                    [object setAnInt:2];
                [observedChanges addObject:@"<<"];
            }
        ];
        [observable addObserver:observer forKeyPath:keyPath options:0 context:NULL];
        
        [observable setAnInt:1];
        
        [observable removeObserver:observer forKeyPath:keyPath];
        
        testassert([observedChanges isEqualToArray:@[@">>", @(1), @">>", @(2), @"<<", @"<<"]]);
        
        return YES;
    }
}

test(AutomaticDependantKeyChangeObserver)
{
    @autoreleasepool
    {
        DependentObservable *observable = [DependentObservable observable];
        NSString *anIntKeyPath = @"anInt";
        NSString *aFloatKeyPath = @"aFloat";
        
        NSMutableArray *observedChanges = [NSMutableArray array];
        
        Observer *observer = [[Observer alloc] initWithBlock:
            ^(Observer *observer, NSString *keyPath, id object, NSDictionary *change) {
                static int recursion = 0;
                ++recursion;
                
                BOOL isPrior = [change valueForKey:NSKeyValueChangeNotificationIsPriorKey] != nil;
                
                if (isPrior) {
                    [observedChanges addObject:[NSString stringWithFormat:@"%d willChange %@ %@", recursion, keyPath, [object valueForKey:keyPath]]];
                }
                
                if (!isPrior && [keyPath isEqualToString:anIntKeyPath]) {
                    if ([object anInt] != 42)
                        [object setAnInt:42];
                }
                
                if (!isPrior) {
                    [observedChanges addObject:[NSString stringWithFormat:@"%d didChange %@ %@", recursion, keyPath, [object valueForKey:keyPath]]];
                }
                
                --recursion;
            }
        ];
        
        [observable addObserver:observer forKeyPath:anIntKeyPath options:NSKeyValueObservingOptionPrior context:NULL];
        [observable addObserver:observer forKeyPath:aFloatKeyPath options:NSKeyValueObservingOptionPrior context:NULL];
        
        [observable setAnInt:1];
        
        [observable removeObserver:observer forKeyPath:anIntKeyPath];
        [observable removeObserver:observer forKeyPath:aFloatKeyPath];
        
        testassert([observedChanges isEqualToArray:@[
             @"1 willChange anInt 0",
#ifdef APPORTABLE
#warning TODO - Remove me when NSNunmber is fixed.
             @"1 willChange aFloat 0.0",
#else
             @"1 willChange aFloat 0",
#endif
             @"1 didChange aFloat 1",
             @"2 willChange anInt 1",
             @"2 willChange aFloat 1",
             @"2 didChange aFloat 42",
             @"2 didChange anInt 42",
             @"1 didChange anInt 42"
        ]]);
        
        return YES;
    }
}

test(ManualDepedentKeyChangeObserver)
{
    @autoreleasepool
    {
        ManualDepedentObservable *observable = [ManualDepedentObservable observable];
        NSString *anIntKeyPath = @"anInt";
        NSString *stringOfAnIntKeyPath = @"stringOfAnInt";
        
        NSMutableArray *observedChanges = [NSMutableArray array];
        
        Observer *observer = [[Observer alloc] initWithBlock:
            ^(Observer *observer, NSString *keyPath, id object, NSDictionary *change) {
                static int recursion = 0;
                ++recursion;
                
                BOOL isPrior = [change valueForKey:NSKeyValueChangeNotificationIsPriorKey] != nil;
                
                if (isPrior) {
                    [observedChanges addObject:[NSString stringWithFormat:@"%d willChange %@ %@", recursion, keyPath, [object valueForKey:keyPath]]];
                }
                
                if (!isPrior && [keyPath isEqualToString:anIntKeyPath]) {
                    if ([object anInt] != 42)
                        [object setAnInt:42];
                }
                
                if (!isPrior) {
                    [observedChanges addObject:[NSString stringWithFormat:@"%d didChange %@ %@", recursion, keyPath, [object valueForKey:keyPath]]];
                }
                
                --recursion;
            }
        ];
        
        [observable addObserver:observer forKeyPath:anIntKeyPath options:NSKeyValueObservingOptionPrior context:NULL];
        [observable addObserver:observer forKeyPath:stringOfAnIntKeyPath options:NSKeyValueObservingOptionPrior context:NULL];
        
        [observable setAnInt:1];
        
        [observable removeObserver:observer forKeyPath:anIntKeyPath];
        [observable removeObserver:observer forKeyPath:stringOfAnIntKeyPath];
        
        testassert([observedChanges isEqualToArray:@[
             @"1 willChange anInt 0",
             @"1 willChange stringOfAnInt 0",
             @"2 willChange anInt 1",
             @"2 willChange stringOfAnInt 1",
             @"2 didChange anInt 42",
             @"2 didChange stringOfAnInt 42",
             @"1 didChange anInt 42",
             @"1 didChange stringOfAnInt 42"
        ]]);
        
        return YES;
    }
}

test(MultipleChangeOnChangeObservers)
{
    @autoreleasepool
    {
        Observable *observable = [Observable observable];
        NSString *keyPath = @"anInt";
        
        NSMutableArray *observedChanges = [NSMutableArray array];
        
        Observer *firstObserver = [[Observer alloc] initWithBlock:
            ^(Observer *observer, NSString *string, id object, NSDictionary *change) {
                [observedChanges addObject:@">> firstObserver"];
                [observedChanges addObject:@([object anInt])];
                if ([object anInt] != 2) {
                    [object setAnInt:2];
                }
                [observedChanges addObject:@"<< firstObserver"];
            }
        ];
        
        Observer *secondObserver = [[Observer alloc] initWithBlock:
            ^(Observer *observer, NSString *string, id object, NSDictionary *change) {
                [observedChanges addObject:@">> secondObserver"];
                [observedChanges addObject:@([object anInt])];
                [observedChanges addObject:@"<< secondObserver"];
            }
        ];
        
        [observable addObserver:secondObserver forKeyPath:keyPath options:0 context:NULL];
        [observable addObserver:firstObserver forKeyPath:keyPath options:0 context:NULL];
        
        [observable setAnInt:1];
        
        [observable removeObserver:firstObserver forKeyPath:keyPath];
        [observable removeObserver:secondObserver forKeyPath:keyPath];
        
        testassert([observedChanges isEqualToArray:@[
            @">> firstObserver",
                @(1),
                @">> firstObserver",
                    @(2),
                @"<< firstObserver",
                @">> secondObserver",
                    @(2),
                @"<< secondObserver",
            @"<< firstObserver",
            @">> secondObserver",
                @(2),
            @"<< secondObserver"
        ]]);
        
        return YES;
    }
}

test(PriorObservance)
{
    OBSERVER_PROLOGUE(Observable, @"anInt", NSKeyValueObservingOptionPrior, NULL);

    [observable setAnInt:42];

    testassert([observer priorObservationMadeForKeyPath:keyPath]);

    OBSERVER_EPILOGUE();
}

test(ZeroObservancesWithBadObservable)
{
    OBSERVER_PROLOGUE(BadObservable, @"anInt", 0, NULL);

    testassert([observer observationCountForKeyPath:keyPath] == 0);

    OBSERVER_EPILOGUE();
}

test(SingleObservanceWithBadObservable)
{
    OBSERVER_PROLOGUE(BadObservable, @"anInt", 0, NULL);

    [observable setAnInt:42];

    testassert([observer observationCountForKeyPath:keyPath] == 1);

    OBSERVER_EPILOGUE();
}

test(ManyObservancesWithBadObservable)
{
    static const NSUInteger iterations = 10;

    OBSERVER_PROLOGUE(BadObservable, @"anInt", 0, NULL);

    for (NSUInteger i = 0; i < iterations; i++)
    {
        [observable setAnInt:i];
    }

    testassert([observer observationCountForKeyPath:keyPath] == iterations);

    OBSERVER_EPILOGUE();
}

test(PriorObservanceWithBadObservable)
{
    OBSERVER_PROLOGUE(BadObservable, @"anInt", NSKeyValueObservingOptionPrior, NULL);

    [observable setAnInt:42];

    testassert([observer priorObservationMadeForKeyPath:keyPath]);

    OBSERVER_EPILOGUE();
}


test(DependantKeyChange)
{
    @autoreleasepool
    {
        DependentObservable *observable = [DependentObservable observable];
        Observer *observer = [Observer observer];
        [observable addObserver:observer forKeyPath:@"aFloat" options:0 context:NULL];
        [observable setAnInt:5];
        [observable removeObserver:observer forKeyPath:@"aFloat"];
        testassert([observer observationCountForKeyPath:@"aFloat"] == 1);
        return YES;
    }
}
test(DependantKeyIndependentChange)
{
    @autoreleasepool
    {
        DependentObservable *observable = [DependentObservable observable];
        Observer *observer = [Observer observer];
        [observable addObserver:observer forKeyPath:@"aFloat" options:0 context:NULL];
        [observable setAFloat:5.0f];
        [observable removeObserver:observer forKeyPath:@"aFloat"];
        testassert([observer observationCountForKeyPath:@"aFloat"] == 1);
        return YES;
    }
}
test(NestedDependantKeyChange)
{
    @autoreleasepool
    {
        NestedDependentObservable *observable = [NestedDependentObservable observable];
        Observer *observer = [Observer observer];
        observable.nameObject = [NameClass new];
        [observable addObserver:observer forKeyPath:@"fullName" options:0 context:NULL];
        [observable.nameObject setFirstName:@"Bob"];
        [observable removeObserver:observer forKeyPath:@"fullName"];
        testassert([observer observationCountForKeyPath:@"fullName"] == 1);
        return YES;
    }
}
test(NestedDependantKeyUnnestedChange)
{
    @autoreleasepool
    {
        NestedDependentObservable *observable = [NestedDependentObservable observable];
        Observer *observer = [Observer observer];
        observable.nameObject = [NameClass new];
        [observable addObserver:observer forKeyPath:@"fullName" options:0 context:NULL];
        observable.nameObject = [NameClass new];
        [observable removeObserver:observer forKeyPath:@"fullName"];
        testassert([observer observationCountForKeyPath:@"fullName"] == 1);
        return YES;
    }
}


test(NestedObservableLeaf)
{
    @autoreleasepool
    {
        NestedObservable *topLevelObservable = [NestedObservable observable];
        NestedObservable *leafObservable = [NestedObservable observable];
        topLevelObservable.nested = leafObservable;
        Observer *observer = [Observer observer];
        [topLevelObservable addObserver:observer forKeyPath:@"nested.anInt" options:0 context:NULL];
        [leafObservable setAnInt:5];
        [topLevelObservable removeObserver:observer forKeyPath:@"nested.anInt"];
        testassert([observer observationCountForKeyPath:@"nested.anInt"] == 1);
        return YES;
    }
}

test(NestedObservableBranch)
{
    @autoreleasepool
    {
        NestedObservable *topLevelObservable = [NestedObservable observable];
        NestedObservable *leafObservable = [NestedObservable observable];
        leafObservable.anInt = 5;
        Observer *observer = [Observer observer];
        [topLevelObservable addObserver:observer forKeyPath:@"nested.anInt" options:0 context:NULL];
        [topLevelObservable setNested:leafObservable];
        [topLevelObservable removeObserver:observer forKeyPath:@"nested.anInt"];
        testassert([observer observationCountForKeyPath:@"nested.anInt"] == 1);
        return YES;
    }
}

test(ArrayAddObserverException)
{
    @autoreleasepool
    {
        NSArray *array = @[];
        Observer *observer = [Observer observer];
        BOOL exception = NO;
        @try
        {
            [array addObserver:observer forKeyPath:@"count" options:0 context:NULL];
        }
        @catch (NSException *e)
        {
            exception = YES;
            testassert([[e name] isEqualToString:NSInvalidArgumentException]);
        }
        testassert(exception);
        return YES;
    }
}

test(ArrayAddObserverForIndexes)
{
    @autoreleasepool
    {
        NSArray *array = @[[Observable observable], [Observable observable], [Observable observable], [Observable observable]];
        Observer *observer = [Observer observer];
        NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSetWithIndex:1];
        [indexSet addIndex:3];
        [array addObserver:observer toObjectsAtIndexes:indexSet forKeyPath:@"anInt" options:0 context:NULL];
        for (Observable *ob in array)
        {
            ob.anInt = 5;
        }
        [array removeObserver:observer fromObjectsAtIndexes:indexSet forKeyPath:@"anInt" context:NULL];
        // The documentation on the above method is a lie.
        testassert([observer observationCountForKeyPath:@"anInt"] == 2);
        return YES;
    }
}
test(ArrayAddObserverForIndexesNoContextRemove)
{
    @autoreleasepool
    {
        NSArray *array = @[[Observable observable], [Observable observable], [Observable observable], [Observable observable]];
        Observer *observer = [Observer observer];
        NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSetWithIndex:1];
        [indexSet addIndex:3];
        [array addObserver:observer toObjectsAtIndexes:indexSet forKeyPath:@"anInt" options:0 context:NULL];
        for (Observable *ob in array)
        {
            ob.anInt = 5;
        }
        [array removeObserver:observer fromObjectsAtIndexes:indexSet forKeyPath:@"anInt"];
        testassert([observer observationCountForKeyPath:@"anInt"] == 2);
        return YES;
    }
}

test(SetAddObserverException)
{
    @autoreleasepool
    {
        NSSet *set = [NSSet set];
        Observer *observer = [Observer observer];
        BOOL exception = NO;
        @try
        {
            [set addObserver:observer forKeyPath:@"count" options:0 context:NULL];
        }
        @catch (NSException *e)
        {
            exception = YES;
            testassert([[e name] isEqualToString:NSInvalidArgumentException]);
        }
        testassert(exception);
        return YES;
    }
}

test(OrderedSetAddObserverException)
{
    @autoreleasepool
    {
        NSOrderedSet *orderedSet = [NSOrderedSet orderedSet];
        Observer *observer = [Observer observer];
        BOOL exception = NO;
        @try
        {
            [orderedSet addObserver:observer forKeyPath:@"count" options:0 context:NULL];
        }
        @catch (NSException *e)
        {
            exception = YES;
            testassert([[e name] isEqualToString:NSInvalidArgumentException]);
        }
        testassert(exception);
        return YES;
    }
}




// "Bad" Tests. These tests tests things you shouldn't do with KVO that existing implementations
// let you do anyway. It would not more accurate to call these tests of unspecified behavior
// rather than undocumented, although they are generally not documented either. These tests have
// the potential to break the global data structures used by KVO; as such they are at the bottom
// of the test suite, and should remain there, to avoid fouling other tests. Tests which are found
// to break these data structures should be removed. As some of them are relatively common
// programming errors, however, they should be supported where possible, at least to the extent
// that exists in KVO implementations already.

test(MidCycleUnregister)
{
    @autoreleasepool
    {
        ReallyBadObservable *badObservable = [ReallyBadObservable observable];
        Observer *observer = [Observer observer];
        [badObservable addObserver:observer forKeyPath:@"anInt" options:0 context:NULL];
        [badObservable willChangeValueForKey:@"anInt"];
        [badObservable setAnInt:50];
        [badObservable removeObserver:observer forKeyPath:@"anInt"];
        [badObservable didChangeValueForKey:@"anInt"];
        testassert([observer observationCountForKeyPath:@"anInt"] == 0);
        return YES;
    }
}
test(MidCycleRegister)
{
    @autoreleasepool
    {
        ReallyBadObservable *badObservable = [ReallyBadObservable observable];
        Observer *observer = [Observer observer];
        Observer *observer2 = [Observer observer];
        [badObservable addObserver:observer forKeyPath:@"anInt" options:0 context:NULL];
        [badObservable willChangeValueForKey:@"anInt"];
        [badObservable addObserver:observer2 forKeyPath:@"anInt" options:0 context:NULL];
        [badObservable setAnInt:50];
        [badObservable didChangeValueForKey:@"anInt"];
        [badObservable removeObserver:observer forKeyPath:@"anInt"];
        [badObservable removeObserver:observer2 forKeyPath:@"anInt"];
        testassert([observer observationCountForKeyPath:@"anInt"] == 1); //TODO: is this a bug in iOS?
        testassert([observer2 observationCountForKeyPath:@"anInt"] == 0);
        return YES;
    }
}
test(MidCycleRegisterSame)
{
    @autoreleasepool
    {
        ReallyBadObservable *badObservable = [ReallyBadObservable observable];
        Observer *observer = [Observer observer];
        [badObservable addObserver:observer forKeyPath:@"anInt" options:0 context:NULL];
        [badObservable willChangeValueForKey:@"anInt"];
        [badObservable addObserver:observer forKeyPath:@"anInt" options:0 context:NULL];
        [badObservable setAnInt:50];
        [badObservable didChangeValueForKey:@"anInt"];
        [badObservable removeObserver:observer forKeyPath:@"anInt"];
        [badObservable removeObserver:observer forKeyPath:@"anInt"];
        testassert([observer observationCountForKeyPath:@"anInt"] == 1); //TODO: is this a bug in iOS?
        return YES;
    }
}

test(MidCyclePartialUnregister)
{
    @autoreleasepool
    {
        ReallyBadObservable *badObservable = [ReallyBadObservable observable];
        Observer *observer = [Observer observer];
        [badObservable addObserver:observer forKeyPath:@"anInt" options:0 context:NULL];
        [badObservable addObserver:observer forKeyPath:@"anInt" options:0 context:NULL];
        [badObservable willChangeValueForKey:@"anInt"];
        [badObservable setAnInt:50];
        [badObservable removeObserver:observer forKeyPath:@"anInt"];
        [badObservable didChangeValueForKey:@"anInt"];
        [badObservable removeObserver:observer forKeyPath:@"anInt"];
        testassert([observer observationCountForKeyPath:@"anInt"] == 2); //This seems wrong.
        return YES;
    }
}

test(MidCycleReregister)
{
    @autoreleasepool
    {
        ReallyBadObservable *badObservable = [ReallyBadObservable observable];
        Observer *observer = [Observer observer];
        [badObservable addObserver:observer forKeyPath:@"anInt" options:0 context:NULL];
        [badObservable willChangeValueForKey:@"anInt"];
        [badObservable removeObserver:observer forKeyPath:@"anInt"];
        [badObservable setAnInt:50];
        [badObservable addObserver:observer forKeyPath:@"anInt" options:0 context:NULL];
        [badObservable didChangeValueForKey:@"anInt"];
        [badObservable removeObserver:observer forKeyPath:@"anInt"];
        testassert([observer observationCountForKeyPath:@"anInt"] == 1); // really?
        return YES;
    }
}

test(MidCycleReregisterWithContext)
{
    @autoreleasepool
    {
        ReallyBadObservable *badObservable = [ReallyBadObservable observable];
        Observer *observer = [Observer observer];
        [badObservable addObserver:observer forKeyPath:@"anInt" options:0 context:NULL];
        [badObservable willChangeValueForKey:@"anInt"];
        [badObservable removeObserver:observer forKeyPath:@"anInt"];
        [badObservable setAnInt:50];
        [badObservable addObserver:observer forKeyPath:@"anInt" options:0 context:badObservable];
        [badObservable didChangeValueForKey:@"anInt"];
        [badObservable removeObserver:observer forKeyPath:@"anInt"];
        testassert([observer observationCountForKeyPath:@"anInt"] == 0);
        return YES;
    }
}

#undef OBSERVER_PROLOGUE
#undef OBSERVER_EPILOGUE

@end
