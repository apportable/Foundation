//
//  NSRegularExpression.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/NSRegularExpression.h>

#import <Foundation/NSArray.h>
#import <Foundation/NSCharacterSet.h>
#import <Foundation/NSError.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSException.h>
#import "NSErrorInternal.h"
#import "NSRegularExpressionCheckingResult.h"
#import <dispatch/dispatch.h>
#import <unicode/uregex.h>
#import <unicode/uclean.h>
#import <unicode/udata.h>
#import <CoreFoundation/CFString.h>

@implementation NSRegularExpression

+ (NSRegularExpression *)regularExpressionWithPattern:(NSString *)pattern options:(NSRegularExpressionOptions)options error:(NSError **)error
{
    return [[[self alloc] initWithPattern:pattern options:options error:error] autorelease];
}

+ (NSString *)escapedPatternForString:(NSString *)string
{
    static NSCharacterSet *regexCharacters = nil;
    static dispatch_once_t once = 0L;
    dispatch_once(&once, ^{
        regexCharacters = [[NSCharacterSet characterSetWithCharactersInString:@"$^*()+[]{}\\|./"] retain];
    });
    NSRange search = NSMakeRange(0, [string length]);
    NSMutableString *escaped = [string mutableCopy];
    while (search.length > 0)
    {
        NSRange found = [escaped rangeOfCharacterFromSet:regexCharacters options:0 range:search];
        [escaped insertString:@"\\" atIndex:found.location];
        search.location = NSMaxRange(found) + 1;
        search.length += 1;
    }

    return [escaped autorelease];
}

- (id)initWithPattern:(NSString *)pattern options:(NSRegularExpressionOptions)options error:(NSError **)error
{
    self = [super init];
    if (self)
    {
        if (pattern == nil)
        {
            [NSException raise:NSInvalidArgumentException format:@"pattern is nil"];
            [self release];
            return nil;
        }
        if ((options & NSRegularExpressionIgnoreMetacharacters) != 0)
        {
            _pattern = [[NSRegularExpression escapedPatternForString:pattern] copy];
        }
        else
        {
            _pattern = [pattern copy];
        }

        BOOL needsFree = NO;
        int32_t len = (int32_t)[_pattern length];
        const UChar *pat = CFStringGetCharactersPtr((CFStringRef)_pattern);
        if (pat == NULL)
        {
            pat = malloc(sizeof(UChar) * len);
            if (pat == NULL)
            {
                if (error != NULL)
                {
                    *error = [NSError _outOfMemoryError];
                }
                [self release];
                return nil;
            }
            [pattern getCharacters:(unichar *)pat range:NSMakeRange(0, len)];
            needsFree = YES;
        }
        UParseError parse_err = { 0 };
        UErrorCode status = 0;

        uint32_t flags = 0;
        if ((options & NSRegularExpressionCaseInsensitive) != 0)
        {
            flags |= UREGEX_CASE_INSENSITIVE;
        }
        if ((options & NSRegularExpressionAllowCommentsAndWhitespace) != 0)
        {
            flags |= UREGEX_COMMENTS;
        }
        if ((options & NSRegularExpressionDotMatchesLineSeparators) != 0)
        {
            flags |= UREGEX_DOTALL;
        }
        if ((options & NSRegularExpressionAnchorsMatchLines) != 0)
        {
            flags |= UREGEX_MULTILINE;
        }
        if ((options & NSRegularExpressionUseUnixLineSeparators) != 0)
        {
            flags |= UREGEX_UNIX_LINES;
        }
        if ((options & NSRegularExpressionUseUnicodeWordBoundaries) != 0)
        {
            flags |= UREGEX_UWORD;
        }
        _internal = uregex_open(pat, len, flags, &parse_err, &status);
        if (needsFree)
        {
            free((void *)pat);
        }
        if (_internal == NULL)
        {
            if (error)
            {
                *error = [NSError errorWithDomain:@"NSRegularExpressionError" code:status userInfo:@{
                      @"line" : @(parse_err.line),
                    @"offset" : @(parse_err.offset),
                }];
            }
            [self release];
            return nil;
        }
    }
    return self;
}

