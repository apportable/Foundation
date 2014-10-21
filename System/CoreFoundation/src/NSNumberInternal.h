#import "NSObjectInternal.h"
#import "CFInternal.h"
#import <CoreFoundation/CFNumber.h>

CF_EXPORT Boolean _CFNumberGetValue(CFNumberRef number, CFNumberType type, void *valuePtr);
CF_EXPORT CFNumberType _CFNumberGetType(CFNumberRef num);
CF_EXPORT CFNumberType _CFNumberGetType2(CFNumberRef number);
CF_EXPORT CFStringRef __CFNumberCreateFormattingDescription(CFAllocatorRef allocator, CFTypeRef cf, CFDictionaryRef formatOptions);

__attribute__((visibility("hidden")))
@interface __NSCFNumber : __NSCFType

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key;
- (NSComparisonResult)compare:(id)other;
- (NSComparisonResult)_reverseCompare:(id)other;
- (Boolean)_getValue:(void *)value forType:(CFNumberType)type;
- (CFNumberType)_cfNumberType;
- (CFTypeID)_cfTypeID;
- (BOOL)boolValue;
- (unsigned int)unsignedIntegerValue;
- (int)integerValue;
- (double)doubleValue;
- (float)floatValue;
- (unsigned long long)unsignedLongLongValue;
- (long long)longLongValue;
- (unsigned long)unsignedLongValue;
- (long)longValue;
- (unsigned int)unsignedIntValue;
- (int)intValue;
- (unsigned short)unsignedShortValue;
- (short)shortValue;
- (unsigned char)unsignedCharValue;
- (BOOL)charValue;
- (const char *)objCType;
- (void)getValue:(void *)value;
- (id)copyWithZone:(NSZone *)zone;
- (id)stringValue;
- (id)description;
- (id)descriptionWithLocale:(id)locale;
- (unsigned int)retainCount;
- (BOOL)_isDeallocating;
- (BOOL)_tryRetain;
- (oneway void)release;
- (id)retain;
- (NSUInteger)hash;
- (BOOL)isEqual:(id)other;
- (BOOL)isEqualToNumber:(id)other;
- (BOOL)isNSNumber__;

@end

__attribute__((visibility("hidden")))
@interface __NSCFBoolean : __NSCFType

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key;
- (NSComparisonResult)compare:(id)other;
- (NSComparisonResult)_reverseCompare:(id)other;
- (BOOL)_getValue:(void *)val forType:(CFNumberType)type;
- (CFNumberType)_cfNumberType;
- (id)copyWithZone:(NSZone *)zone;
- (const char *)objCType;
- (void)getValue:(void *)value;
- (CFTypeID)_cfTypeID;
- (BOOL)boolValue;
- (unsigned int)unsignedIntegerValue;
- (int)integerValue;
- (double)doubleValue;
- (float)floatValue;
- (unsigned long long)unsignedLongLongValue;
- (long long)longLongValue;
- (unsigned long)unsignedLongValue;
- (long)longValue;
- (unsigned int)unsignedIntValue;
- (int)intValue;
- (unsigned short)unsignedShortValue;
- (short)shortValue;
- (unsigned char)unsignedCharValue;
- (BOOL)charValue;
- (id)stringValue;
- (id)description;
- (id)descriptionWithLocale:(id)locale;
- (unsigned int)retainCount;
- (BOOL)_isDeallocating;
- (BOOL)_tryRetain;
- (oneway void)release;
- (id)retain;
- (unsigned int)hash;
- (BOOL)isEqual:(id)other;
- (BOOL)isEqualToNumber:(id)otherNumber;

@end
