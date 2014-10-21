#import <Foundation/NSTextCheckingResult.h>

@class NSDictionary;

@interface NSAddressCheckingResult : NSTextCheckingResult {
    NSRange _range;
    NSDictionary *_components;
    id _underlyingResult;
}

@property(readonly) void *underlyingResult;

- (id)initWithRange:(NSRange)range components:(NSDictionary *)components;
- (id)initWithRange:(NSRange)range components:(NSDictionary *)components underlyingResult:(void *)underlyingResult;
- (id)initWithCoder:(NSCoder *)coder;
- (void)encodeWithCoder:(NSCoder *)coder;
- (void)dealloc;
- (NSDictionary *)components;
- (BOOL)_adjustRangesWithOffset:(NSInteger)offset;
- (id)resultByAdjustingRangesWithOffset:(NSInteger)offset;
- (NSRange)range;
- (NSTextCheckingType)resultType;

@end
