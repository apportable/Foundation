//
//  NSURL.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/NSURL.h>
#import <Foundation/NSFileManager.h>
#import <Foundation/NSException.h>
#import "NSObjectInternal.h"
#import "NSURLInternal.h"
#import <Foundation/NSCoder.h>
#import <Foundation/NSData.h>
#import "ForFoundationOnly.h"
#import <CoreFoundation/CFNumber.h>
#import <CoreFoundation/CFURL.h>
#import <objc/runtime.h>

@implementation NSURL (NSURL)

OBJC_PROTOCOL_IMPL_PUSH
- (id)initFileURLWithPath:(NSString *)path isDirectory:(BOOL)isDir
{
    NSUInteger length = [path length];
    if (length != 0)
    {
        if (![path isAbsolutePath])
        {
            path = [path stringByStandardizingPath];
            length = [path length];
        }
        if ([path characterAtIndex:length - 1] == '/')
        {
            isDir = YES;
        }

        BOOL isDirectory = NO;
        BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory];
        if (exists && isDir != isDirectory) // catch the dirty lies from the user?
        {
            [self release];
            return nil;
        }
        else if (!_CFURLInitWithFileSystemPath([self _cfurl], (CFStringRef)path, kCFURLPOSIXPathStyle, isDirectory, NULL))
        {
            [self release];
            return nil;
        }
        return self;
    }
    else
    {
        [self release];
        return nil;
    }
}

- (id)initFileURLWithPath:(NSString *)path
{
    if (path == nil)
    {
        [self release];
        [NSException raise:NSInvalidArgumentException format:@"path cannot be nil"];
        return nil;
    }
    BOOL isDir = NO;
    [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir];
    
    if (!_CFURLInitWithFileSystemPath([self _cfurl], (CFStringRef)path, kCFURLPOSIXPathStyle, isDir, NULL))
    {
        [self release];
        return nil;
    }
    return self;
}
OBJC_PROTOCOL_IMPL_POP

- (id)initFileURLWithFileSystemRepresentation:(const char *)path isDirectory:(BOOL)isDir relativeToURL:(NSURL *)baseURL
{
    if ([self class] == [NSURL class])
    {
        if (!_CFURLInitWithFileSystemRepresentation((CFURLRef)self, (const UInt8 *)path, strlen(path), isDir, (CFURLRef)baseURL))
        {
            [self release];
            return nil;
        }
    }
    else
    {
        self = [super init];

        if (self)
        {
            _reserved = (void *)CFURLCreateFromFileSystemRepresentationRelativeToBase(kCFAllocatorDefault, path, strlen(path), isDir, (CFURLRef)baseURL);
        }
    }
    return self;
}

+ (id)allocWithZone:(NSZone *)zone
{
    if (self == [NSURL class])
    {
        return (NSURL *)_CFURLAlloc(kCFAllocatorDefault);
    }
    else
    {
        return [super allocWithZone:zone];
    }
}

OBJC_PROTOCOL_IMPL_PUSH
+ (id)fileURLWithFileSystemRepresentation:(const char *)path isDirectory:(BOOL)isDir relativeToURL:(NSURL *)baseURL
{
    return [[[self alloc] initFileURLWithFileSystemRepresentation:path isDirectory:isDir relativeToURL:baseURL] autorelease];
}

+ (id)fileURLWithPath:(NSString *)path isDirectory:(BOOL)isDir
{
    return [[[self alloc] initFileURLWithPath:path isDirectory:isDir] autorelease];
}

+ (id)fileURLWithPath:(NSString *)path
{
    return [[[self alloc] initFileURLWithPath:path] autorelease];
}

+ (id)URLWithString:(NSString *)str relativeToURL:(NSURL *)url
{
    if (str == nil)
    {
        return nil; 
        // See initWithString:relativeToURL:
        // This is the lack of consistency Gotham needs right now, not the consistency Gotham deserves. 
    }
    return [[[self alloc] initWithString:str relativeToURL:url] autorelease];
}

+ (id)URLWithString:(NSString *)str
{
    return [self URLWithString:str relativeToURL:nil];
}

- (BOOL)isFileURL
{
    return _CFURLIsFileURL([self _cfurl]);
}

- (NSString *)fragment
{
    return [(NSString *)CFURLCopyFragment([self _cfurl], NULL) autorelease];
}

