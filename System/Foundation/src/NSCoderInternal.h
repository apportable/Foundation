#import <Foundation/NSCoder.h>
#import "NSExternals.h"

enum {
    NSKeyedArchiverKeyFlag = 0x01,
    NSArchiverFinished = 0x02,
    NSSecureCodingFlag = 0x04,
};

#define NSCoderSystemVersion 1000
#define NSKeyedArchiverSystemVersion 2000
#define NSKeyedArchiverPlistVersion 100000

@class NSArray, NSString;

@interface NSXPCCoder : NSCoder {
    id <NSObject> _userInfo;
    id _reserved1;
}
@property (retain) id <NSObject> userInfo;
- (void)dealloc;
- (id)decodeXPCObjectForKey:(NSString *)key;
- (void)encodeXPCObject:(id)object forKey:(NSString *)key;
- (BOOL)requiresSecureCoding;
@end

@interface NSCoder (NSGeometryCoding)
- (CGRect)decodeRect;
- (void)encodeRect:(CGRect)r;
- (CGSize)decodeSize;
- (void)encodeSize:(CGSize)sz;
- (CGPoint)decodePoint;
- (void)encodePoint:(CGPoint)pt;
@end

@interface NSCoder (NSKeyedGeometryCoding)
- (CGRect)decodeRectForKey:(NSString *)key;
- (CGSize)decodeSizeForKey:(NSString *)key;
- (CGPoint)decodePointForKey:(NSString *)key;
- (void)encodeRect:(CGRect)r forKey:(NSString *)key;
- (void)encodeSize:(CGSize)sz forKey:(NSString *)key;
- (void)encodePoint:(CGPoint)pt forKey:(NSString *)key;
@end

@interface NSCoder (Internal)
- (id)_decodePropertyListForKey:(NSString *)key;
- (void)_encodePropertyList:(id)plist forKey:(NSString *)key;
- (NSArray *)_decodeArrayOfObjectsForKey:(NSString *)key;
- (void)_encodeArrayOfObjects:(NSArray *)objects forKey:(NSString *)key;
@end

CF_PRIVATE
@interface _NSKeyedCoderOldStyleArray : NSObject
- (id)initWithCoder:(NSCoder *)decoder;
- (void)encodeWithCoder:(NSCoder *)coder;
- (void)fillObjCType:(char)type count:(NSUInteger)count at:(void *)addr;
- (void)dealloc;
- (id)initWithObjCType:(char)type count:(NSUInteger)count at:(const void *)addr;
@end
