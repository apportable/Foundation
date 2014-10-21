#import <Foundation/NSJSONSerialization.h>
#import <Foundation/NSError.h>
#import <Foundation/NSString.h>
#import <Foundation/NSStream.h>
#import <Foundation/NSData.h>

@interface _NSJSONReader : NSObject {
    id input;
    NSJSONReadingOptions kind;
    NSError *error;
}

+ (BOOL)validForJSON:(id)obj depth:(NSUInteger)depth allowFragments:(BOOL)frags;
- (id)init;
- (void)dealloc;
- (id)parseStream:(NSInputStream *)stream options:(NSJSONReadingOptions)opts;
- (id)parseData:(NSData *)data options:(NSJSONReadingOptions)opts;
- (NSStringEncoding)findEncodingFromData:(NSData *)data withBOMSkipLength:(NSUInteger *)bomLength;
- (id)parseUTF8JSONData:(NSData *)data skipBytes:(NSUInteger)skip options:(NSJSONReadingOptions)opts;
- (void)setError:(NSError *)error;
- (NSError *)error;

@end

@interface _NSJSONWriter : NSObject {
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

- (id)init;
- (void)dealloc;
- (int)appendString:(NSString *)string range:(NSRange)range;
- (void)resizeTemporaryBuffer:(size_t)size;
- (int)writeRootObject:(id)object toStream:(NSOutputStream *)stream options:(NSJSONWritingOptions)opts error:(NSError **)error;
- (NSData *)dataWithRootObject:(id)object options:(NSJSONWritingOptions)options error:(NSError **)error;

@end
