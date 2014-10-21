//
//  NSFileHandle.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <stdio.h>
#import <sys/ioctl.h>
#import <sys/socket.h>
#import <dispatch/dispatch.h>
#import <CoreFoundation/CFRunLoop.h>
#import <Foundation/NSFileHandle.h>
#import <Foundation/NSString.h>
#import <Foundation/NSPathUtilities.h>
#import <Foundation/NSNotification.h>
#import "NSCoderInternal.h"
#import "NSObjectInternal.h"
#import <Foundation/NSURL.h>
#import <Foundation/NSData.h>
#import <Foundation/NSError.h>
#import <Foundation/NSProgress.h>

NSString * const NSFileHandleConnectionAcceptedNotification = @"NSFileHandleConnectionAcceptedNotification";
NSString * const NSFileHandleReadCompletionNotification = @"NSFileHandleReadCompletionNotification";
NSString * const NSFileHandleReadToEndOfFileCompletionNotification = @"NSFileHandleReadToEndOfFileCompletionNotification";
NSString * const NSFileHandleDataAvailableNotification = @"NSFileHandleDataAvailableNotification";
NSString * const NSFileHandleNotificationFileHandleItem = @"NSFileHandleNotificationFileHandleItem";
NSString * const NSFileHandleNotificationDataItem = @"NSFileHandleNotificationDataItem";

typedef NS_OPTIONS(unsigned short, NSConcreteFileHandleFlags) {
    NSConcreteFileHandleIsStandardInput =    0x8000,
    NSConcreteFileHandleIsStandardOutput =   0x4000,
    NSConcreteFileHandleIsStandardError =    0x2000,
    NSConcreteFileHandleClosed =             0x0002,
    NSConcreteFileHandleOwnsFileDescriptor = 0x0001,
};

typedef NS_ENUM(unsigned int, NSFileHandleActivity) {
    NSFileHandleNoActivity,
    NSFileHandleAcceptConnectionActivity,
    NSFileHandleReadActivity,
    NSFileHandleReadToEndOfFileActivity,
    NSFileHandleWaitForDataActivity,
};

CF_PRIVATE
@interface NSConcreteFileHandle : NSFileHandle
@end

CF_PRIVATE
@interface _NSStdIOFileHandle : NSConcreteFileHandle
@end

CF_PRIVATE
@interface NSNullFileHandle : NSFileHandle
@end

@interface NSFileHandle ()
@end

@interface NSConcreteFileHandle () {
  @public
    int _fd;
    unsigned short _flags;
    CFRunLoopSourceRef _source;
    CFRunLoopRef _rl;
    NSFileHandleActivity _activity;
    unsigned int _error;
    int _resultSocket;
    dispatch_source_t _dsrc;
    dispatch_data_t _resultData;
    dispatch_queue_t _fhQueue;
    void (^_readabilityHandler)(NSFileHandle *);
    void (^_writeabilityHandler)(NSFileHandle *);
    dispatch_source_t _readMonitoringSource;
    dispatch_source_t _writeMonitoringSource;
    dispatch_queue_t _monitoringQueue;
}
@end

CF_PRIVATE
@interface NSConcreteFileHandleARCWeakRef : NSObject
- (void)storeWeak:(NSConcreteFileHandle *)fh;
- (id)loadWeak;
@end

static void _NSFileHandleRaiseOperationException(id object, SEL selector)
{
    [NSException raise:@"NSFileHandleOperationException" format:@"%@: %s", _NSMethodExceptionProem(object, selector),
        errno ? strerror(errno) : "unknown error"];
}

static int _NSOpenFileDescriptor(const char *path, int flags, NSInteger createMode)
{
    int fd = open(path, flags, createMode);

    if (fd != -1) {
        struct stat sbuf;

        if (fstat(fd, &sbuf) < 0 || (sbuf.st_mode & S_IFMT) == S_IFDIR) {
            close(fd);
            fd = -1;
        }
    }
    return fd;
}

static NSInteger _NSCloseFileDescriptor(int fd)
{
    return close(fd);
}

static size_t _NSPreferredChunkSizeForFileDescriptor(int fd)
{
    struct stat sbuf;
#if 0
    struct statfs sfsbuf;

    if (fstatfs(fd, &sfsbuf) != -1) {
        return sfsbuf.f_iosize;
    } else
#endif
    if (fstat(fd, &sbuf) != -1) {
        return sbuf.st_blksize;
    }
    return -1;
}

