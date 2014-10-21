#import <Foundation/NSTextCheckingResult.h>

@class NSString;

@interface NSPhoneNumberCheckingResult : NSTextCheckingResult {
    NSRange _range;
    NSString *_phoneNumber;
    id _underlyingResult;
}

@property (readonly) void *underlyingResult;
- (NSString *)phoneNumber;
- (BOOL)_adjustRangesWithOffset:(NSInteger)offset;
- (id)resultByAdjustingRangesWithOffset:(NSInteger)offset;
- (NSRange)range;
- (NSTextCheckingType)resultType;
- (id)initWithCoder:(NSCoder *)coder;
- (void)encodeWithCoder:(NSCoder *)coder;
- (NSString *)description;
- (void)dealloc;
- (id)initWithRange:(NSRange)range phoneNumber:(NSString *)phoneNumber;
- (id)initWithRange:(NSRange)range phoneNumber:(NSString *)phoneNumber underlyingResult:(void *)underlyingResult;

@end
