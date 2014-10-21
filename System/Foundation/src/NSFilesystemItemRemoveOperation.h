#import <Foundation/NSOperation.h>
#import <Foundation/NSFileManager.h>

CF_PRIVATE
@interface NSFilesystemItemRemoveOperation : NSOperation

+ (id)filesystemItemRemoveOperationWithPath:(NSString *)path;
+ (NSError *)_errorWithErrno:(int)err atPath:(NSString *)path;
- (void)dealloc;
- (void)main;
- (id)initWithPath:(NSString *)path;
- (BOOL)_filtersUnderbars;
- (void)_setFilterUnderbars:(BOOL)filterUnderbars;
- (void)_setError:(NSError *)error;
- (NSError *)error;
- (void)setDelegate:(NSFileManager *)delegate;
- (NSFileManager *)delegate;

@end