#define FD_PROGRESS_BODY(rw) \
{ \
    size_t remainingBytes = nbytes; \
    NSProgress *progress = nil; \
    size_t chunkSize = nbytes; \
    int result = 0; \
    if (nbytes == 0) \
    { \
        return 0; \
    } \
    if (useProgress && [NSProgress currentProgress] != nil && (progress = [NSProgress progressWithTotalUnitCount:nbytes])) \
    { \
        chunkSize = _NSPreferredChunkSizeForFileDescriptor(fd); \
        if (chunkSize == -1) \
        { \
            chunkSize = nbytes; \
        } \
    } \
    if (nbytes == 0) \
    { \
        return 0; \
    } \
    int realChunk = MIN(chunkSize, INT_MAX); \
    do { \
        if ([progress isCancelled]) \
        { \
            return -1; \
        } \
        int rwThisMuch = MIN(realChunk, remainingBytes); \
        if ([progress isCancelled]) { \
            return -1; \
        } \
        do { \
            result = rw(fd, bytes, rwThisMuch); \
        } while (result < 0 && errno == EINTR); \
        if (result < 0) \
        { \
            return -1;                           \
        } \
        else if (result == 0) \
        { \
            return nbytes - remainingBytes; \
        } \
        remainingBytes -= result; \
        [progress setCompletedUnitCount:nbytes - remainingBytes]; \
        if (result < rwThisMuch) \
        { \
            return nbytes - remainingBytes; \
        } \
        bytes = (char *)bytes + result; \
    } while (remainingBytes > 0); \
    return nbytes; \
}

static ssize_t _NSWriteToFileDescriptorWithProgress(int fd, void *bytes, size_t nbytes, BOOL useProgress) FD_PROGRESS_BODY(write)

static ssize_t _NSWriteToFileDescriptor(int fd, void *bytes, size_t nbytes)
{
    return _NSWriteToFileDescriptorWithProgress(fd, bytes, nbytes, NO);
}

static ssize_t _NSReadFromFileDescriptorWithProgress(int fd, void *bytes, size_t nbytes, BOOL useProgress) FD_PROGRESS_BODY(read)

static ssize_t _NSReadFromFileDescriptor(int fd, void *bytes, size_t nbytes)
{
    return _NSReadFromFileDescriptorWithProgress(fd, bytes, nbytes, NO);
}

static NSError *_NSErrorWithFilePath(int code, id path)
{
    NSDictionary *userInfo = [path isKindOfClass:[NSURL class]] ? @{ @"NSURL"/*NSURLErrorKey*/: path } :
                                                                  @{ @"NSFilePath"/*NSFilePathErrorKey*/: path };
    return [NSError errorWithDomain:NSCocoaErrorDomain code:code userInfo:userInfo];
}

@implementation NSFileHandle

+ (id)fileHandleWithStandardInput
{
    static dispatch_once_t onceToken;
    static NSFileHandle *__NSFileHandleStandardInput = nil;

    dispatch_once(&onceToken, ^{
        __NSFileHandleStandardInput = [[_NSStdIOFileHandle alloc] initWithFileDescriptor:STDIN_FILENO closeOnDealloc:NO];
        if (__NSFileHandleStandardInput != nil) {
            ((NSConcreteFileHandle *)__NSFileHandleStandardInput)->_flags |= NSConcreteFileHandleIsStandardInput;
        } else {
            __NSFileHandleStandardInput = [self fileHandleWithNullDevice];
        }
    });
    return __NSFileHandleStandardInput;
}

+ (id)fileHandleWithStandardOutput
{
    static dispatch_once_t onceToken;
    static NSFileHandle *__NSFileHandleStandardOutput = nil;

    dispatch_once(&onceToken, ^{
        __NSFileHandleStandardOutput = [[_NSStdIOFileHandle alloc] initWithFileDescriptor:STDOUT_FILENO closeOnDealloc:NO];
        if (__NSFileHandleStandardOutput != nil) {
            ((NSConcreteFileHandle *)__NSFileHandleStandardOutput)->_flags |= NSConcreteFileHandleIsStandardOutput;
        } else {
            __NSFileHandleStandardOutput = [self fileHandleWithNullDevice];
        }
    });
    return __NSFileHandleStandardOutput;
}

+ (id)fileHandleWithStandardError
{
    static dispatch_once_t onceToken;
    static NSFileHandle *__NSFileHandleStandardError = nil;

    dispatch_once(&onceToken, ^{
        __NSFileHandleStandardError = [[_NSStdIOFileHandle alloc] initWithFileDescriptor:STDERR_FILENO closeOnDealloc:NO];
        if (__NSFileHandleStandardError != nil) {
            ((NSConcreteFileHandle *)__NSFileHandleStandardError)->_flags |= NSConcreteFileHandleIsStandardError;
        } else {
            __NSFileHandleStandardError = [self fileHandleWithNullDevice];
        }
    });
    return __NSFileHandleStandardError;
}

