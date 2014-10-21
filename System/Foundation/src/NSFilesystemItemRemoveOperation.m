//
//  NSFilesystemItemRemoveOperation.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "NSFilesystemItemRemoveOperation.h"
#import <ftw.h>
#import <errno.h>
#import <unistd.h>
#import <stdlib.h>
#import <stdio.h>
#import <Foundation/NSError.h>

@implementation NSFilesystemItemRemoveOperation {
    NSFileManager *_delegate;
    NSString *_removePath;
    NSError *_error;
    void *_state;
    BOOL _filterUnderbars;
}

+ (id)filesystemItemRemoveOperationWithPath:(NSString *)path
{
    return [[[NSFilesystemItemRemoveOperation alloc] initWithPath:path] autorelease];
}

+ (NSError *)_errorWithErrno:(int)err atPath:(NSString *)path
{
    NSDictionary *info = nil;
    if (path != nil)
    {
        info = @{
            NSFilePathErrorKey: path
        };
    }
    return [NSError errorWithDomain:NSPOSIXErrorDomain code:err userInfo:info];
}

- (id)initWithPath:(NSString *)path
{
    self = [super init];

    if (self)
    {
        _removePath = [path retain];
    }

    return self;
    
}

- (void)dealloc
{
    [_error release];
    [_removePath release];

    [super dealloc];
}

static int NSFilesystemItemRemoveOperationFunction(const char *path, const struct stat *stat_info, int flags, struct FTW *info, void *ctx)
{
    NSFilesystemItemRemoveOperation *op = (NSFilesystemItemRemoveOperation *)ctx;
    NSFileManager *fm = [op delegate];
    id fmDelegate = [fm delegate];
    BOOL shouldRemove = YES;
    NSString *pathStr = [NSString stringWithUTF8String:path];
    if ([fmDelegate respondsToSelector:@selector(fileManager:shouldRemoveItemAtPath:)])
    {
        shouldRemove = [fmDelegate fileManager:fm shouldRemoveItemAtPath:pathStr];
    }

    if (!shouldRemove)
    {
        return 0;
    }

    int err = remove(path);

    if (err != 0)
    {
        BOOL shouldProceed = YES;
        NSError *error = [NSFilesystemItemRemoveOperation _errorWithErrno:errno atPath:pathStr];
        [op _setError:error];
        if ([fmDelegate respondsToSelector:@selector(fileManager:shouldProceedAfterError:removingItemAtPath:)])
        {
            shouldProceed = [fmDelegate fileManager:fm shouldProceedAfterError:error removingItemAtPath:pathStr];
        }
        if (!shouldProceed)
        {
            return -1; // FTW_STOP missing from both bionic and iOS?
        }
    }

    return 0;
}

- (void)main
{
    @autoreleasepool
    {
        extern int _nftw_context(const char *path, int (*fn)(const char *, const struct stat *, int, struct FTW *, void *), int nfds, int ftwflags, void *ctx);
        int err = _nftw_context([_removePath cString], NSFilesystemItemRemoveOperationFunction, 0, FTW_DEPTH, self);
        if (_error == nil && err != 0)
        {
            NSError *error = [NSFilesystemItemRemoveOperation _errorWithErrno:errno atPath:_removePath];
            [self _setError:error];
        }
    }
}

- (BOOL)_filtersUnderbars
{
    return _filterUnderbars;
}

- (void)_setFilterUnderbars:(BOOL)filterUnderbars
{
    _filterUnderbars = filterUnderbars;
}

- (void)_setError:(NSError *)error
{
    if (error != _error)
    {
        [_error release];
        _error = [error retain];
    }
}

- (id)error
{
    return _error;
}

- (void)setDelegate:(NSFileManager *)delegate
{
    _delegate = delegate;
}

- (NSFileManager *)delegate
{
    return _delegate;
}

@end
