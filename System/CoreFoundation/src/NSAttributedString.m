//
//  NSAttributedString.m
//  CoreFoundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "NSAttributedStringInternal.h"
#import "NSObjectInternal.h"

@implementation NSAttributedString

@end

@implementation NSMutableAttributedString

@end

@implementation __NSCFAttributedString

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key
{
    return NO;
}

static BOOL _rangeCheckRange(__NSCFAttributedString *self, NSRange range)
{
    if ((uint64_t)range.location + range.length > [self length])
    {
        [NSException raise:NSRangeException format:@"range (%d,%d) beyond NSAttributedString bounds (%d)", range.location, range.length, [self length]];
        return NO;
    }
    return YES;
}

#define RANGE_CHECK_RANGE(val) if (!_rangeCheckRange(self, range)) return val;

static BOOL _rangeCheckIndex(__NSCFAttributedString *self, NSUInteger index)
{
    if (index > [self length])
    {
        [NSException raise:NSRangeException format:@"index (%d) beyond NSAttributedString bounds (%d)", index, [self length]];
        return NO;
    }
    return YES;
}

#define RANGE_CHECK_INDEX() if (!_rangeCheckIndex(self, index)) return 0;

- (void)removeAttribute:(NSString *)name range:(NSRange)range
{
    RANGE_CHECK_RANGE();
    CFAttributedStringRemoveAttribute((CFMutableAttributedStringRef)self, CFRangeMake(range.location, range.length), (CFStringRef) name);
}

- (void)addAttribute:(NSString *)name value:(id)value range:(NSRange)range
{
    NSDictionary *d = @{ name : value };
    [self addAttributes:d range:range];
}

- (void)addAttributes:(NSDictionary *)attrs range:(NSRange)range
{
    RANGE_CHECK_RANGE();
    CFAttributedStringSetAttributes((CFMutableAttributedStringRef)self, CFRangeMake(range.location, range.length), (CFDictionaryRef)attrs, false);
}

- (void)setAttributedString:(NSAttributedString *)attrString
{
    CFAttributedStringReplaceAttributedString((CFMutableAttributedStringRef)self, CFRangeMake(0, [self length]), (CFAttributedStringRef)attrString);
}
- (void)deleteCharactersInRange:(NSRange)range
{
    RANGE_CHECK_RANGE();
    CFAttributedStringReplaceString((CFMutableAttributedStringRef)self, CFRangeMake(range.location, range.length), CFSTR("")); 
}

- (void)appendAttributedString:(NSAttributedString *)attrString
{
    CFAttributedStringReplaceAttributedString((CFMutableAttributedStringRef)self, CFRangeMake([self length], 0), (CFAttributedStringRef)attrString);
}

- (void)insertAttributedString:(NSAttributedString *)attrString atIndex:(NSUInteger)loc
{
    CFAttributedStringReplaceAttributedString((CFMutableAttributedStringRef)self, CFRangeMake(loc, 0), (CFAttributedStringRef)attrString);
}
- (void)replaceCharactersInRange:(NSRange)range withAttributedString:(NSAttributedString *)attrString
{
    RANGE_CHECK_RANGE();
    CFAttributedStringReplaceAttributedString((CFMutableAttributedStringRef)self, CFRangeMake(range.location, range.length), (CFAttributedStringRef)attrString);
}

- (void)setAttributes:(NSDictionary *)attributes range:(NSRange)range
{
    RANGE_CHECK_RANGE();
    CFAttributedStringSetAttributes((CFMutableAttributedStringRef)self, CFRangeMake(range.location, range.length), (CFDictionaryRef)attributes, true);
}

- (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)string
{
    RANGE_CHECK_RANGE();
    CFAttributedStringReplaceString((CFMutableAttributedStringRef)self, CFRangeMake(range.location, range.length), (CFStringRef)string);
}

- (Class)classForCoder
{
    return [NSAttributedString self];
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    return (id)CFAttributedStringCreateMutableCopy(kCFAllocatorSystemDefault, 0, (CFAttributedStringRef)self);
}

- (id)copyWithZone:(NSZone *)zone
{
    return (id)CFAttributedStringCreateCopy(kCFAllocatorSystemDefault, (CFAttributedStringRef)self);
}

- (NSAttributedString *)attributedSubstringFromRange:(NSRange)range
{
    RANGE_CHECK_RANGE(nil);
    return [(NSAttributedString *)CFAttributedStringCreateWithSubstring(kCFAllocatorSystemDefault, 
        (CFAttributedStringRef)self, CFRangeMake(range.location, range.length)) autorelease];
}

- (NSDictionary *)attributesAtIndex:(NSUInteger)index longestEffectiveRange:(NSRangePointer)range inRange:(NSRange)rangeLimit
{
    RANGE_CHECK_INDEX();
    NSDictionary *retVal = (NSDictionary *)CFAttributedStringGetAttributesAndLongestEffectiveRange((CFAttributedStringRef)self, index, 
        CFRangeMake(rangeLimit.location, rangeLimit.length), (CFRange *)range);
    // CF doesn't zero out missing ranges
    if (retVal && range) {
        if ((signed)(range->length) <= 0)
        {
            *range = NSMakeRange(0,0);
        }
    }
    return retVal;
}

- (id)attribute:(NSString *)attrName atIndex:(NSUInteger)index longestEffectiveRange:(NSRangePointer)range inRange:(NSRange)rangeLimit
{
    RANGE_CHECK_INDEX();
    id retVal = (id)CFAttributedStringGetAttributeAndLongestEffectiveRange((CFAttributedStringRef)self, index, 
        (CFStringRef)attrName, CFRangeMake(rangeLimit.location, rangeLimit.length), (CFRange *)range);
    // CF doesn't zero out missing ranges
    if (retVal && range) {
        if ((signed)(range->length) <= 0)
        {
            *range = NSMakeRange(0,0);
        }
    }
    return retVal;
}

 - (id)attribute:(NSString *)attrName atIndex:(NSUInteger)index effectiveRange:(NSRangePointer)rangePtr
{
    RANGE_CHECK_INDEX();
    return CFAttributedStringGetAttribute((CFAttributedStringRef)self, index, (CFStringRef)attrName, (CFRange *)rangePtr);
}

- (NSUInteger)length
{
    return CFAttributedStringGetLength((CFAttributedStringRef)self);
}

- (NSDictionary *)attributesAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)aRange
{
    RANGE_CHECK_INDEX();
    return (NSDictionary *)CFAttributedStringGetAttributes((CFAttributedStringRef)self, index, (CFRange *)aRange);
}

- (NSString *)string
{
    return (NSString *)CFAttributedStringGetString((CFAttributedStringRef)self);
}

- (BOOL)isEqual:(id)other
{
    if (other == nil)
    {
        return NO;
    }
    return CFEqual((CFAttributedStringRef)self, (CFAttributedStringRef)other);
}

- (BOOL)isEqualToAttributedString:(NSAttributedString *)other
{
    if (other == nil)
    {
        return NO;
    }
    return CFEqual((CFAttributedStringRef)self, (CFAttributedStringRef)other);
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
    CFRelease(self);
}

- (id)retain
{
    return CFRetain(self);
}

@end
