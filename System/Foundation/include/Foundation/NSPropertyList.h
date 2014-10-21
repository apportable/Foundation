#import <Foundation/NSObject.h>
#import <CoreFoundation/CFPropertyList.h>

@class NSData, NSString, NSError, NSInputStream, NSOutputStream;

typedef NS_OPTIONS(NSUInteger, NSPropertyListMutabilityOptions) {
    NSPropertyListImmutable = kCFPropertyListImmutable,
    NSPropertyListMutableContainers = kCFPropertyListMutableContainers,
    NSPropertyListMutableContainersAndLeaves = kCFPropertyListMutableContainersAndLeaves
};

typedef NS_ENUM(NSUInteger, NSPropertyListFormat) {
    NSPropertyListOpenStepFormat = kCFPropertyListOpenStepFormat,
    NSPropertyListXMLFormat_v1_0 = kCFPropertyListXMLFormat_v1_0,
    NSPropertyListBinaryFormat_v1_0 = kCFPropertyListBinaryFormat_v1_0
};

typedef NSUInteger NSPropertyListReadOptions;
typedef NSUInteger NSPropertyListWriteOptions;

@interface NSPropertyListSerialization : NSObject

+ (BOOL)propertyList:(id)plist isValidForFormat:(NSPropertyListFormat)format;
+ (NSData *)dataWithPropertyList:(id)plist format:(NSPropertyListFormat)format options:(NSPropertyListWriteOptions)opt error:(out NSError **)error;
+ (NSInteger)writePropertyList:(id)plist toStream:(NSOutputStream *)stream format:(NSPropertyListFormat)format options:(NSPropertyListWriteOptions)opt error:(out NSError **)error;
+ (id)propertyListWithData:(NSData *)data options:(NSPropertyListReadOptions)opt format:(NSPropertyListFormat *)format error:(out NSError **)error;
+ (id)propertyListWithStream:(NSInputStream *)stream options:(NSPropertyListReadOptions)opt format:(NSPropertyListFormat *)format error:(out NSError **)error;
+ (NSData *)dataFromPropertyList:(id)plist format:(NSPropertyListFormat)format errorDescription:(out __strong NSString **)errorString;
+ (id)propertyListFromData:(NSData *)data mutabilityOption:(NSPropertyListMutabilityOptions)opt format:(NSPropertyListFormat *)format errorDescription:(out __strong NSString **)errorString;

@end
