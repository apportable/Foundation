
#import <Foundation/NSObject.h>

@class NSError, NSFileVersion, NSOperationQueue, NSURL;

@protocol NSFilePresenter<NSObject>

@required
@property (readonly) NSURL *presentedItemURL;
@property (readonly) NSOperationQueue *presentedItemOperationQueue;

@optional
@property (readonly) NSURL *primaryPresentedItemURL;

- (void)presentedItemDidMoveToURL:(NSURL *)newURL;
- (void)presentedItemDidChange;
- (void)presentedItemDidGainVersion:(NSFileVersion *)version;
- (void)presentedItemDidLoseVersion:(NSFileVersion *)version;
- (void)presentedItemDidResolveConflictVersion:(NSFileVersion *)version;
- (void)presentedSubitemDidAppearAtURL:(NSURL *)url;
- (void)presentedSubitemAtURL:(NSURL *)oldURL didMoveToURL:(NSURL *)newURL;
- (void)presentedSubitemDidChangeAtURL:(NSURL *)url;
- (void)presentedSubitemAtURL:(NSURL *)url didGainVersion:(NSFileVersion *)version;
- (void)presentedSubitemAtURL:(NSURL *)url didLoseVersion:(NSFileVersion *)version;
- (void)presentedSubitemAtURL:(NSURL *)url didResolveConflictVersion:(NSFileVersion *)version;

@end
