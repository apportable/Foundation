#import <Foundation/NSObject.h>

@class NSArray, NSDate, NSDictionary, NSError, NSString, NSURL;

typedef NS_OPTIONS(NSUInteger, NSFileVersionAddingOptions) {
    NSFileVersionAddingByMoving = 1 << 0
};

typedef NS_OPTIONS(NSUInteger, NSFileVersionReplacingOptions) {
    NSFileVersionReplacingByMoving = 1 << 0
};

@interface NSFileVersion : NSObject

@property (readonly) NSURL *URL;
@property (readonly) NSString *localizedName;
@property (readonly) NSString *localizedNameOfSavingComputer;
@property (readonly) NSDate *modificationDate;
@property (readonly) id<NSCoding> persistentIdentifier;
@property (readonly, getter=isConflict) BOOL conflict;
@property (getter=isResolved) BOOL resolved;
@property (getter=isDiscardable) BOOL discardable;

+ (NSFileVersion *)currentVersionOfItemAtURL:(NSURL *)url;
+ (NSArray *)otherVersionsOfItemAtURL:(NSURL *)url;
+ (NSArray *)unresolvedConflictVersionsOfItemAtURL:(NSURL *)url;
+ (NSFileVersion *)versionOfItemAtURL:(NSURL *)url forPersistentIdentifier:(id)persistentIdentifier;
+ (NSFileVersion *)addVersionOfItemAtURL:(NSURL *)url withContentsOfURL:(NSURL *)contentsURL options:(NSFileVersionAddingOptions)options error:(NSError **)outError;
+ (NSURL *)temporaryDirectoryURLForNewVersionOfItemAtURL:(NSURL *)url;
+ (BOOL)removeOtherVersionsOfItemAtURL:(NSURL *)url error:(NSError **)outError;

- (NSURL *)replaceItemAtURL:(NSURL *)url options:(NSFileVersionReplacingOptions)options error:(NSError **)error;
- (BOOL)removeAndReturnError:(NSError **)outError;

@end