+ (id)fileHandleWithNullDevice
{
    static dispatch_once_t onceToken;
    static NSFileHandle *__NSNullFileHandle = nil;

    dispatch_once(&onceToken, ^{
        __NSNullFileHandle = [[NSNullFileHandle alloc] init];
    });
    return __NSNullFileHandle;
}

+ (id)allocWithZone:(NSZone *)zone
{
    if (self == [NSFileHandle class])
    {
        return NSAllocateObject([NSConcreteFileHandle self], 0, zone);
    }
    else
    {
        return NSAllocateObject(self, 0, zone);
    }
}

+ (id)fileHandleForReadingAtPath:(NSString *)path
{
    return [[[self alloc] initWithPath:path flags:O_RDONLY createMode:0] autorelease];
}

+ (id)fileHandleForWritingAtPath:(NSString *)path
{
    return [[[self alloc] initWithPath:path flags:O_WRONLY createMode:0] autorelease];
}

+ (id)fileHandleForUpdatingAtPath:(NSString *)path
{
    return [[[self alloc] initWithPath:path flags:O_RDWR createMode:0] autorelease];
}

+ (id)fileHandleForReadingFromURL:(NSURL *)url error:(NSError **)error
{
    return [[[self alloc] initWithURL:url flags:O_RDONLY createMode:0 error:error] autorelease];
}

+ (id)fileHandleForWritingToURL:(NSURL *)url error:(NSError **)error
{
    return [[[self alloc] initWithURL:url flags:O_WRONLY createMode:0 error:error] autorelease];
}

+ (id)fileHandleForUpdatingURL:(NSURL *)url error:(NSError **)error
{
    return [[[self alloc] initWithURL:url flags:O_RDWR createMode:0 error:error] autorelease];
}

+ (id)fileHandleForReadingFromURL:(NSURL *)url mode:(NSInteger)mode error:(NSError **)error
{
    return [[[self alloc] initWithURL:url flags:O_RDONLY|O_CREAT createMode:mode error:error] autorelease];
}

+ (id)fileHandleForWritingToURL:(NSURL *)url mode:(NSInteger)mode error:(NSError **)error
{
    return [[[self alloc] initWithURL:url flags:O_WRONLY|O_CREAT createMode:mode error:error] autorelease];
}

+ (id)fileHandleForUpdatingURL:(NSURL *)url mode:(NSInteger)mode error:(NSError **)error
{
    return [[[self alloc] initWithURL:url flags:O_RDWR|O_CREAT createMode:mode error:error] autorelease];
}

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (id)initWithPath:(NSString *)path flags:(NSInteger)flags createMode:(NSInteger)createMode
{
    NSRequestConcreteImplementation();
    return nil;
}

- (id)initWithPath:(NSString *)path flags:(NSInteger)flags createMode:(NSInteger)createMode error:(NSError **)error
{
    NSRequestConcreteImplementation();
    return nil;
}

- (id)initWithURL:(NSURL *)url flags:(NSInteger)flags createMode:(NSInteger)mode error:(NSError **)error
{
    NSString *path;
    if ([url isFileURL])
    {
        path = [url path];
    }
    else
    {
        path = nil;
    }

    return [self initWithPath:path flags:flags createMode:mode error:error];
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    NSRequestConcreteImplementation();
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if (![decoder isKindOfClass:[NSXPCCoder self]])
    {
        [self release];
        [NSException raise:NSInvalidArgumentException format:@"File handles can only be decoded by xpc coders"];
        return nil;
    }

#warning TODO xpc coders
    DEBUG_BREAK();
    [self release];
    return nil;
}

- (Class)classForCoder
{
    return [NSFileHandle self];
}

- (NSData *)availableData
{
    NSRequestConcreteImplementation();
    return nil;
}

- (NSData *)readDataToEndOfFile
{
    NSRequestConcreteImplementation();
    return nil;
}

- (NSData *)readDataOfLength:(NSUInteger)length
{
    NSRequestConcreteImplementation();
    return nil;
}

- (void)writeData:(NSData *)data
{
    NSRequestConcreteImplementation();
}

- (unsigned long long)offsetInFile
{
    NSRequestConcreteImplementation();
    return 0ULL;
}

- (unsigned long long)seekToEndOfFile
{
    NSRequestConcreteImplementation();
    return 0ULL;
}

- (void)seekToFileOffset:(unsigned long long)offset
{
    NSRequestConcreteImplementation();
}

- (void)truncateFileAtOffset:(unsigned long long)offset
{
    NSRequestConcreteImplementation();
}

- (void)synchronizeFile
{
    NSRequestConcreteImplementation();
}

- (void)closeFile
{
    NSRequestConcreteImplementation();
}

- (void (^)(NSFileHandle *))readabilityHandler
{
    NSRequestConcreteImplementation();
    return nil;
}

