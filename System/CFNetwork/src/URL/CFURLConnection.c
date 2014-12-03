//
//  CFURLConnection.c
//  CFNetwork
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#include "CFURLConnection.h"
#include <CFNetwork/CFHTTPMessage.h>
#include <CFNetwork/CFHTTPStream.h>
#include <CFNetwork/CFProxySupport.h>
#include <CFNetwork/CFCachedURLResponse.h>
#include <CFNetwork/CFURLCache.h>
#include "CFURLResponse.h"
#include <CFNetwork/CFNetworkErrors.h>
#include <stdlib.h>
#include <libkern/OSAtomic.h>
#include <CoreFoundation/CFBase.h>
#include <CoreFoundation/CFNumber.h>
#include <CFNetwork/CFHTTPAuthentication.h>
#include "CFRuntime.h"
#include <zlib.h>
#include <pthread.h>
#include "CFHTTPCookieStorage.h"
#include "CFRuntimeUtils.h"

#ifndef NDEBUG
#define CACHE_LOG_ENABLED
#define CACHE_LOG(format, arguments...) debugLog("CACHE-DBG", format, ##arguments)
#else
#define CACHE_LOG(format, arguments...)
#endif

// https://devforums.apple.com/message/108292#108292
#define CFURLREQUEST_MIN_TIMEOUT 240.0

static const CFStringRef ErrorDomain = CFSTR("NSURLErrorDomain");

static const CFIndex kCFURLConnectionRedirectRetryMax = 10;

#define RUNLOOP_WAIT        0.25
#define NUM_QUEUES          16

// Timeout between readStreamEvent gets notified on certain stream.
#define SCHEDULE_EVENT_TIMEOUT 10.0

typedef struct {
    void *pool_context;
} cfurlconnection_runloop_info;

static pthread_mutex_t managerLock = PTHREAD_MUTEX_INITIALIZER;
static CFRunLoopSourceRef managerSource = NULL;
static pthread_cond_t managerCondition = PTHREAD_COND_INITIALIZER;
static OSSpinLock queue_lock = OS_SPINLOCK_INIT;
static CFURLConnectionRef activeConnections[NUM_QUEUES] = { NULL };
static cfurlconnection_runloop_info s_runLoopInfo;
static CFMutableArrayRef enqueuedConnections = NULL;
static CFRunLoopRef managerLoop = NULL;
static int s_managerLoopWokeUp;

static void *CFURLConnectionManager(void *ctx);
static int standardizePath(UniChar *base, int baseLength, const UniChar *redirect, int redirectLength);
static void setProxy(CFReadStreamRef stream);
static void unscheduleFromRunLoops(struct _CFURLConnection *connection);
static void broadcastConnectionState(struct _CFURLConnection *connection, Boolean invalidateConnection);

extern void *_objc_autoreleasePoolPush(void);
extern void _objc_autoreleasePoolPop(void *);

typedef enum {
    kCachingStateNotCaching,
    kCachingStateCaching,
    kCachingStateReplayingCached
} CachingState;

static void startCaching(struct _CFURLConnection *connection);
static void cacheData(struct _CFURLConnection *connection, CFDataRef data);
static void finishCaching(struct _CFURLConnection *connection);
static Boolean replayCached(struct _CFURLConnection *connection);

enum {
    kConnectionEventFinishedBit = 0x100,
    kConnectionEventInvalid     = 0,
    kConnectionEventGotResponse = 1,
    kConnectionEventGotData     = 2,
    kConnectionEventFailed      = 3 | kConnectionEventFinishedBit,
    kConnectionEventFinished    = 4 | kConnectionEventFinishedBit
};
typedef CFIndex ConnectionEventType;

typedef struct {
    CFRuntimeBase _base;
    ConnectionEventType type;
    CFTypeRef payload;
} ConnectionEvent;

static void connectionEventDeallocate(CFTypeRef cf) {
    ConnectionEvent *event = (ConnectionEvent *)cf;
    if (event->payload) {
        CFRelease(event->payload);
    }
}

static const CFRuntimeClass connectionEventClass = {
    .version = 0,
    .className = "CFURLConnectionEvent",
    .finalize = &connectionEventDeallocate
};
static CFTypeID connectionEventTypeID = _kCFRuntimeNotATypeID;

static ConnectionEvent *connectionEventAllocate(ConnectionEventType type, CFTypeRef payload) {
    _CFRuntimeRegisterClassOnce(&connectionEventTypeID, &connectionEventClass);
    CFIndex size = sizeof(ConnectionEvent) - sizeof(CFRuntimeBase);
    ConnectionEvent *event = (ConnectionEvent *)_CFRuntimeCreateInstance(
        kCFAllocatorDefault,
        connectionEventTypeID,
        size,
        NULL);
    event->type = type;
    if (payload) {
        event->payload = CFRetain(payload);
    }
    return event;
}

typedef enum {
    kContentEncodingUnknown,
    kContentEncodingNone,
    kContentEncodingGZIP,
    kContentEncodingDeflate,
} ContentEncoding;

static ContentEncoding parseContentEncoding(CFURLResponseRef response);

struct _CFURLConnection {
    CFRuntimeBase _base;
    CFURLConnectionContext context;
    CFURLConnectionHandlerContext handler;

    Boolean valid;
    Boolean streamValid;
    Boolean finished;

    CFHTTPMessageRef message;
    CFURLRequestRef request;
    CFIndex redirectCycleCount;
    CFReadStreamRef stream;
    CFReadStreamRef replacementStream;
    CFURLResponseRef response;
    CFErrorRef error;
    ContentEncoding contentEncoding;

    CachingState cachingState;
    CFMutableArrayRef cachedDataArray;

    OSSpinLock eventsLock;
    CFMutableArrayRef events;

    pthread_mutex_t modeLock;
    CFRunLoopRef runLoop;
    CFRunLoopSourceRef source;
    CFMutableArrayRef modes;

    z_stream *zStream;
    CFAbsoluteTime lastScheduleTime;
    CFAbsoluteTime createdTime;
};

static void queueConnectionEvent(struct _CFURLConnection *connection,
                                 ConnectionEventType type, CFTypeRef payload);

static void __CFURLConnectionDeallocate(CFTypeRef cf) {
    struct _CFURLConnection *connection = (struct _CFURLConnection *)cf;
    if (connection->context.info != NULL) {
        connection->context.release(connection->context.info);
        connection->context.info = NULL;
    }

    if (connection->request != NULL) {
        CFRelease(connection->request);
        connection->request = NULL;
    }

    if (connection->stream != NULL) {
        CFRelease(connection->stream);
        connection->stream = NULL;
    }

    if (connection->replacementStream != NULL) {
        CFRelease(connection->replacementStream);
        connection->replacementStream = NULL;
    }

    if (connection->handler.info != NULL) {
        connection->handler.release(connection->handler.info);
        connection->handler.info = NULL;
    }

    if (connection->response != NULL) {
        CFRelease(connection->response);
        connection->response = NULL;
    }

    if (connection->error != NULL) {
        CFRelease(connection->error);
        connection->error = NULL;
    }

    if (connection->events != NULL) {
        CFRelease(connection->events);
        connection->events = NULL;
    }

    if (connection->cachedDataArray != NULL) {
        CFRelease(connection->cachedDataArray);
        connection->cachedDataArray = NULL;
    }

    if (connection->zStream != NULL) {
        inflateEnd(connection->zStream);
        free(connection->zStream);
        connection->zStream = NULL;
    }

    if (connection->runLoop != NULL) {
        CFRelease(connection->runLoop);
        connection->runLoop = NULL;
    }

    if (connection->modes != NULL) {
        CFRelease(connection->modes);
        connection->modes = NULL;
    }
}