- (void)dealloc
{
    if (_internal)
    {
        uregex_close(_internal);
    }
    [super dealloc];
}

- (NSUInteger)numberOfCaptureGroups
{
    NSUInteger count = 0;
    URegularExpression *regexp = (URegularExpression *)_internal;
    if (regexp != NULL)
    {
        UErrorCode status = 0;
        count = uregex_groupCount(regexp, &status);
#warning TODO https://code.google.com/p/apportable/issues/detail?id=251
    }
    return count;
}

@end

@implementation NSRegularExpression (NSMatching)

typedef UBool (^matchBlock)(int32_t steps);
typedef UBool (^findProgressBlock)(int64_t matchIndex);

static UBool enumerateMatchCallback(const void *context, int32_t steps)
{
    return ((matchBlock)context)(steps);
}

static UBool enumerateFindProgressCallback(const void *context, int64_t matchIndex)
{
    return ((findProgressBlock)context)(matchIndex);
}

- (void)enumerateMatchesInString:(NSString *)string options:(NSMatchingOptions)options range:(NSRange)range usingBlock:(void (^)(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop))block
{
    if (string == nil)
    {
        [NSException raise:NSInvalidArgumentException format:@"Nil string passed to NSRegularExpression API"];
        return;
    }

    URegularExpression *regexp = (URegularExpression *)_internal;
    const UChar *text = CFStringGetCharactersPtr((CFStringRef)string);
    NSUInteger captureGroups = [self numberOfCaptureGroups];
    int32_t len = (int32_t)[string length];
    BOOL needsFree = NO;
    if (text == NULL)
    {
        text = malloc(sizeof(UChar) * len);
        [string getCharacters:(unichar *)text range:NSMakeRange(0, len)];
        needsFree = YES;
    }

    UErrorCode error = U_ZERO_ERROR;
    uregex_setText(regexp, text, len, &error);
    matchBlock match = ^UBool(int32_t matchIndex) {
        UBool shouldStop = FALSE;
        NSTextCheckingResult *result = nil;
        NSMatchingFlags flags = 0;
        block(result, flags, &shouldStop);
        return (UBool)!shouldStop;
    };
    findProgressBlock findProgress = ^UBool(int64_t matchIndex) {
        UBool shouldStop = TRUE;
        NSMatchingFlags flags = NSMatchingProgress;
        NSTextCheckingResult *result = nil;
        block(result, flags, &shouldStop);
        return (UBool)!shouldStop;
    };

    if (U_SUCCESS(error))
    {
        if ((options & NSMatchingWithoutAnchoringBounds) != 0)
        {
            uregex_useAnchoringBounds(regexp, NO, &error);
        }
        else if ((options & NSMatchingAnchored) != 0)
        {
            uregex_useAnchoringBounds(regexp, YES, &error);
        }
    }

    if (U_SUCCESS(error))
    {
        if ((options & NSMatchingWithTransparentBounds) != 0)
        {
            uregex_useTransparentBounds(regexp, YES, &error);
        }
        else
        {
            uregex_useTransparentBounds(regexp, NO, &error);
        }
    }

    if (U_SUCCESS(error))
    {
        if ((options & NSMatchingReportProgress) != 0)
        {
            uregex_setFindProgressCallback(regexp, &enumerateFindProgressCallback, findProgress, &error);
        }
    }

    if (U_SUCCESS(error))
    {
        if ((options & NSMatchingReportCompletion) != 0)
        {
            uregex_setMatchCallback(regexp, &enumerateMatchCallback, match, &error);
        }
    }

    if (U_SUCCESS(error))
    {
        uregex_setRegion64(regexp, range.location, range.length, &error);
    }

    BOOL shouldStop = NO;
    while (U_SUCCESS(error) && !shouldStop && uregex_findNext(regexp, &error))
    {
        NSUInteger rangeCount = captureGroups + 1;
        NSRange ranges[rangeCount];
        for (int i = 0; U_SUCCESS(error) && i < rangeCount; i++)
        {
            int64_t location = uregex_start64(regexp, i, &error);
            if (U_SUCCESS(error))
            {
                ranges[i].location = location == -1 ? NSNotFound : location;
                ranges[i].length = uregex_end64(regexp, i, &error) - location;
            }
        }

        NSTextCheckingResult *result = nil;
        if (U_SUCCESS(error))
        {
            result = [NSTextCheckingResult regularExpressionCheckingResultWithRanges:ranges count:rangeCount regularExpression:self];
        }

        NSMatchingFlags flags = 0;
        if (U_SUCCESS(error) && uregex_hitEnd(regexp, &error))
        {
            flags |= NSMatchingHitEnd;
        }

        if (U_SUCCESS(error) && uregex_requireEnd(regexp, &error))
        {
            flags |= NSMatchingRequiredEnd;
        }

        if (U_SUCCESS(error))
        {
            block(result, flags, &shouldStop);
        }
    }

    if (options & NSMatchingReportCompletion)
    {
        NSMatchingFlags flags = 0;
        if (U_SUCCESS(error) && uregex_hitEnd(regexp, &error))
        {
            flags |= NSMatchingHitEnd;
        }

        if (U_SUCCESS(error) && uregex_requireEnd(regexp, &error))
        {
            flags |= NSMatchingRequiredEnd;
        }

        if (U_SUCCESS(error))
        {
            block(nil, flags | NSMatchingCompleted, &shouldStop);
        }
    }
    
    if (needsFree)
    {
        free((UChar *)text);
    }

    if (U_FAILURE(error))
    {
        DEBUG_LOG("ICU failure %s (%d)", u_errorName(error), (int)error);
    }
}