- (void)setReadabilityHandler:(void (^)(NSFileHandle *))handler
{
    NSRequestConcreteImplementation();
}

- (void (^)(NSFileHandle *))writeabilityHandler
{
    NSRequestConcreteImplementation();
    return nil;
}

- (void)setWriteabilityHandler:(void (^)(NSFileHandle *))handler
{
    NSRequestConcreteImplementation();
}

- (int)fileDescriptor
{
    NSRequestConcreteImplementation();
    return -1;
}

@end

@implementation NSConcreteFileHandle

#define FAIL() _NSFileHandleRaiseOperationException(self, _cmd)

#define FAIL_IF_CLOSED(retval) \
if ((_flags & NSConcreteFileHandleClosed) != 0) \
{ \
    FAIL(); \
    return retval; \
}

- (id)initWithPath:(NSString *)path flags:(NSInteger)flags createMode:(NSInteger)createMode
{
    return [self initWithPath:path flags:flags createMode:createMode error:NULL];
}

- (id)initWithPath:(NSString *)path flags:(NSInteger)flags createMode:(NSInteger)createMode error:(NSError **)error
{
    if ([path length] == 0)
    {
        [super dealloc];
        return nil;
    }

    return [self initWithURL:[NSURL fileURLWithPath:path] flags:flags createMode:createMode error:error];
}

- (id)initWithURL:(NSURL *)url flags:(NSInteger)flags createMode:(NSInteger)createMode error:(NSError **)error
{
    char fsRep[PATH_MAX + 2];
    _fd = -1;

    if (![url getFileSystemRepresentation:fsRep maxLength:PATH_MAX + 2]) {
        [self release];
        return nil;
    }

    _fd = _NSOpenFileDescriptor(fsRep, flags, createMode);
    if (_fd < 0)
    {
        if (error)
        {
            *error = _NSErrorWithFilePath(errno, [url path]);
        }
        [self release];
        return nil;
    }
    _fhQueue = dispatch_queue_create("NSFileHandle", NULL);
    return self;
}

- (id)init
{
    _fd = -1;
    [super dealloc];
    return nil;
}

- (id)initWithFileDescriptor:(int)fd
{
    return [self initWithFileDescriptor:fd closeOnDealloc:NO];
}

- (id)initWithFileDescriptor:(int)fd closeOnDealloc:(BOOL)cloDealloc
{
    _fd = fd;
    _fhQueue = dispatch_queue_create("NSFileHandle", NULL);
    if (cloDealloc) {
        _flags |= NSConcreteFileHandleOwnsFileDescriptor;
    }

    return self;
}

- (void)writeData:(NSData *)data
{
    if ([data length] == 0)
    {
        return;
    }

    FAIL_IF_CLOSED();

    [data enumerateByteRangesUsingBlock: ^ (const void *bytes, NSRange byteRange, BOOL *stop) {
        if (byteRange.length == 0)
        {
            return;
        }

        NSUInteger n = 0;
        while (n < byteRange.length)
        {
            ssize_t r = _NSWriteToFileDescriptor(_fd, (uint8_t *)bytes + n, byteRange.length - n);
            if (r < 0)
            {
                FAIL();
            }
            n += r;
        }
    }];
}

- (NSData *)readDataToEndOfFile
{
    return [self readDataOfLength:(NSUInteger)-1];
}

- (NSData *)readDataOfLength:(NSUInteger)length
{
    FAIL_IF_CLOSED(nil);

    struct stat sbuf;
    int ret = fstat(_fd, &sbuf);
    if (ret != 0)
    {
        FAIL();
        return nil;
    }

    if (S_ISREG(sbuf.st_mode))
    {
        off_t offset = lseek(_fd, 0, SEEK_CUR);
        if (offset < 0)
        {
            FAIL();
            return nil;
        }
        if (sbuf.st_size <= offset)
        {
            return [NSData data];
        }
        size_t dataSize = MIN(sbuf.st_size - offset, length);
        if (dataSize == 0)
        {
            return [NSData data];
        }
        char *buf = malloc(dataSize);
        if (buf == NULL)
        {
            FAIL();
            return nil;
        }
        size_t remainingSize = dataSize;
        size_t totalReadSize = 0;
        do {
            ssize_t readSize = _NSReadFromFileDescriptor(_fd, buf + totalReadSize, remainingSize);
            if (readSize < 0)
            {
                free(buf);
                FAIL();
                return nil;
            }
            totalReadSize += readSize;
            remainingSize -= readSize;
        } while (remainingSize > 0);
        return [NSData dataWithBytesNoCopy:buf length:dataSize];
    }
    else
    {
        const size_t READ_SIZE = 4096;
        size_t totalReadSize = 0;
        size_t bufSize = READ_SIZE;
        char *buf = malloc(bufSize);
        if (buf == NULL)
        {
            FAIL();
            return nil;
        }
        ssize_t readSize;
        do {
            size_t maxReadSize = MIN(READ_SIZE, bufSize - totalReadSize);
            readSize = _NSReadFromFileDescriptor(_fd, buf + totalReadSize, maxReadSize);
            if (readSize < 0)
            {
                free(buf);
                FAIL();
                return nil;
            }
            totalReadSize += readSize;
            if (totalReadSize + READ_SIZE > bufSize)
            {
                char *oldBuf = buf;
                bufSize *= 2;
                buf = realloc(buf, bufSize);
                if (buf == NULL)
                {
                    free(oldBuf);
                    FAIL();
                    return nil;
                }
            }
        } while (readSize > 0);
        return [NSData dataWithBytesNoCopy:buf length:totalReadSize];
    }
}

