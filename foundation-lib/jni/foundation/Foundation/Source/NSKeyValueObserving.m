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
#import "Foundation/uthash.h"

enum PropertyAttributeKind 
{
    /**
     * Property has no attributes.
     */
    OBJC_PR_noattr    = 0x00,
    /**
     * The property is declared read-only.
     */
    OBJC_PR_readonly  = (1<<0),
    /**
     * The property has a getter.
     */
    OBJC_PR_getter    = (1<<1),
    /**
     * The property has assign semantics.
     */
    OBJC_PR_assign    = (1<<2),
    /**
     * The property is declared read-write.
     */
    OBJC_PR_readwrite = (1<<3),
    /**
     * Property has retain semantics.
     */
    OBJC_PR_retain    = (1<<4),
    /**
     * Property has copy semantics.
     */
    OBJC_PR_copy      = (1<<5),
    /**
     * Property is marked as non-atomic.
     */
    OBJC_PR_nonatomic = (1<<6),
    /**
     * Property has setter.
     */
    OBJC_PR_setter    = (1<<7)
};

// NOTE: The runtime has a really backwards concept of setter and getter names, they seem to be dyslexic...
struct objc_property
{
    const char *name;
    const char attributes;
    const char isSynthesized;
    const char *getter_name;
    const char *getter_types;
    const char *setter_name;
    const char *setter_types;
};


NSString *const NSKeyValueChangeKindKey = @"kind";
NSString *const NSKeyValueChangeNewKey = @"new";
NSString *const NSKeyValueChangeOldKey = @"old";
NSString *const NSKeyValueChangeIndexesKey = @"indexes";
NSString *const NSKeyValueChangeNotificationIsPriorKey = @"prior";
NSString *const NSKVOObserverClassKey = @"kvocls";

static const void *NSKVOPropertyStoreKey = "NSKVOPropertyStoreKey";
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


static Class swapClass(id self, Class cls)
{
    Class isa = self->isa;
    self->isa = cls;
    return isa;
}

typedef struct {
    const char *name;
    objc_property_t property;
    UT_hash_handle hh;
} NSKVOPropertyStore;

static void kvo_set(id self, SEL _cmd, ...)
{
    NSKVOPropertyStore *propertyStore = objc_getAssociatedObject(self, NSKVOPropertyStoreKey);

    NSKVOPropertyStore *entry;

    HASH_FIND_STR(propertyStore,sel_getName(_cmd), entry);

    objc_property_t property = NULL;
    if (entry != NULL)
    {
        property = entry->property;
    }

    Class cls =  objc_getAssociatedObject(self, NSKVOObserverClassKey);
    Class old = swapClass(self, cls);
    if (property != NULL)
    {
        [self willChangeValueForKey:[NSString stringWithUTF8String:property->name]];
    }
    NSMethodSignature *signature = [NSMethodSignature signatureWithObjCTypes:property->setter_types];
    size_t sz = objc_sizeof_type([signature getArgumentTypeAtIndex:2]);
    void *arg = malloc(sz);
    va_list args;
    va_start(args, _cmd);
    memcpy(arg, (void *)args, sz);
    va_end(args);
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:signature];
    [inv setTarget:self];
    [inv setSelector:_cmd];
    [inv setArgument:arg atIndex:2];
    [inv invoke];
    free(arg);

    if (property != NULL)
    {
        [self didChangeValueForKey:[NSString stringWithUTF8String:property->name]];
    }
    swapClass(self, old);
}

