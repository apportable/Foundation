//
//  NSData.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/NSData.h>

#import <Foundation/NSError.h>
#import <Foundation/NSException.h>
#import <Foundation/NSURL.h>
#import <Foundation/NSURLConnection.h>
#import <Foundation/NSURLRequest.h>
#import "CFInternal.h"
#import "NSCoderInternal.h"
#import "NSKeyedArchiver.h"
#import "NSObjectInternal.h"
#import "NSRangeCheck.h"
#import "NSURLResponseInternal.h"
#import "_NSFileIO.h"
#import <objc/runtime.h>
#import <stdlib.h>
#import <sys/mman.h>


@interface NSData (NSData)
- (id)initWithBytes:(void *)bytes length:(NSUInteger)length copy:(BOOL)shouldCopy deallocator:(void (^)(void *bytes, NSUInteger length))deallocator;
- (id)initWithBytes:(void *)bytes length:(NSUInteger)length copy:(BOOL)shouldCopy freeWhenDone:(BOOL)shouldFree bytesAreVM:(BOOL)vm;
@end


CF_PRIVATE
@interface NSConcreteData : NSData
@end


CF_PRIVATE
@interface NSConcreteMutableData : NSMutableData
@end


CF_PRIVATE
@interface __NSZeroData : NSData
@end


CF_PRIVATE
@interface __NSPlaceholderData : NSData
@end


CF_PRIVATE
@interface NSSubrangeData : NSData
- (id)initWithData:(NSData *)data range:(NSRange)range;
@end


@implementation __NSPlaceholderData

- (id)init
{
    return [self initWithBytes:NULL length:0 copy:YES deallocator:nil];
}

- (id)initWithData:(NSData *)data
{
    Class otherDataClass = [data class];

    if (otherDataClass == [NSConcreteData class] ||
        otherDataClass == [NSConcreteMutableData class] ||
        otherDataClass == [__NSZeroData class] ||
        otherDataClass == objc_getClass("__NSCFData"))
    {
        return [data copy];
    }
    else
    {
        return [super initWithData:data];
    }
}

- (id)initWithBytes:(void *)bytes length:(NSUInteger)length copy:(BOOL)shouldCopy deallocator:(void (^)(void *, NSUInteger))deallocator
{
    if (length == 0)
    {
        __NSZeroData *data = [__NSZeroData data];
        if (deallocator != nil)
        {
            deallocator(bytes, 0);
        }
        return (id)data;
    }

    return (id)[[NSConcreteData alloc] initWithBytes:bytes length:length copy:shouldCopy deallocator:deallocator];
}

SINGLETON_RR()

@end


#define NSCONCRETEDATA_BUFFER_SIZE 12

@implementation NSConcreteData {
    // isa: 4 bytes
    unsigned int _isInline:1;
    unsigned int _retainCount:31;
    // 8 bytes
    NSUInteger  _length;
    NSUInteger _capacity;
    // 16 bytes
    void *_bytes;
    // 20 bytes
    union {
        unsigned char _space[NSCONCRETEDATA_BUFFER_SIZE];
        /* 12 makes a full allocation size of 32 bytes */
        void (^_deallocator)(void *buffer, NSUInteger size);
    } _u;
}

- (id)initWithBytes:(void *)bytes length:(NSUInteger)length copy:(BOOL)shouldCopy deallocator:(void (^)(void *, NSUInteger))deallocator
{
    self = [super init];

    if (self == nil)
    {
        return nil;
    }

    _length = length;
    _capacity = _length;

    if (length == 0)
    {
        _isInline = NO;
        _bytes = NULL;
        if (deallocator != nil)
        {
            deallocator(bytes, 0);
        }
        _u._deallocator = nil;
    }
    else if (shouldCopy)
    {
        if (length <= NSCONCRETEDATA_BUFFER_SIZE)
        {
            _isInline = YES;
            _bytes = _u._space;
        }
        else
        {
            _isInline = NO;
            _bytes = malloc(length);
            if (_bytes == NULL)
            {
                [self release];
                [NSException raise:NSInvalidArgumentException format:@"Length too great for NSData"];
                return nil;
            }
            _u._deallocator = [^(void *buffer, NSUInteger size) {
                free(buffer);
            } copy];
        }
        memcpy(_bytes, bytes, length);
    }
    else
    {
        _isInline = NO;
        _bytes = bytes;
        if (deallocator != nil)
        {
            _u._deallocator = [deallocator retain];
        }
        else
        {
            _u._deallocator = nil;
        }
    }

    return self;
}

- (id)init
{
    return [self initWithBytes:NULL length:0 copy:NO freeWhenDone:NO bytesAreVM:NO];
}

- (void)dealloc
{
    if (!_isInline && _u._deallocator != nil && _bytes != NULL)
    {
        _u._deallocator(_bytes, _length);
        [_u._deallocator release];
    }
    _bytes = NULL;
    [super dealloc];
}

- (void)getBytes:(void *)buffer range:(NSRange)range
{
    if (!NSRangeCheckException(range, _length))
    {
        return;
    }

    if (range.length == 0)
    {
        return;
    }
    if (_isInline)
    {
        memcpy(buffer, &_u._space[range.location], range.length);
    }
    else
    {
        memcpy(buffer, (char *)_bytes + range.location, range.length);
    }
}

- (void)getBytes:(void *)buffer length:(NSUInteger)length
{
    [self getBytes:buffer range:NSMakeRange(0, MIN(length, _length))];
}

- (void)getBytes:(void *)buffer
{
    [self getBytes:buffer range:NSMakeRange(0, [self length])];
}

- (id)copyWithZone:(NSZone *)zone
{
    return [self retain];
}

- (const void *)bytes
{
    if (_isInline)
    {
        return (const void *)&_u._space[0];
    }
    else
    {
        return _bytes;
    }
}

- (NSUInteger)length
{
    return _length;
}

@end


@implementation NSMutableData (NSMutableData)

+ (id)allocWithZone:(NSZone *)zone
{
    Class dataClassToAllocate = self;

    if (self == [NSMutableData self])
    {
        dataClassToAllocate = [NSConcreteMutableData self];
    }

    return NSAllocateObject(dataClassToAllocate, 0, zone);
}

+ (id)dataWithCapacity:(NSUInteger)aNumItems
{
    return [[[self alloc] initWithCapacity:aNumItems] autorelease];
}

