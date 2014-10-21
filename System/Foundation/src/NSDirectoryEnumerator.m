//
//  NSDirectoryEnumerator.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "NSDirectoryEnumerator.h"
#import "NSObjectInternal.h"

@implementation NSDirectoryEnumerator

- (NSDictionary *)fileAttributes
{
    NSRequestConcreteImplementation();
    return nil;
}

- (NSDictionary *)directoryAttributes
{
    NSRequestConcreteImplementation();
    return nil;
}

- (void)skipDescendents
{
    [self skipDescendants];
}

- (NSUInteger)level
{
    NSRequestConcreteImplementation();
    return 0;
}

- (void)skipDescendants
{
    NSRequestConcreteImplementation();
}

@end

@implementation NSAllDescendantPathsEnumerator

+ (id)newWithPath:(NSString *)path prepend:(NSString *)prefix attributes:(NSArray *)properties cross:(BOOL)cross depth:(NSUInteger)depth
{
    NSAllDescendantPathsEnumerator *enumerator = [[NSAllDescendantPathsEnumerator alloc] init];
    NSFileManager *fm = [NSFileManager defaultManager];
    
    enumerator->contents = [[fm contentsOfDirectoryAtPath:path error:NULL] copy];
    enumerator->path = [path copy];
    enumerator->prepend = [prefix copy];
    enumerator->cross = cross;
    enumerator->depth = depth;
    enumerator->directoryAttributes = nil;
    
    return enumerator;
}

- (void)dealloc
{
    [contents release];
    [path release];
    [prepend release];
    [under release];
    [super dealloc];
}

- (void)skipDescendants
{
    cross = NO;
}

- (void)skipDescendents
{
    [self skipDescendants];
}

- (NSAllDescendantPathsEnumerator *)_under
{
    return under;
}

- (NSUInteger)level
{
    return depth;
}

- (id)currentSubdirectoryAttributes
{
    return [[NSFileManager defaultManager] attributesOfItemAtPath:[pathToLastReportedItem stringByDeletingLastPathComponent] error:NULL];
}

- (NSDictionary *)directoryAttributes
{
    return [[NSFileManager defaultManager] attributesOfItemAtPath:path error:NULL];
}

- (NSDictionary *)fileAttributes
{
    return [[NSFileManager defaultManager] attributesOfItemAtPath:pathToLastReportedItem error:NULL];
}

- (id)nextObject
{
    NSString *item = nil;
    if (under != nil)
    {
        item = [under nextObject];
        if (item == nil)
        {
            [under release];
            under = nil;
        }
    }
    
    if ([contents count] > idx && item == nil)
    {
        item = contents[idx];
        pathToLastReportedItem = [[path stringByAppendingPathComponent:item] retain];
        BOOL isDir = NO;
        BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:pathToLastReportedItem isDirectory:&isDir];
        if (exists && isDir && cross)
        {
            under = [NSAllDescendantPathsEnumerator newWithPath:pathToLastReportedItem prepend:item attributes:nil cross:cross depth:depth + 1];
        }
        idx++;
    }
    
    if (prepend != nil && item != nil)
    {
        return [NSString stringWithFormat:@"%@/%@", prepend, item];
    }
    else
    {
        return item;
    }
}

@end

static CFURLEnumeratorOptions CFURLEnumeratorOptionsFromNSDirectoryEnumeration(NSDirectoryEnumerationOptions opts)
{
    CFURLEnumeratorOptions options = kCFURLEnumeratorDefaultBehavior;
    if ((opts & NSDirectoryEnumerationSkipsSubdirectoryDescendants) != 0)
    {
        options |= kCFURLEnumeratorDescendRecursively;
    }
    
    if ((opts & NSDirectoryEnumerationSkipsHiddenFiles) != 0)
    {
        options |= kCFURLEnumeratorSkipInvisibles;
    }

    if ((opts & NSVolumeEnumerationProduceFileReferenceURLs) != 0)
    {
        options |= kCFURLEnumeratorGenerateFileReferenceURLs;
    }

    if ((opts & NSDirectoryEnumerationSkipsPackageDescendants) != 0)
    {
        options |= kCFURLEnumeratorSkipPackageContents;
    }

    return options;
}

@implementation NSURLDirectoryEnumerator

- (id)initWithURL:(NSURL *)url includingPropertiesForKeys:(NSArray *)properties options:(NSDirectoryEnumerationOptions)options errorHandler:(BOOL (^)(NSURL *url, NSError *error))handler
{
    self = [super init];
    if (self)
    {
        if (!url)
        {
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"URL is nil" userInfo:nil];
        }

        _enumerator = CFURLEnumeratorCreateForDirectoryURL(kCFAllocatorDefault, (CFURLRef)[url standardizedURL], CFURLEnumeratorOptionsFromNSDirectoryEnumeration(options), (CFArrayRef)properties);
        if (_enumerator) 
        {
            self.errorHandler = handler;
            shouldContinue = YES;
        }
    }
    return self;
}

- (void)dealloc
{
    if (_enumerator)
    {
        CFRelease(_enumerator);
    }
    self.errorHandler = nil;
    [super dealloc];
}

- (NSDictionary *)directoryAttributes
{
    return nil;
}

- (NSDictionary *)fileAttributes
{
    return nil;
}

- (NSUInteger)level
{
    return (NSUInteger)CFURLEnumeratorGetDescendentLevel(_enumerator);
}

- (void)skipDescendants
{
    CFURLEnumeratorSkipDescendents(_enumerator);
}

- (void)skipDescendents
{
    [self skipDescendants];
}

- (id)nextObject
{
    CFURLRef url = NULL;
    while (shouldContinue)
    {
        CFErrorRef error = NULL;
        if (!CFURLEnumeratorGetNextURL(_enumerator, &url, &error))
        {
            if (self.errorHandler != NULL)
            {
                shouldContinue = self.errorHandler((NSURL *)url, (NSError *)error);
            }
        }
        else
        {
            break;
        }
        if (error != NULL)
        {
            CFRelease(error);
        }
    }
    return [(NSURL *)url autorelease];
}

@end
