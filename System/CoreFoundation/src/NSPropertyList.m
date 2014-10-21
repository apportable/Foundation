//
//  NSPropertyList.m
//  CoreFoundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/NSPropertyList.h>
#import <Foundation/NSData.h>
#import <Foundation/NSString.h>

@implementation NSPropertyListSerialization

+ (BOOL)propertyList:(id)plist isValidForFormat:(NSPropertyListFormat)format
{
    return CFPropertyListIsValid((CFPropertyListRef)plist, (CFPropertyListFormat)format);
}

+ (NSData *)dataWithPropertyList:(id)plist format:(NSPropertyListFormat)format options:(NSPropertyListWriteOptions)opt error:(out NSError **)error
{
    return [(NSData *)CFPropertyListCreateData(kCFAllocatorDefault, (CFPropertyListRef)plist, (CFPropertyListFormat)format, opt, (CFErrorRef *)error) autorelease];
}

+ (NSInteger)writePropertyList:(id)plist toStream:(NSOutputStream *)stream format:(NSPropertyListFormat)format options:(NSPropertyListWriteOptions)opt error:(out NSError **)error
{
    return CFPropertyListWrite((CFPropertyListRef)plist, (CFWriteStreamRef)stream, (CFPropertyListFormat)format, opt, (CFErrorRef *)error);
}

+ (id)propertyListWithData:(NSData *)data options:(NSPropertyListReadOptions)opt format:(NSPropertyListFormat *)format error:(out NSError **)error
{
    return [(id)CFPropertyListCreateWithData(kCFAllocatorDefault, (CFDataRef)data, opt, (CFPropertyListFormat *)format, (CFErrorRef *)error) autorelease];
}

+ (id)propertyListWithStream:(NSInputStream *)stream options:(NSPropertyListReadOptions)opt format:(NSPropertyListFormat *)format error:(out NSError **)error
{
    return [(id)CFPropertyListCreateWithStream(kCFAllocatorDefault, (CFReadStreamRef)stream, 0, opt, (CFPropertyListFormat *)format, (CFErrorRef *)error) autorelease];
}

+ (NSData *)dataFromPropertyList:(id)plist format:(NSPropertyListFormat)format errorDescription:(out __strong NSString **)errorString
{
    CFWriteStreamRef stream = CFWriteStreamCreateWithAllocatedBuffers(kCFAllocatorDefault, kCFAllocatorDefault);
    
    if (!CFWriteStreamOpen(stream))
    {
        return nil;
    }

    CFPropertyListWriteToStream((CFPropertyListRef)plist, stream, (CFPropertyListFormat)format, (CFStringRef *)errorString);
    NSData *data = (NSData *)CFWriteStreamCopyProperty(stream, kCFStreamPropertyDataWritten);
    CFWriteStreamClose(stream);
    CFRelease(stream);

    return [data autorelease];
}

+ (id)propertyListFromData:(NSData *)data mutabilityOption:(NSPropertyListMutabilityOptions)opt format:(NSPropertyListFormat *)format errorDescription:(out __strong NSString **)errorString
{
    CFErrorRef error = NULL;
    // technically we could detect the plist format if it is that format, and then release the plist, and claim it was an error... but meh.
    id plist = (id)CFPropertyListCreateWithData(kCFAllocatorDefault, (CFDataRef)data, opt, (CFPropertyListFormat *)format, &error);
    
    if (plist == nil && errorString != NULL)
    {
        if (error == nil)
        {
            *errorString = @"Internal error, could not procure error to display";
        }
        else
        {
            *errorString = [(NSString *)CFErrorCopyDescription(error) autorelease];
        }
    }
    
    return [plist autorelease];
}

@end