static CFTypeID __kCFURLConnectionTypeID = _kCFRuntimeNotATypeID;

static const CFRuntimeClass __CFURLConnectionClass = {
    _kCFRuntimeScannedObject,
    "CFURLConnection",
    NULL,
    NULL,
    __CFURLConnectionDeallocate,
    NULL,
    NULL,
    NULL,
    NULL
};

static void __CFURLConnectionInitialize(void) {
    __kCFURLConnectionTypeID = _CFRuntimeRegisterClass(&__CFURLConnectionClass);
}

CFTypeID CFURLConnectionGetTypeID(void) {
    if (__kCFURLConnectionTypeID == _kCFRuntimeNotATypeID) {
        __CFURLConnectionInitialize();
    }
    return __kCFURLConnectionTypeID;
}

const CFStringRef _kCFURLConnectionPrivateRunLoopMode = CFSTR("URLConnectionMode");

static const void *noopRetain(const void *info) {
    return info;
}

static void noopRelease(const void *info) {

}

CF_RETURNS_RETAINED static CFStringRef pointerDescription(const void *info) {
    return CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("%p"), info);
}

static Boolean pointerEqual(const void *info1, const void *info2) {
    return info1 == info2;
}

static CFHashCode pointerHash(const void *info) {
    return (CFHashCode)info;
}

static Boolean noopHandledByProtocol(const void *info)
{
    return false;
}

static Boolean noopCanAuth(const void *info, CFURLProtectionSpaceRef space)
{
    return true;
}

static void noopCancel(const void *info, CFURLAuthChallengeRef challenge)
{

}

static void noopFailure(const void *info, CFErrorRef error) {

}

static void noopReceive(const void *info, CFURLAuthChallengeRef challenge)
{

}

static void noopSend(const void *info, CFURLAuthChallengeRef challenge)
{

}
static void noopAuth(const void *info, CFURLAuthChallengeRef challenge) {

}

static Boolean noopCredentialStorage(const void *info) {
    return true;
}

