//
//  NSCharacterSet.m
//  CoreFoundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/NSCharacterSet.h>
#import "NSCFType.h"
#import "CFInternal.h"
#import "NSObjectInternal.h"

extern Boolean __CFCharacterSetIsMutable(CFCharacterSetRef cset);
extern void CFCharacterSetFast(CFMutableCharacterSetRef theSet);
extern void CFCharacterSetCompact(CFMutableCharacterSetRef theSet);

CF_PRIVATE
@interface __NSCFCharacterSet : __NSCFType
@end

@implementation NSCharacterSet

+ (id)controlCharacterSet
{
    return (id)CFCharacterSetGetPredefined(kCFCharacterSetControl);
}

+ (id)whitespaceCharacterSet
{
    return (id)CFCharacterSetGetPredefined(kCFCharacterSetWhitespace);
}

+ (id)whitespaceAndNewlineCharacterSet
{
    return (id)CFCharacterSetGetPredefined(kCFCharacterSetWhitespaceAndNewline);
}

+ (id)decimalDigitCharacterSet
{
    return (id)CFCharacterSetGetPredefined(kCFCharacterSetDecimalDigit);
}

+ (id)letterCharacterSet
{
    return (id)CFCharacterSetGetPredefined(kCFCharacterSetLetter);
}

+ (id)lowercaseLetterCharacterSet
{
    return (id)CFCharacterSetGetPredefined(kCFCharacterSetLowercaseLetter);
}

+ (id)uppercaseLetterCharacterSet
{
    return (id)CFCharacterSetGetPredefined(kCFCharacterSetUppercaseLetter);
}

+ (id)nonBaseCharacterSet
{
    return (id)CFCharacterSetGetPredefined(kCFCharacterSetNonBase);
}

+ (id)alphanumericCharacterSet
{
    return (id)CFCharacterSetGetPredefined(kCFCharacterSetAlphaNumeric);
}

+ (id)decomposableCharacterSet
{
    return (id)CFCharacterSetGetPredefined(kCFCharacterSetDecomposable);
}

+ (id)illegalCharacterSet
{
    return (id)CFCharacterSetGetPredefined(kCFCharacterSetIllegal);
}

+ (id)punctuationCharacterSet
{
    return (id)CFCharacterSetGetPredefined(kCFCharacterSetPunctuation);
}

+ (id)capitalizedLetterCharacterSet
{
    return (id)CFCharacterSetGetPredefined(kCFCharacterSetCapitalizedLetter);
}

+ (id)symbolCharacterSet
{
    return (id)CFCharacterSetGetPredefined(kCFCharacterSetSymbol);
}

+ (id)newlineCharacterSet
{
    return (id)CFCharacterSetGetPredefined(kCFCharacterSetNewline);
}

+ (id)characterSetWithRange:(NSRange)range
{
    return [(NSCharacterSet *)CFCharacterSetCreateWithCharactersInRange(kCFAllocatorDefault, CFRangeMake(range.location, range.length)) autorelease];
}

+ (id)characterSetWithCharactersInString:(NSString *)string
{
    return [(NSCharacterSet *)CFCharacterSetCreateWithCharactersInString(kCFAllocatorDefault, (CFStringRef)string) autorelease];
}

+ (id)characterSetWithBitmapRepresentation:(NSData *)data
{
    return [(NSCharacterSet *)CFCharacterSetCreateWithBitmapRepresentation(kCFAllocatorDefault, (CFDataRef)data) autorelease];
}

+ (id)characterSetWithContentsOfFile:(NSString *)path
{
    return [self characterSetWithBitmapRepresentation:[NSData dataWithContentsOfMappedFile:path]];
}

- (id)init
{
    [self release];
    return (id)CFCharacterSetCreateWithCharactersInRange(kCFAllocatorDefault, CFRangeMake(0, 0));
}

- (BOOL)characterIsMember:(unichar)character
{
    NSRequestConcreteImplementation();
    return NO;
}

- (NSData *)bitmapRepresentation
{
    NSRequestConcreteImplementation();
    return nil;
}

- (NSCharacterSet *)invertedSet
{
    NSRequestConcreteImplementation();
    return nil;
}

- (BOOL)longCharacterIsMember:(UTF32Char)character
{
    NSRequestConcreteImplementation();
    return NO;
}

- (BOOL)isSupersetOfSet:(NSCharacterSet *)other
{
    NSRequestConcreteImplementation();
    return NO;
}

- (BOOL)hasMemberInPlane:(uint8_t)plane
{
    NSRequestConcreteImplementation();
    return NO;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    NSRequestConcreteImplementation();
    [self release];
    return nil;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    NSRequestConcreteImplementation();
}

- (id)copyWithZone:(NSZone *)zone
{
    NSRequestConcreteImplementation();
    return nil;
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    NSRequestConcreteImplementation();
    return nil;
}

