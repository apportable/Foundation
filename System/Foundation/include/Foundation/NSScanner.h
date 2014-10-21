#import <Foundation/NSObject.h>

@class NSString, NSCharacterSet, NSDictionary;

@interface NSScanner : NSObject <NSCopying>

- (NSString *)string;
- (NSUInteger)scanLocation;
- (void)setScanLocation:(NSUInteger)pos;
- (void)setCharactersToBeSkipped:(NSCharacterSet *)set;
- (void)setCaseSensitive:(BOOL)flag;
- (void)setLocale:(id)locale;

@end

@interface NSScanner (NSExtendedScanner)

+ (id)scannerWithString:(NSString *)string;
+ (id)localizedScannerWithString:(NSString *)string;
- (NSCharacterSet *)charactersToBeSkipped;
- (BOOL)caseSensitive;
- (id)locale;
- (BOOL)scanInt:(int *)value;
- (BOOL)scanInteger:(NSInteger *)value;
- (BOOL)scanHexLongLong:(unsigned long long *)result;
- (BOOL)scanHexFloat:(float *)result;
- (BOOL)scanHexDouble:(double *)result;
- (BOOL)scanHexInt:(unsigned *)value;
- (BOOL)scanLongLong:(long long *)value;
- (BOOL)scanFloat:(float *)value;
- (BOOL)scanDouble:(double *)value;
- (BOOL)scanString:(NSString *)string intoString:(NSString **)value;
- (BOOL)scanCharactersFromSet:(NSCharacterSet *)set intoString:(NSString **)value;
- (BOOL)scanUpToString:(NSString *)string intoString:(NSString **)value;
- (BOOL)scanUpToCharactersFromSet:(NSCharacterSet *)set intoString:(NSString **)value;
- (BOOL)isAtEnd;
- (id)initWithString:(NSString *)string;

@end
