#import <Foundation/NSObject.h>

@interface NSIndexPath : NSObject <NSCopying, NSCoding>

+ (instancetype)indexPathWithIndex:(NSUInteger)index;
+ (instancetype)indexPathWithIndexes:(const NSUInteger [])indexes length:(NSUInteger)length;
- (instancetype)initWithIndex:(NSUInteger)index;
- (instancetype)initWithIndexes:(const NSUInteger [])indexes length:(NSUInteger)length;
- (NSIndexPath *)indexPathByAddingIndex:(NSUInteger)index;
- (NSIndexPath *)indexPathByRemovingLastIndex;
- (NSUInteger)indexAtPosition:(NSUInteger)position;
- (NSUInteger)length;
- (void)getIndexes:(NSUInteger *)indexes;
- (NSComparisonResult)compare:(NSIndexPath *)otherObject;

@end