- (CFTypeID)_cfTypeID
{
    return CFCharacterSetGetTypeID();
}

- (void)makeImmutable
{

}

- (BOOL)isMutable
{
    return NO;
}

- (CFCharacterSetRef)_expandedCFCharacterSet
{
    return NULL;
}

@end

@implementation NSMutableCharacterSet

+ (id)characterSetWithContentsOfFile:(NSString *)path
{
    return [[[NSCharacterSet characterSetWithContentsOfFile:path] mutableCopyWithZone:nil] autorelease];
}

+ (id)characterSetWithBitmapRepresentation:(NSData *)data
{
    return [[[NSCharacterSet characterSetWithBitmapRepresentation:data] mutableCopyWithZone:nil] autorelease];
}

+ (id)newlineCharacterSet
{
    return [[[NSCharacterSet newlineCharacterSet] mutableCopyWithZone:nil] autorelease];
}

+ (id)symbolCharacterSet
{
    return [[[NSCharacterSet symbolCharacterSet] mutableCopyWithZone:nil] autorelease];
}

+ (id)capitalizedLetterCharacterSet
{
    return [[[NSCharacterSet capitalizedLetterCharacterSet] mutableCopyWithZone:nil] autorelease];
}

+ (id)punctuationCharacterSet
{
    return [[[NSCharacterSet punctuationCharacterSet] mutableCopyWithZone:nil] autorelease];
}

+ (id)illegalCharacterSet
{
    return [[[NSCharacterSet illegalCharacterSet] mutableCopyWithZone:nil] autorelease];
}

+ (id)decomposableCharacterSet
{
    return [[[NSCharacterSet decomposableCharacterSet] mutableCopyWithZone:nil] autorelease];
}

+ (id)alphanumericCharacterSet
{
    return [[[NSCharacterSet alphanumericCharacterSet] mutableCopyWithZone:nil] autorelease];
}

+ (id)nonBaseCharacterSet
{
    return [[[NSCharacterSet nonBaseCharacterSet] mutableCopyWithZone:nil] autorelease];
}

+ (id)uppercaseLetterCharacterSet
{
    return [[[NSCharacterSet uppercaseLetterCharacterSet] mutableCopyWithZone:nil] autorelease];
}

+ (id)lowercaseLetterCharacterSet
{
    return [[[NSCharacterSet lowercaseLetterCharacterSet] mutableCopyWithZone:nil] autorelease];
}

+ (id)letterCharacterSet
{
    return [[[NSCharacterSet letterCharacterSet] mutableCopyWithZone:nil] autorelease];
}

+ (id)decimalDigitCharacterSet
{
    return [[[NSCharacterSet decimalDigitCharacterSet] mutableCopyWithZone:nil] autorelease];
}

+ (id)whitespaceAndNewlineCharacterSet
{
    return [[[NSCharacterSet whitespaceAndNewlineCharacterSet] mutableCopyWithZone:nil] autorelease];
}

+ (id)whitespaceCharacterSet
{
    return [[[NSCharacterSet whitespaceCharacterSet] mutableCopyWithZone:nil] autorelease];
}

+ (id)controlCharacterSet
{
    return [[[NSCharacterSet controlCharacterSet] mutableCopyWithZone:nil] autorelease];
}

+ (id)characterSetWithCharactersInString:(NSString *)string
{
    return [[[NSCharacterSet characterSetWithCharactersInString:string] mutableCopyWithZone:nil] autorelease];
}

+ (id)characterSetWithRange:(NSRange)range
{
    return [[[NSCharacterSet characterSetWithRange:range] mutableCopyWithZone:nil] autorelease];
}

- (void)addCharactersInRange:(NSRange)range
{
    NSRequestConcreteImplementation();
}

- (void)removeCharactersInRange:(NSRange)range
{
    NSRequestConcreteImplementation();
}

- (void)addCharactersInString:(NSString *)string
{
    NSRequestConcreteImplementation();
}

- (void)removeCharactersInString:(NSString *)string
{
    NSRequestConcreteImplementation();
}

- (void)formUnionWithCharacterSet:(NSCharacterSet *)other
{
    NSRequestConcreteImplementation();
}

- (void)formIntersectionWithCharacterSet:(NSCharacterSet *)other
{
    NSRequestConcreteImplementation();
}

- (void)invert
{
    NSRequestConcreteImplementation();
}

- (BOOL)isMutable
{
    return YES;
}

@end

@implementation __NSCFCharacterSet

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key
{
    return NO;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    
}

- (Class)classForCoder
{
    if (__CFCharacterSetIsMutable((CFCharacterSetRef)self))
    {
        return [NSMutableCharacterSet class];
    }
    else
    {
        return [NSCharacterSet class];
    }
}

