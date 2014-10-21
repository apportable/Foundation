#import <Foundation/NSTextCheckingResult.h>

@class NSOrthography;

@interface NSOrthographyCheckingResult : NSTextCheckingResult {
    NSRange _range;
    NSOrthography *_orthography;
}

- (id)initWithRange:(NSRange)range orthography:(NSOrthography *)orthography;
- (id)initWithCoder:(NSCoder *)coder;
- (void)encodeWithCoder:(NSCoder *)coder;
- (void)dealloc;
- (NSOrthography *)orthography;
- (BOOL)_adjustRangesWithOffset:(NSInteger)offset;
- (id)resultByAdjustingRangesWithOffset:(NSInteger)offset;
- (NSRange)range;
- (NSTextCheckingType)resultType;
- (NSString *)description;

@end
