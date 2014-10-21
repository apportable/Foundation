#import <Foundation/NSObject.h>

@interface NSProgress : NSObject

+ (id)currentProgress;
+ (id)progressWithTotalUnitCount:(int64_t)unitCount;

@property(readonly, getter=isCancelled) BOOL cancelled;
@property int64_t completedUnitCount;

@end
