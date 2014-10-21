#import <Foundation/NSObject.h>
#import <CoreFoundation/CFUUID.h>
#import <uuid/uuid.h>

@interface NSUUID : NSObject <NSCopying, NSSecureCoding>

+ (id)UUID;
- (id)init;
- (id)initWithUUIDString:(NSString *)string;
- (id)initWithUUIDBytes:(const uuid_t)bytes;
- (void)getUUIDBytes:(uuid_t)uuid;
- (NSString *)UUIDString;

@end