static void openConnection(struct _CFURLConnection * connection) {
    if (replayCached(connection)) {
        return;
    }
    CFDictionaryRef cookiesHeaderFields = CFHTTPCookieStorageCopyRequestHeaderFieldsForURL(CFHTTPCookieStorageGetDefault(), CFURLRequestGetURL(connection->request));
    if (cookiesHeaderFields != NULL) {
        CFMutableURLRequestRef alteredRequest = CFURLRequestCreateMutableCopy(kCFAllocatorDefault, connection->request);
        CFURLRequestAddValueForHTTPField(alteredRequest, CFSTR("Cookie"), CFDictionaryGetValue(cookiesHeaderFields, CFSTR("Cookie")));
        CFRelease(connection->request);
        connection->request = alteredRequest;
        CFHTTPMessageSetHeaderFieldValue(connection->message, CFSTR("Cookie"), CFDictionaryGetValue(cookiesHeaderFields, CFSTR("Cookie")));
    };

    connection->streamValid = true;
    connection->valid = true;
    connection->lastScheduleTime = CFAbsoluteTimeGetCurrent();
    CFReadStreamScheduleWithRunLoop(connection->stream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
    CFReadStreamOpen(connection->stream);
    __CFURLRequestLog(connection->request);
}

static void broadcastConnectionState(struct _CFURLConnection *connection, Boolean invalidateConnection) {
    OSSpinLockLock(&queue_lock);
    connection->streamValid = false;
    if (invalidateConnection) {
        connection->valid = false;
    }
    OSSpinLockUnlock(&queue_lock);
    CFRunLoopSourceSignal(managerSource);
    CFRunLoopWakeUp(managerLoop);
}

static void queueConnectionEvent(struct _CFURLConnection *connection,
                                 ConnectionEventType type, CFTypeRef payload) {
    assert(!connection->finished);

    OSSpinLockLock(&connection->eventsLock);
    if (!connection->events) {
        connection->events = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
    }
    ConnectionEvent *event = connectionEventAllocate(type, payload);
    CFArrayAppendValue(connection->events, event);
    CFRelease(event);
    OSSpinLockUnlock(&connection->eventsLock);

    CFRunLoopSourceSignal(connection->source);
    CFRunLoopWakeUp(connection->runLoop);

    switch (type) {
        case kConnectionEventGotResponse: {
            assert(!connection->response);
            connection->response = (CFURLResponseRef)CFRetain(payload);
            connection->contentEncoding = parseContentEncoding(connection->response);
            startCaching(connection);
            break;
        }
        case kConnectionEventGotData: {
            cacheData(connection, (CFDataRef)payload);
            break;
        }
        case kConnectionEventFailed: {
            assert(!connection->error);
            connection->error = (CFErrorRef)CFRetain(payload);
            break;
        }
    }

    if (type & kConnectionEventFinishedBit) {
        connection->finished = true;
        broadcastConnectionState(connection, true);
    }
}

static ConnectionEvent *dequeueConnectionEvent(struct _CFURLConnection *connection) {
    ConnectionEvent *event = NULL;
    OSSpinLockLock(&connection->eventsLock);
    if (CFArrayGetCount(connection->events)) {
        event = (ConnectionEvent *)CFRetain(CFArrayGetValueAtIndex(connection->events, 0));
        CFArrayRemoveValueAtIndex(connection->events, 0);
    }
    OSSpinLockUnlock(&connection->eventsLock);
    return event;
}

static void connectionGotResponse(struct _CFURLConnection * connection, CFURLResponseRef response) {
    queueConnectionEvent(connection, kConnectionEventGotResponse, response);
}

static void connectionFinished(struct _CFURLConnection *connection) {
    queueConnectionEvent(connection, kConnectionEventFinished, NULL);
}

static void connectionFailed(struct _CFURLConnection *connection, CFErrorRef error) {
    queueConnectionEvent(connection, kConnectionEventFailed, error);
}

static void connectionGotData(struct _CFURLConnection *connection, CFDataRef data) {
    queueConnectionEvent(connection, kConnectionEventGotData, data);
}

static void connectionDecodeData(struct _CFURLConnection *connection, CFDataRef data) {
    if (connection->contentEncoding != kContentEncodingGZIP &&
        connection->contentEncoding != kContentEncodingDeflate)
    {
        CFErrorRef error = CFErrorCreate(kCFAllocatorDefault, ErrorDomain, kCFURLErrorCannotDecodeRawData, nil);
        connectionFailed(connection, error);
        CFRelease(error);
        return;
    }

    int status = Z_OK;
    CFIndex length = CFDataGetLength(data);
    CFIndex halfLength = length / 2;
    CFMutableDataRef outputData = CFDataCreateMutable(kCFAllocatorDefault, 0);
    CFDataIncreaseLength(outputData, length + halfLength);

    z_stream zStream = *connection->zStream;
    zStream.next_in = (Bytef *)CFDataGetMutableBytePtr((CFMutableDataRef)data);
    zStream.avail_in = (unsigned int)length;
    zStream.avail_out = 0;
    zStream.total_out = 0;
    while (zStream.avail_in != 0) {

        if (zStream.total_out >= CFDataGetLength(outputData)) {
            CFDataIncreaseLength(outputData, halfLength);
        }

        zStream.next_out = (Bytef *)CFDataGetMutableBytePtr(outputData) + zStream.total_out;
        zStream.avail_out = (unsigned int)(CFDataGetLength(outputData) - zStream.total_out);

        status = inflate(&zStream, Z_BLOCK);
        if (status == Z_STREAM_END) {
            break;
        } else if (status < 0) {
            break;
        }
    }

    if (status == Z_OK || status == Z_STREAM_END) {
        CFDataSetLength(outputData, zStream.total_out);
        connectionGotData(connection, outputData);
    } else {
        CFErrorRef error = CFErrorCreate(kCFAllocatorDefault, ErrorDomain, kCFURLErrorCannotDecodeRawData, nil);
        connectionFailed(connection, error);
        CFRelease(error);
    }

    CFRelease(outputData);
}

static void checkTimeoutForActiveConnections() {
    struct _CFURLConnection *connection = NULL;
    OSSpinLockLock(&queue_lock);
    for (int i = 0; i < NUM_QUEUES; i++) {
        if (activeConnections[i] != NULL) {
            if (CFAbsoluteTimeGetCurrent() - activeConnections[i]->lastScheduleTime > SCHEDULE_EVENT_TIMEOUT) {
                // The stream gets lost.
                connection = (struct _CFURLConnection *)activeConnections[i];
                break;
            }
        }
    }
    OSSpinLockUnlock(&queue_lock);
    if (connection && !connection->finished) {
        CFErrorRef timeoutError = CFErrorCreate(kCFAllocatorDefault, ErrorDomain, kCFURLErrorTimedOut, nil);
        connectionFailed(connection, timeoutError);
        CFRelease(timeoutError);
    }
}

static void readStreamEvent(CFReadStreamRef stream, CFStreamEventType type, void *clientCallBackInfo) {
    struct _CFURLConnection *connection = (struct _CFURLConnection *)clientCallBackInfo;
    connection->lastScheduleTime = CFAbsoluteTimeGetCurrent();

    if (connection->response == NULL) {
        CFHTTPMessageRef message = (CFHTTPMessageRef)CFReadStreamCopyProperty(stream, kCFStreamPropertyHTTPResponseHeader);
        if (message != NULL && CFHTTPMessageIsHeaderComplete(message)) {
            CFURLRef finalUrl = CFReadStreamCopyProperty(stream, kCFStreamPropertyHTTPFinalURL);
            CFURLResponseRef response = CFURLResponseCreateWithCFHTTPMessage(kCFAllocatorDefault, finalUrl, message);
            CFHTTPCookieStorageSetCookiesWithResponseHeaderFields(CFHTTPCookieStorageGetDefault(), CFURLResponseGetHeaderFields(response), finalUrl);

            UInt32 statusCode = CFHTTPMessageGetResponseStatusCode(message);

            if (statusCode == 301 || statusCode == 302 || statusCode == 303 || statusCode == 307) {
                CFStringRef redirect_location = (CFStringRef)CFDictionaryGetValue(CFURLResponseGetHeaderFields(response), CFSTR("Location"));

                //check to make sure there is a link to redirect to and that the link is different from the current
                if (redirect_location != NULL) {
                    //make sure the redirect URL is different from the original
                    if (CFStringCompare(redirect_location, CFURLGetString(finalUrl), kCFCompareCaseInsensitive) != kCFCompareEqualTo) {
                        connection->redirectCycleCount++;
                        if (connection->redirectCycleCount > kCFURLConnectionRedirectRetryMax) {
                            // error here
                            CFErrorRef error = CFErrorCreate(kCFAllocatorDefault, ErrorDomain, kCFURLErrorHTTPTooManyRedirects, NULL);
                            connectionFailed(connection, error);
                            CFRelease(error);
                            return;
                        }
                        else {
                            CFURLRequestRef originalRequest = connection->request;

                            CFURLRef redirectURL = CFURLCreateWithString(kCFAllocatorDefault, redirect_location, NULL);
                            if (CFURLGetByteRangeForComponent(redirectURL, kCFURLComponentNetLocation, NULL).location == kCFNotFound) {
                                // redirect_location is a path not the full url
                                CFRange pathRange = CFURLGetByteRangeForComponent(finalUrl, kCFURLComponentPath, NULL);
                                if (pathRange.location != kCFNotFound) {
                                    CFRelease(redirectURL);
                                    CFStringRef basePath = CFURLCopyPath(finalUrl);
                                    CFStringRef finalUrlStr = CFURLGetString(finalUrl);

                                    int basePathBufferSize = CFStringGetLength(basePath) * sizeof(UniChar) + CFStringGetLength(redirect_location) * sizeof(UniChar);
                                    int redirectBufferSize = CFStringGetLength(redirect_location) * sizeof(UniChar);
                                    UniChar *baseBuffer = malloc(basePathBufferSize);
                                    UniChar *redirectBuffer = malloc(redirectBufferSize);

                                    CFRange basePathRange;
                                    basePathRange.location = 0;
                                    basePathRange.length = CFStringGetLength(basePath);
                                    CFStringGetCharacters(basePath, basePathRange, baseBuffer);

                                    CFRange redirectLocationRange;
                                    redirectLocationRange.location = 0;
                                    redirectLocationRange.length = CFStringGetLength(redirect_location);
                                    CFStringGetCharacters(redirect_location, redirectLocationRange, redirectBuffer);

                                    int newPathLength = standardizePath(baseBuffer, basePathRange.length, redirectBuffer, redirectLocationRange.length);

                                    CFRange range;
                                    range.location = 0;
                                    range.length = pathRange.location;

                                    CFStringRef baseURLStr = CFStringCreateWithSubstring(kCFAllocatorDefault, finalUrlStr, range);
                                    CFMutableStringRef newURL = CFStringCreateMutable(kCFAllocatorDefault, basePathBufferSize + CFStringGetLength(baseURLStr));
                                    CFStringAppend(newURL, baseURLStr);
                                    CFStringAppendCharacters(newURL, baseBuffer, newPathLength);
                                    redirectURL = CFURLCreateWithString(kCFAllocatorDefault, newURL, NULL);

                                    CFRelease(newURL);
                                    CFRelease(baseURLStr);
                                    CFRelease(basePath);
                                    free(baseBuffer);
                                    free(redirectBuffer);
                                }
                            }

                            CFMutableURLRequestRef redirectRequest = (CFMutableURLRequestRef)CFURLRequestCreate(kCFAllocatorDefault, redirectURL, CFURLRequestGetCachePolicy(originalRequest), CFURLRequestGetTimeout(originalRequest));
                            CFRelease(connection->request);
                            CFRelease(redirectURL);

                            connection->request = redirectRequest;

                            if (connection->handler.redirect != NULL) {
                                //form new request from old with new URL

                                CFURLRequestRef contextRequest = connection->handler.redirect(connection->handler.info, connection->request, response);

                                if (contextRequest != connection->request) {
                                    CFRelease(connection->request);
                                    connection->request = contextRequest; // context should have returned retained
                                }
                                else if (contextRequest != NULL) {
                                    CFRelease(contextRequest);
                                }
                            }

                            if (connection->request == NULL) {
                                type = kCFStreamEventEndEncountered;
                            } else {
                                connection->message = CFHTTPMessageCreateRequestFromURLRequest(kCFAllocatorDefault, connection->request);
                                CFOptionFlags flags = kCFStreamEventOpenCompleted |
                                kCFStreamEventHasBytesAvailable |
                                kCFStreamEventErrorOccurred |
                                kCFStreamEventEndEncountered;

                                CFReadStreamSetClient(connection->stream, flags, readStreamEvent, NULL); // unregister the context

                                connection->replacementStream = CFReadStreamCreateForHTTPRequest(kCFAllocatorDefault, connection->message);
                                CFRelease(connection->message);

                                setProxy(connection->replacementStream);

                                CFStreamClientContext clientContext = {
                                    .version = 0,
                                    .info = (void *)connection,
                                    .retain = (void *(*)(void *))&noopRetain,
                                    .release = (void (*)(void *))&noopRelease
                                };
                                CFReadStreamSetClient(connection->replacementStream, flags, readStreamEvent, &clientContext);
                                broadcastConnectionState(connection, false);
                                return;
                            }
                        }
                    }
                    else
                    {
                        CFErrorRef error = CFErrorCreate(kCFAllocatorDefault, ErrorDomain, kCFErrorHTTPRedirectionLoopDetected, NULL);
                        connectionFailed(connection, error);
                        CFRelease(error);
                        return;
                    }
                }
                else
                {
                    CFErrorRef error = CFErrorCreate(kCFAllocatorDefault, ErrorDomain, kCFURLErrorRedirectToNonExistentLocation, NULL);
                    connectionFailed(connection, error);
                    CFRelease(error);
                    return;
                }
            }
            else if (statusCode == 401 || statusCode == 407) {
                CFHTTPAuthenticationRef auth = CFHTTPAuthenticationCreateFromResponse(kCFAllocatorDefault, message);
                if (auth != NULL && CFHTTPAuthenticationIsValid(auth, NULL)) {
                    // handle auth delegation here
                }
                if (auth != NULL) {
                    CFRelease(auth);
                }
            }
            connectionGotResponse(connection, response);
            CFRelease(response);
            CFRelease(finalUrl);
        }
        if (message) {
            CFRelease(message);
        }
    }

    switch (type) {
        case kCFStreamEventOpenCompleted:
            break;
        case kCFStreamEventHasBytesAvailable: {
            CFDataRef data = NULL;

            CFIndex length = 0;
            const UInt8 *streamBuffer = CFReadStreamGetBuffer(stream, 0, &length);
            if (streamBuffer) {
                data = CFDataCreate(kCFAllocatorDefault, streamBuffer, length);
            } else {
                UInt8 buffer[1024];
                length = CFReadStreamRead(stream, buffer, sizeof(buffer));
                data = CFDataCreate(kCFAllocatorDefault, buffer, length);
            }

            if (length) {
                if (connection->contentEncoding == kContentEncodingNone) {
                    connectionGotData(connection, data);
                } else {
                    connectionDecodeData(connection, data);
                }
            }

            if (data) {
                CFRelease(data);
            }

            break;
        }
        case kCFStreamEventErrorOccurred: {
            CFErrorRef error = CFReadStreamCopyError(stream);
            connectionFailed(connection, error);
            if (error) {
                CFRelease(error);
            }
            break;
        }
        case kCFStreamEventEndEncountered:
            connectionFinished(connection);
            break;
    }

    checkTimeoutForActiveConnections();
}

CFURLConnectionRef CFURLConnectionCreate(CFAllocatorRef allocator, CFURLRequestRef request, const CFURLConnectionContext *ctx) {
    static const CFURLConnectionContext defaultContext = {
        .version = 0,
        .info = NULL,
        .retain = &noopRetain,
        .release = &noopRelease,
        .copyDescription = &pointerDescription,
        .equal = &pointerEqual,
        .hash = &pointerHash,
        .canAuth = &noopCanAuth,
        .cancelledAuthChallenge = &noopCancel,
        .failed = &noopFailure,
        .receivedAuthChallenge = &noopSend,
        .sendRequestForAuthChallenge = &noopAuth,
        .useCredentialStorage = &noopCredentialStorage,
    };

    CFIndex size = sizeof(struct _CFURLConnection) - sizeof(CFRuntimeBase);
    struct _CFURLConnection *connection = (struct _CFURLConnection *)_CFRuntimeCreateInstance(allocator, CFURLConnectionGetTypeID(), size, NULL);

    connection->finished = false;

    connection->request = (CFURLRequestRef)CFRetain(request);

    if (ctx == NULL) {
        ctx = &defaultContext;
    }

    connection->context.version = ctx->version;
    connection->context.retain = ctx->retain ? ctx->retain : noopRetain;
    connection->context.release = ctx->release ? ctx->release : noopRelease;
    connection->context.copyDescription = ctx->copyDescription ? ctx->copyDescription : pointerDescription;
    connection->context.equal = ctx->equal ? ctx->equal : pointerEqual;
    connection->context.hash = ctx->hash ? ctx->hash : pointerHash;
    connection->context.handledByProtocol = ctx->handledByProtocol ? ctx->handledByProtocol : noopHandledByProtocol;
    connection->context.canAuth = ctx->canAuth ? ctx->canAuth : noopCanAuth;
    connection->context.cancelledAuthChallenge = ctx->cancelledAuthChallenge ? ctx->cancelledAuthChallenge : noopCancel;
    connection->context.failed = ctx->failed ? ctx->failed : noopFailure;
    connection->context.receivedAuthChallenge = ctx->receivedAuthChallenge ? ctx->receivedAuthChallenge : noopReceive;
    connection->context.sendRequestForAuthChallenge = ctx->sendRequestForAuthChallenge ? ctx->sendRequestForAuthChallenge : noopAuth;
    connection->context.useCredentialStorage = ctx->useCredentialStorage ? ctx->useCredentialStorage : noopCredentialStorage;
    connection->context.info = (void *)connection->context.retain(ctx->info);

    connection->source = NULL;
    connection->error = NULL;
    connection->response = NULL;
    connection->eventsLock = OS_SPINLOCK_INIT;
    connection->runLoop = NULL;
    connection->handler = (CFURLConnectionHandlerContext){0};
    connection->createdTime = CFAbsoluteTimeGetCurrent();
    connection->cachingState = kCachingStateNotCaching;
    connection->cachedDataArray = NULL;
    connection->contentEncoding = kContentEncodingUnknown;
    if (connection->createdTime <= 0) {
        connection->createdTime = CFURLREQUEST_MIN_TIMEOUT;
    }
    connection->message = CFHTTPMessageCreateRequestFromURLRequest(kCFAllocatorDefault, request);
    if (connection->message) {
        connection->stream = CFReadStreamCreateForHTTPRequest(kCFAllocatorDefault, connection->message);
    }
    else {
        connection->stream = NULL;
    }

    if (connection->message) {
        CFRelease(connection->message);
    }
    CFOptionFlags flags = kCFStreamEventOpenCompleted |
    kCFStreamEventHasBytesAvailable |
    kCFStreamEventErrorOccurred |
    kCFStreamEventEndEncountered;

    setProxy(connection->stream);

    CFStreamClientContext clientContext = {
        .version = 0,
        .info = (void *)connection,
        .retain = (void *(*)(void *))&noopRetain,
        .release = (void (*)(void *))&noopRelease
    };
    CFReadStreamSetClient(connection->stream, flags, readStreamEvent, &clientContext);

    connection->zStream = malloc(sizeof(z_stream));
    connection->zStream->zalloc = Z_NULL;
    connection->zStream->zfree = Z_NULL;
    connection->zStream->opaque = Z_NULL;
    connection->zStream->avail_in = 0;
    connection->zStream->next_in = 0;
    inflateInit2(connection->zStream, (MAX_WBITS + 32));

    return connection;
}

void CFURLConnectionSetHandler(CFURLConnectionRef conn, const CFURLConnectionHandlerContext *handlerContext) {
    struct _CFURLConnection *connection = (struct _CFURLConnection *)conn;
    if (connection->handler.info) {
        connection->handler.release(connection->handler.info);
    }
    connection->handler = *handlerContext;
    if (!connection->handler.retain) {
        connection->handler.retain = &noopRetain;
    }
    if (!connection->handler.release) {
        connection->handler.release = &noopRelease;
    }
    if (!connection->handler.copyDescription) {
        connection->handler.copyDescription = &pointerDescription;
    }
    if (!connection->handler.equal) {
        connection->handler.equal = &pointerEqual;
    }
    if (!connection->handler.hash) {
        connection->handler.hash = &pointerHash;
    }
    connection->handler.info = connection->handler.retain(connection->handler.info);
}

static void connectionSourcePerform(struct _CFURLConnection *connection) {
    ConnectionEvent *event;
    while ((event = dequeueConnectionEvent(connection))) {
        switch (event->type) {
            case kConnectionEventGotResponse: {
                if (connection->handler.response) {
                    connection->handler.response(connection->handler.info,
                                                 (CFURLResponseRef)event->payload);
                }
                break;
            }
            case kConnectionEventGotData: {
                if (connection->handler.data) {
                    connection->handler.data(connection->handler.info,
                                             (CFDataRef)event->payload);
                }
                break;
            }
            case kConnectionEventFailed: {
                if (connection->context.failed) {
                    connection->context.failed(connection->handler.info,
                                               (CFErrorRef)event->payload);
                }
                break;
            }
            case kConnectionEventFinished: {
                finishCaching(connection);
                if (connection->handler.finished) {
                    connection->handler.finished(connection->handler.info);
                }
                break;
            }
            default: {
                assert(false);
                CFRelease(event);
                continue;
            }
        }
        Boolean finished = (event->type & kConnectionEventFinishedBit) != 0;
        CFRelease(event);

        if (finished) {
            unscheduleFromRunLoops(connection);
            break;
        }
    }
}

static void unscheduleFromRunLoops(struct _CFURLConnection *connection) {
    pthread_mutex_lock(&connection->modeLock);
    for (CFIndex idx = 0; idx < CFArrayGetCount(connection->modes); idx++) {
        CFStringRef runLoopMode = (CFStringRef)CFArrayGetValueAtIndex(connection->modes, idx);
        CFRunLoopRemoveSource(connection->runLoop, connection->source, runLoopMode);
    }
    CFArrayRemoveAllValues(connection->modes);
    pthread_mutex_unlock(&connection->modeLock);
}

void CFURLConnectionScheduleWithRunLoop(CFURLConnectionRef conn, CFRunLoopRef runLoop, CFStringRef runLoopMode) {
    struct _CFURLConnection *connection = (struct _CFURLConnection*)conn;

    Boolean createdSource = false;
    if(connection->source == NULL) {
        CFRunLoopSourceContext context = {
            .version = 0,
            .info = connection,
            .perform = (void (*)(void *))&connectionSourcePerform,
            .retain = &CFRetain,
            .release = &CFRelease
        };
        connection->source = CFRunLoopSourceCreate(NULL, 0, &context);
        connection->runLoop = (CFRunLoopRef)CFRetain(CFRunLoopGetCurrent());
        connection->modes = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
        createdSource = true;
    }

    pthread_mutex_lock(&connection->modeLock);
    CFArrayAppendValue(connection->modes, runLoopMode);
    pthread_mutex_unlock(&connection->modeLock);

    CFRunLoopAddSource(runLoop, connection->source, runLoopMode);
    if (createdSource)
    {
        CFRelease(connection->source);
    }
    CFRunLoopWakeUp(runLoop);
}

void CFURLConnectionUnscheduleFromRunLoop(CFURLConnectionRef conn, CFRunLoopRef runLoop, CFStringRef runLoopMode) {
    struct _CFURLConnection *connection = (struct _CFURLConnection*)conn;

    pthread_mutex_lock(&connection->modeLock);
    CFIndex idx = CFArrayGetFirstIndexOfValue(connection->modes, CFRangeMake(0, CFArrayGetCount(connection->modes)), runLoopMode);
    if (idx != kCFNotFound) {
        CFArrayRemoveValueAtIndex(connection->modes, idx);
    }
    pthread_mutex_unlock(&connection->modeLock);

    CFRunLoopRemoveSource(runLoop, connection->source, runLoopMode);
}

static void enqueueConnection(CFURLConnectionRef connection) {
    pthread_mutex_lock(&managerLock);

    if (enqueuedConnections == NULL) {
        enqueuedConnections = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
    }

    if (managerSource == NULL) {
        pthread_t t;
        pthread_create(&t, NULL, &CFURLConnectionManager, NULL);

        while (!s_managerLoopWokeUp) {
            pthread_cond_wait(&managerCondition, &managerLock);
        }
    }

    Boolean needSchedule = true;
    if (connection->context.handledByProtocol) {
        if (connection->context.handledByProtocol(connection->handler.info)) {
            needSchedule = false;
        }
    }

    if (needSchedule) {
        CFArrayInsertValueAtIndex(enqueuedConnections, CFArrayGetCount(enqueuedConnections), connection);
    }

    pthread_mutex_unlock(&managerLock);
    CFRunLoopSourceSignal(managerSource);
    CFRunLoopWakeUp(managerLoop);
}

static void requeueConnection(CFURLConnectionRef connection) {
    pthread_mutex_lock(&managerLock);
    CFArrayInsertValueAtIndex(enqueuedConnections, 0, connection);
    pthread_mutex_unlock(&managerLock);
}

static CFURLConnectionRef CF_RETURNS_RETAINED dequeueConnection() {
    CFURLConnectionRef connection = NULL;
    pthread_mutex_lock(&managerLock);
    if (CFArrayGetCount(enqueuedConnections) > 0) {
        connection = (CFURLConnectionRef)CFRetain(CFArrayGetValueAtIndex(enqueuedConnections, 0));
        CFArrayRemoveValueAtIndex(enqueuedConnections, 0);
    }
    pthread_mutex_unlock(&managerLock);
    return connection;
}

static void checkTimeoutForConnectionsInQueue() {
    CFIndex i;
    struct _CFURLConnection *connectionTimeout = NULL;
    pthread_mutex_lock(&managerLock);
    for (i = 0; i < CFArrayGetCount(enqueuedConnections); i++) {
        CFURLConnectionRef connection = (CFURLConnectionRef)CFArrayGetValueAtIndex(enqueuedConnections, i);
        CFTimeInterval effectiveTimeoutValue = CFURLRequestGetTimeout(connection->request);
        if (effectiveTimeoutValue > 0 && CFAbsoluteTimeGetCurrent() - connection->createdTime > effectiveTimeoutValue) {
            connectionTimeout = (struct _CFURLConnection *)connection;
            break;
        }
    }

    if (connectionTimeout) {
        CFErrorRef timeoutError = CFErrorCreate(kCFAllocatorDefault, ErrorDomain, kCFURLErrorTimedOut, nil);
        connectionFailed(connectionTimeout, timeoutError);
        CFArrayRemoveValueAtIndex(enqueuedConnections, i);
        CFRelease(timeoutError);
    }
    pthread_mutex_unlock(&managerLock);
}

static void updateQueue(void *ctx) {
    checkTimeoutForConnectionsInQueue();
    CFRunLoopRef runLoop = CFRunLoopGetCurrent();
    OSSpinLockLock(&queue_lock);
    for (int i = 0; i < NUM_QUEUES; i++) {
        struct _CFURLConnection *connection = (struct _CFURLConnection *)activeConnections[i];
        if (connection != NULL && !connection->streamValid) {
            CFReadStreamClose(connection->stream);
            CFReadStreamUnscheduleFromRunLoop(connection->stream, runLoop, kCFRunLoopCommonModes);
            if (connection->replacementStream) {
                CFRelease(connection->stream);
                connection->stream = connection->replacementStream;
                connection->replacementStream = NULL;
                openConnection(connection);
            }
        }
        if (connection && !connection->valid) {
            CFRelease(connection);
            activeConnections[i] = NULL;
        }
    }
    OSSpinLockUnlock(&queue_lock);
    while (true) {
        struct _CFURLConnection *connection = (struct _CFURLConnection *)dequeueConnection();
        if (connection != NULL) {
            int found = -1;
            OSSpinLockLock(&queue_lock);
            for (int i = 0; i < NUM_QUEUES; i++) {
                if (activeConnections[i] == NULL) {
                    // dequeueConnection returns retained, so we don't retain here
                    activeConnections[i] = connection;
                    found = i;
                    break;
                }
            }
            OSSpinLockUnlock(&queue_lock);
            if (found >= 0) {
                openConnection(connection);
            } else {
                requeueConnection(connection);
                // dequeueConnection returns retained, so release here
                CFRelease(connection);
                break;
            }
        } else {
            break;
        }
    }
}

static void runloop_callback(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info) {
    cfurlconnection_runloop_info *rlInfo = info;
    switch (activity) {
        case kCFRunLoopEntry:
            rlInfo->pool_context = _objc_autoreleasePoolPush();
            break;
        case kCFRunLoopBeforeTimers:
            _objc_autoreleasePoolPop(rlInfo->pool_context);
            rlInfo->pool_context = _objc_autoreleasePoolPush();
            break;
        case kCFRunLoopExit:
            _objc_autoreleasePoolPop(rlInfo->pool_context);
            break;
        default:
            break;
    }
}

static void *CFURLConnectionManager(void *ctx) {
    pthread_mutex_lock(&managerLock);
    managerLoop = CFRunLoopGetCurrent();
    CFRunLoopSourceContext context = {
        .version = 0,
        .perform = (void (*)(void *))&updateQueue,
    };
    managerSource = CFRunLoopSourceCreate(NULL, 0, &context);

    // Use an observer to push and pop autoreleases
    CFRunLoopObserverContext obsContext = {
        .version = 0,
        .info = &s_runLoopInfo,
    };

    CFRunLoopObserverRef observer = CFRunLoopObserverCreate(kCFAllocatorDefault,
                                                            /* Once for entry and another for exit of the event loop 
                                                             * as well as per handling of sources and timers
                                                             */
                                                            kCFRunLoopEntry | kCFRunLoopExit | kCFRunLoopBeforeTimers,
                                                            /* Repeats */
                                                            1,
                                                            /* Order */
                                                            0,
                                                            (CFRunLoopObserverCallBack)&runloop_callback,
                                                            &obsContext);

    CFRunLoopAddObserver(managerLoop, observer, kCFRunLoopDefaultMode);
    CFRelease(observer);

    CFRunLoopAddSource(managerLoop, managerSource, kCFRunLoopCommonModes);
    CFRunLoopWakeUp(managerLoop);
    s_managerLoopWokeUp = 1;
    pthread_cond_broadcast(&managerCondition);
    pthread_mutex_unlock(&managerLock);
    SInt32 status = 0;
    do {
        CFRunLoopRun();
    } while(status != kCFRunLoopRunFinished && status != kCFRunLoopRunStopped);
    DEBUG_BREAK(); // never gets to here.... lets hope
    return NULL;
}

void CFURLConnectionStart(CFURLConnectionRef conn) {
    enqueueConnection(conn);
}

void CFURLConnectionCancel(CFURLConnectionRef conn) {
    struct _CFURLConnection *connection = (struct _CFURLConnection*)conn;
    broadcastConnectionState(connection, true);
}

Boolean CFURLConnectionGetResponse(CFURLConnectionRef conn, CFURLResponseRef *response, CFErrorRef *error) {
    struct _CFURLConnection *connection = (struct _CFURLConnection *)conn;
    Boolean success = false;
    if (response != NULL && connection->response != NULL) {
        *response = (CFURLResponseRef)CFRetain(connection->response);
    } else if (response != NULL) {
        *response = NULL;
    }

    if (error != NULL && connection->error != NULL) {
        *error = (CFErrorRef)CFRetain(connection->error);
    } else if (error != NULL) {
        *error = NULL;
    }

    return connection->error == NULL;
}

static Boolean canAuth(const void *info, CFURLProtectionSpaceRef space) {
    return true;
}

static void cancelledAuthChallenge(const void *info, CFURLAuthChallengeRef challenge) {

}

static void failed(const void *info, CFErrorRef error) {

}

static void receivedAuthChallenge(const void *info, CFURLAuthChallengeRef challenge) {

}

static void sendRequestForAuthChallenge(const void *info, CFURLAuthChallengeRef challenge) {

}

static Boolean useCredentialStorage(const void *info) {
    return true;
}

Boolean CFURLConnectionIsFinished(CFURLConnectionRef connection) {
    return connection->finished;
}

static void connectionRequestDataEvent(CFMutableDataRef buffer, CFDataRef data) {
    CFDataAppendBytes(buffer, CFDataGetBytePtr(data), CFDataGetLength(data));
}

Boolean CFURLConnectionSendSynchronousRequest(CFURLRequestRef request, CFDataRef *data, CFURLResponseRef *response, CFErrorRef *error) {
    CFMutableDataRef buffer = CFDataCreateMutable(kCFAllocatorDefault, 0);

    CFURLConnectionContext ctx = {
        .version = 0,
        .info = buffer,
        .retain = &CFRetain,
        .release = &CFRelease,
        .copyDescription = &CFCopyDescription,
        .equal = &CFEqual,
        .hash = &CFHash,
        .canAuth = &canAuth,
        .cancelledAuthChallenge = &cancelledAuthChallenge,
        .failed = &failed,
        .receivedAuthChallenge = &receivedAuthChallenge,
        .sendRequestForAuthChallenge = &sendRequestForAuthChallenge,
        .useCredentialStorage = &useCredentialStorage,
    };
    CFURLConnectionHandlerContext handler = {
        .version = 0,
        .info = buffer,
        .data = (void (*)(const void *info, CFDataRef data))&connectionRequestDataEvent
    };
    CFURLConnectionRef connection = CFURLConnectionCreate(kCFAllocatorDefault, request, &ctx);
    CFRunLoopRef rl = CFRunLoopGetCurrent();
    CFTimeInterval timeout = CFURLRequestGetTimeout(request);
    CFURLConnectionScheduleWithRunLoop(connection, rl, _kCFURLConnectionPrivateRunLoopMode);
    CFURLConnectionSetHandler(connection, &handler);
    CFURLConnectionStart(connection);
    CFTimeInterval later = CFAbsoluteTimeGetCurrent() + timeout;
    SInt32 status = 0;
    do {
        status = CFRunLoopRunInMode(_kCFURLConnectionPrivateRunLoopMode, timeout, true);
    } while(status != kCFRunLoopRunFinished && status != kCFRunLoopRunStopped &&
            (0 < (timeout = (later - CFAbsoluteTimeGetCurrent()))));

    if (data) {
        *data = buffer;
    }
    Boolean success = CFURLConnectionGetResponse(connection, response, error);
    CFRelease(connection);
    return (0 < timeout) ? success : false;
}

void CFURLConnectionSendAsynchronousRequest(CFURLRequestRef request, void (^handler)(CFURLResponseRef, CFDataRef, CFErrorRef)) {
    CFURLRequestRef req = (CFURLRequestRef)CFRetain(request);
    // I have a feeling this is actually upside down; synchronous waits on the async instead of async calling sync
    // but this should be good enough for now...
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CFErrorRef error = NULL;
        CFDataRef data = NULL;
        CFURLResponseRef response = NULL;
        CFURLConnectionSendSynchronousRequest(req, &data, &response, &error);
        if (handler) {
            handler(response, data, error);
        }
        if (data != NULL) {
            CFRelease(data);
        }
        if (error != NULL) {
            CFRelease(error);
        }
        if (response != NULL) {
            CFRelease(response);
        }
        CFRelease(req);
    });
}