- (NSArray *)matchesInString:(NSString *)string options:(NSMatchingOptions)options range:(NSRange)range
{
    NSMutableArray *matches = [[NSMutableArray alloc] init];
    [self enumerateMatchesInString:string options:options range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        [matches addObject:result];
    }];
    return [matches autorelease];
}

- (NSUInteger)numberOfMatchesInString:(NSString *)string options:(NSMatchingOptions)options range:(NSRange)range
{
    __block NSUInteger count = 0;
    [self enumerateMatchesInString:string options:options range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        count++;
    }];
    return count;
}

- (NSTextCheckingResult *)firstMatchInString:(NSString *)string options:(NSMatchingOptions)options range:(NSRange)range
{
    __block NSTextCheckingResult *first = nil;
    [self enumerateMatchesInString:string options:options range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        first = result;
        *stop = YES;
    }];
    return first;
}

- (NSRange)rangeOfFirstMatchInString:(NSString *)string options:(NSMatchingOptions)options range:(NSRange)range
{
    __block NSRange found = NSMakeRange(NSNotFound, 0);
    [self enumerateMatchesInString:string options:options range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        found = result.range;
        *stop = YES;
    }];
    return found;
}

- (NSString *)replacementStringForResult:(NSTextCheckingResult *)result inString:(NSString *)string offset:(NSInteger)offset template:(NSString *)templ
{
    static dispatch_once_t once = 0L;
    static NSCharacterSet *replacementCharacterSet = nil;
    dispatch_once(&once, ^{
        replacementCharacterSet = [[NSCharacterSet characterSetWithCharactersInString:@"\\$"] retain];
    });

    if (result == nil || string == nil || templ == nil)
    {
        [NSException raise:NSInvalidArgumentException format:@"nil argument"];
        return nil;
    }
    NSRange r = [templ rangeOfCharacterFromSet:replacementCharacterSet];
    if (r.location == NSNotFound)
    {
        return templ;
    }

    NSUInteger rangeCount = [result numberOfRanges];
    NSMutableString *str = [NSMutableString stringWithString:templ];
    unichar last = 0;
    for (NSUInteger idx = 0; idx < [str length]; idx++)
    {
        unichar ch = [str characterAtIndex:idx];

        if (ch == '\\' && last == '\\')
        {
            [str replaceCharactersInRange:NSMakeRange(idx - 1, 2) withString:@"\\"];

            // Decrementing idx to account for mutated result string
            idx--;
            // Prevent _next_ character from being escaped
            last = 0;
            continue;
        }
        else if (ch == '$' && last == '\\')
        {
            [str replaceCharactersInRange:NSMakeRange(idx - 1, 2) withString:@"$"];

            // Decrementing idx to account for mutated result string
            idx--;
        }
        else if (ch == '$')
        {
            if (idx < [str length] - 1)
            {
                unichar nextch = [str characterAtIndex:idx + 1];
         
                if ('0' <= nextch && nextch <= '9')
                {
                    NSUInteger ridx = nextch - '0';
                    NSString *repl = @"";
         
                    if (ridx < rangeCount)
                    {
                        repl = [string substringWithRange:[result rangeAtIndex:ridx]];
                    }
         
                    [str replaceCharactersInRange:NSMakeRange(idx, 2) withString:repl];
                    idx += [repl length];
                }
            }
        }

        last = ch;
    }

    return str;
}

