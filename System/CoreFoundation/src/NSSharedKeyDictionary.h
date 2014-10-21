#import <Foundation/NSDictionary.h>
#import "NSSharedKeySet.h"

@interface NSSharedKeyDictionary : NSMutableDictionary {
    NSSharedKeySet *_keyMap;
    NSUInteger _count;
    id *_values;
    NSUInteger (*_ifkIMP)(id,SEL,id);
    NSMutableDictionary *_sideDic;
    NSUInteger _mutations;
}

+ (id)sharedKeyDictionaryWithKeySet:(NSSharedKeySet *)keySet;
- (id)initWithKeySet:(NSSharedKeySet *)keySet;
- (id)initWithCoder:(NSCoder *)coder;
- (void)encodeWithCoder:(NSCoder *)coder;
- (Class)classForCoder;
- (id)mutableCopyWithZone:(NSZone *)zone;
- (id)copyWithZone:(NSZone *)zone;
- (void)dealloc;
- (NSSharedKeySet *)keySet;
- (void)removeObjectForKey:(id)key;
- (void)setObject:(id)object forKey:(id)key;
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])buffer count:(NSUInteger)len;
- (NSEnumerator *)keyEnumerator;
- (void)getObjects:(id *)objects andKeys:(id *)keys count:(NSUInteger)count;
- (id)objectForKey:(id)key;
- (NSUInteger)count;

@end