- (NSString *)query
{
    return [(NSString *)CFURLCopyQueryString([self _cfurl], NULL) autorelease];
}

- (NSString *)parameterString
{
    return [(NSString *)CFURLCopyParameterString([self _cfurl], NULL) autorelease];
}

- (NSString *)path
{
    CFURLRef absolute = CFURLCopyAbsoluteURL([self _cfurl]);
    NSString *path = (NSString *)CFURLCopyFileSystemPath(absolute, kCFURLPOSIXPathStyle);
    CFRelease(absolute);
    return [path autorelease];
}

- (NSString *)relativePath
{
    return [(NSString *)CFURLCopyFileSystemPath([self _cfurl], kCFURLPOSIXPathStyle) autorelease];
}

- (NSString *)password
{
    return [(NSString *)CFURLCopyPassword([self _cfurl]) autorelease];
}

- (NSString *)user
{
    return [(NSString *)CFURLCopyUserName([self _cfurl]) autorelease];
}

- (NSNumber *)port
{
    SInt32 port = CFURLGetPortNumber([self _cfurl]);
    if (port != -1) // NOTE: it seems that a url as such http://www.apportable.com:-2 is a valid port according to tests
    {
        id num = (id)CFNumberCreate(kCFAllocatorDefault, kCFNumberIntType, &port);
        return [num autorelease];
    }
    else
    {
        return nil;
    }
}

- (NSString *)host
{
    return [(NSString *)CFURLCopyHostName([self _cfurl]) autorelease];
}
OBJC_PROTOCOL_IMPL_POP

- (id)standardizedURL
{
    NSURL *standardized = nil;
    CFURLComponentsRFC1808 comps;
    while (_CFURLCopyComponents([self _cfurl], kCFURLComponentDecompositionRFC1808, &comps))
    {
        if (comps.pathComponents == NULL)
        {
            break;
        }
        NSMutableArray *components = (NSMutableArray *)CFArrayCreateMutableCopy(kCFAllocatorDefault, 0, comps.pathComponents);
        CFRelease(comps.pathComponents);
        comps.pathComponents = (CFArrayRef)components;

        NSUInteger lastCount, currentCount;
        do {
            BOOL foundUpDir = NO;
            BOOL foundCurrentDir = NO;
            currentCount = [components count];
            NSUInteger idx = [components indexOfObject:@".."];
            if (idx != NSNotFound)
            {
                foundUpDir = YES;
                [components removeObjectAtIndex:idx];
                if (idx > 0)
                {
                    [components removeObjectAtIndex:idx - 1];
                }
            }
            idx = [components indexOfObject:@"."];
            if (idx != NSNotFound)
            {
                foundCurrentDir = YES;
                [components removeObjectAtIndex:idx];
            }
            if (!foundUpDir && !foundCurrentDir)
            {
                break;
            }
            lastCount = [components count];
        } while (lastCount != currentCount);


        standardized = (NSURL *)_CFURLCreateFromComponents(kCFAllocatorDefault, kCFURLComponentDecompositionRFC1808, &comps);
        break;
    }

    if (comps.scheme)
    {
        CFRelease(comps.scheme);
    }
    if (comps.user)
    {
        CFRelease(comps.user);
    }
    if (comps.password)
    {
        CFRelease(comps.password);
    }
    if (comps.host)
    {
        CFRelease(comps.host);
    }
    if (comps.pathComponents)
    {
        CFRelease(comps.pathComponents);
    }
    if (comps.parameterString)
    {
        CFRelease(comps.parameterString);
    }
    if (comps.query)
    {
        CFRelease(comps.query);
    }
    if (comps.fragment)
    {
        CFRelease(comps.fragment);
    }
    if (comps.baseURL)
    {
        CFRelease(comps.baseURL);
    }

    return [standardized autorelease];
}

OBJC_PROTOCOL_IMPL_PUSH
- (NSURL *)absoluteURL
{
    return [(NSURL *)CFURLCopyAbsoluteURL([self _cfurl]) autorelease];
}

- (NSString *)absoluteString
{
    CFURLRef url = CFURLCopyAbsoluteURL([self _cfurl]);
    CFStringRef str = CFRetain(CFURLGetString(url));
    CFRelease(url);
    return [(NSString *)str autorelease];
}

