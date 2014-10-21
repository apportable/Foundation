#import <Foundation/NSMapTable.h>
#import "NSPointerFunctionsInternal.h"
#import "NSObjectInternal.h"

__attribute__((visibility("hidden")))
@interface NSConcreteMapTable : NSMapTable
{
    struct NSSlice keys;
    struct NSSlice values;
    NSUInteger count;
    NSUInteger capacity;
    NSPointerFunctionsOptions keyOptions;
    NSPointerFunctionsOptions valueOptions;
    NSUInteger mutations;
    int32_t growLock;
    BOOL shouldRehash;
}

- (NSArray *)allValues;
- (NSArray *)allKeys;
- (BOOL)isEqual:(id)other;
- (NSUInteger)hash;
- (NSUInteger)getKeys:(const void **)keys values:(const void **)values;
- (id)objectEnumerator;
- (id)keyEnumerator;
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])buffer count:(NSUInteger)len;
- (NSString *)description;
- (void)dealloc;
- (void)removeAllItems;
- (void)removeObjectForKey:(id)key;
- (void)rehash;
- (NSUInteger)rehashAround:(NSUInteger)index;
- (void)replaceItem:(const void *)item forExistingKey:(const void *)key;
- (BOOL)mapMember:(const void *)member originalKey:(const void **)key value:(const void **)value;
- (void *)existingItemForSetItem:(const void *)item forAbsentKey:(const void *)key;
- (void)setItem:(const void *)item forKnownAbsentKey:(const void *)key;
- (void)setItem:(const void *)item forAbsentKey:(const void *)key;
- (void)setObject:(id)object forKey:(id)key;
- (id)objectForKey:(id)key;
- (void)assign:(NSUInteger)index key:(const void *)key value:(const void *)value isNew:(BOOL)isNew;
- (void)grow;
- (id)dump;
- (BOOL)containsKeys:(const void **)keyArray values:(const void **)valueArray count:(NSUInteger)objectCount;
- (NSUInteger)count;
- (NSPointerFunctions *)valuePointerFunctions;
- (NSPointerFunctions *)keyPointerFunctions;
- (void)encodeWithCoder:(NSCoder *)aCoder;
- (id)initWithCoder:(NSCoder *)aCoder;
- (Class)classForCoder;
- (id)initWithKeyOptions:(NSPointerFunctionsOptions)keyOptions valueOptions:(NSPointerFunctionsOptions)valueOptions capacity:(NSUInteger)initialCapacity;
- (id)initWithKeyPointerFunctions:(NSPointerFunctions *)keyFunctions valuePointerFunctions:(NSPointerFunctions *)valueFunctions capacity:(NSUInteger)initialCapacity;
- (id)copy;
- (void)_setBackingStore;
- (void)_initBlock;
- (void)zeroPairedEntries;
- (void)checkCount:(BOOL *)dirty;
- (NSUInteger)realCount;
- (void)raiseCountUnderflowException;
- (id)init;

@end
