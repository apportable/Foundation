#import <Foundation/NSObject.h>

@class NSString, NSCache;

@protocol NSCacheDelegate <NSObject>
@optional
- (void)cache:(NSCache *)cache willEvictObject:(id)obj;
@end

@interface NSCache : NSObject

- (void)setName:(NSString *)n;
- (NSString *)name;
- (void)setDelegate:(id <NSCacheDelegate>)delegate;
- (id <NSCacheDelegate>)delegate;
- (id)objectForKey:(id)key;
- (void)setObject:(id)obj forKey:(id)key;
- (void)setObject:(id)obj forKey:(id)key cost:(NSUInteger)cost;
- (void)removeObjectForKey:(id)key;
- (void)removeAllObjects;
- (void)setTotalCostLimit:(NSUInteger)limit;
- (NSUInteger)totalCostLimit;
- (void)setCountLimit:(NSUInteger)limit;
- (NSUInteger)countLimit;
- (BOOL)evictsObjectsWithDiscardedContent;
- (void)setEvictsObjectsWithDiscardedContent:(BOOL)evicts;

@end
