#import <Foundation/NSObject.h>

#import "NSKeyValueObservingInternal.h"

CF_PRIVATE
@interface NSKeyValueContainerClass : NSObject
{
    Class _originalClass;
    IMP _cachedObservationInfoImplementation;
    IMP _cachedSetObservationInfoImplementation;
    BOOL _cachedSetObservationInfoTakesAnObject;
    NSKVONotifyingInfo *_notifyingInfo;
}
@property (nonatomic, retain) Class originalClass;
@property (nonatomic, assign) IMP cachedObservationInfoImplementation;
@property (nonatomic, assign) IMP cachedSetObservationInfoImplementation;
@property (nonatomic, assign) BOOL cachedSetObservationInfoTakesAnObject;
@property (nonatomic, assign) NSKVONotifyingInfo *notifyingInfo;

- (id)description;
- (id)initWithOriginalClass:(Class)cls;

@end
