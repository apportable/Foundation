//
//  NSJSONSerialization.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/NSJSONSerialization.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSData.h>
#import <Foundation/NSDecimalNumber.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSError.h>
#import <Foundation/NSNull.h>
#import <Foundation/NSStream.h>
#import <Foundation/NSString.h>
#import "NSObjectInternal.h"
#import "NSBOMEncoding.h"

@interface _NSJSONReader : NSObject
@end

@interface _NSJSONWriter : NSObject
- (int)appendString:(NSString *)string range:(NSRange)range;
@end

@implementation _NSJSONReader {
    id input;
    NSJSONReadingOptions kind;
    NSError *error;
}

+ (BOOL)validForJSON:(id)obj depth:(NSUInteger)depth allowFragments:(BOOL)frags
{
    BOOL isString = [obj isNSString__];
    BOOL isNumber = [obj isNSNumber__];
    BOOL isArray = [obj isNSArray__];
    BOOL isDictionary = [obj isNSDictionary__];
    BOOL isNull = obj == [NSNull null];

    if (isString || isNumber || isNull)
    {
        if (depth == 1 && frags)
        {
            return YES;
        }
        else if (depth == 0)
        {
            return NO;
        }
        return YES;
    }
    else if (isArray)
    {
        for (id item in (NSArray *)obj)
        {
            if (![_NSJSONReader validForJSON:item depth:depth + 1 allowFragments:frags])
            {
                return NO;
            }
        }
        return YES;
    }
    else if (isDictionary)
    {
        for (id key in (NSDictionary *)obj)
        {
            id item = [(NSDictionary *)obj objectForKey:key];
            if (![_NSJSONReader validForJSON:key depth:depth + 1 allowFragments:frags])
            {
                return NO;
            }
            if (![_NSJSONReader validForJSON:item depth:depth + 1 allowFragments:frags])
            {
                return NO;
            }
        }
        return YES;
    }
    return NO;
}

- (id)init
{
    self = [super init];
    if (self)
    {

    }
    return self;
}

- (void)dealloc
{
    [input release];
    [error release];
    [super dealloc];
}

- (id)parseStream:(NSInputStream *)stream options:(NSJSONReadingOptions)opts
{
    id parsed = nil;
    if (kind == 0)
    {
        NSMutableData *data = [[NSMutableData alloc] init];

        while ([stream hasBytesAvailable])
        {
            uint8_t *buffer = NULL;
            NSUInteger len = 0;
            BOOL needsFree = NO;
            if (![stream getBuffer:&buffer length:&len])
            {
                len = 1024;
                buffer = malloc(len);
                needsFree = YES;
                len = [stream read:buffer maxLength:len];
            }

            [data appendBytes:buffer length:len];

            if (needsFree)
            {
                free(buffer);
            }
        }
        NSStreamStatus status = [stream streamStatus];
        if (status == NSStreamStatusError)
        {
            [self setError:[stream streamError]];
        }
        parsed = [self parseData:data options:opts];
        [data release];
    }
    return parsed;
}

- (id)parseData:(NSData *)data options:(NSJSONReadingOptions)opts
{
    id parsed = nil;
    if (kind == 0)
    {
        NSUInteger bom = 0;
        NSStringEncoding encoding = [self findEncodingFromData:data withBOMSkipLength:&bom];
        if (encoding != NSUTF8StringEncoding)
        {
            NSString *str = [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:encoding];
            data = [str dataUsingEncoding:NSUTF8StringEncoding];
            [str release];
            if (data == nil)
            {
                // TODO: fault here with an error?
                // and how can this even reasonably happen? JSON
                return nil;
            }
        }
        return [self parseUTF8JSONData:data skipBytes:bom options:opts];
    }
    return [parsed autorelease];
}

- (NSStringEncoding)findEncodingFromData:(NSData *)data withBOMSkipLength:(NSUInteger *)bomLength
{
    NSStringEncoding encoding = NSUTF8StringEncoding;
    uint32_t BOM;

    if ([data length] > 4)
    {
        [data getBytes:&BOM length:4];
        _NSDetectEncodingFromBOM(BOM, &encoding, bomLength);
    }

    return encoding;
}

static inline unichar incrementBuffer(unichar **buffer) {
    *buffer = *buffer + 1;
    return **buffer;
}

static inline BOOL is_utf8_whitespace(unichar *buffer) {
    if (isspace(*buffer)) {
        return YES;
    }
    // TODO: does JSON support other whitespace characters other than 0x20, 0x09, 0x0a, 0x0b, 0x0c, and 0x0d?
    /*
     U+0020  SPACE
     U+00A0  NO-BREAK SPACE
     U+1680  OGHAM SPACE MARK
     U+180E  MONGOLIAN VOWEL SEPARATOR
     U+2000  EN QUAD
     U+2001  EM QUAD
     U+2002  EN SPACE
     U+2003  EM SPACE
     U+2004  THREE-PER-EM SPACE
     U+2005  FOUR-PER-EM SPACE
     U+2006  SIX-PER-EM SPACE
     U+2007  FIGURE SPACE
     U+2008  PUNCTUATION SPACE
     U+2009  THIN SPACE
     U+200A  HAIR SPACE
     U+200B  ZERO WIDTH SPACE
     U+202F  NARROW NO-BREAK SPACE
     U+205F  MEDIUM MATHEMATICAL SPACE
     U+3000  IDEOGRAPHIC SPACE
     U+FEFF  ZERO WIDTH NO-BREAK SPACE
     */
    return NO;
}

