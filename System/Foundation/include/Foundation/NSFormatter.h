#import <Foundation/NSObject.h>
#import <Foundation/NSRange.h>

@class NSString;
@class NSAttributedString;
@class NSDictionary;

@interface NSFormatter : NSObject <NSCopying, NSCoding>

- (NSString *)stringForObjectValue:(id)obj;
- (NSAttributedString *)attributedStringForObjectValue:(id)obj withDefaultAttributes:(NSDictionary *)attrs;
- (NSString *)editingStringForObjectValue:(id)obj;
- (BOOL)getObjectValue:(out id *)obj forString:(NSString *)string errorDescription:(out NSString **)error;
- (BOOL)isPartialStringValid:(NSString *)partialString newEditingString:(NSString **)newString errorDescription:(NSString **)error;
- (BOOL)isPartialStringValid:(NSString **)partialStringPtr proposedSelectedRange:(NSRangePointer)proposedSelRangePtr originalString:(NSString *)origString originalSelectedRange:(NSRange)origSelRange errorDescription:(NSString **)error;

@end
