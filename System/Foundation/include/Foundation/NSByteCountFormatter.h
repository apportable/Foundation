#import <Foundation/NSFormatter.h>

typedef NS_OPTIONS(NSUInteger, NSByteCountFormatterUnits) {
    NSByteCountFormatterUseDefault      = 0,
    NSByteCountFormatterUseBytes        = 1UL << 0,
    NSByteCountFormatterUseKB           = 1UL << 1,
    NSByteCountFormatterUseMB           = 1UL << 2,
    NSByteCountFormatterUseGB           = 1UL << 3,
    NSByteCountFormatterUseTB           = 1UL << 4,
    NSByteCountFormatterUsePB           = 1UL << 5,
    NSByteCountFormatterUseEB           = 1UL << 6,
    NSByteCountFormatterUseZB           = 1UL << 7,
    NSByteCountFormatterUseYBOrHigher   = 0x0FFUL << 8,
    NSByteCountFormatterUseAll          = 0x0FFFFUL

};

typedef NS_ENUM(NSInteger, NSByteCountFormatterCountStyle) {
    NSByteCountFormatterCountStyleFile    = 0,
    NSByteCountFormatterCountStyleMemory  = 1,
    NSByteCountFormatterCountStyleDecimal = 2,
    NSByteCountFormatterCountStyleBinary  = 3
};

@interface NSByteCountFormatter : NSFormatter

@property NSByteCountFormatterUnits allowedUnits;
@property NSByteCountFormatterCountStyle countStyle;
@property BOOL allowsNonnumericFormatting;
@property BOOL includesUnit;
@property BOOL includesCount;
@property BOOL includesActualByteCount;
@property (getter=isAdaptive) BOOL adaptive;
@property BOOL zeroPadsFractionDigits;

+ (NSString *)stringFromByteCount:(long long)byteCount countStyle:(NSByteCountFormatterCountStyle)style;
- (NSString *)stringFromByteCount:(long long)byteCount;

@end