static inline BOOL is_surrogate_lead(unichar c)
{
    return 0xD800 <= c && c <= 0xDBFF;
}

static inline BOOL is_surrogate_trail(unichar c)
{
    return 0xDC00 <= c && c <= 0xDFFF;
}

static inline BOOL skipWhitespace(_NSJSONReader *reader, unichar **buffer) {
    unichar *data = *buffer;
    BOOL success = YES;

    while (is_utf8_whitespace(data)) {
        if (!incrementBuffer(&data)) {
            success = NO;
            [reader setError:[NSError errorWithDomain:NSCocoaErrorDomain code:-1 userInfo:@{
                NSLocalizedDescriptionKey: @"unexpected end of document"
            }]];
            break;
        }
    }

    *buffer = data;
    return success;
}

static inline NSDictionary *parseDictionary(_NSJSONReader *reader, unichar **buffer, NSJSONReadingOptions opts, NSUInteger depth);
static inline NSArray *parseArray(_NSJSONReader *reader, unichar **buffer, NSJSONReadingOptions opts, NSUInteger depth);
static inline NSString *parseString(_NSJSONReader *reader, unichar **buffer, NSJSONReadingOptions opts, NSUInteger depth);
static inline NSNumber *parseNumber(_NSJSONReader *reader, unichar **buffer, NSJSONReadingOptions opts, NSUInteger depth);
static inline NSNumber *parseBoolean(_NSJSONReader *reader, unichar **buffer, NSJSONReadingOptions opts, NSUInteger depth);
static inline NSNull *parseNull(_NSJSONReader *reader, unichar **buffer, NSJSONReadingOptions opts, NSUInteger depth);
static inline id parseObject(_NSJSONReader *reader, unichar **buffer, NSJSONReadingOptions opts, NSUInteger depth);

#define STACK_SIZE 31

typedef enum {
    JSONErrorNone = 0,
    JSONErrorEOF,
    JSONErrorMalformedDictionary,
    JSONErrorMalformedArray,
    JSONErrorMalformedStringEscaping,
    JSONErrorUnterminatedString,
    JSONErrorData, // NOTE: pass-through, handled by non-collection element's parser, e.g. parseNumber
    JSONErrorCatastrophic,
} JSONError;

