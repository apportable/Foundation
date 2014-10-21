#import <Foundation/NSObject.h>

@class NSError, NSFileVersion, NSOperationQueue, NSURL;

@protocol NSFilePresenter<NSObject>
@required

@property (readonly) NSURL *presentedItemURL;
@property (readonly) NSOperationQueue *presentedItemOperationQueue;

@optional

#if NS_BLOCKS_AVAILABLE
- (void)relinquishPresentedItemToReader:(void (^)(void (^reacquirer)(void)))reader;
- (void)relinquishPresentedItemToWriter:(void (^)(void (^reacquirer)(void)))writer;
- (void)savePresentedItemChangesWithCompletionHandler:(void (^)(NSError *errorOrNil))completionHandler;
- (void)accommodatePresentedItemDeletionWithCompletionHandler:(void (^)(NSError *errorOrNil))completionHandler;
#endif
- (void)presentedItemDidMoveToURL:(NSURL *)newURL;
- (void)presentedItemDidChange;
- (void)presentedItemDidGainVersion:(NSFileVersion *)version;
- (void)presentedItemDidLoseVersion:(NSFileVersion *)version;
- (void)presentedItemDidResolveConflictVersion:(NSFileVersion *)version;
#if NS_BLOCKS_AVAILABLE
- (void)accommodatePresentedSubitemDeletionAtURL:(NSURL *)url completionHandler:(void (^)(NSError *errorOrNil))completionHandler;
#endif
- (void)presentedSubitemDidAppearAtURL:(NSURL *)url;
- (void)presentedSubitemAtURL:(NSURL *)oldURL didMoveToURL:(NSURL *)newURL;
- (void)presentedSubitemDidChangeAtURL:(NSURL *)url;
- (void)presentedSubitemAtURL:(NSURL *)url didGainVersion:(NSFileVersion *)version;
- (void)presentedSubitemAtURL:(NSURL *)url didLoseVersion:(NSFileVersion *)version;
- (void)presentedSubitemAtURL:(NSURL *)url didResolveConflictVersion:(NSFileVersion *)version;

@end
