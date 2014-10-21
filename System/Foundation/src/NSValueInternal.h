#import "NSObjectInternal.h"
#import "CFInternal.h"
#import "NSExternals.h"
#import <CoreFoundation/CFNumber.h>

CF_EXPORT Boolean _CFNumberGetValue(CFNumberRef number, CFNumberType type, void *valuePtr);
CF_EXPORT CFNumberType _CFNumberGetType(CFNumberRef num);
CF_EXPORT CFNumberType _CFNumberGetType2(CFNumberRef number);
CF_EXPORT CFStringRef __CFNumberCreateFormattingDescription(CFAllocatorRef allocator, CFTypeRef cf, CFDictionaryRef formatOptions);

CF_PRIVATE
@interface NSPlaceholderValue : NSNumber
@end

CF_PRIVATE
@interface NSPlaceholderNumber : NSPlaceholderValue
@end

typedef struct {
    int size;
    const char *name;
    char type[0];
} NSValueTypeInfo;

typedef NS_ENUM(NSUInteger, NSConcreteValueSpecialType) {
    NSNotSpecialType = 0,
    NSPointType = 1,
    NSSizeType = 2,
    NSRectType = 3,
    NSRangeType = 4,
    /* 5-8 raise exceptions it seems*/
    NSAffineTransformType = 9,
    NSEdgeInsetsType = 10,
    NSEdgeType = 11,
    NSOffsetType = 12,

    NSCGRectType = 0x2603
};

@interface NSConcreteValue : NSValue {
@public
    NSConcreteValueSpecialType _specialFlags;
    NSValueTypeInfo *typeInfo;
}

+ (BOOL)supportsSecureCoding;
+ (void)initialize;
- (void)encodeWithCoder:(NSCoder *)aCoder;
- (NSString *)description;
- (id)copyWithZone:(NSZone *)zone;
- (NSUInteger)hash;
- (BOOL)isEqualToValue:(NSValue *)other;
- (const void *)_value;
- (const char *)objCType NS_RETURNS_INNER_POINTER;
- (void)getValue:(void *)value;

@end

@interface NSValue (Internal)

+ (NSValue *)valueWithPoint:(CGPoint)point;
+ (NSValue *)valueWithRect:(CGRect)rect;
+ (NSValue *)valueWithSize:(CGSize)size;
- (CGRect)rectValue;
- (CGSize)sizeValue;
- (CGPoint)pointValue;

@end
