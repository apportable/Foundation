#import <Foundation/NSTextCheckingResult.h>

@class NSURL;

@interface NSLinkCheckingResult : NSTextCheckingResult {
    NSRange _range;
    NSURL *_url;
}

- (id)initWithRange:(NSRange)range URL:(NSURL *)url;
- (id)initWithCoder:(NSCoder *)coder;
- (void)encodeWithCoder:(NSCoder *)coder;
- (void)dealloc;
- (NSURL *)URL;
- (BOOL)_adjustRangesWithOffset:(NSInteger)offset;
- (id)resultByAdjustingRangesWithOffset:(NSInteger)offset;
- (NSRange)range;
- (NSTextCheckingType)resultType;
- (NSString *)description;

@end
