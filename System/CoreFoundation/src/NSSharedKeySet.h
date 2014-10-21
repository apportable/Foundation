#import <Foundation/NSArray.h>

@class NSString;

@interface NSSharedKeySet : NSObject <NSFastEnumeration, NSCopying, NSCoding>
{
    char *_g;
    unsigned char _select;
    void *_rankTable;
    double _c;
    unsigned int _M;
    unsigned int _factor;
    NSUInteger _numKey;
    unsigned int _seeds[2];
    id *_keys;
    NSSharedKeySet *_subSharedKeySet;
}

+ (id)keySetWithKeys:(NSArray *)keys;
- (NSUInteger)keySetCount;
- (void)dealloc;
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])buffer count:(NSUInteger)len;
- (id)keyAtIndex:(NSUInteger)index;
- (NSUInteger)indexForKey:(id)key;
- (NSArray *)allKeys;
- (NSUInteger)maximumIndex;
- (BOOL)isEmpty;
- (NSUInteger)count;
- (id)initWithCoder:(NSCoder *)coder;
- (void)encodeWithCoder:(NSCoder *)coder;
- (id)copyWithZone:(NSZone *)zone;
- (id)init;
- (id)initWithKeys:(id *)keys count:(NSUInteger)count;
- (void)createSubclassCode:(NSString *)subclassName interface:(CFStringRef *)interface implementation:(CFStringRef *)implementation;

@end
