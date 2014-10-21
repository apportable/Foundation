#import <Foundation/NSObject.h>

@class NSArray;

typedef struct {
    unsigned long state;
    id __unsafe_unretained *itemsPtr;
    unsigned long *mutationsPtr;
    unsigned long extra[5];
} NSFastEnumerationState;

@protocol NSFastEnumeration

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])buffer count:(NSUInteger)len;

@end

@interface NSEnumerator : NSObject <NSFastEnumeration>

- (id)nextObject;

@end

@interface NSEnumerator (NSExtendedEnumerator)

- (NSArray *)allObjects;

@end