static int standardizePath(UniChar *base, int baseLength, const UniChar *redirect, int redirectLength)
{
    if (redirectLength == 0) {
        return 0;
    } else if ((redirect)[0] == '/') {
        // The redirect path is absolute path eg(/foo/bar, /bar). Use the redirect path directly.
        memcpy(base, redirect, redirectLength * sizeof(UniChar));
        return redirectLength;
    } else {
        // The redirect path is relative path eg(../foo/bar, ./bar).
        int baseLastSlashIndex = 0;

        for (int i = baseLength - 1; i >= 0; i--) {
            if ((base)[i] == '/') {
                baseLastSlashIndex = i;
                break;
            }
        }

        int lastHead = 0;
        int i = 1;
        int resultLength = baseLength;
        for (; i < redirectLength; i++) {
            if ((redirect)[i] == '/') {
                if (i - lastHead == 1 && redirect[lastHead] == '.') {
                    // Do nothing, because . is the current component.
                } else if (i - lastHead == 2 && redirect[lastHead] == '.' && redirect[lastHead + 1] == '.') {
                    // The component is .. Move the base path to the last component.
                    int j = baseLastSlashIndex - 1;
                    for (; j >= 0; j--) {
                        if (base[j] == '/') {
                            baseLastSlashIndex = j;
                            break;
                        }
                    }
                    if (j == -1) {
                        resultLength = 0;
                        baseLastSlashIndex = 0;
                    }
                } else {
                    // Append the component to the base path.
                    memcpy(base + baseLastSlashIndex + 1, redirect + lastHead, (i - lastHead + 1) * sizeof(UniChar));
                    baseLastSlashIndex += i - lastHead + 1;
                    resultLength = baseLastSlashIndex + 1 + i - lastHead + 1;
                }
                lastHead = i + 1;
            }
        }
        if (i != redirectLength + 1) {
            memcpy(base + baseLastSlashIndex + 1, redirect + lastHead, (i - lastHead) * sizeof(UniChar));
            resultLength = baseLastSlashIndex + 1 + i - lastHead;
        }
        return resultLength;
    }
}

