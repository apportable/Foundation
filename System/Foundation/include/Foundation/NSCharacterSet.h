#import <CoreFoundation/CFCharacterSet.h>
#import <Foundation/NSObject.h>
#import <Foundation/NSRange.h>
#import <Foundation/NSString.h>

@class NSData;

enum {
    NSOpenStepUnicodeReservedBase = 0xF400
};

@interface NSCharacterSet : NSObject <NSCopying, NSMutableCopying, NSCoding>

+ (id)controlCharacterSet;
+ (id)whitespaceCharacterSet;
+ (id)whitespaceAndNewlineCharacterSet;
+ (id)decimalDigitCharacterSet;
+ (id)letterCharacterSet;
+ (id)lowercaseLetterCharacterSet;
+ (id)uppercaseLetterCharacterSet;
+ (id)nonBaseCharacterSet;
+ (id)alphanumericCharacterSet;
+ (id)decomposableCharacterSet;
+ (id)illegalCharacterSet;
+ (id)punctuationCharacterSet;
+ (id)capitalizedLetterCharacterSet;
+ (id)symbolCharacterSet;
+ (id)newlineCharacterSet;
+ (id)characterSetWithRange:(NSRange)range;
+ (id)characterSetWithCharactersInString:(NSString *)string;
+ (id)characterSetWithBitmapRepresentation:(NSData *)data;
+ (id)characterSetWithContentsOfFile:(NSString *)path;

- (BOOL)characterIsMember:(unichar)character;
- (NSData *)bitmapRepresentation;
- (NSCharacterSet *)invertedSet;
- (BOOL)longCharacterIsMember:(UTF32Char)character;
- (BOOL)isSupersetOfSet:(NSCharacterSet *)other;
- (BOOL)hasMemberInPlane:(uint8_t)plane;

@end

@interface NSMutableCharacterSet : NSCharacterSet <NSCopying, NSMutableCopying>

- (void)addCharactersInRange:(NSRange)range;
- (void)removeCharactersInRange:(NSRange)range;
- (void)addCharactersInString:(NSString *)string;
- (void)removeCharactersInString:(NSString *)string;
- (void)formUnionWithCharacterSet:(NSCharacterSet *)other;
- (void)formIntersectionWithCharacterSet:(NSCharacterSet *)other;
- (void)invert;

@end
