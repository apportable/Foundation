#import <Foundation/NSObject.h>

@class NSArray, NSKeyValueObservance;

CF_PRIVATE
@interface NSKeyValueObservationInfo : NSObject
- (NSArray *)observances;
- (void)addObservance:(NSKeyValueObservance *)observance;
- (void)removeObservance:(NSKeyValueObservance *)observance;
@end
