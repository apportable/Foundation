#import "NSCFType.h"
#import <Foundation/NSAttributedString.h>

@interface __NSPlaceholderAttributedString : NSAttributedString

+ (id)mutablePlaceholder;
+ (id)immutablePlaceholder;

- (id)initWithString:(NSString *)str attributes:(NSDictionary *)attrs;
- (id)initWithAttributedString:(NSAttributedString *)attrStr;

@end

@interface __NSCFAttributedString : __NSCFType

+ (BOOL)automaticallyNotifiesObserversForKey:(id)key;
- (void)removeAttribute:(NSString *)name range:(NSRange)range;
- (void)addAttribute:(NSString *)name value:(id)value range:(NSRange)range;
- (void)addAttributes:(NSDictionary *)attrs range:(NSRange)range;
- (void)setAttributedString:(NSAttributedString *)attrString;
- (void)deleteCharactersInRange:(NSRange)range;
- (void)appendAttributedString:(NSAttributedString *)attrString;
- (void)insertAttributedString:(NSAttributedString *)attrString atIndex:(NSUInteger)loc;
- (void)replaceCharactersInRange:(NSRange)range withAttributedString:(NSAttributedString *)attrString;
- (void)setAttributes:(NSDictionary *)attributes range:(NSRange)range;
- (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)string;
- (Class)classForCoder;
- (id)mutableCopyWithZone:(NSZone *)zone;
- (id)copyWithZone:(NSZone *)zone;
- (BOOL)isEqualToAttributedString:(NSAttributedString *)other;
- (NSAttributedString *)attributedSubstringFromRange:(NSRange)range;
- (NSDictionary *)attributesAtIndex:(NSUInteger)index longestEffectiveRange:(NSRangePointer)range inRange:(NSRange)rangeLimit;
- (id)attribute:(NSString *)attrName atIndex:(NSUInteger)index longestEffectiveRange:(NSRangePointer)range inRange:(NSRange)rangeLimit;
- (id)attribute:(NSString *)attrName atIndex:(NSUInteger)index effectiveRange:(NSRangePointer)rangePtr;
- (NSUInteger)length;
- (NSDictionary *)attributesAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)aRange;
- (NSString *)string;
- (BOOL)isEqual:(id)other;
- (NSUInteger)retainCount;
- (BOOL)_isDeallocating;
- (BOOL)_tryRetain;
- (oneway void)release;
- (id)retain;

@end
