MODULE = System/Foundation

CCFLAGS = \

    # -I$(SYSDIR)/Foundation/Headers/Additions \
    # -I$(SYSDIR)/Foundation/Headers \
    # -I$(SYSDIR)/Foundation/Source \
    # -I$(SYSDIR)/objc/Headers \
    # -I$(SYSDIR)/chromium_ppapi \
    # -I$(SYSDIR) \

OBJECTS = \

    # Source/Additions/GCArray.o \
    # Source/Additions/GCDictionary.o \
    # Source/Additions/GCObject.o \
    # Source/Additions/GSFunctions.o \
    # Source/Additions/GSInsensitiveDictionary.o \
    # Source/Additions/GSLock.o \
    # Source/Additions/GSMime.o \
    # Source/Additions/GSObjCRuntime.o \
    # Source/Additions/GSXML.o \
    # Source/Additions/NSArray+GNUstepBase.o \
    # Source/Additions/NSAttributedString+GNUstepBase.o \
    # Source/Additions/NSBundle+GNUstepBase.o \
    # Source/Additions/NSCalendarDate+GNUstepBase.o \
    # Source/Additions/NSData+GNUstepBase.o \
    # Source/Additions/NSDebug+GNUstepBase.o \
    # Source/Additions/NSError+GNUstepBase.o \
    # Source/Additions/NSFileHandle+GNUstepBase.o \
    # Source/Additions/NSLock+GNUstepBase.o \
    # Source/Additions/NSMutableString+GNUstepBase.o \
    # Source/Additions/NSNumber+GNUstepBase.o \
    # Source/Additions/NSObject+GNUstepBase.o \
    # Source/Additions/NSProcessInfo+GNUstepBase.o \
    # Source/Additions/NSStream+GNUstepBase.o \
    # Source/Additions/NSString+GNUstepBase.o \
    # Source/Additions/NSTask+GNUstepBase.o \
    # Source/Additions/NSThread+GNUstepBase.o \
    # Source/Additions/NSThread+cocotron.o \
    # Source/Additions/NSURL+GNUstepBase.o \
    # Source/Additions/Unicode.o \
    # Source/CXXException.o\
    # Source/GSArray.o \
    # Source/GSAttributedString.o \
    # Source/GSConcreteValue.o \
    # Source/GSCountedSet.o \
    # Source/GSDictionary.o \
    # Source/GSFormat.o \
    # Source/GSICUString.o \
    # Source/GSLocale.o \
    # Source/GSRunLoopWatcher.o \
    # Source/GSSet.o \
    # Source/GSString.o \
    # Source/GSValue.o \
    # Source/NSAffineTransform.o \
    # Source/NSArchiver.o \
    # Source/NSArray.o \
    # Source/NSAssertionHandler.o \
    # Source/NSAttributedString.o \
    # Source/NSAutoreleasePool.o \
    # Source/NSCache.o \
    # Source/NSCachedURLResponse.o \
    # Source/NSCalendarDate.o \
    # Source/NSCallBacks.o \
    # Source/NSCharacterSet.o \
    # Source/NSClassDescription.o \
    # Source/NSCoder.o \
    # Source/NSConcreteHashTable.o \
    # Source/NSConcreteMapTable.o \
    # Source/NSConcretePointerFunctions.o \
    # Source/NSCopyObject.o \
    # Source/NSCountedSet.o \
    # Source/NSData.o \
    # Source/NSDate.o \
    # Source/NSDateFormatter.o \
    # Source/NSDebug.o \
    # Source/NSDecimal.o \
    # Source/NSDecimalNumber.o \
    # Source/NSDictionary.o \
    # Source/NSDistantObject.o \
    # Source/NSDistributedLock.o \
    # Source/NSDistributedNotificationCenter.o \
    # Source/NSEnumerator.o \
    # Source/NSError.o \
    # Source/NSException.o \
    # Source/NSFileHandle.o \
    # Source/NSFormatter.o \
    # Source/NSGarbageCollector.o \
    # Source/NSGeometry.o \
    # Source/NSHTTPCookie.o \
    # Source/NSHashTable.o \
    # Source/NSIndexPath.o \
    # Source/NSIndexSet.o \
    # Source/NSInvocation.o \
    # Source/NSKeyValueCoding.o \
    # Source/NSKeyValueObserving.o \
    # Source/NSKeyedArchiver.o \
    # Source/NSKeyedUnarchiver.o \
    # Source/NSLocale.o \
    # Source/NSLock.o \
    # Source/NSLog.o \
    # Source/NSMachPort.o \
    # Source/NSMapTable.o \
    # Source/NSMethodSignature.o \
    # Source/NSNotification.o \
    # Source/NSNotificationCenter.o \
    # Source/NSNotificationQueue.o \
    # Source/NSNull.o \
    # Source/NSNumber.o \
    # Source/NSNumberFormatter.o \
    # Source/NSObjCRuntime.o \
    # Source/NSObject+NSComparisonMethods.o \
    # Source/NSObject.o \
    # Source/NSOperation.o \
    # Source/NSPage.o \
    # Source/NSPathUtilities.o \
    # Source/NSPipe.o \
    # Source/NSPointerArray.o \
    # Source/NSPointerFunctions.o \
    # Source/NSPort.o \
    # Source/NSPortCoder.o \
    # Source/NSPortMessage.o \
    # Source/NSPortNameServer.o \
    # Source/NSPredicate.o \
    # Source/NSProcessInfo.o \
    # Source/NSPropertyList.o \
    # Source/NSProtocolChecker.o \
    # Source/NSProxy.o \
    # Source/NSRange.o \
    # Source/NSRegularExpression.o\
    # Source/NSRunLoop.o \
    # Source/NSScanner.o \
    # Source/NSSerializer.o \
    # Source/NSSet.o \
    # Source/NSSortDescriptor.o \
    # Source/NSSpellServer.o \
    # Source/NSString.o \
    # Source/NSTextCheckingResult.o\
    # Source/NSThread.o \
    # Source/NSTimeZone.o \
    # Source/NSTimer.o \
    # Source/NSURL.o \
    # Source/NSURLAuthenticationChallenge.o \
    # Source/NSURLCache.o \
    # Source/NSURLConnection.o \
    # Source/NSURLCredential.o \
    # Source/NSURLCredentialStorage.o \
    # Source/NSURLDownload.o \
    # Source/NSURLHandle.o \
    # Source/NSURLProtectionSpace.o \
    # Source/NSURLProtocol.o \
    # Source/NSURLRequest.o \
    # Source/NSURLResponse.o \
    # Source/NSUnarchiver.o \
    # Source/NSUndoManager.o \
    # Source/NSUserDefaults.o \
    # Source/NSValue.o \
    # Source/NSValueTransformer.o \
    # Source/NSXMLDTD.o \
    # Source/NSXMLDTDNode.o \
    # Source/NSXMLDocument.o \
    # Source/NSXMLElement.o \
    # Source/NSXMLNode.o \
    # Source/NSXMLParser.o \
    # Source/NSZone.o \
    # Source/externs.o \
    # Source/NSHost.o \
    # Source/NSStream.o \
    # Source/GSStream.o \
    
# ifeq ($(OS), linux)
# OBJECTS += Source/msgSendv-linux.o
# endif
# ifeq ($(OS), mac)
# OBJECTS += Source/msgSendv-mac.o
# endif
# ifeq ($(OS), win)
# OBJECTS += Source/msgSendv-windows.o Source/win32/NSUserDefaults.o
# endif

EXCLUDED_OBJECTS = \

    # Source/GSFTPURLHandle.o \
    # Source/GSHTTPAuthentication.o \
    # Source/GSHTTPURLHandle.o \
    # Source/GSSocketStream.o \
    # Source/NSConnection.o \
    # Source/NSFileManager.o \
    # Source/NSBundle.o \
    # Source/NSSocketPort.o \
    # Source/NSSocketPortNameServer.o \
    # Source/NSHTTPCookieStorage.o \
    # Source/NSTask.o \
    # Source/objc-load.o \

include $(ROOTDIR)/module.mk
