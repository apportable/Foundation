#import <Foundation/NSScanner.h>

CF_PRIVATE
@interface NSConcreteScanner : NSScanner
{
    NSString *scanString;
    NSCharacterSet *skipSet;
    NSCharacterSet *invertedSkipSet;
    id locale;
    unsigned int scanLocation;
    struct {
        unsigned int caseSensitive:1;
        unsigned int :31;
    } flags;
}

- (void)dealloc;
- (BOOL)scanLongLong:(long long *)longLong;
- (BOOL)scanInt:(int *)anInt;
- (id)locale;
- (void)setLocale:(id)locale;
- (BOOL)caseSensitive;
- (void)setCaseSensitive:(BOOL)caseSensitive;
- (id)charactersToBeSkipped;
- (void)setCharactersToBeSkipped:(NSCharacterSet *)charactersToBeSkipped;
- (NSUInteger)scanLocation;
- (void)setScanLocation:(NSUInteger)location;
- (NSCharacterSet *)_invertedSkipSet;
- (NSString *)string;
- (id)initWithString:(NSString *)string;

@end
