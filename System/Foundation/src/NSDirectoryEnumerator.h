#import <Foundation/NSFileManager.h>
#import "NSFileAttributes.h"
#import <Foundation/NSURL.h>
#import <CoreFoundation/CFURLEnumerator.h>

CF_PRIVATE
@interface NSAllDescendantPathsEnumerator : NSDirectoryEnumerator {
    NSString *path;
    NSArray *contents;
    NSUInteger idx;
    NSString *prepend;
    NSAllDescendantPathsEnumerator *under;
    NSFileAttributes *directoryAttributes;
    NSString *pathToLastReportedItem;
    NSUInteger depth;
    BOOL cross;
    char _padding[3];
}

+ (id)newWithPath:(NSString *)path prepend:(NSString *)prefix attributes:(NSArray *)properties cross:(BOOL)cross depth:(NSUInteger)depth;
- (void)dealloc;
- (void)skipDescendants;
- (void)skipDescendents;
- (NSAllDescendantPathsEnumerator *)_under;
- (NSUInteger)level;
- (id)currentSubdirectoryAttributes;
- (NSDictionary *)directoryAttributes;
- (NSDictionary *)fileAttributes;
- (id)nextObject;

@end

CF_PRIVATE
@interface NSURLDirectoryEnumerator : NSDirectoryEnumerator {
    CFURLEnumeratorRef _enumerator;
    BOOL (^_errorHandler)(NSURL *url, NSError *error);
    BOOL shouldContinue;
}

@property (copy) BOOL (^errorHandler)(NSURL *url, NSError *error);

- (id)initWithURL:(NSURL *)url includingPropertiesForKeys:(NSArray *)properties options:(NSDirectoryEnumerationOptions)options errorHandler:(BOOL (^)(NSURL *url, NSError *error))handler;
- (void)dealloc;
- (NSDictionary *)directoryAttributes;
- (NSDictionary *)fileAttributes;
- (NSUInteger)level;
- (void)skipDescendants;
- (void)skipDescendents;
- (id)nextObject;

@end
