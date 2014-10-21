#import <Foundation/NSCoder.h>
#import <Foundation/NSPropertyList.h>

@class NSArray, NSMutableData, NSData, NSKeyedArchiver, NSKeyedUnarchiver;

@protocol NSKeyedArchiverDelegate <NSObject>
@optional

- (id)archiver:(NSKeyedArchiver *)archiver willEncodeObject:(id)object;
- (void)archiver:(NSKeyedArchiver *)archiver didEncodeObject:(id)object;
- (void)archiver:(NSKeyedArchiver *)archiver willReplaceObject:(id)object withObject:(id)newObject;
- (void)archiverWillFinish:(NSKeyedArchiver *)archiver;
- (void)archiverDidFinish:(NSKeyedArchiver *)archiver;

@end

@protocol NSKeyedUnarchiverDelegate <NSObject>
@optional

- (Class)unarchiver:(NSKeyedUnarchiver *)unarchiver cannotDecodeObjectOfClassName:(NSString *)name originalClasses:(NSArray *)classNames;
- (id)unarchiver:(NSKeyedUnarchiver *)unarchiver didDecodeObject:(id) NS_RELEASES_ARGUMENT object NS_RETURNS_RETAINED;
- (void)unarchiver:(NSKeyedUnarchiver *)unarchiver willReplaceObject:(id)object withObject:(id)newObject;
- (void)unarchiverWillFinish:(NSKeyedUnarchiver *)unarchiver;
- (void)unarchiverDidFinish:(NSKeyedUnarchiver *)unarchiver;

@end

FOUNDATION_EXPORT NSString * const NSInvalidArchiveOperationException;
FOUNDATION_EXPORT NSString * const NSInvalidUnarchiveOperationException;

@interface NSKeyedArchiver : NSCoder

+ (NSData *)archivedDataWithRootObject:(id)rootObject;
+ (BOOL)archiveRootObject:(id)rootObject toFile:(NSString *)path;
+ (void)setClassName:(NSString *)codedName forClass:(Class)cls;
+ (NSString *)classNameForClass:(Class)cls;

- (id)initForWritingWithMutableData:(NSMutableData *)data;
- (void)setDelegate:(id <NSKeyedArchiverDelegate>)delegate;
- (id <NSKeyedArchiverDelegate>)delegate;
- (void)setOutputFormat:(NSPropertyListFormat)format;
- (NSPropertyListFormat)outputFormat;
- (void)finishEncoding;
- (void)setClassName:(NSString *)codedName forClass:(Class)cls;
- (NSString *)classNameForClass:(Class)cls;
- (void)encodeObject:(id)objv forKey:(NSString *)key;
- (void)encodeConditionalObject:(id)objv forKey:(NSString *)key;
- (void)encodeBool:(BOOL)boolv forKey:(NSString *)key;
- (void)encodeInt:(int)intv forKey:(NSString *)key;
- (void)encodeInt32:(int32_t)intv forKey:(NSString *)key;
- (void)encodeInt64:(int64_t)intv forKey:(NSString *)key;
- (void)encodeFloat:(float)realv forKey:(NSString *)key;
- (void)encodeDouble:(double)realv forKey:(NSString *)key;
- (void)encodeBytes:(const uint8_t *)bytesp length:(NSUInteger)lenv forKey:(NSString *)key;

@end

@interface NSKeyedUnarchiver : NSCoder

+ (id)unarchiveObjectWithData:(NSData *)data;
+ (id)unarchiveObjectWithFile:(NSString *)path;
- (id)initForReadingWithData:(NSData *)data;
- (void)setDelegate:(id <NSKeyedUnarchiverDelegate>)delegate;
- (id <NSKeyedUnarchiverDelegate>)delegate;
- (void)finishDecoding;
+ (void)setClass:(Class)cls forClassName:(NSString *)codedName;
- (void)setClass:(Class)cls forClassName:(NSString *)codedName;
+ (Class)classForClassName:(NSString *)codedName;
- (Class)classForClassName:(NSString *)codedName;
- (BOOL)containsValueForKey:(NSString *)key;
- (id)decodeObjectForKey:(NSString *)key;
- (BOOL)decodeBoolForKey:(NSString *)key;
- (int)decodeIntForKey:(NSString *)key;
- (int32_t)decodeInt32ForKey:(NSString *)key;
- (int64_t)decodeInt64ForKey:(NSString *)key;
- (float)decodeFloatForKey:(NSString *)key;
- (double)decodeDoubleForKey:(NSString *)key;
- (const uint8_t *)decodeBytesForKey:(NSString *)key returnedLength:(NSUInteger *)lengthp NS_RETURNS_INNER_POINTER;

@end

@interface NSObject (NSKeyedArchiverObjectSubstitution)

+ (NSArray *)classFallbacksForKeyedArchiver;
- (Class)classForKeyedArchiver;
- (id)replacementObjectForKeyedArchiver:(NSKeyedArchiver *)archiver;

@end

@interface NSObject (NSKeyedUnarchiverObjectSubstitution)

+ (Class)classForKeyedUnarchiver;

@end