- (unsigned long long)offsetInFile
{
    FAIL_IF_CLOSED(0ULL);

    off_t offset = lseek(_fd, 0, SEEK_CUR);
    if (offset < 0)
    {
        FAIL();
        return -1;
    }
    return offset;
}

- (unsigned long long)seekToEndOfFile
{
    FAIL_IF_CLOSED(0ULL);

    off_t offset = lseek(_fd, 0ULL, SEEK_END);
    if (offset == -1)
    {
        FAIL();
        return 0ULL;
    }
    return offset;
}

- (void)seekToFileOffset:(unsigned long long)offset
{
    FAIL_IF_CLOSED();

    if (lseek(_fd, offset, SEEK_SET) == -1)
    {
        FAIL();
    }
}

- (void)truncateFileAtOffset:(unsigned long long)offset
{
    FAIL_IF_CLOSED();

    if (lseek(_fd, offset, SEEK_CUR) < 0)
    {
        FAIL();
    }
    if (ftruncate(_fd, offset) < 0)
    {
        FAIL();
    }
}

- (void)synchronizeFile
{
    FAIL_IF_CLOSED();

    if (fsync(_fd) < 0)
    {
        FAIL();
    }
}

- (void)closeFile
{
    if ((_flags & NSConcreteFileHandleClosed) != 0)
    {
        return;
    }

    _flags |= NSConcreteFileHandleClosed;
    [self _cancelDispatchSources];
    _NSCloseFileDescriptor(_fd);
}

- (void (^)(NSFileHandle *))readabilityHandler
{
    __block void (^handler)(NSFileHandle *);
    dispatch_sync(_fhQueue, ^{
        handler = [_readabilityHandler retain];
    });
    return [handler autorelease];
}

- (void)setReadabilityHandler:(void (^)(NSFileHandle *))handler
{
    void (^copy)(NSFileHandle *) = [handler copy];
    dispatch_sync(_fhQueue, ^{
        [self _locked_clearHandler:&_readabilityHandler forSource:&_readMonitoringSource];
        _readabilityHandler = copy;
        if (_readabilityHandler != nil)
        {
            _readMonitoringSource = [self _monitor:NO];
        }
    });
}

- (void (^)(NSFileHandle *))writeabilityHandler
{
    __block void (^handler)(NSFileHandle *);
    dispatch_sync(_fhQueue, ^{
        handler = [_writeabilityHandler retain];
    });
    return [handler autorelease];
}

- (void)setWriteabilityHandler:(void (^)(NSFileHandle *))handler
{
    void (^copy)(NSFileHandle *) = [handler copy];
    dispatch_sync(_fhQueue, ^{
        [self _locked_clearHandler:&_writeabilityHandler forSource:&_writeMonitoringSource];
        _writeabilityHandler = copy;
        if (_writeabilityHandler != nil)
        {
            _writeMonitoringSource = [self _monitor:YES];
        }
    });
}