+ (id)dataWithLength:(NSUInteger)length
{
    return [[[self alloc] initWithLength:length] autorelease];
}

- (id)initWithLength:(NSUInteger)length
{
    self = [self initWithCapacity:length];
    if (self != nil)
    {
        [self setLength:length];
    }
    return self;
}

- (id)initWithCapacity:(NSUInteger)capacity
{
    NSRequestConcreteImplementation();
    return nil;
}

- (void)replaceBytesInRange:(NSRange)range withBytes:(const void *)buffer length:(NSUInteger)bufferLength
{
    NSUInteger oldLength = [self length];

    if (!NSRangeLengthCheckException(range, oldLength))
    {
        return;
    }

    if ((oldLength - range.length) + bufferLength < bufferLength)
    {
        [NSException raise:NSRangeException format:@"range {%d,%d} and buffer length %d causes overflow",
                     range.location, range.length, bufferLength];
        return;
    }

    char *bytes = [self mutableBytes];
    NSUInteger newLength = oldLength - range.length + bufferLength;
    char *tailSource = bytes + NSMaxRange(range); // get the tail
    void *tailDest = tailSource + bufferLength - range.length; // second two terms are how far to shift
    size_t tailLength = oldLength - NSMaxRange(range); // how much should be shifted

    BOOL bufferLivesInBytes = (uintptr_t)buffer > (uintptr_t)bytes && (uintptr_t)buffer + bufferLength < (uintptr_t)bytes + oldLength;

    if (newLength > oldLength)
    {
        [self setLength:newLength];
        if (bytes != [self mutableBytes]) // ugly, but necessary in case increasing the length required the realloc to allocate a new _bytes.
        {                                 // TODO: verify how we're invalidating the bytes/mutableBytes pointers under similar circumstances as we do.

            uintptr_t bufferOffset = (uintptr_t)buffer - (uintptr_t)bytes; // yuck
            bytes = [self mutableBytes];
            tailSource = bytes + NSMaxRange(range);
            tailDest = tailSource + bufferLength - range.length;
            tailLength = oldLength - NSMaxRange(range);

            if (bufferLivesInBytes)
            {
                buffer = bytes + bufferOffset; // ugly, but that's the price for a correct, non-copying implementation
                                               // that doesn't use memory after freeing it.
            }

        }
        memmove(tailDest, tailSource, tailLength); // shift the tail first
                                                   // so we don't overwrite it with the contents of buffer

        BOOL bufferStartsInTail = (uintptr_t)buffer > (uintptr_t)bytes + range.location + range.length && (uintptr_t)buffer < (uintptr_t)bytes + oldLength;
        uintptr_t middleSource = (uintptr_t)buffer;
        if (bufferStartsInTail)
        {
            middleSource += bufferLength - range.length;
        }

        void *middleDest = bytes + range.location;
        size_t middleLength = bufferLength;
        if (buffer == NULL)
        {
            bzero(middleDest, middleLength);
        }
        else
        {
            memmove(middleDest, (void *)middleSource, middleLength);
        }
    }
    else
    {
        uintptr_t middleSource = (uintptr_t)buffer;
        void *middleDest = bytes + range.location;
        size_t middleLength = bufferLength;
        if (buffer == NULL)
        {
            bzero(middleDest, middleLength);
        }
        else
        {
            memmove(middleDest, (void *)middleSource, middleLength);
        }
        if (newLength < oldLength)
        {
            memmove(tailDest, tailSource, tailLength);

            [self setLength:newLength];
        }

    }
/*
    if will grow
        grow data
        shift tail
        if buffer starts in tail
            add offset to buffer
        memmove buffer to range.location
    if will shrink
        memmove buffer to range.location
        shift tail
        shrink data
*/

}

- (void)replaceBytesInRange:(NSRange)range withBytes:(const void *)buffer
{
    if (range.length == 0)
    {
        return;
    }

    NSUInteger oldLength = [self length];

    if (!NSRangeLengthCheckException(range, oldLength))
    {
        return;
    }

    if (NSMaxRange(range) > oldLength)
    {
        [self setLength:NSMaxRange(range)];
    }

    memmove((char *)[self mutableBytes] + range.location, buffer, range.length);
}

- (void)resetBytesInRange:(NSRange)range
{
    if (range.length == 0)
    {
        return;
    }

    NSUInteger oldLength = [self length];

    if (!NSRangeLengthCheckException(range, oldLength))
    {
        return;
    }

    if (NSMaxRange(range) > oldLength)
    {
        [self setLength:NSMaxRange(range)];
    }

    bzero((char *)[self mutableBytes] + range.location, range.length);
}

- (void)appendBytes:(const void *)buffer length:(NSUInteger)bufferLength
{
    if (bufferLength == 0)
    {
        return;
    }

    NSUInteger oldLength = [self length];
    NSUInteger newLength = bufferLength + oldLength;
    if (newLength < bufferLength)
    {
        [NSException raise:NSRangeException format:@"absurd data size overflow"];
        return;
    }

    [self setLength:newLength];
    memmove((char *)[self mutableBytes] + oldLength, buffer, bufferLength);
}

- (void)appendData:(NSData *)otherData
{
    NSUInteger otherLength = [otherData length];
    if (otherLength == 0)
    {
        return;
    }

    NSUInteger oldLength = [self length];

    [self increaseLengthBy:otherLength];

    memcpy((char *)[self mutableBytes] + oldLength, [otherData bytes], otherLength);
}

OBJC_PROTOCOL_IMPL_PUSH
- (void *)mutableBytes
{
    NSRequestConcreteImplementation();
    return NULL;
}

- (void)setLength:(NSUInteger)length
{
    NSRequestConcreteImplementation();
}
OBJC_PROTOCOL_IMPL_POP

- (void)increaseLengthBy:(NSUInteger)extraLength
{
    NSUInteger newLength = extraLength + [self length];
    if (newLength < extraLength)
    {
        [NSException raise:NSRangeException format:@"Increasing length of data %p by %d causes overflow", self, extraLength];
        return;
    }

    [self setLength:newLength];
}

- (void)setData:(NSData *)data
{
    NSUInteger newLength = [data length];

    // Note that replaceBytesInRange:withBytes: will extend storage if
    // necessary. That means that either order of replacing the data
    // and setting the length will work. This order is preferred, as
    // setting the length first may cause the buffer to be zeroed,
    // only to be copied over.
    [self replaceBytesInRange:NSMakeRange(0, newLength) withBytes:[data bytes]];
    [self setLength:newLength];
}

