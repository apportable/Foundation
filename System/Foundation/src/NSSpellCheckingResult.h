#import <Foundation/NSTextCheckingResult.h>

@interface NSSpellCheckingResult : NSTextCheckingResult {
    NSRange _range;
}

- (id)initWithRange:(NSRange)range;
- (id)initWithCoder:(NSCoder *)coder;
- (void)encodeWithCoder:(NSCoder *)coder;
- (BOOL)_adjustRangesWithOffset:(NSInteger)offset;
- (id)resultByAdjustingRangesWithOffset:(NSInteger)offset;
- (NSRange)range;
- (NSTextCheckingType)resultType;

@end
