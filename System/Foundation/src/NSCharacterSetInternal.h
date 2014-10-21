#import <Foundation/NSCharacterSet.h>
#import "NSCFType.h"

__attribute__((visibility("hidden")))
@interface __NSCFCharacterSet : __NSCFType

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key;
- (void)encodeWithCoder:(NSCoder *)coder;
- (Class)classForKeyedArchiver;
- (void)makeCharacterSetFast;
- (void)makeCharacterSetCompact;
- (void)invert;
- (void)formIntersectionWithCharacterSet:(NSCharacterSet *)other;
- (void)formUnionWithCharacterSet:(NSCharacterSet *)other;
- (void)removeCharactersInString:(NSString *)string;
- (void)addCharactersInString:(NSString *)string;
- (void)removeCharactersInRange:(NSRange)range;
- (void)addCharactersInRange:(NSRange)range;
- (NSCharacterSet *)invertedSet;
- (NSData *)bitmapRepresentation;
- (BOOL)hasMemberInPlane:(uint8_t)plane;
- (BOOL)isSupersetOfSet:(NSCharacterSet *)other;
- (BOOL)longCharacterIsMember:(UTF32Char)character;
- (BOOL)characterIsMember:(unichar)character;
- (id)mutableCopyWithZone:(NSZone *)zone;
- (id)copyWithZone:(NSZone *)zone;
- (NSUInteger)retainCount;
- (BOOL)_isDeallocating;
- (BOOL)_tryRetain;
- (oneway void)release;
- (id)retain;
- (NSUInteger)hash;
- (BOOL)isEqual:(id)other;

@end