- (Class)classForCoder
{
    return [NSMutableData self];
}

@end


@implementation NSData (NSData)

- (Class)classForCoder
{
    return [NSData self];
}

- (NSString *)description
{
    uint8_t *bytes = (uint8_t *)[self bytes];
    NSUInteger length = [self length];
    NSUInteger strIdx = 0;
    char *buffer = malloc(1 + 2 * length + (length / 4) + 1);
    if (buffer == NULL)
    {
        return nil;
    }
    buffer[strIdx++] = '<';
    for (NSUInteger idx = 0; idx < length; idx++)
    {
        sprintf(&buffer[strIdx], "%02x", bytes[idx]);
        strIdx += 2;
        if (idx % 4 == 3 && idx < length - 1)
        {
            buffer[strIdx] = ' ';
            strIdx += 1;
        }
    }
    buffer[strIdx] = '>';
    strIdx++;
    return [[[NSString alloc] initWithBytesNoCopy:buffer length:strIdx encoding:NSASCIIStringEncoding freeWhenDone:YES] autorelease];
}

- (void)getBytes:(void *)buffer length:(NSUInteger)length
{
    memcpy(buffer, [self bytes], MIN(length, [self length]));
}

- (void)getBytes:(void *)buffer range:(NSRange)range
{
    if (!NSRangeCheckException(range, [self length]))
    {
        return;
    }
    memcpy(buffer, (char *)[self bytes] + range.location, range.length);
}

- (NSUInteger)hash
{
    NSUInteger length = [self length];
    const void* bytes = [self bytes];
    return CFHashBytes((uint8_t *)bytes, length < 0x50 ? length : 0x50);
}

- (BOOL)isEqual:(id)other
{
    if (![other isNSData__])
    {
        return NO;
    }
    return [self isEqualToData:other];
}

- (BOOL)isEqualToData:(NSData *)other
{
    if (other == self)
    {
        return YES;
    }
    NSUInteger len1 = [self length];
    NSUInteger len2 = [other length];
    if (len1 != len2)
    {
        return NO;
    }
    const void *buffer1 = [self bytes];
    const void *buffer2 = [other bytes];
    if (buffer1 == buffer2)
    {
        return YES;
    }
    return memcmp(buffer1, buffer2, len1) == 0;
}

- (NSData *)subdataWithRange:(NSRange)range
{
    if (!NSRangeCheckException(range, [self length]))
    {
        return nil;
    }

    if ([self isKindOfClass:[NSConcreteData class]])
    {
        return [[[NSSubrangeData alloc] initWithData:self range:range] autorelease];
    }
    else
    {
        return [[[NSData alloc] initWithBytes:(char *)self.bytes + range.location length:range.length] autorelease];
    }
}

- (BOOL)writeToFile:(NSString *)path atomically:(BOOL)atomically
{
    if (path == nil)
    {
        return NO;
    }
    return _NSWriteBytesToFile(self, path, atomically ? NSDataWritingAtomic : 0, NULL);
}

- (BOOL)writeToURL:(NSURL *)url atomically:(BOOL)atomically
{
    if (url == nil)
    {
        return NO;
    }
    return _NSWriteBytesToFile(self, url, atomically ? NSDataWritingAtomic : 0, NULL);
}

- (BOOL)writeToFile:(NSString *)path options:(NSDataWritingOptions)writeOptionsMask error:(NSError **)errorPtr
{
    if (path == nil)
    {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Cannot write to a nil path" userInfo:nil];
        return NO;
    }
    return _NSWriteBytesToFile(self, path, writeOptionsMask, errorPtr);
}

- (BOOL)writeToURL:(NSURL *)url options:(NSDataWritingOptions)writeOptionsMask error:(NSError **)errorPtr
{
    if (url == nil)
    {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Cannot write to a nil URL" userInfo:nil];
        return NO;
    }
    return _NSWriteBytesToFile(self, url, writeOptionsMask, errorPtr);
}

- (NSRange)rangeOfData:(NSData *)dataToFind options:(NSDataSearchOptions)mask range:(NSRange)searchRange
{
    NSUInteger needleLength = [dataToFind length];
    if (needleLength == 0 || needleLength > searchRange.length)
    {
        return NSMakeRange(NSNotFound, 0);
    }

    NSUInteger length = [self length];

    uint8_t *bytes = (uint8_t *)[self bytes];
    uint8_t *needle = (uint8_t *)[dataToFind bytes];

    if (NSMaxRange(searchRange) > length)
    {
        [NSException raise:NSRangeException format:@"Search range {%d, %d} out of bounds of length %d", searchRange.location, searchRange.length, length];
        return NSMakeRange(NSNotFound, 0);
    }
    else if (length < needleLength)
    {
        [NSException raise:NSRangeException format:@"Search data length %d is greater than data length %d", needleLength, length];
        return NSMakeRange(NSNotFound, 0);
    }


    bytes += searchRange.location;
    if ((mask & NSDataSearchBackwards) != 0 && (mask & NSDataSearchAnchored) != 0)
    {
        if (memcmp(bytes + searchRange.length - needleLength, needle, needleLength) == 0)
        {
            return NSMakeRange(searchRange.location + searchRange.length - needleLength, needleLength);
        }
    }
    else if ((mask & NSDataSearchBackwards) != 0)
    {
        for (uint8_t *haystack = bytes + searchRange.length - needleLength; haystack != bytes; haystack--)
        {
            if (memcmp(haystack, needle, needleLength) == 0)
            {
                return NSMakeRange(haystack - bytes + searchRange.location, needleLength);
            }
        }
    }
    else if ((mask & NSDataSearchAnchored) != 0)
    {
        if (memcmp(bytes, needle, needleLength) == 0)
        {
            return NSMakeRange(searchRange.location, needleLength);
        }
    }
    else
    {
        for (uint8_t *haystack = bytes; haystack != bytes + searchRange.length; haystack++)
        {
            if (memcmp(haystack, needle, needleLength) == 0)
            {
                return NSMakeRange(haystack - bytes + searchRange.location, needleLength);
            }
        }
    }
    return NSMakeRange(NSNotFound, 0);
}