- (id)copyWithZone:(NSZone *)zone
{
    return [self retain];
}
OBJC_PROTOCOL_IMPL_POP

- (id)description
{
    NSURL *base = [self baseURL];

    if (base != nil)
    {
        return [NSString stringWithFormat:@"%@ -- %@", [self relativeString], base];
    }
    else
    {
        return [self absoluteString];
    }
}

OBJC_PROTOCOL_IMPL_PUSH
- (id)initWithCoder:(NSCoder *)coder
{
    NSURL *base = nil;
    NSString *relative = nil;
    if ([coder allowsKeyedCoding])
    {
        base = [coder decodeObjectForKey:@"NS.base"];
        relative = [coder decodeObjectForKey:@"NS.relative"];
    }
    else
    {
        BOOL hasBase = NO;
        [coder decodeValueOfObjCType:@encode(BOOL) at:&hasBase];
        if (hasBase)
        {
            base = [coder decodeObject];
        }
        relative = [coder decodeObject];
    }
    return [self initWithString:relative relativeToURL:base];
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    if ([coder allowsKeyedCoding])
    {
        [coder encodeObject:[self baseURL] forKey:@"NS.base"];
        [coder encodeObject:[self relativeString] forKey:@"NS.relative"];
    }
    else
    {
        NSURL *baseURL = [self baseURL];
        BOOL hasBase = baseURL != nil;
        [coder encodeValueOfObjCType:@encode(BOOL) at:&hasBase];
        if (hasBase)
        {
             [coder encodeObject:baseURL];   
        }
        else
        {
            [coder encodeObject:[self relativeString]];
        }
    }
}
OBJC_PROTOCOL_IMPL_POP

- (NSUInteger)hash
{
    return CFHash([self _cfurl]);
}

- (BOOL)isEqual:(id)other
{
    if (other == nil)
    {
        return NO;
    }
    id compare = other;
    if ([other isKindOfClass:[NSURL class]])
    {
        compare = (id)[other _cfurl];
    }
    return CFEqual([self _cfurl], compare);
}

OBJC_PROTOCOL_IMPL_PUSH
- (id)initWithScheme:(NSString *)scheme host:(NSString *)host path:(NSString *)path
{
    if (![path isAbsolutePath])
    {
        [NSException raise:NSInvalidArgumentException format:@"path must be absolute %@", path];
    }
    NSString *escapedHost = [host stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *standardizedPath = [path stringByStandardizingPath];
    if (scheme == nil)
    {
        scheme = @"http";
    }

    return [self initWithString:[NSString stringWithFormat:@"%@://%@%@", scheme, escapedHost, standardizedPath]];
}

- (id)initWithString:(NSString *)string
{
    return [self initWithString:string relativeToURL:nil];
}
OBJC_PROTOCOL_IMPL_POP

- (id)init
{
    [self release]; // this is a silent failure on iOS
    return nil;
}

- (id)resourceSpecifier
{
    if (![self _isAbsolute])
    {
        return [self relativeString];
    }
    else
    {
        CFURLRef url = [self _cfurl];

        if (url == NULL)
        {
            return nil; // how can this happen in the wild?
        }
        
        if (!CFURLCanBeDecomposed(url))
        {
            return [(NSString *)CFURLCopyResourceSpecifier(url) autorelease];
        }
        else
        {
            if (CFURLGetBaseURL(url) == NULL)
            {
                NSString *loc = [(NSString *)CFURLCopyNetLocation(url) autorelease];
                NSString *path = [(NSString *)CFURLCopyPath(url) autorelease];
                NSString *res = [(NSString *)CFURLCopyResourceSpecifier(url) autorelease];
                if (loc == nil)
                {
                    // lots of stuff here!
                    if (path == nil)
                    {
                        return nil;
                    }
                    
                    if (res == nil)
                    {
                        return path;
                    }
                    
                    return [NSString stringWithFormat:@"%@%@", path, res];
                }
                else if (path == nil)
                {
                    return [NSString stringWithFormat:@"//%@", loc];
                }
                else if (res != nil)
                {
                    return [NSString stringWithFormat:@"//%@%@%@", loc, path, res];
                }
                else
                {
                    return [NSString stringWithFormat:@"//%@%@", loc, path];
                }
            }
            else
            {
                return (NSString *)CFURLGetString(url);
            }
        }
    }
}

- (BOOL)_isAbsolute
{
    if ([self baseURL] == nil)
    {
        return [self scheme] != nil;
    }
    return YES;
}

- (id)_relativeURLPath
{
    return [(NSString *)CFURLCopyPath([self _cfurl]) autorelease];
}

- (id)scheme
{
    return [(NSString *)CFURLCopyScheme([self _cfurl]) autorelease];
}

- (id)baseURL
{
    return (NSURL *)CFURLGetBaseURL([self _cfurl]);
}

- (id)relativeString
{
    return (NSString *)CFURLGetString([self _cfurl]);
}

- (void)dealloc
{
    [self _freeClients];
    if (object_getClass(self) != [NSURL class])
    {
        [(id)_reserved release];
    }
    [super dealloc];
}

- (void)_freeClients
{
    CFURLRef url = [self _cfurl];
    CFDictionaryRef reserved = __CFURLReservedPtr(url);
    if (reserved != NULL)
    {
        CFRelease(reserved);
        __CFURLSetReservedPtr(url, NULL);
    }
}

- (CFDictionaryRef)_clientsCreatingIfNecessary:(BOOL)create
{
    CFURLRef url = [self _cfurl];
    CFDictionaryRef reserved = __CFURLReservedPtr(url);
    if (reserved == NULL && create)
    {
        reserved = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, NULL, NULL);
        __CFURLSetReservedPtr(url, (void *)reserved);
    }
    return reserved;
}