static Class kvo_class(id self, SEL _cmd, ...)
{
    Class cls =  objc_getAssociatedObject(self, NSKVOObserverClassKey);
    if (cls != NULL)
    {
        return cls;
    }
    else
    {
        return object_getClass(self);
    }
}

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
        Class cls = object_getClass(self);
        BOOL isKVOClass = [NSStringFromClass(cls) hasSuffix:@"_$KVOObserver"];
        if (!isKVOClass)
        {
            unsigned int methodCount = 0;
            unsigned int propertyCount = 0;
            Class superCls = class_getSuperclass(cls);
            
            const char *kvoName =  [[NSStringFromClass(cls) stringByAppendingString:@"_$KVOObserver"] UTF8String];
            
            Class kvoClass = objc_allocateClassPair(superCls, kvoName, 0);

            // Copy all instance methods
            // Copy all class methods

            Method *methods = class_copyMethodList(cls, &methodCount);
            objc_property_t *properties = class_copyPropertyList(cls, &propertyCount);
            
            for (int i = 0; i < methodCount; i++)
            {
                Method m = methods[i];
                BOOL found = NO;
                for (int j = 0; j < propertyCount; j++)
                {
                    objc_property_t property = properties[j];

                    if (property->isSynthesized)
                    {
                        if (property->attributes & OBJC_PR_noattr)
                        {
                            continue;
                        }

                        if (property->attributes & OBJC_PR_readonly)
                        {
                            continue;
                        }
                        BOOL atomic = property->attributes & OBJC_PR_nonatomic;
                        SEL cmdName = NULL;
                        cmdName = sel_getUid(property->setter_name);
                        if (cmdName != NULL && strcmp(sel_getName(cmdName), sel_getName(method_getName(m))) == 0) {
                            found = YES;
                        }
                    }
                }
                if(!found) {
                    class_addMethod(kvoClass, method_getName(m), method_getImplementation(m), method_getTypeEncoding(m));
                } 
            }
            class_addMethod(kvoClass, sel_getUid("class"), (IMP)&kvo_class, "#@:");
            
            // wrap all property setters

            for (int i = 0; i < propertyCount; i++)
            {
                objc_property_t property = properties[i];

                if (property->isSynthesized)
                {
                    if (property->attributes & OBJC_PR_noattr)
                    {
                        continue;
                    }

                    if (property->attributes & OBJC_PR_readonly)
                    {
                        continue;
                    }
                    BOOL atomic = property->attributes & OBJC_PR_nonatomic;
                    SEL cmd;

                    cmd = sel_getUid(property->setter_name);
                

                    if ((property->attributes & OBJC_PR_assign) ||  (property->attributes & OBJC_PR_retain) || (property->attributes & OBJC_PR_copy))
                    {
                        NSKVOPropertyStore *propertyStore = objc_getAssociatedObject(self, NSKVOPropertyStoreKey);

                        if(!class_addMethod(kvoClass, cmd, (IMP)&kvo_set, property->setter_types))
                        {
                            Method m = class_getInstanceMethod(kvoClass, cmd);
                            if (m != NULL)
                            {
                                NSKVOPropertyStore *entry = malloc(sizeof(NSKVOPropertyStore));
                                entry->name = strdup(sel_getName(cmd));
                                entry->property = property;

                                HASH_ADD_KEYPTR( hh, propertyStore, entry->name, strlen(entry->name), entry);

                                objc_setAssociatedObject(self, NSKVOPropertyStoreKey, propertyStore, OBJC_ASSOCIATION_ASSIGN);
                                method_setImplementation(m, (IMP)&kvo_set);
                            }
                            
                        }
                        else
                        {
                            NSKVOPropertyStore *entry = malloc(sizeof(NSKVOPropertyStore));
                            entry->name = strdup(sel_getName(cmd));
                            entry->property = property;

                            HASH_ADD_KEYPTR( hh, propertyStore, entry->name, strlen(entry->name), entry);

                            objc_setAssociatedObject(self, NSKVOPropertyStoreKey, propertyStore, OBJC_ASSOCIATION_ASSIGN);
                        }
                    }
                }
                
            }

            // TODO: Drain properties
            // if (properties)
            // {
            //     free(properties);
            // }

            swapClass(self, kvoClass);
            objc_setAssociatedObject(self, NSKVOObserverClassKey, cls, OBJC_ASSOCIATION_ASSIGN);
        }
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
        if ([observers count] == 0)
        {
            Class cls = objc_getAssociatedObject(self, NSKVOObserverClassKey);
            if (cls != NULL)
            {
               swapClass(self, cls);
            }
        }
        // TODO: drain the uthash here!
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