static void setProxy(CFReadStreamRef stream) {
    if (!stream) {
        return;
    }

    CFDictionaryRef proxySettings = CFNetworkCopySystemProxySettings();
    if (proxySettings) {
        CFReadStreamSetProperty(stream, kCFStreamPropertyHTTPProxy, proxySettings);
        CFRelease(proxySettings);
    }
}

static void debugLog(const char* tag, CFStringRef format, ...) {
    va_list arguments;
    va_start(arguments, format);
    CFStringRef message = CFStringCreateWithFormatAndArguments(
        kCFAllocatorDefault,
        NULL, format, arguments);
    va_end(arguments);

    CFIndex utf8Length = 1 + CFStringGetMaximumSizeForEncoding(
        CFStringGetLength(message),
        kCFStringEncodingUTF8);
    char utf8[utf8Length];
    if (CFStringGetCString(message, utf8, utf8Length, kCFStringEncodingUTF8)) {
        RELEASE_LOG("%s: %s", tag, utf8);
    }
    CFRelease(message);
}

static void startCaching(struct _CFURLConnection *connection) {
    if (connection->cachingState != kCachingStateNotCaching) {
        return;
    }

    Boolean cacheable = _CFURLResponseIsCacheableWithRequest(connection->response, connection->request);
#ifdef CACHE_LOG_ENABLED
    {
        CFTypeRef cacheControl = NULL;
        CFDictionaryRef responseHeaders = CFURLResponseGetHeaderFields(connection->response);
        if (responseHeaders) {
            cacheControl = CFDictionaryGetValue(responseHeaders, CFSTR("Cache-Control"));
        }
        CACHE_LOG(CFSTR("%s request to '%@', Cache-Control is '%@'"),
            (cacheable ? "CACHING" : "not caching"),
            CFURLRequestGetURL(connection->request),
            cacheControl);
    }
#endif
    if (!cacheable) {
        return;
    }

    connection->cachingState = kCachingStateCaching;

    if (!connection->cachedDataArray) {
        connection->cachedDataArray = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
    } else {
        CFArrayRemoveAllValues(connection->cachedDataArray);
    }
}