- (CFURLRef)_cfurl
{
    if (object_getClass(self) == [NSURL class])
    {
        return (CFURLRef)self;
    }
    else
    {
        return _reserved;
    }
}

OBJC_PROTOCOL_IMPL_PUSH
- (id)initWithString:(NSString *)string relativeToURL:(NSURL *)url
{
    if ([self class] == [NSURL class])
    {
        if (!_CFURLInitWithURLString([self _cfurl], (CFStringRef)string, true, [url _cfurl]))
        {
            [self release];
            return nil;
        }
    }
    else
    {
        self = [super init];

        if (self)
        {
            _reserved = (void *)CFURLCreateWithString(kCFAllocatorDefault, (CFStringRef)string, (CFURLRef)url);
        }
    }
    return self;
}
OBJC_PROTOCOL_IMPL_POP

// What is this for?
#if 0
- (id)_initWithMinimalBookmarkData:(id)minimalBookmarkData
{

}
#endif

- (CFTypeID)_cfTypeID
{
    return CFURLGetTypeID();
}

- (BOOL)_isDeallocating
{
    return _CFIsDeallocating([self _cfurl]);
}

- (BOOL)_tryRetain
{
    return _CFTryRetain([self _cfurl]) != NULL;
}

- (NSUInteger)retainCount
{
    return CFGetRetainCount([self _cfurl]);
}

- (oneway void)release
{
    CFRelease([self _cfurl]);
}

- (id)retain
{
    CFRetain([self _cfurl]);
    return self;
}

- (NSURL *)URLByAppendingPathComponent:(NSString *)pathComponent
{
    return [self URLByAppendingPathComponent:pathComponent isDirectory:NO];
}

- (NSURL *)URLByAppendingPathComponent:(NSString *)pathComponent isDirectory:(BOOL)isDirectory
{
    return [(NSURL *)CFURLCreateCopyAppendingPathComponent(CFGetAllocator(self), (CFURLRef)self, (CFStringRef) pathComponent, isDirectory) autorelease];
}

@end

@implementation NSURL (NSURLPathUtilities)

+ (NSURL *)fileURLWithPathComponents:(NSArray *)components
{
    return [NSURL fileURLWithPath:[components componentsJoinedByString:@"/"]];
}

- (NSArray *)pathComponents
{
    return [[self path] pathComponents];
}

- (NSString *)lastPathComponent
{
    return [[self path] lastPathComponent];
}

- (NSString *)pathExtension
{
    return [[self path] pathExtension];
}

