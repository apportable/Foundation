#import <Foundation/NSObject.h>
#import <Foundation/NSDate.h>

enum {
    NSWindowsNTOperatingSystem = 1,
    NSWindows95OperatingSystem,
    NSSolarisOperatingSystem,
    NSHPUXOperatingSystem,
    NSMACHOperatingSystem,
    NSSunOSOperatingSystem,
    NSOSF1OperatingSystem,
    NSAndroidOperatingSystem,
};

@class NSArray, NSString, NSDictionary;

@interface NSProcessInfo : NSObject

+ (NSProcessInfo *)processInfo;

- (NSDictionary *)environment;
- (NSArray *)arguments;
- (NSString *)hostName;
- (NSString *)processName;
- (int)processIdentifier;
- (void)setProcessName:(NSString *)newName;
- (NSString *)globallyUniqueString;
- (NSUInteger)operatingSystem;
- (NSString *)operatingSystemName;
- (NSString *)operatingSystemVersionString;
- (NSUInteger)processorCount;
- (NSUInteger)activeProcessorCount;
- (unsigned long long)physicalMemory;
- (NSTimeInterval)systemUptime;

@end
