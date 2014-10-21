#import <Foundation/NSObject.h>

@class NSError, NSOutputStream, NSInputStream, NSData;

typedef NS_OPTIONS(NSUInteger, NSJSONReadingOptions) {
    NSJSONReadingMutableContainers = (1UL << 0),
    NSJSONReadingMutableLeaves     = (1UL << 1),
    NSJSONReadingAllowFragments    = (1UL << 2)
};

typedef NS_OPTIONS(NSUInteger, NSJSONWritingOptions) {
    NSJSONWritingPrettyPrinted = (1UL << 0)
};

@interface NSJSONSerialization : NSObject

+ (BOOL)isValidJSONObject:(id)obj;
+ (NSData *)dataWithJSONObject:(id)obj options:(NSJSONWritingOptions)opt error:(NSError **)error;
+ (id)JSONObjectWithData:(NSData *)data options:(NSJSONReadingOptions)opt error:(NSError **)error;
+ (NSInteger)writeJSONObject:(id)obj toStream:(NSOutputStream *)stream options:(NSJSONWritingOptions)opt error:(NSError **)error;
+ (id)JSONObjectWithStream:(NSInputStream *)stream options:(NSJSONReadingOptions)opt error:(NSError **)error;

@end
