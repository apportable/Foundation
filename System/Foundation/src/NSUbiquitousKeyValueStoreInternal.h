#import <Foundation/NSUbiquitousKeyValueStore.h>

@protocol _NSUbiquitousKeyValueStoreProvider <NSObject>

- (NSUInteger)count;
- (id)objectForKey:(NSString *)key;
- (NSEnumerator *)keyEnumerator;

- (void)setObject:(id)anObject forKey:(NSString *)key;
- (void)removeObjectForKey:(NSString *)key;

@optional

- (BOOL)synchronize;

@end

@interface NSUbiquitousKeyValueStore (Internal)

- (id)_initWithProvider:(id<_NSUbiquitousKeyValueStoreProvider>)provider;
- (void)_setKeyValueStoreProvider:(id<_NSUbiquitousKeyValueStoreProvider>)provider;

@end
