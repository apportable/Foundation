#import <Foundation/NSTextCheckingResult.h>

@class NSDictionary;

@interface NSTransitInformationCheckingResult : NSTextCheckingResult {
    NSRange _range;
    NSDictionary *_components;
    id _underlyingResult;
}

@property (readonly) void *underlyingResult;
- (NSDictionary *)components;
- (BOOL)_adjustRangesWithOffset:(NSInteger)offset;
- (id)resultByAdjustingRangesWithOffset:(NSInteger)offset;
- (NSRange)range;
- (NSTextCheckingType)resultType;
- (id)initWithCoder:(NSCoder *)coder;
- (void)encodeWithCoder:(NSCoder *)coder;
- (void)dealloc;
- (id)initWithRange:(NSRange)range components:(NSDictionary *)components;
- (id)initWithRange:(NSRange)range components:(NSDictionary *)components underlyingResult:(void *)underlyingResult;

@end