static inline NSDictionary *parseDictionary(_NSJSONReader *reader, unichar **buffer, NSJSONReadingOptions opts, NSUInteger depth)
{
    NSDictionary *dictionary = nil;
    id stack_keys[STACK_SIZE];
    id stack_values[STACK_SIZE];
    id *keys = &stack_keys[0];
    id *values = &stack_values[0];
    NSUInteger count = 0;
    NSUInteger capacity = STACK_SIZE;
    JSONError failure = JSONErrorNone;

    incrementBuffer(buffer); //skip '{'

    while (**buffer != '}') {
        if (!skipWhitespace(reader, buffer)) {
            failure = JSONErrorData;
            break;
        }
        if (**buffer == '}') {
            failure = JSONErrorNone;
            break;
        }

        id key = parseObject(reader, buffer, opts, depth);
        if (key == nil) {
            failure = JSONErrorData;
            break;
        }

        if (!skipWhitespace(reader, buffer)) {
            failure = JSONErrorData;
            break;
        }

        if (**buffer != ':') {
            failure = JSONErrorMalformedDictionary;
            break;
        } else if (!incrementBuffer(buffer)) {
            failure = JSONErrorEOF;
            break;
        }

        if (!skipWhitespace(reader, buffer)) {
            failure = JSONErrorData;
            break;
        }

        id value = parseObject(reader, buffer, opts, depth);
        if (value == nil) {
            failure = JSONErrorData;
            break;
        }

        if (!skipWhitespace(reader, buffer)) {
            failure = JSONErrorData;
            break;
        }

        if (**buffer == ',') {
            incrementBuffer(buffer);
        } else if (**buffer == '}') {
            failure = JSONErrorNone;
        } else {
            if (**buffer == '\0') {
                failure = JSONErrorEOF;
            } else {
                failure = JSONErrorMalformedDictionary;
            }
            break;
        }

        if (count + 1 > STACK_SIZE &&
            keys == &stack_keys[0] &&
            values == &stack_values[0]) {
            capacity *= 2;
            keys = malloc(sizeof(id) * capacity);
            if (keys == NULL) {
                failure = JSONErrorCatastrophic;
                break;
            }
            values = malloc(sizeof(id) * capacity);
            if (values == NULL) {
                failure = JSONErrorCatastrophic;
                break;
            }
            memcpy(keys, &stack_keys[0], sizeof(id) * count);
            memcpy(values, &stack_values[0], sizeof(id) * count);
        } else if (count + 1 > capacity) {
            capacity *= 2;
            keys = realloc(keys, sizeof(id) * capacity);
            if (keys == NULL) {
                failure = JSONErrorCatastrophic;
                break;
            }
            values = realloc(values, sizeof(id) * capacity);
            if (values == NULL) {
                failure = JSONErrorCatastrophic;
                break;
            }
        }

        keys[count] = key;
        values[count] = value;
        count++;
    }

    if (!failure) {
        incrementBuffer(buffer); // consume }
        if ((opts & NSJSONReadingMutableContainers) != 0) {
            dictionary = (NSDictionary *)CFDictionaryCreateMutable(kCFAllocatorDefault, count, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
            for (NSUInteger idx = 0; idx < count; idx++) {
                if ([(NSObject *)keys[idx] respondsToSelector:@selector(copyWithZone:)]) {
                    CFDictionarySetValue((CFMutableDictionaryRef)dictionary, keys[idx], values[idx]);
                } else {
                    CFRelease((CFMutableDictionaryRef)dictionary);
                    dictionary = nil;
                    // does this throw?
                    // @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@""] userInfo:@{}];
                    break;
                }
            }
        } else {
            dictionary = (NSDictionary *)CFDictionaryCreate(kCFAllocatorDefault, (const void **)keys, (const void **)values, count, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        }
    } else {
        handleParseFailure(reader, failure);
    }

    for (NSUInteger idx = 0; idx < count; idx++) {
        if (keys != &stack_keys[0] && keys != NULL) {
            [keys[idx] release];
        } else if (keys == NULL) {
            [stack_keys[idx] release];
        }
        if (values != NULL) {
            [values[idx] release];
        } else if (values == NULL) {
            [stack_values[idx] release];
        }
    }

    if (keys != &stack_keys[0] && keys != NULL) {
        free(keys);
    }

    if (values != &stack_values[0] && values != NULL) {
        free(values);
    }

    return dictionary;
}

static inline NSArray *parseArray(_NSJSONReader *reader, unichar **buffer, NSJSONReadingOptions opts, NSUInteger depth) {
    NSArray *array = nil;
    id stack_values[STACK_SIZE];
    id *values = &stack_values[0];
    NSUInteger count = 0;
    NSUInteger capacity = STACK_SIZE;
    JSONError failure = JSONErrorNone;

    incrementBuffer(buffer); //skip '['

    while (**buffer != ']') {
        if (!skipWhitespace(reader, buffer)) {
            failure = JSONErrorData;
            break;
        }
        if (**buffer == ']') {
            failure = JSONErrorNone;
            break;
        }

        id value = parseObject(reader, buffer, opts, depth);
        if (value == nil) {
            failure = JSONErrorData;
            break;
        }

        if (!skipWhitespace(reader, buffer)) {
            failure = JSONErrorData;
            break;
        }

        if (**buffer == ',') {
            incrementBuffer(buffer);
        } else if (**buffer == ']') {
            failure = JSONErrorNone;
        } else {
            if (**buffer == '\0') {
                failure = JSONErrorEOF;
            } else {
                failure = JSONErrorMalformedArray;
            }
            break;
        }

        if (count + 1 > STACK_SIZE &&
            values == &stack_values[0]) {
            capacity *= 2;
            values = malloc(sizeof(id) * capacity);
            if (values == NULL) {
                failure = JSONErrorCatastrophic;
                break;
            }
            memcpy(values, &stack_values[0], sizeof(id) * count);
        } else if (count + 1 > capacity) {
            capacity *= 2;
            values = realloc(values, sizeof(id) * capacity);
            if (values == NULL) {
                failure = JSONErrorCatastrophic;
                break;
            }
        }

        values[count] = value;
        count++;
    }

    if (!failure) {
        incrementBuffer(buffer); // consume ]
        if ((opts & NSJSONReadingMutableContainers) != 0) {
            array = (NSArray *)CFArrayCreateMutable(kCFAllocatorDefault, count, &kCFTypeArrayCallBacks);
            for (CFIndex idx = 0; idx < count; idx++) {
                id object = values[idx];
                CFArrayInsertValueAtIndex((CFMutableArrayRef)array, idx, (const void *)object);
            }
        } else {
            array = (NSArray *)CFArrayCreate(kCFAllocatorDefault, (const void **)values, count, &kCFTypeArrayCallBacks);
        }
    } else {
        handleParseFailure(reader, failure);
    }

    for (NSUInteger idx = 0; idx < count; idx++) {
        if (values != NULL) {
            [values[idx] release];
        } else if (values == NULL) {
            [stack_values[idx] release];
        }
    }

    if (values != &stack_values[0] && values != NULL) {
        free(values);
    }

    return array;
}

static inline void handleParseFailure(_NSJSONReader *reader, JSONError failure) {
    switch(failure) {
        case JSONErrorEOF:
            // "{\"foo\" : \"bar\""
            // "[1,2" (improper terminator)
            [reader setError:[NSError errorWithDomain:NSCocoaErrorDomain code:-1 userInfo:@{
                NSLocalizedDescriptionKey: @"unexpected end of document"
            }]];
            break;
        case JSONErrorMalformedDictionary:
            // "{\"foo\" \"bar\"" (improper separator)
            [reader setError:[NSError errorWithDomain:NSCocoaErrorDomain code:-1 userInfo:@{
                NSLocalizedDescriptionKey: @"unable to parse dictionary"
            }]];
            break;
        case JSONErrorMalformedArray:
            // "[1 2" (improper separator)
            [reader setError:[NSError errorWithDomain:NSCocoaErrorDomain code:-1 userInfo:@{
                NSLocalizedDescriptionKey: @"unable to parse array"
            }]];
            break;
        case JSONErrorMalformedStringEscaping:
            [reader setError:[NSError errorWithDomain:NSCocoaErrorDomain code:-1 userInfo:@{
                NSLocalizedDescriptionKey: @"unable to parse string; invalid escaping"
            }]];
            break;
        case JSONErrorUnterminatedString:
            [reader setError:[NSError errorWithDomain:NSCocoaErrorDomain code:-1 userInfo:@{
                NSLocalizedDescriptionKey: @"unterminated string literal"
            }]];
            break;
        case JSONErrorCatastrophic:
            [reader setError:[NSError errorWithDomain:NSCocoaErrorDomain code:-1 userInfo:@{
                NSLocalizedDescriptionKey: @"unable to parse document; out of memory"
            }]];
            break;
        case JSONErrorNone:
        case JSONErrorData:
        default:
            break;
    }
}

static inline unichar parseUnicode(_NSJSONReader *reader, unichar **buffer, BOOL *success) {
    unichar num = 0;
    if (success) {
        *success = NO;
    }
    NSUInteger idx;
    for (idx = 0; idx < 4; idx++) {
        num *= 16;
        char ch = **buffer;
        if (ch == '\0') {
            return 0;
        }
        *buffer = *buffer + 1;
        if ('0' <= ch && ch <= '9') {
            num += ch - '0' + 0x00;
        } else if ('a' <= ch && ch <= 'f') {
            num += ch - 'a' + 0x0a;
        } else if ('A' <= ch && ch <= 'F') {
            num += ch - 'A' + 0x0a;
        } else {
            return 0;
        }
    }
    if (idx == 4 && success) {
        *success = YES;
    }
    return num;
}

static inline NSUInteger parseEscape(_NSJSONReader *reader, unichar **buffer, unichar *characters, NSUInteger idx) {
    switch (incrementBuffer(buffer)) {
        case '\\':
            characters[idx] = '\\';
            incrementBuffer(buffer);
            return 1;
        case '"':
            characters[idx] = '"';
            incrementBuffer(buffer);
            return 1;
        case '/':
            characters[idx] = '/';
            incrementBuffer(buffer);
            return 1;
        case 'b':
            characters[idx] = '\b';
            incrementBuffer(buffer);
            return 1;
        case 'f':
            characters[idx] = '\f';
            incrementBuffer(buffer);
            return 1;
        case 'n':
            characters[idx] = '\n';
            incrementBuffer(buffer);
            return 1;
        case 'r':
            characters[idx] = '\r';
            incrementBuffer(buffer);
            return 1;
        case 't':
            characters[idx] = '\t';
            incrementBuffer(buffer);
            return 1;
        case 'u':
            if (*(*buffer + 1) == 0) {
                return 0;
            }
            incrementBuffer(buffer);
            BOOL success = NO;
            unichar c = parseUnicode(reader, buffer, &success);
            if (success)
            {
                if (is_surrogate_lead(c))
                {
                    if (**buffer != '\\')
                    {
                        return 0;
                    }
                    incrementBuffer(buffer);
                    if (**buffer != 'u')
                    {
                        return 0;
                    }
                    incrementBuffer(buffer);
                    unichar c2 = parseUnicode(reader, buffer, &success);
                    if (!success || !is_surrogate_trail(c2))
                    {
                        return 0;
                    }
                    characters[idx] = c;
                    characters[idx + 1] = c2;
                    return 2;
                }
                else if (is_surrogate_trail(c))
                {
                    [reader setError:[NSError errorWithDomain:NSCocoaErrorDomain code:-1 userInfo:@{
                        NSLocalizedDescriptionKey: @"illegal surrogate code point"
                    }]];
                    return 0;
                }
                else {
                    characters[idx] = c;
                    return 1;
                }
            }
            else
            {
                return 0;
            }
        default:
            return 0;
    }
}

static inline NSString *parseString(_NSJSONReader *reader, unichar **buffer, NSJSONReadingOptions opts, NSUInteger depth) {
    NSString *string = nil;
    unichar stack_characters[STACK_SIZE];
    unichar *characters = stack_characters;
    NSUInteger count = 0;
    NSUInteger capacity = STACK_SIZE;
    BOOL escaped = NO;
    JSONError failure = JSONErrorNone;

    if (depth <= 1 && (opts & NSJSONReadingAllowFragments) == 0) {
        return nil;
    }

    incrementBuffer(buffer); // skip "

    while (**buffer != '\0' && **buffer != '"' && !escaped) {
        if (**buffer == '\\') {
            escaped = YES;
        }

        if (count + 1 > STACK_SIZE &&
            characters == stack_characters) {
            capacity *= 2;
            characters = malloc(sizeof(unichar) * capacity);
            if (characters == NULL) {
                failure = JSONErrorCatastrophic;
                break;
            }
            memcpy(characters, stack_characters, sizeof(unichar) * count);
        } else if (count + 1 > capacity) {
            capacity *= 2;
            characters = realloc(characters, sizeof(unichar) * capacity);
            if (characters == NULL) {
                failure = JSONErrorCatastrophic;
                break;
            }
        }

        if (escaped) {
            NSUInteger written = parseEscape(reader, buffer, characters, count);
            if (written)
            {
                escaped = NO;
                count += written;
            } else {
                failure = JSONErrorMalformedStringEscaping;
                break;
            }
        } else {
            characters[count++] = **buffer;
            incrementBuffer(buffer);
        }
    }

    if (**buffer == '\0')
    {
        failure = JSONErrorUnterminatedString;
    }

    if (!failure) {
        incrementBuffer(buffer); // consume the "
        if ((opts & NSJSONReadingMutableLeaves) != 0) {
            string = [[NSMutableString alloc] initWithCharacters:characters length:count];
        } else {
            if (characters != stack_characters) {
                string = [[NSString alloc] initWithCharactersNoCopy:characters length:count freeWhenDone:YES];
                characters = NULL;
            } else {
                string = [[NSString alloc] initWithCharacters:characters length:count];
            }
        }
    } else {
        handleParseFailure(reader, failure);
    }

    if (characters != stack_characters && characters != NULL) {
        free(characters);
    }

    return string;
}

typedef enum {
    JSONNumberPhaseStart,
    JSONNumberPhaseWholeNumberStart,
    JSONNumberPhaseWholeNumberMinus,
    JSONNumberPhaseWholeNumberZero,
    JSONNumberPhaseWholeNumber,
    JSONNumberPhaseFractionalNumberStart,
    JSONNumberPhaseFractionalNumber,
    JSONNumberPhaseExponentStart,
    JSONNumberPhaseExponentPlusMinus,
    JSONNumberPhaseExponent,
    JSONNumberPhaseEnd,
} JSONNumberPhase;

static inline NSNumber *parseNumber(_NSJSONReader *reader, unichar **buffer, NSJSONReadingOptions opts, NSUInteger depth) {
    if (depth <= 1 && (opts & NSJSONReadingAllowFragments) == 0) {
        return nil;
    }

    JSONNumberPhase phase = JSONNumberPhaseStart;
    unichar *last = NULL;
    BOOL negativeMantissa = NO;
    uint64_t mantissa = 0;
    BOOL negativeExponent = NO;
    BOOL hasExponent = NO;
    short exponent = 0;
    short fraction = 0;
    BOOL floatingPoint = NO;

    while (true) {
        switch (phase) {

            case JSONNumberPhaseStart:
                if (**buffer == '-') {
                    phase = JSONNumberPhaseWholeNumberMinus;
                    negativeMantissa = YES;
                    break;
                }
                // FALL THROUGH!
            case JSONNumberPhaseWholeNumberMinus:
                if (**buffer == '0') {
                    phase = JSONNumberPhaseWholeNumberZero;
                    break;
                } else if ('1' <= **buffer && **buffer <= '9') {
                    phase = JSONNumberPhaseWholeNumber;
                    mantissa *= 10;
                    mantissa += **buffer - '0';
                    break;
                } else {
                    [reader setError:[NSError errorWithDomain:NSCocoaErrorDomain code:-1 userInfo:@{
                        NSLocalizedDescriptionKey: @"unable to parse number"
                    }]];
                    return nil;
                }



            case JSONNumberPhaseExponentStart:
                if (**buffer == '+' || **buffer == '-') {
                    phase = JSONNumberPhaseExponentPlusMinus;
                    negativeExponent = (**buffer == '-');
                    break;
                }
                // FALL THROUGH!
            case JSONNumberPhaseFractionalNumberStart:
                // FALL THROUGH!
            case JSONNumberPhaseExponentPlusMinus:
                if (!('0' <= **buffer && **buffer <= '9')) {
                    [reader setError:[NSError errorWithDomain:NSCocoaErrorDomain code:-1 userInfo:@{
                        NSLocalizedDescriptionKey: @"unable to parse number"
                    }]];
                    return nil;
                } else {
                    if (phase == JSONNumberPhaseFractionalNumberStart) {
                        phase = JSONNumberPhaseFractionalNumber;
                    } else {
                        phase = JSONNumberPhaseExponent;
                        exponent *= 10;
                        exponent += **buffer - '0';
                        break;
                    }
                }



            case JSONNumberPhaseWholeNumberZero:
            case JSONNumberPhaseWholeNumber:
                if (**buffer == '.') {
                    phase = JSONNumberPhaseFractionalNumberStart;
                    break;
                }
                // FALL THROUGH!
            case JSONNumberPhaseFractionalNumber:
                if (**buffer == 'e' || **buffer == 'E') {
                    phase = JSONNumberPhaseExponentStart;
                    break;
                }
                // FALL THROUGH!
            case JSONNumberPhaseExponent:
                if (!('0' <= **buffer && **buffer <= '9') ||
                    phase == JSONNumberPhaseWholeNumberZero) {
                    phase = JSONNumberPhaseEnd;
                    *buffer = last;
                } else if (('0' <= **buffer && **buffer <= '9') &&
                           phase == JSONNumberPhaseExponent) {
                    exponent *= 10;
                    exponent += **buffer - '0';
                    hasExponent = YES;
                } else if (('0' <= **buffer && **buffer <= '9') &&
                           phase == JSONNumberPhaseFractionalNumber) {
                    mantissa *= 10;
                    mantissa += **buffer - '0';
                    fraction ++;
                    floatingPoint = YES;
                } else if (('0' <= **buffer && **buffer <= '9') &&
                           phase == JSONNumberPhaseWholeNumber) {
                    mantissa *= 10;
                    mantissa += **buffer - '0';
                }
                // FALL THROUGH!
            case JSONNumberPhaseEnd:
                break;


            default:
                [reader setError:[NSError errorWithDomain:NSCocoaErrorDomain code:-1 userInfo:@{
                    NSLocalizedDescriptionKey: @"unhandle number transition; likely invalid number"
                }]];
                return nil;
        }
        last = *buffer;
        incrementBuffer(buffer);
        if (phase == JSONNumberPhaseEnd) {
            break;
        }
    }
    if (hasExponent || floatingPoint) {
        return [[NSDecimalNumber alloc] initWithMantissa:mantissa exponent:exponent * (negativeExponent ? -1 : 1) - fraction isNegative:negativeMantissa];
    } else if (negativeMantissa) {
        return [[NSNumber alloc] initWithLongLong:-mantissa];
    } else {
        return [[NSNumber alloc] initWithUnsignedLongLong:mantissa];
    }
}

static inline int unichar_strncasecmp(const char *str, unichar *ustr, int len) {
    for (int i = 0; i < len; i++)
    {
        if (*ustr == 0) {
            return -1;
        }
        if (str[i] > ustr[i])
        {
            return -1;
        }
        else if (str[i] < ustr[i])
        {
            return 1;
        }
    }
    return 0;
}

static inline NSNumber *parseBoolean(_NSJSONReader *reader, unichar **buffer, NSJSONReadingOptions opts, NSUInteger depth) {
    if (depth <= 1 && (opts & NSJSONReadingAllowFragments) == 0) {
        return nil;
    }

    if (unichar_strncasecmp("true", *buffer, 4) == 0) {
        *buffer = *buffer + 4;
        return @YES;
    } else if (unichar_strncasecmp("false", *buffer, 5) == 0) {
        *buffer = *buffer + 5;
        return @NO;
    }

    [reader setError:[NSError errorWithDomain:NSCocoaErrorDomain code:-1 userInfo:@{
        NSLocalizedDescriptionKey: @"unable to parse boolean"
    }]];
    return nil;
}

static inline NSNull *parseNull(_NSJSONReader *reader, unichar **buffer, NSJSONReadingOptions opts, NSUInteger depth) {
    if (depth <= 1 && (opts & NSJSONReadingAllowFragments) == 0) {
        return nil;
    }

    if (unichar_strncasecmp("null", *buffer, 4) == 0) {
        *buffer = *buffer + 4;
        return [NSNull null];
    }

    [reader setError:[NSError errorWithDomain:NSCocoaErrorDomain code:-1 userInfo:@{
        NSLocalizedDescriptionKey: @"unable to parse null element"
    }]];
    return nil;
}

static inline id parseObject(_NSJSONReader *reader, unichar **buffer, NSJSONReadingOptions opts, NSUInteger depth) {
    id obj = nil;
    switch (**buffer) {
        case '[':
            obj = parseArray(reader, buffer, opts, depth + 1);
            break;
        case '{':
            obj = parseDictionary(reader, buffer, opts, depth + 1);
            break;
        case '"':
            obj = parseString(reader, buffer, opts, depth + 1);
            break;
        case 'n':
            obj = parseNull(reader, buffer, opts, depth + 1);
            break;
        case 't':
        case 'T':
        case 'f':
        case 'F':
            obj = parseBoolean(reader, buffer, opts, depth + 1);
        case '\0':
            break;
        default:
            obj = parseNumber(reader, buffer, opts, depth + 1);
            break;
    }
    return obj;
}

- (id)parseUTF8JSONData:(NSData *)data skipBytes:(NSUInteger)skip options:(NSJSONReadingOptions)opts
{
    id jsonObject = nil;
    unichar *jsonBuffer = NULL;
    unichar *jsonData = NULL;
    NSString *str = nil;
    if (kind == 0)
    {
        do {
            kind = opts;
            input = [data retain];
            str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            jsonBuffer = (unichar *)malloc(sizeof(unichar) * ([str length] + 1));
            if (jsonBuffer == NULL)
            {
                break;
            }
            jsonData = jsonBuffer;

            [str getCharacters:jsonData range:NSMakeRange(0, [str length])];
            jsonData[[str length]] = '\0';
            jsonData += skip;
            if (!skipWhitespace(self, &jsonData))
            {
                break;
            }
            if ((opts & NSJSONReadingAllowFragments) == 0 &&
                *jsonData != '[' &&
                *jsonData != '{')
            {
                [self setError:[NSError errorWithDomain:NSCocoaErrorDomain code:-1 userInfo:@{
                    NSLocalizedDescriptionKey: @"expected object or array when NSJSONReadingAllowFragments is not set"
                }]];
            }
            jsonObject = parseObject(self, &jsonData, opts, 0);

        } while (0);
    }
    if (jsonBuffer != NULL)
    {
        free(jsonBuffer);
    }
    [str release];
    return jsonObject;
}

- (void)setError:(NSError *)err
{
    if (![error isEqual:err])
    {
        [error release];
        error = [err retain];
    }
}

- (NSError *)error
{
    return error;
}

@end

static inline BOOL writeString(_NSJSONWriter *writer, NSString *object, NSJSONWritingOptions opts, NSUInteger depth);
static inline BOOL writeDictionary(_NSJSONWriter *writer, NSDictionary *object, NSJSONWritingOptions opts, NSUInteger depth);
static inline BOOL writeArray(_NSJSONWriter *writer, id object, NSJSONWritingOptions opt, NSUInteger depth);
static inline BOOL writeNull(_NSJSONWriter *writer, NSNull *object, NSJSONWritingOptions opt, NSUInteger depth);
static inline BOOL writeBoolean(_NSJSONWriter *writer, NSNumber *object, NSJSONWritingOptions opt, NSUInteger depth);
static inline BOOL writeNumber(_NSJSONWriter *writer, NSNumber *object, NSJSONWritingOptions opt, NSUInteger depth);
static inline BOOL writeObject(_NSJSONWriter *writer, id object, NSJSONWritingOptions opts, NSUInteger depth);

static NSString *escapeString(NSString *string) {
    NSString *result = [string stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
    return [result stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
}

static inline BOOL writeString(_NSJSONWriter *writer, NSString *object, NSJSONWritingOptions opts, NSUInteger depth) {
    NSString *escaped = escapeString(object);
    if (escaped != nil) {
        [writer appendString:[NSString stringWithFormat:@"\"%@\"", escaped] range:NSMakeRange(0, 0)];
        return YES;
    }
    return NO;
}

static inline BOOL writeDictionary(_NSJSONWriter *writer, NSDictionary *object, NSJSONWritingOptions opts, NSUInteger depth) {
    BOOL pretty = (opts & NSJSONWritingPrettyPrinted) != 0;
    if (pretty) {
        [writer appendString:@"{\n" range:NSMakeRange(0, 0)];
    } else {
        [writer appendString:@"{" range:NSMakeRange(0, 0)];
    }
    NSUInteger count = [object count];
    NSUInteger idx = 0;

    for (id key in object) {
        id value = object[key];
        if (pretty) {
            for (NSUInteger i = 0; i < depth; i++) {
                [writer appendString:@"\t" range:NSMakeRange(0, 0)];
            }
        }

        if (!writeObject(writer, key, (opts | ~(NSJSONWritingPrettyPrinted)), depth)) {
            return NO;
        }

        [writer appendString:@":" range:NSMakeRange(0, 0)];
        if (!writeObject(writer, value, opts, depth)) {
            return NO;
        }

        if (idx + 1 < count) {
            [writer appendString:@"," range:NSMakeRange(0, 0)];
        }
        if (pretty) {
            [writer appendString:@"\n" range:NSMakeRange(0, 0)];
        }
        idx++;
    }

    [writer appendString:@"}" range:NSMakeRange(0, 0)];
    return YES;
}

static inline BOOL writeArray(_NSJSONWriter *writer, id object, NSJSONWritingOptions opts, NSUInteger depth) {
    BOOL pretty = (opts & NSJSONWritingPrettyPrinted) != 0;
    if (pretty) {
        [writer appendString:@"[\n" range:NSMakeRange(0, 0)];
    } else {
        [writer appendString:@"[" range:NSMakeRange(0, 0)];
    }
    NSUInteger count = [object count];
    NSUInteger idx = 0;

    for (id value in object) {
        if (pretty) {
            for (NSUInteger i = 0; i < depth; i++) {
                [writer appendString:@"\t" range:NSMakeRange(0, 0)];
            }
        }

        if (!writeObject(writer, value, opts, depth)) {
            return NO;
        }

        if (idx + 1 < count) {
            [writer appendString:@"," range:NSMakeRange(0, 0)];
        }
        if (pretty) {
            [writer appendString:@"\n" range:NSMakeRange(0, 0)];
        }
        idx++;
    }

    [writer appendString:@"]" range:NSMakeRange(0, 0)];
    return YES;
}

static inline BOOL writeNull(_NSJSONWriter *writer, NSNull *object, NSJSONWritingOptions opts, NSUInteger depth) {
    [writer appendString:@"null" range:NSMakeRange(0, 0)];
    return YES;
}

static inline BOOL writeBoolean(_NSJSONWriter *writer, NSNumber *object, NSJSONWritingOptions opts, NSUInteger depth) {
    if ((CFBooleanRef)object == kCFBooleanTrue) {
        [writer appendString:@"true" range:NSMakeRange(0, 0)];
    } else if ((CFBooleanRef)object == kCFBooleanFalse) {
        [writer appendString:@"false" range:NSMakeRange(0, 0)];
    }
    return YES;
}

static inline BOOL writeNumber(_NSJSONWriter *writer, NSNumber *object, NSJSONWritingOptions opts, NSUInteger depth) {
    NSString *value = [object stringValue];
    [writer appendString:value range:NSMakeRange(0, 0)];
    return YES;
}

static inline BOOL writeObject(_NSJSONWriter *writer, id object, NSJSONWritingOptions opts, NSUInteger depth) {
    BOOL allowFragments = (opts & NSJSONReadingAllowFragments) != 0;
    if (![_NSJSONReader validForJSON:object depth:depth + 1 allowFragments:allowFragments]) {
        // TODO populate error here
        return NO;
    }

    if ([object isKindOfClass:[NSString class]]) {
        return writeString(writer, object, opts, depth + 1);
    } else if ([object isKindOfClass:[NSDictionary class]]) {
        return writeDictionary(writer, object, opts, depth + 1);
    } else if ([object isKindOfClass:[NSArray class]]) {
        return writeArray(writer, object, opts, depth + 1);
    } else if (object == [NSNull null]) {
        return writeNull(writer, object, opts, depth + 1);
    } else if ((CFBooleanRef)object == kCFBooleanTrue || (CFBooleanRef)object == kCFBooleanFalse) {
        return writeBoolean(writer, object, opts, depth + 1);
    } else if ([object isKindOfClass:[NSNumber class]]) {
        return writeNumber(writer, object, opts, depth + 1);
    } else {
        // TODO how did we even get to here?!
        return NO;
    }
}

@implementation _NSJSONWriter {
    NSOutputStream *outputStream;
    NSJSONWritingOptions kind;
    char *dataBuffer;
    NSUInteger dataBufferLen;
    NSUInteger dataLen;
    BOOL freeDataBuffer;
    char *tempBuffer;
    NSUInteger tempBufferLen;
    NSInteger totalDataWritten;
}

- (id)init
{
    self = [super init];
    if (self)
    {

    }
    return self;
}

- (void)dealloc
{
    [outputStream release];
    [super dealloc];
}

- (NSInteger)appendString:(NSString *)string range:(NSRange)range
{
    const char *buffer = [string UTF8String];
    NSUInteger length = [string lengthOfBytesUsingEncoding:NSUTF8StringEncoding];

    NSInteger written = 0;
    while ([outputStream hasSpaceAvailable] && length > written) {
        written += [outputStream write:buffer + written maxLength:length];
    }

    if (length < written) {
        #warning TODO: handle incomplete writes w/ buffering
    }
    totalDataWritten += written;
    return written;
}

- (void)resizeTemporaryBuffer:(size_t)size
{

}

- (NSInteger)writeRootObject:(id)object toStream:(NSOutputStream *)stream options:(NSJSONWritingOptions)opts error:(NSError **)error
{
    if (outputStream != stream)
    {
        [outputStream release];
        outputStream = [stream retain];
    }
    totalDataWritten = 0;
    writeObject(self, object, opts, 0);
    return totalDataWritten;
}

- (NSData *)dataWithRootObject:(id)object options:(NSJSONWritingOptions)options error:(NSError **)error
{
    NSOutputStream *stream = [[NSOutputStream alloc] initToMemory];
    [stream open];
    [self writeRootObject:object toStream:stream options:options error:error];
    NSData *data = [[stream propertyForKey:NSStreamDataWrittenToMemoryStreamKey] retain];
    [stream release];
    return [data autorelease];
}

@end

@implementation NSJSONSerialization

+ (BOOL)isValidJSONObject:(id)obj
{
    return [_NSJSONReader validForJSON:obj depth:1 allowFragments:NO];
}

+ (NSData *)dataWithJSONObject:(id)obj options:(NSJSONWritingOptions)opt error:(NSError **)error
{
    if (obj == nil)
    {
        [NSException raise:NSInvalidArgumentException format:@"object parameter is nil"];
        return nil;
    }
    _NSJSONWriter *writer = [[_NSJSONWriter alloc] init];
    NSData *data = [writer dataWithRootObject:obj options:opt error:error];
    [writer release];
    return data;
}

+ (id)JSONObjectWithData:(NSData *)data options:(NSJSONReadingOptions)opt error:(NSError **)error
{
    _NSJSONReader *reader = [[_NSJSONReader alloc] init];
    id parsed = [reader parseData:data options:opt];
    if (error && parsed == nil) {
        *error = [[[reader error] retain] autorelease];
    }
    [reader release];
    return parsed;
}


+ (NSInteger)writeJSONObject:(id)obj toStream:(NSOutputStream *)stream options:(NSJSONWritingOptions)opt error:(NSError **)error
{
    if (obj == nil)
    {
        [NSException raise:NSInvalidArgumentException format:@"object parameter is nil"];
        return 0;
    }
    if ([stream streamStatus] < NSStreamStatusOpen)
    {
        [NSException raise:NSInvalidArgumentException format:@"stream must be open before usage"];
        return 0;
    }
    _NSJSONWriter *writer = [[_NSJSONWriter alloc] init];
    NSInteger written = [writer writeRootObject:obj toStream:stream options:opt error:error];
    [writer release];
    return written;
}

+ (id)JSONObjectWithStream:(NSInputStream *)stream options:(NSJSONReadingOptions)opt error:(NSError **)error
{
    if ([stream streamStatus] < NSStreamStatusOpen)
    {
        [NSException raise:NSInvalidArgumentException format:@"stream must be open before usage"];
        return nil;
    }
    _NSJSONReader *reader = [[_NSJSONReader alloc] init];
    id parsed = [reader parseStream:stream options:opt];
    if (error != NULL)
    {
        *error = [[[reader error] retain] autorelease];
    }
    [reader release];
    return parsed;
}

@end
