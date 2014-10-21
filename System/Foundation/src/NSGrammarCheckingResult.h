#import <Foundation/NSTextCheckingResult.h>

@class NSArray;

@interface NSGrammarCheckingResult : NSTextCheckingResult {
    NSRange _range;
    NSArray *_details;
}

- (id)initWithRange:(NSRange)range details:(NSArray *)details;
- (id)initWithCoder:(NSCoder *)coder;
- (void)encodeWithCoder:(NSCoder *)coder;
- (void)dealloc;
- (NSArray *)grammarDetails;
- (BOOL)_adjustRangesWithOffset:(NSInteger)offset;
- (id)resultByAdjustingRangesWithOffset:(NSInteger)offset;
- (NSRange)range;
- (NSTextCheckingType)resultType;

@end
