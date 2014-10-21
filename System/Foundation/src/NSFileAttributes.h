#import <Foundation/NSFileManager.h>
#import <sys/stat.h>

CF_PRIVATE
@interface NSFileAttributes : NSDictionary

+ (id)attributesWithStat:(struct stat *)info;
+ (id)_attributesAtURL:(NSURL *)url partialReturn:(BOOL)partial filterResourceFork:(BOOL)filter error:(NSError **)error;
+ (id)_attributesAtPath:(NSString *)path partialReturn:(BOOL)partial filterResourceFork:(BOOL)filter error:(NSError **)error;
+ (id)attributesAtPath:(NSString *)path traverseLink:(BOOL)yorn;

- (id)initWithStat:(struct stat *)info;

- (BOOL)isDirectory;
- (unsigned int)fileGroupOwnerAccountNumber;
- (unsigned int)fileOwnerAccountNumber;
- (unsigned long long)fileSize;
- (NSDate *)fileModificationDate;
- (NSString *)fileType;
- (NSUInteger)filePosixPermissions;
- (NSString *)fileOwnerAccountName;
- (NSString *)fileGroupOwnerAccountName;
- (NSInteger)fileSystemNumber;
- (NSUInteger)fileSystemFileNumber;
- (id)keyEnumerator;
- (NSUInteger)count;
- (id)objectForKey:(id)key;
- (BOOL)isEqual:(id)other;
- (NSUInteger)hash;
- (void)dealloc;

@end