static void NSConcreteFileHandlePerform(void *info)
{
    static NSString * const NSFileHandleError = @"NSFileHandleError";

    NSConcreteFileHandle *fh = info;

    NSDictionary *userInfo = nil;
    NSString *notification = nil;

    @autoreleasepool
    {
        switch (fh->_activity)
        {
            case NSFileHandleNoActivity:
                break;

            case NSFileHandleAcceptConnectionActivity:
            {
                notification = NSFileHandleConnectionAcceptedNotification;

                if (fh->_resultSocket < 0)
                {
                    userInfo = @{ NSFileHandleError : @(fh->_error) };
                }
                else
                {
                    NSFileHandle *fhCopy = [[NSFileHandle alloc] initWithFileDescriptor:fh->_resultSocket closeOnDealloc:YES];
                    userInfo = @{ NSFileHandleNotificationFileHandleItem : fhCopy };
                    [fhCopy release];
                }

                break;
            }

            case NSFileHandleReadActivity:
            case NSFileHandleReadToEndOfFileActivity:
            {
                if (fh->_activity == NSFileHandleReadActivity)
                {
                    notification = NSFileHandleReadCompletionNotification;
                }
                else
                {
                    notification = NSFileHandleReadToEndOfFileCompletionNotification;
                }

                if (fh->_error != 0)
                {
                    userInfo = @{
                        NSFileHandleError : @(fh->_error),
                        NSFileHandleNotificationDataItem : [NSData data]
                    };
                }
                else
                {
                    NSData *data = (NSData *)fh->_resultData;
                    if (fh->_resultData == nil)
                    {
                        data = [NSData data];
                    }

                    userInfo = @{ NSFileHandleNotificationDataItem : data };

                    if (fh->_resultData != nil)
                    {
                        dispatch_release(fh->_resultData);
                    }

                    fh->_resultData = nil;
                }

                break;
            }

            case NSFileHandleWaitForDataActivity:
            {
                notification = NSFileHandleDataAvailableNotification;

                if (fh->_error != 0)
                {
                    userInfo = @{ NSFileHandleError : @(fh->_error) };
                }
                else
                {
                    userInfo = @{};
                }

                break;
            }
        }

        CFRunLoopSourceInvalidate(fh->_source);
        CFRelease(fh->_source);
        fh->_source = nil;

        fh->_activity = NSFileHandleNoActivity;

        [userInfo retain];
    }

    if (notification != nil)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:notification object:fh userInfo:userInfo];
    }

    [userInfo release];
    [fh release];
}

- (void)performActivity:(NSFileHandleActivity)activityType modes:(NSArray *)modes
{
    if (_activity != NSFileHandleNoActivity && _activity != activityType)
    {
        [NSException raise:NSInvalidArgumentException format:@"Activity already in progress on file handle %@", self];
        return;
    }

    if (modes == nil)
    {
        modes = [[NSArray alloc] initWithObjects:(id)kCFRunLoopDefaultMode, nil];
    }
    else
    {
        [modes retain];
    }

    if (_activity == NSFileHandleNoActivity)
    {
        _activity = activityType;

        CFRunLoopRef currentRunLoop = CFRunLoopGetCurrent();
        CFRetain(currentRunLoop);

        CFRunLoopSourceContext sourceContext = {
            .info = [self retain],
            .perform = NSConcreteFileHandlePerform,
        };
        CFRunLoopSourceRef runLoopSource = CFRunLoopSourceCreate(kCFAllocatorDefault, 0, &sourceContext);
        _source = runLoopSource;

        int originalFd = [self fileDescriptor];
        int dupFd = dup(originalFd);
        if (dupFd < 0)
        {
            FAIL();
        }

        _error = 0;

        switch (activityType)
        {
            case NSFileHandleNoActivity:
                break;

            case NSFileHandleAcceptConnectionActivity:
            case NSFileHandleWaitForDataActivity:
            {
                dispatch_source_t acceptSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_READ, dupFd, 0, _fhQueue);
                _dsrc = acceptSource;
                dispatch_source_set_cancel_handler(_dsrc, ^{
                    CFRelease(currentRunLoop);
                    close(dupFd);
                    dispatch_release(acceptSource);
                });
                dispatch_source_set_event_handler(_dsrc, ^{
                    _dsrc = nil;
                    dispatch_source_cancel(acceptSource);
                    if (_activity == NSFileHandleAcceptConnectionActivity)
                    {
                        _resultSocket = accept(originalFd, NULL, NULL);
                        if (_resultSocket < 0)
                        {
                            _error = errno;
                        }
                    }

                    CFRunLoopSourceSignal(runLoopSource);
                    CFRunLoopWakeUp(currentRunLoop);
                });
                dispatch_resume(_dsrc);
                break;
            }

            case NSFileHandleReadActivity:
            {
                const size_t readSize = 4096;
                dispatch_read(dupFd, readSize, _fhQueue, ^(dispatch_data_t data, int error) {
                    if (error != 0)
                    {
                        _error = error;
                    }

                    dispatch_retain(data);
                    _resultData = data;

                    CFRunLoopSourceSignal(runLoopSource);
                    CFRunLoopWakeUp(currentRunLoop);

                    close(dupFd);
                    CFRelease(currentRunLoop);
                });
                break;
            }

            case NSFileHandleReadToEndOfFileActivity:
            {
                dispatch_io_t channel = dispatch_io_create(DISPATCH_IO_STREAM, dupFd, _fhQueue, ^(int error) {
                    close(dupFd);
                });
                dispatch_io_set_low_water(channel, SIZE_MAX);
                dispatch_io_read(channel, 0, SIZE_MAX, _fhQueue, ^(bool done, dispatch_data_t data, int error) {
                    if (error != 0)
                    {
                        _error = error;
                    }

                    if (data != NULL && data != dispatch_data_empty)
                    {
                        if (_resultData == NULL)
                        {
                            _resultData = dispatch_data_empty;
                        }

                        dispatch_data_t newData = dispatch_data_create_concat(_resultData, data);
                        dispatch_release(_resultData);
                        _resultData = newData;

                        if (done)
                        {
                            dispatch_release(channel);

                            CFRunLoopSourceSignal(runLoopSource);
                            CFRunLoopWakeUp(currentRunLoop);

                            CFRelease(currentRunLoop);
                        }
                    }
                });
                break;
            }
        }
    }

    for (NSString *mode in modes)
    {
        CFRunLoopAddSource(CFRunLoopGetCurrent(), _source, (CFStringRef)mode);
    }

    [modes release];
}