- (Class)classForKeyedArchiver
{
    if (__CFCharacterSetIsMutable((CFCharacterSetRef)self))
    {
        return [NSMutableCharacterSet class];
    }
    else
    {
        return [NSCharacterSet class];
    }
}

- (void)makeCharacterSetFast
{
    if (__CFCharacterSetIsMutable((CFCharacterSetRef)self))
    {
        CFCharacterSetFast((CFMutableCharacterSetRef)self);
    }
}

- (void)makeCharacterSetCompact
{
    if (__CFCharacterSetIsMutable((CFCharacterSetRef)self))
    {
        CFCharacterSetCompact((CFMutableCharacterSetRef)self);
    }
}

- (void)invert
{
    if (__CFCharacterSetIsMutable((CFCharacterSetRef)self))
    {
        CFCharacterSetInvert((CFMutableCharacterSetRef)self);
    }
}

- (void)formIntersectionWithCharacterSet:(NSCharacterSet *)other
{
    if (__CFCharacterSetIsMutable((CFCharacterSetRef)self))
    {
        CFCharacterSetIntersect((CFMutableCharacterSetRef)self, (CFCharacterSetRef)other);
    }
}

- (void)formUnionWithCharacterSet:(NSCharacterSet *)other
{
    if (__CFCharacterSetIsMutable((CFCharacterSetRef)self))
    {
        CFCharacterSetUnion((CFMutableCharacterSetRef)self, (CFCharacterSetRef)other);
    }
}

- (void)removeCharactersInString:(NSString *)string
{
    if (__CFCharacterSetIsMutable((CFCharacterSetRef)self))
    {
        CFCharacterSetRemoveCharactersInString((CFMutableCharacterSetRef)self, (CFStringRef)string);
    }
}

- (void)addCharactersInString:(NSString *)string
{
    if (__CFCharacterSetIsMutable((CFCharacterSetRef)self))
    {
        CFCharacterSetAddCharactersInString((CFMutableCharacterSetRef)self, (CFStringRef)string);
    }
}

- (void)removeCharactersInRange:(NSRange)range
{
    if (__CFCharacterSetIsMutable((CFCharacterSetRef)self))
    {
        CFCharacterSetRemoveCharactersInRange((CFMutableCharacterSetRef)self, CFRangeMake(range.location, range.length));
    }
}

- (void)addCharactersInRange:(NSRange)range
{
    if (__CFCharacterSetIsMutable((CFCharacterSetRef)self))
    {
        CFCharacterSetAddCharactersInRange((CFMutableCharacterSetRef)self, CFRangeMake(range.location, range.length));
    }
}

- (NSCharacterSet *)invertedSet
{
    return [(NSCharacterSet *)CFCharacterSetCreateInvertedSet(kCFAllocatorDefault, (CFCharacterSetRef)self) autorelease];
}

- (NSData *)bitmapRepresentation
{
    return [(NSData *)CFCharacterSetCreateBitmapRepresentation(kCFAllocatorDefault, (CFCharacterSetRef)self) autorelease];
}

- (BOOL)hasMemberInPlane:(uint8_t)plane
{
    return CFCharacterSetHasMemberInPlane((CFCharacterSetRef)self, plane);
}

- (BOOL)isSupersetOfSet:(id)other
{
    return CFCharacterSetIsSupersetOfSet((CFCharacterSetRef)self, (CFCharacterSetRef)other);
}

- (BOOL)longCharacterIsMember:(UTF32Char)character
{
    return CFCharacterSetIsLongCharacterMember((CFCharacterSetRef)self, character);
}

- (BOOL)characterIsMember:(unichar)character
{
    return CFCharacterSetIsCharacterMember((CFCharacterSetRef)self, character);
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    return (id)CFCharacterSetCreateMutableCopy(kCFAllocatorDefault, (CFCharacterSetRef)self);
}

- (id)copyWithZone:(NSZone *)zone
{
    return (id)CFCharacterSetCreateCopy(kCFAllocatorDefault, (CFCharacterSetRef)self);
}

- (NSUInteger)retainCount
{
    return CFGetRetainCount((CFTypeRef)self);
}

- (BOOL)_isDeallocating
{
    return _CFIsDeallocating((CFTypeRef)self);
}

- (BOOL)_tryRetain
{
    return _CFTryRetain((CFTypeRef)self) != NULL;
}

- (oneway void)release
{
    CFRelease((CFTypeRef)self);
}

- (id)retain
{
    return (id)CFRetain((CFTypeRef)self);
}

- (NSUInteger)hash
{
    return CFHash((CFTypeRef)self);
}

- (BOOL)isEqual:(id)other
{
    if (other == nil)
    {
        return NO;
    }
    return CFEqual((CFTypeRef)self, (CFTypeRef)other);
}

@end