static void cacheData(struct _CFURLConnection *connection, CFDataRef data) {
    if (connection->cachingState != kCachingStateCaching || data == NULL || CFDataGetLength(data) == 0) {
        return;
    }

    size_t maxCachedDataSize = 0;
    {
        CFURLCacheRef cache = NULL;
        if (CFURLCacheGetShared(&cache)) {
            // In documentation for 'connection:willCacheResponse:' Apple specifies
            // that cache entry must not be larger than 5% of the disk cache size.
            maxCachedDataSize = CFURLCacheDiskCapacity(cache) / 20;
            CFRelease(cache);
        }
    }

    size_t cachedDataSize = 0;
    {
        for (CFIndex i = 0; i != CFArrayGetCount(connection->cachedDataArray); ++i) {
            CFDataRef cachedData = (CFDataRef)CFArrayGetValueAtIndex(
                connection->cachedDataArray,
                i);
            cachedDataSize += CFDataGetLength(cachedData);
        }
        cachedDataSize += CFDataGetLength(data);
    }

    if (cachedDataSize > maxCachedDataSize) {
        CACHE_LOG(CFSTR("STOPPING caching request to '%@' because it exceeded maximum size (%zu > %zu)"),
            CFURLRequestGetURL(connection->request),
            cachedDataSize,
            maxCachedDataSize);
        // Stop caching
        connection->cachingState = kCachingStateNotCaching;
        CFArrayRemoveAllValues(connection->cachedDataArray);
    } else {
        CFArrayAppendValue(connection->cachedDataArray, data);
    }
}