+ (id)allocWithZone:(NSZone *)zone
{
    static dispatch_once_t once;
    static __NSPlaceholderData *placeholder;
    if (self == [NSData self])
    {
        dispatch_once(&once, ^{
            placeholder = [__NSPlaceholderData allocWithZone:zone];
        });
        return placeholder;
    }
    else
    {
        return NSAllocateObject(self, 0, zone);
    }
}

+ (id)data
{
    return [[[self alloc] initWithBytes:NULL length:0 copy:NO freeWhenDone:NO bytesAreVM:NO] autorelease];
}

+ (id)dataWithBytes:(const void *)bytes length:(NSUInteger)length
{
    return [[[self alloc] initWithBytes:(void *)bytes length:length copy:YES freeWhenDone:NO bytesAreVM:NO] autorelease];
}

+ (id)dataWithBytesNoCopy:(void *)bytes length:(NSUInteger)length
{
    return [[[self alloc] initWithBytes:bytes length:length copy:NO freeWhenDone:NO bytesAreVM:NO] autorelease];
}

+ (id)dataWithBytesNoCopy:(void *)bytes length:(NSUInteger)length freeWhenDone:(BOOL)b
{
    return [[[self alloc] initWithBytes:bytes length:length copy:NO freeWhenDone:b bytesAreVM:NO] autorelease];
}

+ (id)dataWithContentsOfFile:(NSString *)path options:(NSDataReadingOptions)readOptionsMask error:(NSError **)errorPtr
{
    return [[[self alloc] initWithContentsOfFile:path options:readOptionsMask error:errorPtr] autorelease];
}

+ (id)dataWithContentsOfURL:(NSURL *)url options:(NSDataReadingOptions)readOptionsMask error:(NSError **)errorPtr
{
    return [[[self alloc] initWithContentsOfURL:url options:readOptionsMask error:errorPtr] autorelease];
}

+ (id)dataWithContentsOfFile:(NSString *)path
{
    return [[[self alloc] initWithContentsOfFile:path] autorelease];
}

+ (id)dataWithContentsOfURL:(NSURL *)url
{
    return [[[self alloc] initWithContentsOfURL:url] autorelease];
}

+ (id)dataWithData:(NSData *)data
{
    if ([self class] == [NSData class])
    {
        return [[data copy] autorelease];
    }

    if ([self class] == [NSMutableData class])
    {
        return [[data mutableCopy] autorelease];
    }

    return [[[self alloc] initWithBytes:[data bytes] length:[data length]] autorelease];
}

+ (id)dataWithContentsOfMappedFile:(NSString *)path
{
    if (path == nil)
    {
        return nil;
    }
    return [[[self alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] options:NSDataReadingMappedAlways error:NULL] autorelease];
}

- (id)initWithBytes:(const void *)bytes length:(NSUInteger)length
{
    return [self initWithBytes:(void *)bytes length:length copy:YES freeWhenDone:NO bytesAreVM:NO];
}

- (id)initWithBytesNoCopy:(void *)bytes length:(NSUInteger)length
{
    return [self initWithBytes:bytes length:length copy:NO freeWhenDone:YES bytesAreVM:NO];
}

- (id)initWithBytesNoCopy:(void *)bytes length:(NSUInteger)length freeWhenDone:(BOOL)b
{
    return [self initWithBytes:bytes length:length copy:NO freeWhenDone:b bytesAreVM:NO];
}

- (id)initWithContentsOfFile:(NSString *)path options:(NSDataReadingOptions)readOptionsMask error:(NSError **)errorPtr
{
    return [self initWithContentsOfURL:[NSURL fileURLWithPath:path] options:readOptionsMask error:errorPtr];
}

- (id)initWithContentsOfURL:(NSURL *)url options:(NSDataReadingOptions)readOptionsMask error:(NSError **)errorPtr
{
    if (url == nil)
    {
        [self release];
        [NSException raise:NSInvalidArgumentException format:@"cannot create data from nil url"];
        return nil;
    }
    if ([url isFileURL])
    {
        NSString *path = [url path];
        if (path == nil)
        {
            [self release];
            return nil;
        }

        NSUInteger length = 0;
        BOOL vm = NO;
        void *buffer = _NSReadBytesFromFile(path, readOptionsMask, &length, &vm, errorPtr);
        if (buffer == nil)
        {
            [self release];
            return nil;
        }
        else
        {
            return [self initWithBytes:buffer length:length copy:NO freeWhenDone:YES bytesAreVM:vm];
        }
    }
    else
    {
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
        NSHTTPURLResponse *response = nil;
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:errorPtr];
        [request release];
        NSInteger statusCode = [response statusCode];
        BOOL isError = [NSHTTPURLResponse isErrorStatusCode:statusCode];
        // 404 and whatnot should return nil bytes, not the error page
        if (data && !isError)
        {
            return [self initWithData:data];
        }
        else
        {
            if (isError && errorPtr)
            {
                *errorPtr = [NSError errorWithDomain:NSCocoaErrorDomain code:-1 userInfo:@{
                    NSLocalizedDescriptionKey:[NSHTTPURLResponse localizedStringForStatusCode:statusCode],
                    NSURLErrorKey:url
                }];
            }
            else if (errorPtr)
            {
                *errorPtr = [NSError errorWithDomain:NSCocoaErrorDomain code:-1 userInfo:@{
                    NSLocalizedDescriptionKey:@"connection either timed out or disconnected",
                    NSURLErrorKey:url
                }];
            }
            [self release];
            return nil;
        }
    }
}

- (id)initWithContentsOfFile:(NSString *)path
{
    if (path == nil)
    {
        [self release];
        return nil;
    }
    return [self initWithContentsOfURL:[NSURL fileURLWithPath:path] options:0 error:NULL];
}

- (id)initWithContentsOfURL:(NSURL *)url
{
    if (url == nil)
    {
        [self release];
        return nil;
    }
    return [self initWithContentsOfURL:url options:0 error:NULL];
}

- (id)initWithData:(NSData *)data
{
    NSUInteger length = [data length];
    if (length == 0)
    {
        return [self initWithBytes:NULL length:0 copy:NO freeWhenDone:NO bytesAreVM:NO];
    }
    else
    {
        return [self initWithBytes:(void *)[data bytes] length:length copy:YES freeWhenDone:NO bytesAreVM:NO];
    }
}

