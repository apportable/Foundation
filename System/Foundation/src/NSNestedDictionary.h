#import <Foundation/NSDictionary.h>

CF_PRIVATE
@interface _NSNestedDictionary : NSMutableDictionary {
@public
    id _locals;
    id _bindings;
}

- (void)removeObjectForKey:(id)key;
- (void)setObject:(id)object forKey:(id<NSCopying>)key;
- (NSEnumerator *)objectEnumerator;
- (NSEnumerator *)keyEnumerator;
- (id)objectForKey:(id)key;
- (NSUInteger)count;
- (id)_recursiveAllValues;
- (id)_recursiveAllKeys;

@end