static void finishCaching(struct _CFURLConnection *connection) {
    if (connection->cachingState != kCachingStateCaching) { // TODO: guard by lock
        return;
    }

    CFMutableDataRef cachedData;
    {
        CFIndex dataSize = 0;
        for (CFIndex i = 0; i != CFArrayGetCount(connection->cachedDataArray); ++i) {
            CFDataRef data = (CFDataRef)CFArrayGetValueAtIndex(connection->cachedDataArray, i);
            dataSize += CFDataGetLength(data);
        }

        cachedData = CFDataCreateMutable(kCFAllocatorDefault, dataSize);
        if (cachedData) {
            for (CFIndex i = 0; i != CFArrayGetCount(connection->cachedDataArray); ++i) {
                CFDataRef data = (CFDataRef)CFArrayGetValueAtIndex(connection->cachedDataArray, i);
                CFDataAppendBytes(cachedData, CFDataGetBytePtr(data), CFDataGetLength(data));
            }
        }
    }

    if (!cachedData) {
        return;
    }

    CFCachedURLResponseRef originalCachedResponse = CFCachedURLResponseCreate(
        kCFAllocatorDefault,
        connection->response,
        cachedData,
        NULL,
        CFURLCacheStorageAllowed /* TODO: get this from request */);
    CFRelease(cachedData);

    CFCachedURLResponseRef cachedResponse = connection->handler.cache ? // TODO: guard
        connection->handler.cache(connection->handler.info, originalCachedResponse):
        originalCachedResponse;
    if (cachedResponse) {
        CFURLCacheRef cache = NULL;
        if (CFURLCacheGetShared(&cache)) {
            CFURLCacheAddCachedResponseForRequest(cache, cachedResponse, connection->request);
            CFRelease(cache);
        }
    }
    CFRelease(originalCachedResponse);
}

