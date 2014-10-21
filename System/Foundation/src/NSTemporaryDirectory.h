#import <Foundation/NSString.h>
#import <Foundation/NSPathUtilities.h>
#import <Foundation/NSProcessInfo.h>

static inline BOOL _NSTempFileCreate(NSString *path, NSString **tempPath, NSString **tempDir, NSError **err)
{
    if (tempPath != NULL)
    {
        *tempPath = nil;
    }

    if (tempDir != NULL)
    {
        *tempDir = nil;
    }
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *tempDirPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[[NSProcessInfo processInfo] globallyUniqueString]];
    NSString *tempFilePath = [tempDirPath stringByAppendingPathComponent:[path lastPathComponent]];

    BOOL isDir = NO;
    BOOL exists = [fm fileExistsAtPath:tempDirPath isDirectory:&isDir];
    if (exists && !isDir)
    {
#warning TODO https://code.google.com/p/apportable/issues/detail?id=255
        return NO;
    }

    if (!exists && ![fm createDirectoryAtPath:tempDirPath attributes:nil])
    {
#warning TODO https://code.google.com/p/apportable/issues/detail?id=255
        return NO;
    }

    if (tempPath != NULL)
    {
        *tempPath = tempFilePath;
    }

    if (tempDir != NULL)
    {
        *tempDir = tempDirPath;
    }

    return [fm createFileAtPath:tempFilePath contents:nil attributes:nil];
}

static inline BOOL _NSTempFileSwap(NSString *tempPath, NSString *destPath)
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *destDir = [destPath stringByDeletingLastPathComponent];
    BOOL isDir = NO;
    BOOL exists = [fm fileExistsAtPath:destDir isDirectory:&isDir];
    if (exists && !isDir)
    {
        return NO;
    }

    exists = [fm fileExistsAtPath:tempPath isDirectory:&isDir];
    if (!exists || isDir)
    {
        return NO;
    }

    return [fm moveItemAtPath:tempPath toPath:destPath error:NULL];
}

static inline BOOL _NSTempCleanup(NSString *tempDir)
{
    NSFileManager *fm = [NSFileManager defaultManager];
    return [fm removeItemAtPath:tempDir error:NULL];
}
