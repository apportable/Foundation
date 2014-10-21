#import "NSKeyedArchiver.h"

@interface NSKeyedArchiver (Internal)

- (void)_encodePropertyList:(id)plistObject forKey:(NSString *)key;

@end

@interface NSKeyedUnarchiver (Internal)

- (id)_decodePropertyListForKey:(NSString *)key;

@end