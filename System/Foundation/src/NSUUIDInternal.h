#import <Foundation/NSUUID.h>
#import "NSObjectInternal.h"

__attribute__((visibility("hidden")))
@interface __NSConcreteUUID : NSUUID

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key;
- (id)copyWithZone:(NSZone *)zone;
- (Class)classForCoder;
- (id)description;
- (CFUUIDBytes)_cfUUIDBytes;
- (void)getUUIDBytes:(uuid_t)bytes;
- (BOOL)isEqual:(id)other;
- (id)initWithUUIDBytes:(const uuid_t)bytes;
- (id)initWithUUIDString:(NSString *)string;
- (id)init;

@end