- (void)readInBackgroundAndNotifyForModes:(NSArray *)modes
{
    [self performActivity:NSFileHandleReadActivity modes:modes];
}

- (void)readInBackgroundAndNotify
{
    [self readInBackgroundAndNotifyForModes:nil];
}

- (void)readToEndOfFileInBackgroundAndNotifyForModes:(NSArray *)modes
{
    [self performActivity:NSFileHandleReadToEndOfFileActivity modes:modes];
}

- (void)readToEndOfFileInBackgroundAndNotify
{
    [self readToEndOfFileInBackgroundAndNotifyForModes:nil];
}

- (void)acceptConnectionInBackgroundAndNotifyForModes:(NSArray *)modes
{
    [self performActivity:NSFileHandleAcceptConnectionActivity modes:modes];
}

- (void)acceptConnectionInBackgroundAndNotify
{
    [self acceptConnectionInBackgroundAndNotifyForModes:nil];
}

- (void)waitForDataInBackgroundAndNotifyForModes:(NSArray *)modes
{
    [self performActivity:NSFileHandleWaitForDataActivity modes:modes];
}

- (void)waitForDataInBackgroundAndNotify
{
    [self waitForDataInBackgroundAndNotifyForModes:nil];
}

- (void)_locked_clearHandler:(void (^*)(NSFileHandle *))handlerPtr forSource:(dispatch_source_t *)sourcePtr
{
    dispatch_source_t source = *sourcePtr;
    *sourcePtr = nil;
    if (source != nil)
    {
        dispatch_source_cancel(source);
    }

    void (^handler)(NSFileHandle *) = *handlerPtr;
    *handlerPtr = nil;
    [handler release];
}

- (dispatch_source_t)_monitor:(BOOL)write
{
    void (^handler)(NSFileHandle *) = write ? _writeabilityHandler : _readabilityHandler;

    int dupFd = dup(_fd);
    if (dupFd == -1)
    {
        FAIL();
        return NULL;
    }

    if (_monitoringQueue == nil)
    {
        _monitoringQueue = dispatch_queue_create("file handle monitor", NULL);
    }

    dispatch_source_type_t type = write ? DISPATCH_SOURCE_TYPE_WRITE : DISPATCH_SOURCE_TYPE_READ;
    dispatch_source_t source = dispatch_source_create(type, dupFd, 0, _monitoringQueue);

    NSConcreteFileHandleARCWeakRef *weakSelf = [[NSConcreteFileHandleARCWeakRef alloc] init];
    [weakSelf storeWeak:self];

    dispatch_source_set_event_handler(source, ^{
        if (dispatch_source_get_data(source) != 0)
        {
            @autoreleasepool {
                NSConcreteFileHandle *myself = [weakSelf loadWeak];
                if (myself != nil)
                {
                    handler(myself);
                }
            }
        }
    });

    [weakSelf release];

    dispatch_source_set_cancel_handler(source, ^{
        close(dupFd);
        dispatch_release(_monitoringQueue);
    });

    dispatch_resume(source);

    return source;
}

- (id)copyWithZone:(NSZone *)zone
{
    return [self retain];
}

- (void)dealloc
{
    [self _cancelDispatchSources];

    if (_source != NULL)
    {
        CFRunLoopSourceInvalidate(_source);
        CFRelease(_source);
    }

    if (_fd >= 0 && ((_flags & NSConcreteFileHandleOwnsFileDescriptor) != 0) && ((_flags & NSConcreteFileHandleClosed) == 0))
    {
        _NSCloseFileDescriptor(_fd);
    }

    if (_fhQueue != nil)
    {
        dispatch_release(_fhQueue);
    }

    if (_monitoringQueue != nil)
    {
        dispatch_release(_monitoringQueue);
    }

    [super dealloc];
}

- (void)setPort:(id)port
{
}

- (id)port
{
    return nil;
}

