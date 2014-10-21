#import <Foundation/NSCoder.h>
#import <Foundation/NSData.h>
#import <Foundation/NSArray.h>

@interface NSArchiver : NSCoder

+ (BOOL)archiveRootObject:(id)object toFile:(NSString *)path;
+ (id)archivedDataWithRootObject:(id)object;
+ (NSString *)classNameEncodedForTrueClassName:(NSString *)name;
+ (void)encodeClassName:(NSString *)name intoClassName:(NSString *)encoded;
+ (void)initialize;
- (NSString *)classNameEncodedForTrueClassName:(NSString *)name;
- (void)encodeClassName:(NSString *)name intoClassName:(NSString *)encoded;
- (void)encodeConditionalObject:(id)object;
- (void)encodeRootObject:(id)object;
- (void)encodeDataObject:(NSData *)object;
- (void)encodeObject:(id)object;
- (void)encodeBytes:(const void *)addr length:(NSUInteger)len;
- (void)encodeArrayOfObjCType:(const char *)type count:(NSUInteger)count at:(const void *)array;
- (void)encodeValuesOfObjCTypes:(const char *)types, ...;
- (void)encodeValueOfObjCType:(const char *)type at:(const void *)addr;
- (NSInteger)versionForClassName:(NSString *)className;
- (void)replaceObject:(id)object withObject:(id)replacement;
- (void)dealloc;
- (id)data;
- (id)archiverData;
- (id)initForWritingWithMutableData:(NSMutableData *)data;

@end

@interface NSUnarchiver : NSCoder

+ (void)initialize;
+ (NSString *)classNameDecodedForArchiveClassName:(NSString *)name;
+ (void)decodeClassName:(NSString *)internalName asClassName:(NSString *)externalName;
+ (id)unarchiveObjectWithFile:(NSString *)path;
+ (id)unarchiveObjectWithData:(NSData *)data;
- (id)initForReadingWithData:(NSData *)data;
- (void)dealloc;
- (NSString *)classNameDecodedForArchiveClassName:(NSString *)name;
- (void)decodeClassName:(NSString *)internalName asClassName:(NSString *)externalName;
- (id)decodeDataObject;
- (id)decodeObject;
- (void *)decodeBytesWithReturnedLength:(NSUInteger *)len;
- (void)decodeArrayOfObjCType:(const char *)itemType count:(NSUInteger)count at:(void *)array;
- (void)decodeValuesOfObjCTypes:(const char *)types, ...;
- (void)decodeValueOfObjCType:(const char *)type at:(void *)data;
- (NSData *)data;
- (NSInteger)versionForClassName:(NSString *)className;
- (unsigned)systemVersion;
- (BOOL)isAtEnd;
- (NSZone *)objectZone;
- (void)setObjectZone:(NSZone *)zone;
- (void)_setAllowedClasses:(NSArray *)classNames;
- (void)replaceObject:(id)obj withObject:(id)replacement;

@end

@interface NSObject (NSArchiverCallBack)
- (id)replacementObjectForArchiver:(NSArchiver *)archiver;
- (Class)classForArchiver;
@end
