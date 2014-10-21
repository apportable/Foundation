#import <Foundation/NSFileManager.h>

@class NSString;

@interface NSFileManager (Internal)
- (BOOL)getFileSystemRepresentation:(char *)buffer maxLength:(NSUInteger)maxLength withPath:(NSString *)path;
@end