- (void)_cancelDispatchSources
{
    void (^block)(void) = ^{
        if (_dsrc != nil)
        {
            dispatch_source_cancel(_dsrc);
        }
        [self _locked_clearHandler:&_readabilityHandler forSource:&_readMonitoringSource];
        [self _locked_clearHandler:&_writeabilityHandler forSource:&_writeMonitoringSource];
    };

    if (_fhQueue != nil)
    {
        dispatch_sync(_fhQueue, block);
    }
    else
    {
        block();
    }
}

- (NSUInteger)readDataOfLength:(NSUInteger)length buffer:(char *)buffer
{
    FAIL_IF_CLOSED(0ULL);

    struct stat sbuf;
    int ret = fstat(_fd, &sbuf);
    if (ret < 0)
    {
        FAIL();
        return 0ULL;
    }

    if (S_ISREG(sbuf.st_mode))
    {
        off_t offset = lseek(_fd, 0, SEEK_CUR);
        if (offset < 0)
        {
            FAIL();
            return 0ULL;
        }
        if (sbuf.st_size <= offset)
        {
            return 0ULL;
        }
        size_t readSize = MIN(sbuf.st_size - offset, length);
        ssize_t amountRead = _NSReadFromFileDescriptor(_fd, buffer, readSize);
        if (amountRead < 0)
        {
            FAIL();
            return -1;
        }
        return ret;
    }
    else
    {
        if (length == 0)
        {
            return 0ULL;
        }
        NSUInteger totalReadSize = 0;
        do {
            size_t readSize = MIN(length, PAGE_SIZE);
            ssize_t amountRead = _NSReadFromFileDescriptor(_fd, buffer + totalReadSize, readSize);
            if (amountRead < 0)
            {
                FAIL();
                return -1;
            }
            if (ret == 0)
            {
                break;
            }
            length -= amountRead;
            totalReadSize += amountRead;
        } while (length > 0);
        return totalReadSize;
    }
}

- (NSData *)availableData
{
    FAIL_IF_CLOSED(nil);

    struct stat sbuf;
    int ret = fstat(_fd, &sbuf);
    if (ret < 0)
    {
        FAIL();
        return nil;
    }

    if (S_ISREG(sbuf.st_mode))
    {
        NSData *data = [self readDataToEndOfFile];
        if (data == nil)
        {
            data = [NSData data];
        }
        return data;
    }
    else
    {
        void *buf = malloc(PAGE_SIZE);
        if (buf == NULL)
        {
            return nil;
        }
        NSUInteger length = _NSReadFromFileDescriptor(_fd, buf, PAGE_SIZE);
        if (length == 0)
        {
            free(buf);
            FAIL();
            return nil;
        }
        return [NSData dataWithBytesNoCopy:buf length:length];
    }
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    if (![coder isKindOfClass:[NSXPCCoder self]])
    {
        [NSException raise:NSInvalidArgumentException format:@"File handles can only be encoded by xpc coders"];
        return;
    }

#warning TODO xpc coders
    DEBUG_BREAK();
}

- (int)fileDescriptor
{
    FAIL_IF_CLOSED(-1);

    return _fd;
}

@end

@implementation NSNullFileHandle

- (NSData *)availableData
{
    return [NSData data];
}

- (NSData *)readDataToEndOfFile
{
    return [NSData data];
}

- (NSData *)readDataOfLength:(NSUInteger)length
{
    return [NSData data];
}

- (void)writeData:(NSData *)data
{
}

- (unsigned long long)offsetInFile
{
    return 0;
}

- (unsigned long long)seekToEndOfFile
{
    return 0;
}

- (void)seekToFileOffset:(unsigned long long)offset
{
}

- (void)truncateFileAtOffset:(unsigned long long)offset
{
}

- (void)synchronizeFile
{
}

- (void)closeFile
{
}

- (int)fileDescriptor
{
    return -1;
}

- (void (^)(NSFileHandle *))readabilityHandler
{
    return nil;
}

- (void)setReadabilityHandler:(void (^)(NSFileHandle *))handler
{
}

- (void (^)(NSFileHandle *))writeabilityHandler
{
    return nil;
}

- (void)setWriteabilityHandler:(void (^)(NSFileHandle *))handler
{
}

@end

@implementation _NSStdIOFileHandle

// This may define extra methods, but not accidentally
// dealloc'ing these seems worth the divergence.
SINGLETON_RR()

@end

@implementation NSConcreteFileHandleARCWeakRef
{
    NSConcreteFileHandle *ref;
}

- (void)storeWeak:(NSConcreteFileHandle *)fh
{
    objc_storeWeak(&ref, fh);
}

- (NSConcreteFileHandle *)loadWeak
{
    return objc_loadWeak(&ref);
}

- (void)dealloc
{
    objc_storeWeak(&ref, nil);
    [super dealloc];
}

@end
