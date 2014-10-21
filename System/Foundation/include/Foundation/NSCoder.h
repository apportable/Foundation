#import <Foundation/NSObject.h>

@class NSString, NSData, NSSet;

@interface NSCoder : NSObject

- (void)encodeValueOfObjCType:(const char *)type at:(const void *)addr;
- (void)encodeDataObject:(NSData *)data;
- (void)decodeValueOfObjCType:(const char *)type at:(void *)data;
- (NSData *)decodeDataObject;
- (NSInteger)versionForClassName:(NSString *)className;

@end

@interface NSCoder (NSExtendedCoder)

- (void)encodeObject:(id)obj;
- (void)encodeRootObject:(id)root;
- (void)encodeBycopyObject:(id)obj;
- (void)encodeByrefObject:(id)obj;
- (void)encodeConditionalObject:(id)object;
- (void)encodeValuesOfObjCTypes:(const char *)types, ...;
- (void)encodeArrayOfObjCType:(const char *)type count:(NSUInteger)count at:(const void *)array;
- (void)encodeBytes:(const void *)addr length:(NSUInteger)len;
- (id)decodeObject;
- (void)decodeValuesOfObjCTypes:(const char *)types, ...;
- (void)decodeArrayOfObjCType:(const char *)itemType count:(NSUInteger)count at:(void *)array;
- (void *)decodeBytesWithReturnedLength:(NSUInteger *)len NS_RETURNS_INNER_POINTER;
- (void)setObjectZone:(NSZone *)zone NS_AUTOMATED_REFCOUNT_UNAVAILABLE;
- (NSZone *)objectZone NS_AUTOMATED_REFCOUNT_UNAVAILABLE;
- (unsigned)systemVersion;
- (BOOL)allowsKeyedCoding;
- (void)encodeObject:(id)obj forKey:(NSString *)key;
- (void)encodeConditionalObject:(id)obj forKey:(NSString *)key;
- (void)encodeBool:(BOOL)value forKey:(NSString *)key;
- (void)encodeInt:(int)value forKey:(NSString *)key;
- (void)encodeInt32:(int32_t)value forKey:(NSString *)key;
- (void)encodeInt64:(int64_t)value forKey:(NSString *)key;
- (void)encodeFloat:(float)value forKey:(NSString *)key;
- (void)encodeDouble:(double)value forKey:(NSString *)key;
- (void)encodeBytes:(const uint8_t *)buffer length:(NSUInteger)len forKey:(NSString *)key;
- (BOOL)containsValueForKey:(NSString *)key;
- (id)decodeObjectForKey:(NSString *)key;
- (BOOL)decodeBoolForKey:(NSString *)key;
- (int)decodeIntForKey:(NSString *)key;
- (int32_t)decodeInt32ForKey:(NSString *)key;
- (int64_t)decodeInt64ForKey:(NSString *)key;
- (float)decodeFloatForKey:(NSString *)key;
- (double)decodeDoubleForKey:(NSString *)key;
- (const uint8_t *)decodeBytesForKey:(NSString *)key returnedLength:(NSUInteger *)len NS_RETURNS_INNER_POINTER;
- (void)encodeInteger:(NSInteger)value forKey:(NSString *)key;
- (NSInteger)decodeIntegerForKey:(NSString *)key;
- (BOOL)requiresSecureCoding;
- (id)decodeObjectOfClass:(Class)aClass forKey:(NSString *)key;
- (id)decodeObjectOfClasses:(NSSet *)classes forKey:(NSString *)key;
- (id)decodePropertyListForKey:(NSString *)key;
- (NSSet *)allowedClasses;

@end
