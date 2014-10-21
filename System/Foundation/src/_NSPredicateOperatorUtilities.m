//
//  _NSPredicateOperatorUtilities.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <unicode/uregex.h>

#import "_NSPredicateOperatorUtilities.h"

#import "NSMatchingPredicateOperator.h"

@implementation _NSPredicateOperatorUtilities

+ (long long)copyRegexFindSafePattern:(NSString *)pattern toBuffer:(unichar *)buffer
{
#warning TODO predicates
    DEBUG_BREAK();
    return 0;
}
static UChar* get_or_copy_uchar_buffer(NSString *inString, BOOL *outBufferNeedsFree)
{
    UChar* buffer = (UChar *)CFStringGetCharactersPtr((CFStringRef)inString);
    if (!buffer) {
        int32_t len = [inString length];
        // CFStringGetCharactersPtr may or may not fail (it only
        // succeeds if it already has a buffer around, and doesn't
        // try to create/copy/make one for you.)
        buffer = malloc(sizeof(*buffer) * len);
        if (!buffer) {
            return nil;
        }
        CFStringGetCharacters((CFStringRef)inString,
                              CFRangeMake(0, len),
                              (UniChar*)buffer);
        *outBufferNeedsFree = YES;
    } else {
        *outBufferNeedsFree = NO;
    }
    return buffer;
}

static NSString* make_string_with_flags(NSString *string, NSComparisonPredicateOptions flags)
{
    if ((flags & NSDiacriticInsensitivePredicateOption) != 0) {
        NSString *aMutableString = [[string mutableCopy] autorelease];
        // NULL locale means the canonical locale e.g. from CFLocaleGetSystem
        CFStringFold((CFMutableStringRef)aMutableString, kCFCompareDiacriticInsensitive, NULL);
        string = aMutableString;
    }
    return string;
}

+ (BOOL)doRegexForString:(NSString *)string pattern:(NSString *)pattern likeProtect:(BOOL)protect flags:(NSComparisonPredicateOptions)flags context:(struct regexContext *)comntext
{
    NSString* origPattern = pattern;

    // stricter for pattern since '*' is expanded to two chars '.*'
    if ([pattern length] > (INT32_MAX / 2) ||
        [string length]  > INT32_MAX) {
        [NSException raise:NSInternalInconsistencyException format:@"Invalid string/pattern length too long"];
        return NO;
    }

    UErrorCode uErrorCode = 0;
    UParseError uParseError = {0};
    BOOL res = NO;

    // Use cached regex, or create one if needed
    // caller will set _field2 (old regex) to NULL (which is the original string pattern) if _field1 (old pattern) didn't match.
    // If _field2 exists, it is still valid for this call.
    // TODO: cached regex assumes (possibly wrongly) options don't matter
    // (options may possibly be set on top of the existing regex).
    // also assumes _field1 is nil if _field2 is NULL.
    if (!comntext->_field2) {
        if (protect) {
            // Match '*' and '?' but not '\*' and '\?'
            pattern = [pattern stringByReplacingOccurrencesOfString:@"\\*(?<!\\\\)" withString:@".*" options:NSRegularExpressionSearch range:NSMakeRange(0, [pattern length])];

            // '?' in like predicates means 'match any character once', so it translates to '.' in regex.
            pattern = [pattern stringByReplacingOccurrencesOfString:@"\\?(?<!\\\\)" withString:@"." options:NSRegularExpressionSearch range:NSMakeRange(0, [pattern length])];
        }

        pattern = make_string_with_flags(pattern, flags);

        // convert NSString to UChar.
        // UniChar is typdef unsigned short and should be compatible with UChar
        UChar *patternBuffer;
        int32_t patternLength = [pattern length];
        BOOL patternBufferNeedsFree;
        // no modification needed case can use direct get, just have to
        // cast from (UniChar *)
        patternBuffer = get_or_copy_uchar_buffer(pattern, &patternBufferNeedsFree);
        if (!patternBuffer) {
            // out of memory
            return NO;
        }

        // open regex
        // error codes must be zeroed (even though they are for output)
        // TODO: use flags
        uint32_t uFlags = 0;
        if ((flags & NSCaseInsensitivePredicateOption) != 0) {
            uFlags |= UREGEX_CASE_INSENSITIVE;
        }

        comntext->_field2 = uregex_open(patternBuffer,
                                        patternLength,
                                        uFlags,
                                        &uParseError,
                                        &uErrorCode);

        if (patternBufferNeedsFree) {
            free(patternBuffer);
        }

        if (U_FAILURE(uErrorCode)) {
            return NO;
        }
        comntext->_field1 = [origPattern retain];
    }

    /*
      TODO: The following options are not supported yet,
      probably require string translations.
      NSLocaleSensitivePredicateOption
    */

    string = make_string_with_flags(string, flags);

    // set string to search in
    UChar *contentStringBuffer;
    int32_t contentStringLength = [string length];
    BOOL contentBufferNeedsFree;

    contentStringBuffer = get_or_copy_uchar_buffer(string, &contentBufferNeedsFree);

    if (!contentStringBuffer) {
        // out of memory
        return NO;
    }

    uErrorCode = 0;
    uregex_setText(comntext->_field2,
                   contentStringBuffer,
                   contentStringLength,
                   &uErrorCode);

    if (!U_FAILURE(uErrorCode)) {
        // match regex
        uErrorCode = 0;
        res = uregex_matches(comntext->_field2, 0, &uErrorCode);
    }

    // free the content string
    // (regex match operates directly on this buffer)
    if (contentBufferNeedsFree) {
        free(contentStringBuffer);
    }

    return res;
}

+ (NSString *)newStringFrom:(id)source usingUnicodeTransforms:(CFStringCompareFlags)transforms
{
#warning TODO predicates
    DEBUG_BREAK();
    return nil;
}

+ (CFLocaleRef)retainedLocale
{
#warning TODO predicates
    DEBUG_BREAK();
    return NULL;
}

@end
