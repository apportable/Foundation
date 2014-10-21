#import <Foundation/NSObject.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSRange.h>

FOUNDATION_EXPORT NSString * const NSFileHandleOperationException;
FOUNDATION_EXPORT NSString * const NSFileHandleReadCompletionNotification;
FOUNDATION_EXPORT NSString * const NSFileHandleReadToEndOfFileCompletionNotification;
FOUNDATION_EXPORT NSString * const NSFileHandleConnectionAcceptedNotification;
FOUNDATION_EXPORT NSString * const NSFileHandleDataAvailableNotification;
FOUNDATION_EXPORT NSString * const NSFileHandleNotificationDataItem;
FOUNDATION_EXPORT NSString * const NSFileHandleNotificationFileHandleItem;
FOUNDATION_EXPORT NSString * const NSFileHandleNotificationMonitorModes;

@class NSString, NSData, NSError;

@interface NSFileHandle : NSObject <NSSecureCoding>

- (NSData *)availableData;
- (NSData *)readDataToEndOfFile;
- (NSData *)readDataOfLength:(NSUInteger)length;
- (void)writeData:(NSData *)data;
- (unsigned long long)offsetInFile;
- (unsigned long long)seekToEndOfFile;
- (void)seekToFileOffset:(unsigned long long)offset;
- (void)truncateFileAtOffset:(unsigned long long)offset;
- (void)synchronizeFile;
- (void)closeFile;

@end

@interface NSFileHandle (NSFileHandleCreation)

+ (id)fileHandleWithStandardInput;
+ (id)fileHandleWithStandardOutput;
+ (id)fileHandleWithStandardError;
+ (id)fileHandleWithNullDevice;
+ (id)fileHandleForReadingAtPath:(NSString *)path;
+ (id)fileHandleForWritingAtPath:(NSString *)path;
+ (id)fileHandleForUpdatingAtPath:(NSString *)path;
+ (id)fileHandleForReadingFromURL:(NSURL *)url error:(NSError **)error;
+ (id)fileHandleForWritingToURL:(NSURL *)url error:(NSError **)error;
+ (id)fileHandleForUpdatingURL:(NSURL *)url error:(NSError **)error;

@end

@interface NSFileHandle (NSFileHandleAsynchronousAccess)

@property (copy) void (^readabilityHandler)(NSFileHandle *);
@property (copy) void (^writeabilityHandler)(NSFileHandle *);

- (void)readInBackgroundAndNotifyForModes:(NSArray *)modes;
- (void)readInBackgroundAndNotify;
- (void)readToEndOfFileInBackgroundAndNotifyForModes:(NSArray *)modes;
- (void)readToEndOfFileInBackgroundAndNotify;
- (void)acceptConnectionInBackgroundAndNotifyForModes:(NSArray *)modes;
- (void)acceptConnectionInBackgroundAndNotify;
- (void)waitForDataInBackgroundAndNotifyForModes:(NSArray *)modes;
- (void)waitForDataInBackgroundAndNotify;

@end

@interface NSFileHandle (NSFileHandlePlatformSpecific)

- (id)initWithFileDescriptor:(int)fd closeOnDealloc:(BOOL)closeopt;
- (id)initWithFileDescriptor:(int)fd;
- (int)fileDescriptor;

@end

@interface NSPipe : NSObject

+ (id)pipe;
- (id)init;
- (NSFileHandle *)fileHandleForReading;
- (NSFileHandle *)fileHandleForWriting;

@end
