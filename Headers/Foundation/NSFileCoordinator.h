#import <Foundation/NSObject.h>

@class NSArray, NSError, NSMutableDictionary, NSURL;

@protocol NSFilePresenter;

typedef NS_OPTIONS(NSUInteger, NSFileCoordinatorReadingOptions) {
    NSFileCoordinatorReadingWithoutChanges       = 1 << 0,
    NSFileCoordinatorReadingResolvesSymbolicLink = 1 << 1
};

typedef NS_OPTIONS(NSUInteger, NSFileCoordinatorWritingOptions) {
    NSFileCoordinatorWritingForDeleting     = 1 << 0,
    NSFileCoordinatorWritingForMoving       = 1 << 1,
    NSFileCoordinatorWritingForMerging      = 1 << 2,
    NSFileCoordinatorWritingForReplacing    = 1 << 3
};

@interface NSFileCoordinator : NSObject

+ (void)addFilePresenter:(id<NSFilePresenter>)filePresenter;
+ (void)removeFilePresenter:(id<NSFilePresenter>)filePresenter;
+ (NSArray *)filePresenters;
- (id)initWithFilePresenter:(id<NSFilePresenter>)filePresenterOrNil;
- (void)itemAtURL:(NSURL *)oldURL willMoveToURL:(NSURL *)newURL;
- (void)itemAtURL:(NSURL *)oldURL didMoveToURL:(NSURL *)newURL;
- (void)cancel;

@end
