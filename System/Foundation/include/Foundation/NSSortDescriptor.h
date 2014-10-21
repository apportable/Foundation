#import <Foundation/NSArray.h>
#import <Foundation/NSSet.h>

@interface NSSortDescriptor : NSObject <NSCoding, NSCopying>

+ (id)sortDescriptorWithKey:(NSString *)key ascending:(BOOL)ascending;
+ (id)sortDescriptorWithKey:(NSString *)key ascending:(BOOL)ascending selector:(SEL)selector;
#if NS_BLOCKS_AVAILABLE
+ (id)sortDescriptorWithKey:(NSString *)key ascending:(BOOL)ascending comparator:(NSComparator)comparator;
#endif
- (id)initWithKey:(NSString *)key ascending:(BOOL)ascending;
- (id)initWithKey:(NSString *)key ascending:(BOOL)ascending selector:(SEL)selector;
- (NSString *)key;
- (BOOL)ascending;
- (SEL)selector;
#if NS_BLOCKS_AVAILABLE
- (id)initWithKey:(NSString *)key ascending:(BOOL)ascending comparator:(NSComparator)comparator;
- (NSComparator)comparator;
#endif
- (NSComparisonResult)compareObject:(id)obj1 toObject:(id)obj2;
- (id)reversedSortDescriptor;

@end

@interface NSSet (NSSortDescriptorSorting)

- (NSArray *)sortedArrayUsingDescriptors:(NSArray *)sortDescriptors;

@end

@interface NSArray (NSSortDescriptorSorting)

- (NSArray *)sortedArrayUsingDescriptors:(NSArray *)sortDescriptors;

@end

@interface NSMutableArray (NSSortDescriptorSorting)

- (void)sortUsingDescriptors:(NSArray *)sortDescriptors;

@end
