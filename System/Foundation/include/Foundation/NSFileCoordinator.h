#import <Foundation/NSObject.h>

@class NSArray, NSError, NSMutableDictionary, NSURL;

@protocol NSFilePresenter;

typedef NS_OPTIONS(NSUInteger, NSFileCoordinatorReadingOptions) {
    NSFileCoordinatorReadingWithoutChanges       = 1 << 0,
    NSFileCoordinatorReadingResolvesSymbolicLink = 1 << 1
};

typedef NS_OPTIONS(NSUInteger, NSFileCoordinatorWritingOptions) {
    NSFileCoordinatorWritingForDeleting  = 1 << 0,
    NSFileCoordinatorWritingForMoving    = 1 << 1,
    NSFileCoordinatorWritingForMerging   = 1 << 2,
    NSFileCoordinatorWritingForReplacing = 1 << 3
};

@interface NSFileCoordinator : NSObject

+ (void)addFilePresenter:(id<NSFilePresenter>)filePresenter;
+ (void)removeFilePresenter:(id<NSFilePresenter>)filePresenter;
+ (NSArray *)filePresenters;

- (id)initWithFilePresenter:(id<NSFilePresenter>)filePresenterOrNil;

#if NS_BLOCKS_AVAILABLE
- (void)coordinateReadingItemAtURL:(NSURL *)url options:(NSFileCoordinatorReadingOptions)options error:(NSError **)outError byAccessor:(void (^)(NSURL *newURL))reader;
- (void)coordinateWritingItemAtURL:(NSURL *)url options:(NSFileCoordinatorWritingOptions)options error:(NSError **)outError byAccessor:(void (^)(NSURL *newURL))writer;
- (void)coordinateReadingItemAtURL:(NSURL *)readingURL options:(NSFileCoordinatorReadingOptions)readingOptions writingItemAtURL:(NSURL *)writingURL options:(NSFileCoordinatorWritingOptions)writingOptions error:(NSError **)outError byAccessor:(void (^)(NSURL *newReadingURL, NSURL *newWritingURL))readerWriter;
- (void)coordinateWritingItemAtURL:(NSURL *)url1 options:(NSFileCoordinatorWritingOptions)options1 writingItemAtURL:(NSURL *)url2 options:(NSFileCoordinatorWritingOptions)options2 error:(NSError **)outError byAccessor:(void (^)(NSURL *newURL1, NSURL *newURL2))writer;
- (void)prepareForReadingItemsAtURLs:(NSArray *)readingURLs options:(NSFileCoordinatorReadingOptions)readingOptions writingItemsAtURLs:(NSArray *)writingURLs options:(NSFileCoordinatorWritingOptions)writingOptions error:(NSError **)outError byAccessor:(void (^)(void (^completionHandler)(void)))batchAccessor;
#endif
- (void)itemAtURL:(NSURL *)oldURL willMoveToURL:(NSURL *)newURL;
- (void)itemAtURL:(NSURL *)oldURL didMoveToURL:(NSURL *)newURL;
- (void)cancel;

@end