- (NSString *)stringByReplacingMatchesInString:(NSString *)string options:(NSMatchingOptions)options range:(NSRange)range withTemplate:(NSString *)templ
{
    if (string == nil)
    {
        [NSException raise:NSInvalidArgumentException format:@"source string cannot be nil"];
        return nil;
    }

    NSMutableString *result = [NSMutableString string];

    NSArray *matches = [self matchesInString:string options:options range:range];
    NSUInteger lastLoc = 0;
    for (NSTextCheckingResult *match in matches)
    {
        NSRange matchRange = [match range];
        
        if (matchRange.length == 0)
        {
            continue;
        }

        NSString *replacement = [self replacementStringForResult:match inString:string offset:0 template:templ];
        if (lastLoc < matchRange.location)
        {
            [result appendString:[string substringWithRange:NSMakeRange(lastLoc, matchRange.location - lastLoc)]];
        }
        [result appendString:replacement];
        lastLoc = NSMaxRange(matchRange);
    }
    NSUInteger length = [string length];

    if (lastLoc < length)
    {
        [result appendString:[string substringWithRange:NSMakeRange(lastLoc, length - lastLoc)]];
    }

    return result;
}

- (NSUInteger)replaceMatchesInString:(NSMutableString *)string options:(NSMatchingOptions)options range:(NSRange)range withTemplate:(NSString *)templ
{
    if (string == nil)
    {
        [NSException raise:NSInvalidArgumentException format:@"source string cannot be nil"];
        return 0;
    }

    NSMutableString *result = [NSMutableString string];

    NSArray *matches = [self matchesInString:string options:options range:range];
    NSUInteger lastLoc = 0;
    for (NSTextCheckingResult *match in matches)
    {
        NSRange matchRange = [match range];
        
        if (matchRange.length == 0)
        {
            continue;
        }

        NSString *replacement = [self replacementStringForResult:match inString:string offset:0 template:templ];
        if (lastLoc < matchRange.location)
        {
            [result appendString:[string substringWithRange:NSMakeRange(lastLoc, matchRange.location - lastLoc)]];
        }
        [result appendString:replacement];
        lastLoc = NSMaxRange(matchRange);
    }
    NSUInteger length = [string length];

    if (lastLoc < length)
    {
        [result appendString:[string substringWithRange:NSMakeRange(lastLoc, length - lastLoc)]];
    }

    // https://code.google.com/p/apportable/issues/detail?id=614 incorrect funneling
    [string setString:result];

    return [matches count];
}

- (NSString *)description
{  
    return [NSString stringWithFormat:@"%@{pattern = %@}", [super description], _pattern];
}

@end
