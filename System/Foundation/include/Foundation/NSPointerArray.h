#import <Foundation/NSObject.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSPointerFunctions.h>

@interface NSPointerArray : NSObject <NSFastEnumeration, NSCopying, NSCoding>

+ (id)pointerArrayWithOptions:(NSPointerFunctionsOptions)options;
+ (id)pointerArrayWithPointerFunctions:(NSPointerFunctions *)functions;
- (id)initWithOptions:(NSPointerFunctionsOptions)options;
- (id)initWithPointerFunctions:(NSPointerFunctions *)functions;
- (NSPointerFunctions *)pointerFunctions;
- (void *)pointerAtIndex:(NSUInteger)index;
- (void)addPointer:(void *)pointer;
- (void)removePointerAtIndex:(NSUInteger)index;
- (void)insertPointer:(void *)item atIndex:(NSUInteger)index;
- (void)replacePointerAtIndex:(NSUInteger)index withPointer:(void *)item;
- (void)compact;
- (NSUInteger)count;
- (void)setCount:(NSUInteger)count;

@end

@interface NSPointerArray (NSPointerArrayConveniences)

+ (id)strongObjectsPointerArray;
+ (id)weakObjectsPointerArray;
- (NSArray *)allObjects;

@end
