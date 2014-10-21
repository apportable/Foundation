#import <Foundation/NSString.h>
#import <Foundation/NSDictionary.h>

typedef NS_OPTIONS(NSUInteger, NSAttributedStringEnumerationOptions) {
    NSAttributedStringEnumerationReverse                          = (1UL << 1),
    NSAttributedStringEnumerationLongestEffectiveRangeNotRequired = (1UL << 20)
};

@interface NSAttributedString : NSObject <NSCopying, NSMutableCopying, NSCoding>

- (NSString *)string;
- (NSDictionary *)attributesAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)range;

@end

@interface NSAttributedString (NSExtendedAttributedString)

- (NSUInteger)length;
- (id)attribute:(NSString *)attrName atIndex:(NSUInteger)index effectiveRange:(NSRangePointer)range;
- (NSAttributedString *)attributedSubstringFromRange:(NSRange)range;
- (NSDictionary *)attributesAtIndex:(NSUInteger)index longestEffectiveRange:(NSRangePointer)range inRange:(NSRange)rangeLimit;
- (id)attribute:(NSString *)attrName atIndex:(NSUInteger)index longestEffectiveRange:(NSRangePointer)range inRange:(NSRange)rangeLimit;
- (BOOL)isEqualToAttributedString:(NSAttributedString *)other;
- (id)initWithString:(NSString *)str;
- (id)initWithString:(NSString *)str attributes:(NSDictionary *)attrs;
- (id)initWithAttributedString:(NSAttributedString *)attrStr;
#if NS_BLOCKS_AVAILABLE
- (void)enumerateAttributesInRange:(NSRange)enumerationRange options:(NSAttributedStringEnumerationOptions)opts usingBlock:(void (^)(NSDictionary *attrs, NSRange range, BOOL *stop))block;
- (void)enumerateAttribute:(NSString *)attrName inRange:(NSRange)enumerationRange options:(NSAttributedStringEnumerationOptions)opts usingBlock:(void (^)(id value, NSRange range, BOOL *stop))block;
#endif

@end

@interface NSMutableAttributedString : NSAttributedString

- (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)str;
- (void)setAttributes:(NSDictionary *)attrs range:(NSRange)range;

@end

@interface NSMutableAttributedString (NSExtendedMutableAttributedString)

- (NSMutableString *)mutableString;
- (void)addAttribute:(NSString *)name value:(id)value range:(NSRange)range;
- (void)addAttributes:(NSDictionary *)attrs range:(NSRange)range;
- (void)removeAttribute:(NSString *)name range:(NSRange)range;
- (void)replaceCharactersInRange:(NSRange)range withAttributedString:(NSAttributedString *)attrString;
- (void)insertAttributedString:(NSAttributedString *)attrString atIndex:(NSUInteger)loc;
- (void)appendAttributedString:(NSAttributedString *)attrString;
- (void)deleteCharactersInRange:(NSRange)range;
- (void)setAttributedString:(NSAttributedString *)attrString;
- (void)beginEditing;
- (void)endEditing;

@end
