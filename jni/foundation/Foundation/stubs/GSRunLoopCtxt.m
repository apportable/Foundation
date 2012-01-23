#import "../Source/GSRunLoopCtxt.h"
#import "../Source/GSPrivate.h"

@implementation GSRunLoopCtxt

// Put endPoll here
- (void) endPoll {
}

- (id) initWithMode: (NSString*)theMode extra: (void*)e
{
    mode = [theMode copy];
    extra = e;

    // NOTIMPLEMENTED
    NSZone	*z;
    z = [self zone];
    performers = NSZoneMalloc(z, sizeof(GSIArray_t));
    timers = NSZoneMalloc(z, sizeof(GSIArray_t));
    watchers = NSZoneMalloc(z, sizeof(GSIArray_t));
    _trigger = NSZoneMalloc(z, sizeof(GSIArray_t));
    GSIArrayInitWithZoneAndCapacity(performers, z, 8);
    GSIArrayInitWithZoneAndCapacity(timers, z, 8);
    GSIArrayInitWithZoneAndCapacity(watchers, z, 8);
    GSIArrayInitWithZoneAndCapacity(_trigger, z, 8);

    return self;
}

- (void) dealloc
{
  RELEASE(mode);
  GSIArrayEmpty(performers);
  NSZoneFree(performers->zone, (void*)performers);
  GSIArrayEmpty(timers);
  NSZoneFree(timers->zone, (void*)timers);
  GSIArrayEmpty(watchers);
  NSZoneFree(watchers->zone, (void*)watchers);
  GSIArrayEmpty(_trigger);
  NSZoneFree(_trigger->zone, (void*)_trigger);
  [super dealloc];
}

- (BOOL) pollUntil: (int)milliseconds within: (NSArray*)contexts
{
  // NOTIMPLEMENTED
  [GSRunLoopInfoForThread(nil) fire];
  return NO;
}

@end
