#import <Foundation/NSTextCheckingResult.h>

@class NSDate, NSTimeZone;

@interface NSDateCheckingResult : NSTextCheckingResult {
    NSRange _range;
    NSDate *_date;
    NSTimeZone *_timeZone;
    NSTimeInterval _duration;
    NSDate *_referenceDate;
    id _underlyingResult;
    BOOL _timeIsSignificant;
    BOOL _timeIsApproximate;
}

@property(readonly) BOOL timeIsApproximate;
@property(readonly) BOOL timeIsSignificant;
@property(readonly) void *underlyingResult;
@property(readonly) NSDate *referenceDate;
@property(readonly) NSTimeInterval duration;
@property(readonly) NSTimeZone *timeZone;

- (id)initWithRange:(NSRange)range date:(NSDate *)date;
- (id)initWithRange:(NSRange)range date:(NSDate *)date timeZone:(NSTimeZone *)timeZone duration:(NSTimeInterval)duration;
- (id)initWithRange:(NSRange)range date:(NSDate *)date timeZone:(NSTimeZone *)timeZone duration:(NSTimeInterval)duration referenceDate:(NSDate *)referenceDate;
- (id)initWithRange:(NSRange)range date:(NSDate *)date timeZone:(NSTimeZone *)timeZone duration:(NSTimeInterval)duration referenceDate:(NSDate *)referenceDate underlyingResult:(void *)underlyingResult;
- (id)initWithRange:(NSRange)range date:(NSDate *)date timeZone:(NSTimeZone *)timeZone duration:(NSTimeInterval)duration referenceDate:(NSDate *)referenceDate underlyingResult:(void *)underlyingResult timeIsSignificant:(BOOL)timeIsSignificant timeIsApproximate:(BOOL)timeIsApproximate;
- (id)initWithCoder:(NSCoder *)coder;
- (void)encodeWithCoder:(NSCoder *)coder;
- (void)dealloc;
- (NSDate *)date;
- (BOOL)_adjustRangesWithOffset:(NSInteger)offset;
- (id)resultByAdjustingRangesWithOffset:(NSInteger)offset;
- (NSRange)range;
- (NSTextCheckingType)resultType;
- (NSString *)description;

@end
