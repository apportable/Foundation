//
//  _NSFileIO.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "_NSFileIO.h"

#import <libv/libv.h>
#import <Foundation/FoundationErrors.h>
#import <Foundation/NSString.h>
#import <Foundation/NSURL.h>
#import <Foundation/NSError.h>
#import <Foundation/NSDictionary.h>
#import <fcntl.h>
#import <errno.h>
#import <libkern/OSAtomic.h>
#import <stdio.h>
#import <sys/mman.h>
#import <sys/stat.h>
#import "NSErrorInternal.h"

void *_NSReadBytesFromFile(NSString *path, NSDataReadingOptions readOptionsMask, NSUInteger *length, BOOL *vm, NSError **err)
{
    *length = 0;

    int fd = open([path UTF8String], O_RDONLY);
    if (fd < 0)
    {
        if (err != NULL)
        {
            *err = [NSError errorWithDomain:NSPOSIXErrorDomain code:errno userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithUTF8String:strerror(errno)]}];
        }
        return NULL;
    }
    struct stat statInfo;
    int result = fstat(fd, &statInfo);
    if (UNLIKELY(result != 0))
    {
        close(fd);
        if (err != NULL)
        {
            *err = [NSError errorWithDomain:NSPOSIXErrorDomain code:errno userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithUTF8String:strerror(errno)]}];
        }
        return NULL;
    }
    if (S_ISDIR(statInfo.st_mode))
    {
        close(fd);
        if (err != NULL)
        {
            *err = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileReadNoPermissionError userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"the path %@ is a directory", path]}];
        }
        return NULL;
    }
    off_t len = statInfo.st_size;
    *length = len;

    if (readOptionsMask & NSDataReadingMappedIfSafe)
    {
        *vm = NO;
        void *bytes = mmap(0, len, PROT_READ, MAP_SHARED, fd, 0);
        if (bytes != MAP_FAILED)
        {
            *vm = YES;

            close(fd);
            return bytes;
        }
    }

    blksize_t preferred_block_size = statInfo.st_blksize;

    // Maybe a special file such as a file in the /proc or /sys virtual filesystems.
    // See http://unix.stackexchange.com/questions/80324/determining-if-a-file-system-object-is-a-procfs-sysfs-etc-virtual-file-which
    BOOL file_size_unknown = statInfo.st_size == 0;
    if (file_size_unknown)
    {
        // Keep reading file until EOF.
        len = preferred_block_size;
    }

    void *bytes = malloc(len);
    if (UNLIKELY(bytes == NULL))
    {
        if (err != NULL)
        {
            *err = [NSError _outOfMemoryError];
        }
        close(fd);
        return nil;
    }
    size_t offset = 0;

    while (offset < len)
    {
        size_t buffer_size = MIN(len - offset, preferred_block_size);
        ssize_t amt = read(fd, (char *)bytes + offset, buffer_size);
        if (amt < 0)
        {
            free(bytes);
            bytes = NULL;
            if (err != NULL)
            {
                *err = [NSError errorWithDomain:NSPOSIXErrorDomain code:errno userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithUTF8String:strerror(errno)]}];
            }
            break;
        }

        offset += amt;

        // if hit EOF, break regardless, otherwise we loop forever
        if (amt == 0)
        {
            len = offset;
            *length = len;
            bytes = reallocf(bytes, len);

            if (UNLIKELY(bytes == NULL))
            {
                if (err != NULL)
                {
                    *err = [NSError _outOfMemoryError];
                }
            }

            break;
        }

        if (file_size_unknown)
        {
            // Allocate more memory and continue reading
            len = offset + preferred_block_size;
            bytes = reallocf(bytes, len);

            if (UNLIKELY(bytes == NULL))
            {
                if (err != NULL)
                {
                    *err = [NSError _outOfMemoryError];
                }
                break;
            }
        }
    }

    close(fd);

    return bytes;
}

BOOL _NSWriteBytesToFile(NSData *data, id pathOrURL, NSDataWritingOptions options, NSError **errorPtr)
{
    if (![pathOrURL isNSString__])
    {
        pathOrURL = [pathOrURL path];
    }
    NSString *dest = pathOrURL;
    if ((options & NSDataWritingAtomic) != 0)
    {
        static int atomicId = 0;
        atomicId = OSAtomicIncrement32(&atomicId);
        pathOrURL = [pathOrURL stringByAppendingFormat:@".tmp%d", atomicId];
    }
    int fd = -1;
    const char *path = [pathOrURL UTF8String];
    if ((options & NSDataWritingWithoutOverwriting) != 0)
    {
        struct stat info;
        int err = lstat(path, &info);
        if (err != 0)
        {
            fd = open(path, O_WRONLY|O_TRUNC|O_CREAT, 0644);
        }
        else if (errorPtr != NULL)
        {
            *errorPtr = [NSError errorWithDomain:NSCocoaErrorDomain code:-1 userInfo:@{
                NSLocalizedDescriptionKey: @"file already exists"
            }];
        }
    }
    else
    {
        fd = open(path, O_WRONLY|O_TRUNC|O_CREAT, 0644);
        if (fd == -1 && errorPtr != NULL)
        {
            *errorPtr = [NSError errorWithDomain:NSPOSIXErrorDomain code:errno userInfo:@{
                NSLocalizedDescriptionKey: [NSString stringWithFormat:@"%s", strerror(errno)]
            }];
        }
    }
    if (fd == -1)
    {
        return NO;
    }
    uint8_t *buffer = (uint8_t *)[data bytes];
    NSUInteger remaining = [data length];
    while (remaining > 0)
    {
        ssize_t amt = write(fd, buffer, remaining);
        if (amt < 0)
        {
            if (errno == EINTR)
            {
                continue;
            }
            else
            {
                if (errorPtr != NULL)
                {
                    *errorPtr = [NSError errorWithDomain:NSPOSIXErrorDomain code:errno userInfo:@{
                        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"%s", strerror(errno)]
                    }];
                }
            }
            return NO;
        }
        else if (amt == 0)
        {
            break;
        }
        else
        {
            remaining -= amt;
            buffer += amt;
        }
    }
    close(fd);
    if (remaining == 0 && dest != pathOrURL)
    {
        if (rename([pathOrURL UTF8String], [dest UTF8String]) != -1)
        {
            return YES;
        }
        else
        {
            if (errorPtr != NULL)
            {
                *errorPtr = [NSError errorWithDomain:NSPOSIXErrorDomain code:errno userInfo:@{
                    NSLocalizedDescriptionKey: [NSString stringWithFormat:@"%s", strerror(errno)]
                }];
            }
            return NO;
        }
    }
    else
    {
        // the error was already set hopefully by the amout being negative.
        return remaining == 0;
    }
}