- (void)getBytes:(void *)buffer
{
    memcpy(buffer, [self bytes], [self length]);
}

- (id)initWithContentsOfMappedFile:(NSString *)path
{
    if (path == nil)
    {
        [self release];
        return nil;
    }
    return [self initWithContentsOfURL:[NSURL fileURLWithPath:path] options:NSDataReadingMappedAlways error:NULL];
}

OBJC_PROTOCOL_IMPL_PUSH
- (NSUInteger)length
{
    NSRequestConcreteImplementation();
    return 0;
}

- (const void *)bytes
{
    NSRequestConcreteImplementation();
    return NULL;
}

- (id)copyWithZone:(NSZone *)zone
{
    return [[NSData alloc] initWithBytes:(void *)[self bytes] length:[self length] copy:YES freeWhenDone:NO bytesAreVM:NO];
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    return [[NSMutableData alloc] initWithData:self];
}

+ (BOOL)supportsSecureCoding
{
    return NO;
}

- (id)initWithCoder:(NSCoder *)coder
{
    NSUInteger length = 0;
    const void *bytes = NULL;

    if ([coder allowsKeyedCoding])
    {
        if ([coder isKindOfClass:[NSKeyedUnarchiver class]] || [coder containsValueForKey:@"NS.data"])
        {
            id data = [coder _decodePropertyListForKey:@"NS.data"];
            self = [self initWithData:data];
        }
        else
        {
            bytes = [coder decodeBytesForKey:@"NS.bytes" returnedLength:&length];
            self = [self initWithBytes:bytes length:length];
        }
    }
    else
    {
        bytes = [coder decodeBytesWithReturnedLength:&length];
        self = [self initWithBytes:bytes length:length];
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

}
OBJC_PROTOCOL_IMPL_POP

- (id)initWithBytes:(void *)bytes length:(NSUInteger)length copy:(BOOL)shouldCopy deallocator:(void (^)(void *bytes, NSUInteger length))deallocator
{
    NSRequestConcreteImplementation();
    [self release];
    return nil;
}

- (id)initWithBytes:(void *)bytes length:(NSUInteger)length copy:(BOOL)shouldCopy freeWhenDone:(BOOL)shouldFree bytesAreVM:(BOOL)vm
{
    void (^deallocator)(void *bytes, NSUInteger length) = nil;
    if (shouldFree)
    {
        if (vm)
        {
            deallocator = ^void(void *bytesToDealloc, NSUInteger lengthToDealloc) {
                munmap(bytesToDealloc, lengthToDealloc);
            };
        }
        else
        {
            deallocator = ^void(void *bytesToDealloc, NSUInteger lengthToDealloc) {
                free(bytesToDealloc);
            };
        }
    }
    return [self initWithBytes:bytes length:length copy:shouldCopy deallocator:deallocator];
}

- (CFTypeID)_cfTypeID
{
    return CFDataGetTypeID();
}

- (BOOL)isNSData__
{
    return YES;
}

- (void)enumerateByteRangesUsingBlock:(void (^)(const void *bytes, NSRange byteRange, BOOL *stop))block
{
    BOOL stop = NO;

    block([self bytes], NSMakeRange(0, [self length]), &stop);
}

- (id)initWithBase64EncodedString:(NSString *)base64String options:(NSDataBase64DecodingOptions)options
{
    return [self initWithBase64EncodedData:[base64String dataUsingEncoding:NSASCIIStringEncoding] options:options];
}

- (NSString *)base64EncodedStringWithOptions:(NSDataBase64EncodingOptions)options
{
    return [[NSString alloc] initWithData:[self base64EncodedDataWithOptions:options] encoding:NSASCIIStringEncoding];
}

#define xx 65 // xx is used to mark invalid Base64 characters
#define EQ 66 // 66 is the sentinel value for the padding '=' character
static uint8_t base64DecodeLookup[256] =
{
    xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx,
    xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, 62, xx, xx, xx, 63, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, xx, xx, xx, EQ, xx, xx,
    xx,  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, xx, xx, xx, xx, xx,
    xx, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, xx, xx, xx, xx, xx,
    xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx,
    xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx,
    xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx,
    xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx,
};

- (id)initWithBase64EncodedData:(NSData *)base64Data options:(NSDataBase64DecodingOptions)options
{
    // Length calculation: Number of Base64 units rounding up times binary unit
    //  size - e.g. 3 bytes of binary output for every 4 bytes of Base64 input.
    NSUInteger outputLen = ((base64Data.length + 3) >> 2) * 3;
    uint8_t *outbytes = calloc(1, outputLen), _acc_bytes[4] = {0}, *acc_bytes = &_acc_bytes[0];
    if (!outbytes)
    {
        [self release];
        return nil;
    }
    __block NSUInteger outpos = 0, j = 0;

    size_t (^convert)(uint8_t *, size_t, uint8_t *) = ^ size_t (uint8_t *accumulated, size_t naccum, uint8_t *outbuf)
    {
        NSAssert(naccum < 5, @"You can't accumulate more than 4 bytes at a time!");
        for (ssize_t idx = 0; idx < (ssize_t)naccum - 1; ++idx)
        {
            // idx cycles 0,1,2 << 1 == 0,2,4; +2 == 2,4,6; 4- == 4,2,0
            outbuf[idx] = (accumulated[idx] << ((idx << 1) + 2)) | (accumulated[idx + 1] >> (4 - (idx << 1)));
        }
        return naccum ? naccum - 1 : 0;
    };
    [base64Data enumerateByteRangesUsingBlock:(void (^)(const void *, NSRange, BOOL *))^ (const uint8_t *bytes, NSRange byteRange, BOOL *stop)
    {
        for (size_t i = 0; i < byteRange.length; ++i)
        {
            uint8_t decode = base64DecodeLookup[bytes[i]];

            // Die if we're not ignoring unknown characters.
            if (decode == xx && (options & NSDataBase64DecodingIgnoreUnknownCharacters) == 0)
            {
                *stop = YES, j = 1; // use as sentinel
                return;
            }
            else if (decode != EQ && decode != xx) // always ignore padding
            {
                acc_bytes[j++] = decode;
                if (j >= 4)
                {
                    outpos += convert(acc_bytes, j, outbytes + outpos);
                    j = 0; // bzero(acc_bytes, 4);
                }
            }
        }
    }];
    if (j != 1) // success
    {
        outpos += convert(acc_bytes, j, outbytes + outpos); // harmless for j == 0
        NSAssert(outpos <= outputLen, @"Overran the output buffer!"); // outputLen is not exact
        self = [self initWithBytesNoCopy:outbytes length:outpos freeWhenDone:YES];
    }
    else // j == 1 means truncated data or unignored unknown character, both fatal
    {
        free(outbytes);
        [self release];
        self = nil;
    }
    return self;
}
#undef xx
#undef EQ

static uint8_t base64EncodeLookup[65] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
- (NSData *)base64EncodedDataWithOptions:(NSDataBase64EncodingOptions)options
{
    if (self.length < 1) return [NSData data]; // speed optimization

    size_t lineLen = ((options & NSDataBase64Encoding64CharacterLineLength) ? 64 :
                     ((options & NSDataBase64Encoding76CharacterLineLength) ? 76 :
                     0));
    size_t newlineLen = ((options & NSDataBase64EncodingEndLineWithLineFeed) ? 1 : 0) +
                        ((options & NSDataBase64EncodingEndLineWithCarriageReturn) ? 1 : 0);

    if (lineLen != 0 && newlineLen == 0) // default to both if given line len and no newline setting
    {
        options |= NSDataBase64EncodingEndLineWithCarriageReturn | NSDataBase64EncodingEndLineWithLineFeed;
        newlineLen = 2;
    }

    // Length calculation: length in binary units + 1 unit padding if needed,
    //  times size of base64 unit; e.g. 4 bytes Base64 output for every 3 bytes
    //  binary input, rounded up.
    NSUInteger outputLen = (((self.length / 3) + !!(self.length % 3)) << 2);
    outputLen += (lineLen ? (outputLen / lineLen) * newlineLen : 0);
    NSMutableData *outputData = [[NSMutableData alloc] initWithLength:outputLen];
    uint8_t *outBytes = outputData.mutableBytes, _acc_bytes[3] = {0}, *acc_bytes = &_acc_bytes[0];
    __block size_t outpos = 0, outchars = 0, j = 0;

    size_t (^convert)(uint8_t, uint8_t *, uint8_t *, size_t, size_t *) = ^ size_t (uint8_t naccum, uint8_t *accumulated, uint8_t *outbuf, size_t lineLength, size_t *nusedsofar)
    {
        size_t nused = 0;

        NSAssert(naccum < 4, @"Can't accumulate more than 3 bytes at a time!");
        if (naccum > 0)
        {
            outbuf[nused++] =              base64EncodeLookup[((accumulated[0] & 0xfc) >> 2) | 0];
            outbuf[nused++] =              base64EncodeLookup[((accumulated[0] & 0x03) << 4) | (naccum > 1 ? ((accumulated[1] & 0xf0) >> 4) : 0)];
            outbuf[nused++] = naccum > 1 ? base64EncodeLookup[((accumulated[1] & 0x0f) << 2) | (naccum > 2 ? ((accumulated[2] & 0xc0) >> 6) : 0)] : '=';
            outbuf[nused++] = naccum > 2 ? base64EncodeLookup[((accumulated[2] & 0x3f) << 0) | 0] : '=';
        }
        *nusedsofar += 4;
        if (lineLength && (*nusedsofar % lineLength) == 0)
        {
            if ((options & NSDataBase64EncodingEndLineWithCarriageReturn))
            {
                outbuf[nused++] = '\r';
            }
            if ((options & NSDataBase64EncodingEndLineWithLineFeed))
            {
                outbuf[nused++] = '\n';
            }
        }
        return nused;
    };
    [self enumerateByteRangesUsingBlock:(void (^)(const void *, NSRange, BOOL *))^ (const uint8_t *bytes, NSRange byteRange, BOOL *stop)
    {
        for (size_t pos = 0; pos < byteRange.length; ++pos)
        {
            acc_bytes[j++] = bytes[pos];
            if (j >= 3)
            {
                NSAssert(j < 4, @"Can only accumulate 3 bytes at a time!");
                outpos += convert(j, acc_bytes, outBytes + outpos, lineLen, &outchars);
                j = 0;
            }
        }
    }];
    outpos += convert(j, acc_bytes, outBytes + outpos, lineLen, &outchars);
    NSAssert(outpos == outputData.length, @"STOP RIGHT HERE, YOU OVERRAN (or underran) THE BUFFER (expected %u bytes got %zu)", outputData.length, outpos);
    return outputData;
}

@end


@implementation NSSubrangeData {
    unsigned int _reserved:3;
    unsigned int _retainCount:29;
    NSRange _range;
    NSData *_data;
}

- (id)initWithData:(NSData *)data range:(NSRange)range
{
    self = [super init];
    if (self)
    {
        _range = range;
        _data = [data retain];
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _range = NSMakeRange(0, 0);
        _data = nil;
    }
    return self;
}

- (void)dealloc
{
    [_data release];
    [super dealloc];
}

- (void)getBytes:(void *)buffer range:(NSRange)range
{
    if (!NSRangeCheckException(range, _range.length))
    {
        return;
    }

    [_data getBytes:buffer range:NSMakeRange(_range.location + range.location, range.length)];
}

- (void)getBytes:(void *)buffer length:(NSUInteger)length
{
    [_data getBytes:buffer range:NSMakeRange(_range.location, MIN(_range.length, length))];
}

- (void)getBytes:(void *)buffer
{
    [self getBytes:buffer range:NSMakeRange(0, _range.length)];
}

- (id)copyWithZone:(NSZone *)zone
{
    return [[NSSubrangeData alloc] initWithData:_data range:_range];
}

- (const void *)bytes
{
    return (char *)[_data bytes] + _range.location;
}

- (NSUInteger)length
{
    return _range.length;
}

@end


@implementation NSConcreteMutableData {
    unsigned int _reserved:1;
    unsigned int _bytesNotYetInitialized:1;
    unsigned int _hasVM:1;
    unsigned int _retainCount:29;
    unsigned int _length;
    unsigned int _capacity;
    void *_bytes;
}

- (id)initWithBytes:(void *)bytes length:(NSUInteger)length copy:(BOOL)shouldCopy deallocator:(void (^)(void *bytes, NSUInteger length))deallocator
{
    NSCapacityCheck(length, 0x80000000, @"Too huge of data length");

    self = [self initWithCapacity:length];
    if (self != nil)
    {
        _length = length;
        memcpy(_bytes, bytes, length);
        _bytesNotYetInitialized = NO;

        if (deallocator != nil)
        {
            deallocator(bytes, length);
        }
    }
    return self;
}

- (id)initWithCapacity:(NSUInteger)capacity
{
    NSCapacityCheck(capacity, 0x80000000, @"Too huge of data length");

    self = [super init];
    if (self)
    {
        _hasVM = NO;
        _capacity = capacity;
        _length = 0;
        _bytes = malloc(_capacity);
        if (!_bytes)
        {
            [self release];
            return nil;
        }
        _bytesNotYetInitialized = YES;
    }
    return self;
}

- (id)initWithLength:(NSUInteger)length
{
    NSCapacityCheck(length, 0x80000000, @"Too huge of data length");

    self = [super init];
    if (self)
    {
        _hasVM = NO;
        _capacity = length;
        _length = length;
        _bytes = calloc(1, _capacity);
        if (!_bytes)
        {
            [self release];
            return nil;
        }
        _bytesNotYetInitialized = NO;
    }
    return self;
}

- (id)init
{
    return [self initWithCapacity:29];
}

- (void)dealloc
{
    free(_bytes);
    _bytes = NULL;
    [super dealloc];
}

- (void)resetBytesInRange:(NSRange)range
{
    if (!NSRangeLengthCheckException(range, _length))
    {
        return;
    }

    NSUInteger rangeLimit = NSMaxRange(range);
    if (rangeLimit > _length)
    {
        [self setLength:rangeLimit];
    }

    bzero((char *)_bytes + range.location, range.length);
}

- (void)replaceBytesInRange:(NSRange)range withBytes:(const void *)buffer
{
    if (!NSRangeLengthCheckException(range, _length))
    {
        return;
    }

    NSUInteger rangeLimit = NSMaxRange(range);
    if (rangeLimit > _length)
    {
        [self setLength:rangeLimit];
    }

    memcpy((char *)_bytes + range.location, buffer, range.length);
}

- (void)increaseLengthBy:(NSUInteger)length
{
    NSUInteger newLength = _length + length;
    if (newLength < length)
    {
        [NSException raise:NSRangeException format:@"Extending length of data %p by %d overflows", self, length];
        return;
    }

    [self setLength:newLength];
}

- (void)appendData:(NSData *)data
{
    [self appendBytes:[data bytes] length:[data length]];
}

- (void)appendBytes:(const void *)buffer length:(NSUInteger)length
{
    if (length == 0)
    {
        return;
    }

    NSUInteger newLength = _length + length;
    if (newLength < length)
    {
        [NSException raise:NSRangeException format:@"Extending length of data %p by %d overflows", self, length];
        return;
    }

    if (_capacity <= newLength)
    {
        _bytesNotYetInitialized = NO;
    }

    if (_capacity < newLength)
    {
        _capacity = newLength;
        void *ptr = realloc(_bytes, _capacity);
        if (!ptr)
        {
            [NSException raise:NSMallocException format:@"Cannot appends bytes"];
            return;
        }
        _bytes = ptr;
    }

    memcpy((char *)_bytes + _length, buffer, length);

    _length = newLength;
}

- (void)setLength:(NSUInteger)length
{
    NSUInteger oldLength = _length;
    NSUInteger oldCapacity = _capacity;

    if (oldLength == length)
    {
        return;
    }

    _length = length;

    if (_capacity < length)
    {
        _capacity = length;
        void *ptr = realloc(_bytes, _capacity);
        if (!ptr)
        {
            [NSException raise:NSMallocException format:@"Cannot set length"];
            return;
        }
        _bytes = ptr;

        if (_bytesNotYetInitialized)
        {
            bzero((char *)_bytes + oldLength, length - oldLength);
        }
        else
        {
            bzero((char *)_bytes + oldCapacity, length - oldCapacity);
        }

        _bytesNotYetInitialized = NO;

        return;
    }
    else if (_capacity == length)
    {
        if (_bytesNotYetInitialized)
        {
            bzero((char *)_bytes + oldLength, length - oldLength);
        }
        _bytesNotYetInitialized = NO;
    }

    if (length < oldLength)
    {
        _bytesNotYetInitialized = YES;
    }
}

- (void)_freeBytes
{
    free(_bytes);
    _bytes = NULL;
}

- (void *)mutableBytes
{
    return _bytes;
}

- (const void *)bytes
{
    return _bytes;
}

- (NSUInteger)length
{
    return _length;
}

@end


typedef enum {
    NSPurgeableDataStorageMapped = 0x1,
    NSPurgeableDataStorageAvailable = 0x2,
    NSPurgeableDataStorageStored = 0x4,
    NSPurgeableDataStorageNeedsFree = 0x8,
} NSPurgeableDataBackingFlags;

typedef struct {
    void *data;
    NSPurgeableDataBackingFlags flags;
    NSUInteger capacity;
} NSPurgeableDataStorage;

static void NSPurgeableDataStorageConvert(NSPurgeableDataStorage *storage, NSUInteger length)
{
    storage->capacity = (length + PAGE_SIZE - 1) & ~(PAGE_SIZE - 1);
    void *data = mmap(NULL, storage->capacity, PROT_READ | PROT_WRITE, MAP_ANON | MAP_PRIVATE, -1, 0);
    if ((storage->flags & NSPurgeableDataStorageMapped) != 0)
    {
        madvise(storage->data, length, MADV_WILLNEED);
    }
    memcpy(data, storage->data, length);
    if ((storage->flags & NSPurgeableDataStorageNeedsFree) != 0)
    {
        free(storage->data);
    }
    storage->flags = NSPurgeableDataStorageMapped | NSPurgeableDataStorageAvailable;
    storage->data = data;
}

static void NSPurgeableDataStorageDiscard(NSPurgeableDataStorage *storage, NSUInteger length)
{
    if ((storage->flags & NSPurgeableDataStorageMapped) != 0)
    {
        madvise(storage->data, length, MADV_DONTNEED);
    }
    else
    {
        NSPurgeableDataStorageConvert(storage, length);
        madvise(storage->data, length, MADV_DONTNEED);
    }
    storage->flags &= ~NSPurgeableDataStorageAvailable;
}

@implementation NSPurgeableData {
    NSUInteger _length;
    int32_t _accessCount;
    uint8_t _private[32];
    NSPurgeableDataStorage *_dataStorage;
}

- (id)init
{
    return [self initWithCapacity:0];
}

- (id)initWithCapacity:(NSUInteger)capacity
{
    NSCapacityCheck(capacity, 0x80000000, @"absurd capacity: %llu", (unsigned long long)capacity);

    self = [super init];
    if (self)
    {
        _length = 0;
        _dataStorage = (NSPurgeableDataStorage *)malloc(sizeof(NSPurgeableDataStorage));
        if (_dataStorage == NULL)
        {
            [self release];
            return nil;
        }
        _dataStorage->flags = NSPurgeableDataStorageMapped | NSPurgeableDataStorageAvailable;
        _dataStorage->capacity = (capacity + PAGE_SIZE - 1) & ~(PAGE_SIZE - 1); // Round up to the next page size
        if (_dataStorage->capacity == 0)
        {
            _dataStorage->data = NULL;
        }
        else
        {
            _dataStorage->data = mmap(NULL, _dataStorage->capacity, PROT_READ | PROT_WRITE, MAP_ANON | MAP_PRIVATE, -1, 0);
            if (_dataStorage->data == MAP_FAILED)
            {
                _dataStorage->data = NULL;
                [self release];
                return nil;
            }
        }
        madvise(_dataStorage->data, _dataStorage->capacity, MADV_NORMAL);
        _accessCount = 1;
    }
    return self;
}

- (id)initWithBytes:(void *)bytes length:(NSUInteger)length copy:(BOOL)shouldCopy deallocator:(void (^)(void *bytes, NSUInteger length))deallocator
{
    NSCapacityCheck(length, 0x80000000, @"absurd capacity: %llu", (unsigned long long)length);

    self = [self initWithCapacity:length];
    if (self != nil)
    {
        _length = length;
        memmove(_dataStorage->data, bytes, _dataStorage->capacity);
        if (deallocator != nil)
        {
            deallocator(bytes, length);
        }
    }
    return self;
}

- (void)dealloc
{
    if (_dataStorage != NULL && _dataStorage->data != NULL)
    {
        if ((_dataStorage->flags & NSPurgeableDataStorageMapped) != 0)
        {
            munmap(_dataStorage->data, _dataStorage->capacity);
        }
        else if ((_dataStorage->flags & NSPurgeableDataStorageNeedsFree) != 0)
        {
            free(_dataStorage->data);
        }
    }
    if (_dataStorage != NULL)
    {
        free(_dataStorage);
    }
    [super dealloc];
}

- (BOOL)isContentDiscarded
{
    return (_dataStorage->flags & NSPurgeableDataStorageAvailable) == 0;
}

- (void)discardContentIfPossible
{
    @synchronized(self)
    {
        if (_accessCount == 0)
        {
            NSPurgeableDataStorageDiscard(_dataStorage, _length);
        }
    }
}

- (void)_destroyMemory
{

}

static inline BOOL NSPurgeableDataCheckAccessCount(NSPurgeableData *d)
{
    if (d->_accessCount == 0)
    {
        [NSException raise:NSGenericException format:@"Cannot access purged purgeable data"];
        return NO;
    }
    return YES;
}

- (void)endContentAccess
{
    @synchronized(self)
    {
        if (!NSPurgeableDataCheckAccessCount(self))
        {
            return;
        }
        _accessCount--;
        if (_accessCount == 0)
        {
            NSPurgeableDataStorageDiscard(_dataStorage, _length);
        }
    }
}

- (BOOL)beginContentAccess
{
    @synchronized(self)
    {
        if (_accessCount == 0)
        {
            madvise(_dataStorage->data, _length, MADV_WILLNEED);
        }
        _accessCount++;
    }
    return YES; // is it even possible for this to return no?
}

- (void)setLength:(NSUInteger)length
{
    if (!NSPurgeableDataCheckAccessCount(self))
    {
        return;
    }

    if (_dataStorage->capacity < length)
    {
        NSUInteger capacity = (length + PAGE_SIZE - 1) & ~(PAGE_SIZE - 1);
        void *data = mmap(NULL, capacity, PROT_READ | PROT_WRITE, MAP_ANON, -1, 0);
        if ((_dataStorage->flags & NSPurgeableDataStorageMapped) != 0)
        {
            madvise(_dataStorage->data, _length, MADV_WILLNEED);
        }
        memcpy(data, _dataStorage->data, _length);
        _length = length;
        if ((_dataStorage->flags & NSPurgeableDataStorageMapped) != 0)
        {
            munmap(_dataStorage->data, _dataStorage->capacity);
        }
        else if ((_dataStorage->flags & NSPurgeableDataStorageNeedsFree) != 0)
        {
            free(_dataStorage->data);
        }
        _dataStorage->capacity = capacity;
        _dataStorage->flags = NSPurgeableDataStorageMapped | NSPurgeableDataStorageAvailable;
        _dataStorage->data = data;
    }
    else
    {
        _length = length;
    }
}

- (void *)mutableBytes
{
    if (!NSPurgeableDataCheckAccessCount(self))
    {
        return NULL;
    }

    if ((_dataStorage->flags & NSPurgeableDataStorageStored) != 0)
    {
        NSPurgeableDataStorageConvert(_dataStorage, _length);
    }
    return _dataStorage->data;
}

- (const void *)bytes
{
    if (!NSPurgeableDataCheckAccessCount(self))
    {
        return NULL;
    }

    return _dataStorage->data;
}

- (NSUInteger)length
{
    if (!NSPurgeableDataCheckAccessCount(self))
    {
        return NSNotFound;
    }

    return _length;
}

- (NSString *)description
{
    @synchronized(self)
    {
        if (_accessCount > 0)
        {
            return [super description];
        }
        else
        {
            return [NSString stringWithFormat:@"<%@: %p>", [self class], self];
        }
    }
}

@end


@implementation __NSZeroData

+ (id)data
{
    static dispatch_once_t once;
    static __NSZeroData *zeroData;
    dispatch_once(&once, ^{
        zeroData = [[__NSZeroData alloc] init];
    });
    return zeroData;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (NSUInteger)length
{
    return 0;
}

- (const void *)bytes
{
    return NULL;
}

SINGLETON_RR()

@end
