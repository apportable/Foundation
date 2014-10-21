#import <Foundation/NSString.h>

@interface NSLocalizableString : NSString <NSCoding, NSCopying> {
    NSString *_stringsFileKey;
    NSString *_developmentLanguageString;
}

@property(readonly) NSString *developmentLanguageString;
@property(readonly) NSString *stringsFileKey;

+ (id)localizableStringWithStringsFileKey:(NSString *)key developmentLanguageString:(NSString *)devLang;
- (id)initWithStringsFileKey:(NSString *)key developmentLanguageString:(NSString *)devLang;
- (void)dealloc;
- (id)awakeAfterUsingCoder:(NSCoder *)coder;
- (void)setDevelopmentLanguageString:(NSString *)str;
- (void)setStringsFileKey:(NSString *)key;
- (unichar)characterAtIndex:(NSUInteger)index;
- (NSUInteger)length;

@end