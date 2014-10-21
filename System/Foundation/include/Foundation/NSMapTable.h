#import <Foundation/NSPointerFunctions.h>
#import <Foundation/NSString.h>
#import <Foundation/NSEnumerator.h>

#if !defined(__FOUNDATION_NSMAPTABLE__)
#define __FOUNDATION_NSMAPTABLE__ 1

@class NSArray, NSDictionary, NSMapTable;

typedef NS_ENUM(NSUInteger, NSMapTableOptions) {
    NSMapTableStrongMemory             = 0,
    NSMapTableCopyIn                   = NSPointerFunctionsCopyIn,
    NSMapTableObjectPointerPersonality = NSPointerFunctionsObjectPointerPersonality,
    NSMapTableWeakMemory               = NSPointerFunctionsWeakMemory
};

@interface NSMapTable : NSObject <NSCopying, NSCoding, NSFastEnumeration>

+ (id)mapTableWithKeyOptions:(NSPointerFunctionsOptions)keyOptions valueOptions:(NSPointerFunctionsOptions)valueOptions;
+ (id)strongToStrongObjectsMapTable;
+ (id)weakToStrongObjectsMapTable;
+ (id)strongToWeakObjectsMapTable;
+ (id)weakToWeakObjectsMapTable;
- (id)initWithKeyOptions:(NSPointerFunctionsOptions)keyOptions valueOptions:(NSPointerFunctionsOptions)valueOptions capacity:(NSUInteger)initialCapacity;
- (id)initWithKeyPointerFunctions:(NSPointerFunctions *)keyFunctions valuePointerFunctions:(NSPointerFunctions *)valueFunctions capacity:(NSUInteger)initialCapacity;
- (NSPointerFunctions *)keyPointerFunctions;
- (NSPointerFunctions *)valuePointerFunctions;
- (id)objectForKey:(id)aKey;
- (void)removeObjectForKey:(id)aKey;
- (void)setObject:(id)anObject forKey:(id)aKey;
- (NSUInteger)count;
- (NSEnumerator *)keyEnumerator;
- (NSEnumerator *)objectEnumerator;
- (void)removeAllObjects;
- (NSDictionary *)dictionaryRepresentation;

@end

#endif
