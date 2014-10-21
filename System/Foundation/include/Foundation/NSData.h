#import <Foundation/NSObject.h>
#import <Foundation/NSRange.h>

@class NSString, NSURL, NSError;

typedef NS_OPTIONS(NSUInteger, NSDataReadingOptions) {
    NSDataReadingMappedIfSafe = 1UL << 0,
    NSDataReadingUncached     = 1UL << 1,
    NSDataReadingMappedAlways = 1UL << 3,
    NSDataReadingMapped       = NSDataReadingMappedIfSafe,
    NSMappedRead              = NSDataReadingMapped,
    NSUncachedRead            = NSDataReadingUncached
};

typedef NS_OPTIONS(NSUInteger, NSDataWritingOptions) {
    NSDataWritingAtomic                                             = 1UL << 0,
    NSDataWritingWithoutOverwriting                                 = 1UL << 1,
    NSDataWritingFileProtectionNone                                 = 0x10000000,
    NSDataWritingFileProtectionComplete                             = 0x20000000,
    NSDataWritingFileProtectionCompleteUnlessOpen                   = 0x30000000,
    NSDataWritingFileProtectionCompleteUntilFirstUserAuthentication = 0x40000000,
    NSDataWritingFileProtectionMask                                 = 0xf0000000,
    NSAtomicWrite = NSDataWritingAtomic
};

typedef NS_OPTIONS(NSUInteger, NSDataSearchOptions) {
    NSDataSearchBackwards = 1UL << 0,
    NSDataSearchAnchored  = 1UL << 1
};

typedef NS_OPTIONS(NSUInteger, NSDataBase64EncodingOptions) {
    NSDataBase64Encoding64CharacterLineLength = 1UL << 0,
    NSDataBase64Encoding76CharacterLineLength = 1UL << 1,
    NSDataBase64EncodingEndLineWithCarriageReturn = 1UL << 4,
    NSDataBase64EncodingEndLineWithLineFeed = 1UL << 5,
};

typedef NS_OPTIONS(NSUInteger, NSDataBase64DecodingOptions) {
    NSDataBase64DecodingIgnoreUnknownCharacters = 1UL << 0
};

@interface NSData : NSObject <NSCopying, NSMutableCopying, NSSecureCoding>

- (NSUInteger)length;
- (const void *)bytes NS_RETURNS_INNER_POINTER;

@end

@interface NSData (NSExtendedData)

- (NSString *)description;
- (void)getBytes:(void *)buffer length:(NSUInteger)length;
- (void)getBytes:(void *)buffer range:(NSRange)range;
- (BOOL)isEqualToData:(NSData *)other;
- (NSData *)subdataWithRange:(NSRange)range;
- (BOOL)writeToFile:(NSString *)path atomically:(BOOL)atomically;
- (BOOL)writeToURL:(NSURL *)url atomically:(BOOL)atomically;
- (BOOL)writeToFile:(NSString *)path options:(NSDataWritingOptions)writeOptionsMask error:(NSError **)errorPtr;
- (BOOL)writeToURL:(NSURL *)url options:(NSDataWritingOptions)writeOptionsMask error:(NSError **)errorPtr;
- (NSRange)rangeOfData:(NSData *)dataToFind options:(NSDataSearchOptions)mask range:(NSRange)searchRange NS_AVAILABLE(10_6, 4_0);

#if NS_BLOCKS_AVAILABLE
- (void) enumerateByteRangesUsingBlock:(void (^)(const void *bytes, NSRange byteRange, BOOL *stop))block;
#endif

@end

@interface NSData (NSDataCreation)

+ (id)data;
+ (id)dataWithBytes:(const void *)bytes length:(NSUInteger)length;
+ (id)dataWithBytesNoCopy:(void *)bytes length:(NSUInteger)length;
+ (id)dataWithBytesNoCopy:(void *)bytes length:(NSUInteger)length freeWhenDone:(BOOL)b;
+ (id)dataWithContentsOfFile:(NSString *)path options:(NSDataReadingOptions)readOptionsMask error:(NSError **)errorPtr;
+ (id)dataWithContentsOfURL:(NSURL *)url options:(NSDataReadingOptions)readOptionsMask error:(NSError **)errorPtr;
+ (id)dataWithContentsOfFile:(NSString *)path;
+ (id)dataWithContentsOfURL:(NSURL *)url;
- (id)initWithBytes:(const void *)bytes length:(NSUInteger)length;
- (id)initWithBytesNoCopy:(void *)bytes length:(NSUInteger)length;
- (id)initWithBytesNoCopy:(void *)bytes length:(NSUInteger)length freeWhenDone:(BOOL)b;
- (id)initWithContentsOfFile:(NSString *)path options:(NSDataReadingOptions)readOptionsMask error:(NSError **)errorPtr;
- (id)initWithContentsOfURL:(NSURL *)url options:(NSDataReadingOptions)readOptionsMask error:(NSError **)errorPtr;
- (id)initWithContentsOfFile:(NSString *)path;
- (id)initWithContentsOfURL:(NSURL *)url;
- (id)initWithData:(NSData *)data;
+ (id)dataWithData:(NSData *)data;

@end

@interface NSData (NSDataBase64Encoding)
- (id)initWithBase64EncodedString:(NSString *)base64String options:(NSDataBase64DecodingOptions)options NS_AVAILABLE(10_9, 7_0);
- (NSString *)base64EncodedStringWithOptions:(NSDataBase64EncodingOptions)options NS_AVAILABLE(10_9, 7_0);
- (id)initWithBase64EncodedData:(NSData *)base64Data options:(NSDataBase64DecodingOptions)options NS_AVAILABLE(10_9, 7_0);
- (NSData *)base64EncodedDataWithOptions:(NSDataBase64EncodingOptions)options NS_AVAILABLE(10_9, 7_0);
@end

@interface NSData (NSDeprecated)

+ (id)dataWithContentsOfMappedFile:(NSString *)path;
- (void)getBytes:(void *)buffer;
- (id)initWithContentsOfMappedFile:(NSString *)path;

@end

@interface NSMutableData : NSData

- (void *)mutableBytes NS_RETURNS_INNER_POINTER;
- (void)setLength:(NSUInteger)length;

@end

@interface NSMutableData (NSExtendedMutableData)

- (void)appendBytes:(const void *)bytes length:(NSUInteger)length;
- (void)appendData:(NSData *)other;
- (void)increaseLengthBy:(NSUInteger)extraLength;
- (void)replaceBytesInRange:(NSRange)range withBytes:(const void *)bytes;
- (void)resetBytesInRange:(NSRange)range;
- (void)setData:(NSData *)data;
- (void)replaceBytesInRange:(NSRange)range withBytes:(const void *)replacementBytes length:(NSUInteger)replacementLength;

@end

@interface NSMutableData (NSMutableDataCreation)

+ (id)dataWithCapacity:(NSUInteger)aNumItems;
+ (id)dataWithLength:(NSUInteger)length;
- (id)initWithCapacity:(NSUInteger)capacity;
- (id)initWithLength:(NSUInteger)length;

@end

@interface NSPurgeableData : NSMutableData <NSDiscardableContent>
@end
