#import <Foundation/NSObject.h>
#import <Foundation/NSDate.h>

@class NSString, NSArray, NSDictionary, NSPredicate, NSMetadataQuery;
@class NSMetadataItem, NSMetadataQueryAttributeValueTuple, NSMetadataQueryResultGroup;

FOUNDATION_EXPORT NSString * const NSMetadataQueryDidStartGatheringNotification;
FOUNDATION_EXPORT NSString * const NSMetadataQueryGatheringProgressNotification;
FOUNDATION_EXPORT NSString * const NSMetadataQueryDidFinishGatheringNotification;
FOUNDATION_EXPORT NSString * const NSMetadataQueryDidUpdateNotification;
FOUNDATION_EXPORT NSString * const NSMetadataQueryResultContentRelevanceAttribute;
FOUNDATION_EXPORT NSString * const NSMetadataQueryUbiquitousDocumentsScope;
FOUNDATION_EXPORT NSString * const NSMetadataQueryUbiquitousDataScope;
FOUNDATION_EXPORT NSString * const NSMetadataItemFSNameKey;
FOUNDATION_EXPORT NSString * const NSMetadataItemDisplayNameKey;
FOUNDATION_EXPORT NSString * const NSMetadataItemURLKey;
FOUNDATION_EXPORT NSString * const NSMetadataItemPathKey;
FOUNDATION_EXPORT NSString * const NSMetadataItemFSSizeKey;
FOUNDATION_EXPORT NSString * const NSMetadataItemFSCreationDateKey;
FOUNDATION_EXPORT NSString * const NSMetadataItemFSContentChangeDateKey;
FOUNDATION_EXPORT NSString * const NSMetadataItemIsUbiquitousKey;
FOUNDATION_EXPORT NSString * const NSMetadataUbiquitousItemHasUnresolvedConflictsKey;
FOUNDATION_EXPORT NSString * const NSMetadataUbiquitousItemIsDownloadedKey;
FOUNDATION_EXPORT NSString * const NSMetadataUbiquitousItemIsDownloadingKey;
FOUNDATION_EXPORT NSString * const NSMetadataUbiquitousItemIsUploadedKey;
FOUNDATION_EXPORT NSString * const NSMetadataUbiquitousItemIsUploadingKey;
FOUNDATION_EXPORT NSString * const NSMetadataUbiquitousItemPercentDownloadedKey;
FOUNDATION_EXPORT NSString * const NSMetadataUbiquitousItemPercentUploadedKey;

@protocol NSMetadataQueryDelegate <NSObject>
@optional

- (id)metadataQuery:(NSMetadataQuery *)query replacementObjectForResultObject:(NSMetadataItem *)result;
- (id)metadataQuery:(NSMetadataQuery *)query replacementValueForAttribute:(NSString *)attrName value:(id)attrValue;

@end

@interface NSMetadataQuery : NSObject

- (id)init;
- (id <NSMetadataQueryDelegate>)delegate;
- (void)setDelegate:(id <NSMetadataQueryDelegate>)delegate;
- (NSPredicate *)predicate;
- (void)setPredicate:(NSPredicate *)predicate;
- (NSArray *)sortDescriptors;
- (void)setSortDescriptors:(NSArray *)descriptors;
- (NSArray *)valueListAttributes;
- (void)setValueListAttributes:(NSArray *)attrs;
- (NSArray *)groupingAttributes;
- (void)setGroupingAttributes:(NSArray *)attrs;
- (NSTimeInterval)notificationBatchingInterval;
- (void)setNotificationBatchingInterval:(NSTimeInterval)ti;
- (NSArray *)searchScopes;
- (void)setSearchScopes:(NSArray *)scopes;
- (BOOL)startQuery;
- (void)stopQuery;
- (BOOL)isStarted;
- (BOOL)isGathering;
- (BOOL)isStopped;
- (void)disableUpdates;
- (void)enableUpdates;
- (NSUInteger)resultCount;
- (id)resultAtIndex:(NSUInteger)idx;
- (NSArray *)results;
- (NSUInteger)indexOfResult:(id)result;
- (NSDictionary *)valueLists;
- (NSArray *)groupedResults;
- (id)valueOfAttribute:(NSString *)attrName forResultAtIndex:(NSUInteger)idx;

@end

@interface NSMetadataItem : NSObject

- (id)valueForAttribute:(NSString *)key;
- (NSDictionary *)valuesForAttributes:(NSArray *)keys;
- (NSArray *)attributes;

@end

@interface NSMetadataQueryAttributeValueTuple : NSObject

- (NSString *)attribute;
- (id)value;
- (NSUInteger)count;

@end

@interface NSMetadataQueryResultGroup : NSObject

- (NSString *)attribute;
- (id)value;
- (NSArray *)subgroups;
- (NSUInteger)resultCount;
- (id)resultAtIndex:(NSUInteger)idx;
- (NSArray *)results;

@end
