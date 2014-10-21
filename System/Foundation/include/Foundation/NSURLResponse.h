#import <Foundation/NSObject.h>

@class NSDictionary, NSString, NSURL, NSURLRequest;

#define NSURLResponseUnknownLength ((long long)-1)

@interface NSURLResponse : NSObject <NSCoding, NSCopying>

- (id)initWithURL:(NSURL *)URL MIMEType:(NSString *)MIMEType expectedContentLength:(NSInteger)length textEncodingName:(NSString *)name;
- (NSURL *)URL;
- (NSString *)MIMEType;
- (long long)expectedContentLength;
- (NSString *)textEncodingName;
- (NSString *)suggestedFilename;

@end

@interface NSHTTPURLResponse : NSURLResponse

+ (NSString *)localizedStringForStatusCode:(NSInteger)statusCode;
- (id)initWithURL:(NSURL*)URL statusCode:(NSInteger)statusCode HTTPVersion:(NSString*)HTTPVersion headerFields:(NSDictionary *)headerFields;
- (NSInteger)statusCode;
- (NSDictionary *)allHeaderFields;

@end
