#import <Foundation/NSTextCheckingResult.h>

@class NSString;

@interface NSSubstitutionCheckingResult : NSTextCheckingResult {
    NSRange _range;
    NSString *_replacementString;
}

- (id)initWithRange:(NSRange)range replacementString:(NSString *)replacementString;
- (id)initWithCoder:(NSCoder *)coder;
- (void)encodeWithCoder:(NSCoder *)coder;
- (void)dealloc;
- (NSString *)replacementString;
- (BOOL)_adjustRangesWithOffset:(NSInteger)offset;
- (id)resultByAdjustingRangesWithOffset:(NSInteger)offset;
- (NSRange)range;
- (NSString *)description;

@end


@interface NSCorrectionCheckingResult : NSSubstitutionCheckingResult

- (NSTextCheckingType)resultType;

@end

@interface NSDashCheckingResult : NSSubstitutionCheckingResult

- (NSTextCheckingType)resultType;

@end

@interface NSQuoteCheckingResult : NSSubstitutionCheckingResult

- (NSTextCheckingType)resultType;

@end
