#import <Foundation/NSURLProtocol.h>
#import <Foundation/NSURLConnection.h>
#import <Foundation/NSURLCache.h>
#import <Foundation/NSLock.h>

CF_PRIVATE
@interface NSURLProtocolInternal : NSObject {
    id <NSURLProtocolClient> client;
    NSURLRequest *request;
    NSCachedURLResponse *cachedResponse;
    NSLock *mutex;
}

- (void)dealloc;
- (id)init;

@end

@interface NSURLProtocol (Internal)

+ (Class)_protocolClassForRequest:(NSURLRequest *)request;

+ (NSArray *)_registeredClasses;

@end


@interface NSURLProtocolDefaultClient : NSObject<NSURLProtocolClient>

@property (nonatomic, assign) id<NSURLConnectionDataDelegate> delegate;

@property (nonatomic, retain) NSURLConnection *connection;

@end