- (NSURL *)URLByAppendingPathComponent:(NSString *)pathComponent
{
    if (pathComponent == nil)
    {
        [NSException raise:NSInvalidArgumentException format:@"cannot append nil path component"];
        return nil;
    }

    BOOL isDirectory = NO;
    if (![pathComponent hasSuffix:@"/"])
    {
        if ([self isFileURL])
        {
            NSNumber *val = nil;
            if ([self getResourceValue:&val forKey:NSURLIsDirectoryKey error:NULL])
            {
                if (![val boolValue])
                {
                    return nil;
                }
            }
        }
    }

    return [self URLByAppendingPathComponent:pathComponent isDirectory:isDirectory];
}

- (NSURL *)URLByAppendingPathComponent:(NSString *)pathComponent isDirectory:(BOOL)isDirectory
{
    if (pathComponent == nil)
    {
        [NSException raise:NSInvalidArgumentException format:@"cannot append nil path component"];
        return nil;
    }

    return [(NSURL *)CFURLCreateCopyAppendingPathComponent(kCFAllocatorDefault, (CFURLRef)self, (CFStringRef)pathComponent, isDirectory) autorelease];
}

- (NSURL *)URLByDeletingLastPathComponent
{
    return [(NSURL *)CFURLCreateCopyDeletingLastPathComponent(kCFAllocatorDefault, (CFURLRef)self) autorelease];
}

- (NSURL *)URLByAppendingPathExtension:(NSString *)pathExtension
{
    return [(NSURL *)CFURLCreateCopyAppendingPathExtension(kCFAllocatorDefault, (CFURLRef)self, (CFStringRef)pathExtension) autorelease];
}

- (NSURL *)URLByDeletingPathExtension
{
    return [(NSURL *)CFURLCreateCopyDeletingPathExtension(kCFAllocatorDefault, (CFURLRef)self) autorelease];
}

- (NSURL *)URLByStandardizingPath
{
    if ([self isFileURL])
    {
        if ([self isFileReferenceURL])
        {
            return [self filePathURL];
        }
        else
        {
            return [NSURL fileURLWithPath:[[self path] stringByStandardizingPath]];
        }
    }
    return self;
}

- (NSURL *)URLByResolvingSymlinksInPath
{
    if ([self isFileURL])
    {
        if ([self isFileReferenceURL])
        {
            return [self filePathURL];
        }
        else
        {
            return [NSURL fileURLWithPath:[[self path] stringByResolvingSymlinksInPath]];
        }
    }
    return self;
}

OBJC_PROTOCOL_IMPL_PUSH
- (BOOL)getFileSystemRepresentation:(char *)buffer maxLength:(NSUInteger)maxBufferLength
{
    return CFURLGetFileSystemRepresentation([self _cfurl], true, buffer, maxBufferLength);
}

- (const char *)fileSystemRepresentation NS_RETURNS_INNER_POINTER
{
    CFURLRef url = [self _cfurl];
    if (url == NULL)
    {
        [NSException raise:NSInvalidArgumentException format:@"the url %p was not initialized", self];
        return NULL;
    }
    size_t sz = 1024;
    
    UInt8 *buffer = malloc(sz);
    if (buffer == NULL)
    {
        [NSException raise:NSMallocException format:@"Could not allocate 1024 bytes for file url"];
        return NULL;
    }

    if (CFURLGetFileSystemRepresentation(url, true, buffer, sz))
    {
        return (const char *)[[NSData dataWithBytesNoCopy:buffer length:sz] bytes];
    }

    CFStringRef path = CFURLCopyFileSystemPath(url, kCFURLPOSIXPathStyle);
    sz = CFStringGetMaximumSizeOfFileSystemRepresentation(path);
    CFRelease(path);
    if (sz > 1024)
    {
        UInt8 *new_buffer = (UInt8 *)realloc(buffer, sz);
        if (new_buffer == NULL)
        {
            free(buffer);
            [NSException raise:NSMallocException format:@"Could not allocate %zu bytes for file url", sz];
            return NULL;
        }
        buffer = new_buffer;
    }

    if (!CFURLGetFileSystemRepresentation(url, true, buffer, sz))
    {
        free(buffer);
        [NSException raise:NSInvalidArgumentException format:@"Unable to convert url %@ to file system representation", self];
        return NULL;
    }
    
    return (const char *)[[NSData dataWithBytesNoCopy:buffer length:sz] bytes];
}
OBJC_PROTOCOL_IMPL_POP

@end
