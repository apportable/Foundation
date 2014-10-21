#import <Foundation/NSObject.h>
#import <Foundation/NSKeyValueObserving.h>

@class NSKeyValueSetter, NSKeyValueProperty;

CF_PRIVATE
@interface NSKeyValueObservance : NSObject
@property (assign) NSObject *observer;
@property (copy) NSString *keyPath;
@property (retain) NSKeyValueProperty *property; //TODO: assign?
@property (assign) NSObject *originalObservable;
@property (assign) void *context;
@property (retain) NSKeyValueSetter *setter;
@property (assign) NSKeyValueObservingOptions options;
- (instancetype)initWithObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath ofObject:(NSObject *)object withContext:(void *)context options:(NSKeyValueObservingOptions)options;
- (instancetype)initWithObserver:(NSObject *)observer forProperty:(NSKeyValueProperty *)property ofObject:(NSObject *)object context:(void *)context options:(NSKeyValueObservingOptions)options;
@end