static Boolean replayCached(struct _CFURLConnection *connection) {
    Boolean result = false;

    CFCachedURLResponseRef cachedResponse = NULL;
    CFDataRef data = NULL;
    do {
        CFURLCacheRef cache = NULL;
        if (CFURLCacheGetShared(&cache)) {
            cachedResponse = CFURLCacheCopyResponseForRequest(cache, connection->request);
            CFRelease(cache);
        }
        if (!cachedResponse) {
            break;
        }

        CFURLResponseSource responseSource = _CFURLResponseChooseSourceWithRequest(
            CFCachedURLResponseGetResponse(cachedResponse),
            connection->request,
            CFAbsoluteTimeGetCurrent());
#ifdef TODO_CONDITIONAL_CACHE
        if (responseSource == kCFURLResponseSourceConditionalCache) {
            ...
        }
#endif
        if (responseSource != kCFURLResponseSourceCache) {
            CACHE_LOG(CFSTR("not replaying EXPIRED response for '%@'"),
                CFURLRequestGetURL(connection->request));
            break;
        }

        if (!CFCachedURLResponseLoadData(cachedResponse, &data)) {
            break;
        }

        CACHE_LOG(CFSTR("REPLAYING cached response for '%@', data size: %zd bytes"),
            CFURLRequestGetURL(connection->request),
            CFCachedURLResponseGetDataSize(cachedResponse));

        connection->cachingState = kCachingStateReplayingCached;

        CFURLResponseRef response = CFCachedURLResponseGetResponse(cachedResponse);
        queueConnectionEvent(connection, kConnectionEventGotResponse, response);

        if (CFDataGetLength(data)) {
            queueConnectionEvent(connection, kConnectionEventGotData, data);
        }

        queueConnectionEvent(connection, kConnectionEventFinished, NULL);

        broadcastConnectionState(connection, true);

        result = true;
    } while (0);
    if (cachedResponse) {
        CFRelease(cachedResponse);
    }
    if (data) {
        CFRelease(data);
    }

    return result;
}

static ContentEncoding parseContentEncoding(CFURLResponseRef response) {
    CFDictionaryRef headerFields = CFURLResponseGetHeaderFields(response);
    CFStringRef value = (CFStringRef)CFDictionaryGetValue(headerFields, CFSTR("Content-Encoding"));

    if (!value) {
        return kContentEncodingNone;
    }
    if (CFStringCompare(value, CFSTR("gzip"), kCFCompareCaseInsensitive) == kCFCompareEqualTo) {
        return kContentEncodingGZIP;
    }
    if (CFStringCompare(value, CFSTR("deflate"), kCFCompareCaseInsensitive) == kCFCompareEqualTo) {
        return kContentEncodingDeflate;
    }
    return kContentEncodingUnknown;
}
