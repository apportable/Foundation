#import <Foundation/NSPointerArray.h>
#import "NSPointerFunctionsInternal.h"

__attribute__((visibility("hidden")))
@interface NSConcretePointerArray : NSPointerArray {
    struct NSSlice slice;
    NSUInteger count;
    NSUInteger capacity;
    NSUInteger options;
    NSUInteger mutations;
    BOOL needsCompaction;
}
- (id)init;
- (id)initWithOptions:(NSPointerFunctionsOptions)options;
- (id)initWithPointerFunctions:(NSPointerFunctions *)pointerFunctions;
- (id)initWithCoder:(NSCoder *)coder;
- (void)dealloc;
- (void)encodeWithCoder:(NSCoder *)coder;
- (BOOL)isEqual:(id)other;
- (NSUInteger)hash;
- (id)copyWithZone:(NSZone *)zone;
- (void)removePointer:(void *)ptr;
- (NSUInteger)indexOfPointer:(void *)ptr;
- (void)setCount:(NSUInteger)count;
- (NSUInteger)count;
- (void)compact;
- (void)_markNeedsCompaction;
- (void)replacePointerAtIndex:(NSUInteger)index withPointer:(void *)ptr;
- (void)insertPointer:(void *)ptr atIndex:(NSUInteger)index;
- (void)removePointerAtIndex:(NSUInteger)index;
- (void)addPointer:(void *)ptr;
- (void *)pointerAtIndex:(NSUInteger)index;
- (void)arrayGrow:(NSUInteger)count;
- (NSPointerFunctions *)pointerFunctions;
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])buffer count:(NSUInteger)len;
- (Class)classForCoder;
- (void)_initBlock;
@end
