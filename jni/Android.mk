LOCAL_PATH := $(call my-dir)

# First include the Objective-C run-time library
include $(CLEAR_VARS)
LOCAL_MODULE    := objc
LOCAL_SRC_FILES := libobjc.so
LOCAL_LDLIBS    := -llog
include $(PREBUILT_SHARED_LIBRARY)

# Include prebuild openssl lib
include $(CLEAR_VARS)
LOCAL_MODULE    := ssl
LOCAL_SRC_FILES := libssl.so
LOCAL_LDLIBS    := 
include $(PREBUILT_SHARED_LIBRARY)

include $(CLEAR_VARS)
BUILD     ?= release
TARGET_OS := android
HOST_OS   ?= Darwin
FRONTEND  ?= clang
ROOTDIR   := $(LOCAL_PATH)
MODULE    := foundation
BINDIR    := $(abspath $(ROOTDIR)/../obj/local/armeabi/objs/ )

LOCAL_ASFLAGS   := -shared -Wl,-Bsymbolic 
LOCAL_LDLIBS    := -llog -L../../objc-runtime/libs/armeabi/ -lobjc -L. -lssl 
LOCAL_MODULE    := foundation
LOCAL_ARM_MODE  := arm
LOCAL_CFLAGS    +=  \
                    -DBUILD_FOUNDATION_LIB \
                    -DTARGET_OS_android \
                    -D__POSIX_SOURCE \

ifeq ($(BUILD), release)
  LOCAL_CFLAGS += \
    -O2 \
    -DNDEBUG \

endif

LOCAL_OBJCFLAGS += -ferror-limit=5 -fblocks -DNS_BLOCKS_AVAILABLE


LOCAL_CFLAGS    +=  \
                    -Ifoundation/Foundation/Headers/Additions \
                    -Ifoundation/Foundation/Headers \
                    -Ifoundation/Foundation/Source \
                    -Ifoundation/objc/Headers \
                    -Ifoundation/ \


LOCAL_CFLAGS    +=  \
                    -DANDROID \
                    -fpic \
                    -Werror-return-type \
                    -ffunction-sections \
                    -funwind-tables \
                    -fstack-protector \
                    -fno-short-enums \
                    -DHAVE_GCC_VISIBILITY \
                    -g \
                    -fpic \
                    -ffunction-sections \
                    -funwind-tables \
                    -fstack-protector \
                    -fno-short-enums \
                    -D__ARM_ARCH_5__ \
                    -D__ANDROID__  \
                    -DAPPORTABLE \
                    -march=armv5 \
                    -msoft-float \
                    -isystem $(ANDROID_NDK_ROOT)/platforms/android-8/arch-arm/usr/include/ \


LOCAL_SRC_FILES := \
                   CoreFoundation/CFRunLoop.o \
                   CoreFoundation/CFBase.o \

#                    CoreFoundation/CFArray.o \
#                    CoreFoundation/CFBase.o \
#                    CoreFoundation/CFByteOrder.o \
#                    CoreFoundation/CFBundle.o \
#                    CoreFoundation/CFData.o \
#                    CoreFoundation/CFDate.o \
#                    CoreFoundation/CFDictionary.o \
#                    CoreFoundation/CFNumber.o \
#                    CoreFoundation/CFUUID.o \
#                    CoreFoundation/CFString.o \
#                    CoreFoundation/CFLocale.o \
#                    CoreFoundation/CFCharacterSet.o \
#                    CoreFoundation/CFURL.o \
#                    CoreFoundation/CFStream.o \
#                    CoreFoundation/CFBinaryHeap.o \


LOCAL_SRC_FILES +=  \
                   Foundation/Source/Additions/GCArray.o \
                   Foundation/Source/Additions/GCDictionary.o \
                   Foundation/Source/Additions/GCObject.o \
                   Foundation/Source/Additions/GSFunctions.o \
                   Foundation/Source/Additions/GSInsensitiveDictionary.o \
                   Foundation/Source/Additions/GSLock.o \
                   Foundation/Source/Additions/GSMime.o \
                   Foundation/Source/Additions/GSObjCRuntime.o \
                   Foundation/Source/Additions/GSXML.o \
                   Foundation/Source/Additions/NSArray+GNUstepBase.o \
                   Foundation/Source/Additions/NSAttributedString+GNUstepBase.o \
                   Foundation/Source/Additions/NSBundle+GNUstepBase.o \
                   Foundation/Source/Additions/NSCalendarDate+GNUstepBase.o \
                   Foundation/Source/Additions/NSData+GNUstepBase.o \
                   Foundation/Source/Additions/NSDebug+GNUstepBase.o \
                   Foundation/Source/Additions/NSError+GNUstepBase.o \
                   Foundation/Source/Additions/NSFileHandle+GNUstepBase.o \
                   Foundation/Source/Additions/NSLock+GNUstepBase.o \
                   Foundation/Source/Additions/NSMutableString+GNUstepBase.o \
                   Foundation/Source/Additions/NSNumber+GNUstepBase.o \
                   Foundation/Source/Additions/NSObject+GNUstepBase.o \
                   Foundation/Source/Additions/NSStream+GNUstepBase.o \
                   Foundation/Source/Additions/NSString+GNUstepBase.o \
                   Foundation/Source/Additions/NSTask+GNUstepBase.o \
                   Foundation/Source/Additions/NSThread+GNUstepBase.o \
                   Foundation/Source/Additions/NSThread+cocotron.o \
                   Foundation/Source/Additions/NSURL+GNUstepBase.o \
                   Foundation/Source/Additions/Unicode.o \
                   Foundation/Source/Additions/NSArray+Blocks.o \
                   Foundation/Source/Additions/NSDictionary+Blocks.o \
                   Foundation/Source/Additions/NSObject+Apportable.o \
                   Foundation/Source/CXXException.o\
                   Foundation/Source/GSArray.o \
                   Foundation/Source/GSAttributedString.o \
                   Foundation/Source/GSConcreteValue.o \
                   Foundation/Source/GSCountedSet.o \
                   Foundation/Source/GSDictionary.o \
                   Foundation/Source/GSFormat.o \
                   Foundation/Source/GSICUString.o \
                   Foundation/Source/GSLocale.o \
                   Foundation/Source/GSRunLoopWatcher.o \
                   Foundation/Source/GSSet.o \
                   Foundation/Source/GSString.o \
                   Foundation/Source/GSValue.o \
                   Foundation/Source/NSAffineTransform.o \
                   Foundation/Source/NSArchiver.o \
                   Foundation/Source/NSArray.o \
                   Foundation/Source/NSAssertionHandler.o \
                   Foundation/Source/NSAttributedString.o \
                   Foundation/Source/NSAutoreleasePool.o \
                   Foundation/Source/NSCache.o \
                   Foundation/Source/NSCachedURLResponse.o \
                   Foundation/Source/NSCalendarDate.o \
                   Foundation/Source/NSCallBacks.o \
                   Foundation/Source/NSCharacterSet.o \
                   Foundation/Source/NSClassDescription.o \
                   Foundation/Source/NSCoder.o \
                   Foundation/Source/NSConcreteHashTable.o \
                   Foundation/Source/NSConcreteMapTable.o \
                   Foundation/Source/NSConcretePointerFunctions.o \
                   Foundation/Source/NSCopyObject.o \
                   Foundation/Source/NSCountedSet.o \
                   Foundation/Source/NSData.o \
                   Foundation/Source/NSDate.o \
                   Foundation/Source/NSDateFormatter.o \
                   Foundation/Source/NSDebug.o \
                   Foundation/Source/NSDecimal.o \
                   Foundation/Source/NSDecimalNumber.o \
                   Foundation/Source/NSDictionary.o \
                   Foundation/Source/NSDistantObject.o \
                   Foundation/Source/NSDistributedLock.o \
                   Foundation/Source/NSDistributedNotificationCenter.o \
                   Foundation/Source/NSEnumerator.o \
                   Foundation/Source/NSError.o \
                   Foundation/Source/NSException.o \
                   Foundation/Source/NSFileHandle.o \
                   Foundation/Source/NSFormatter.o \
                   Foundation/Source/NSGarbageCollector.o \
                   Foundation/Source/NSGeometry.o \
                   Foundation/Source/NSHTTPCookie.o \
                   Foundation/Source/NSHashTable.o \
                   Foundation/Source/NSIndexPath.o \
                   Foundation/Source/NSIndexSet.o \
                   Foundation/Source/NSInvocation.o \
                   Foundation/Source/NSKeyValueCoding.o \
                   Foundation/Source/NSKeyValueObserving.o \
                   Foundation/Source/NSKeyedArchiver.o \
                   Foundation/Source/NSKeyedUnarchiver.o \
                   Foundation/Source/NSLocale.o \
                   Foundation/Source/NSLock.o \
                   Foundation/Source/NSLog.o \
                   Foundation/Source/NSMachPort.o \
                   Foundation/Source/NSMapTable.o \
                   Foundation/Source/NSMethodSignature.o \
                   Foundation/Source/NSNotification.o \
                   Foundation/Source/NSNotificationCenter.o \
                   Foundation/Source/NSNotificationQueue.o \
                   Foundation/Source/NSNull.o \
                   Foundation/Source/NSNumber.o \
                   Foundation/Source/NSNumberFormatter.o \
                   Foundation/Source/NSObjCRuntime.o \
                   Foundation/Source/NSObject+NSComparisonMethods.o \
                   Foundation/Source/NSObject.o \
                   Foundation/Source/NSOperation.o \
                   Foundation/Source/NSPage.o \
                   Foundation/Source/NSPipe.o \
                   Foundation/Source/NSPointerArray.o \
                   Foundation/Source/NSPointerFunctions.o \
                   Foundation/Source/NSPort.o \
                   Foundation/Source/NSPortCoder.o \
                   Foundation/Source/NSPortMessage.o \
                   Foundation/Source/NSPortNameServer.o \
                   Foundation/Source/NSPredicate.o \
                   Foundation/Source/NSPropertyList.o \
                   Foundation/Source/NSProtocolChecker.o \
                   Foundation/Source/NSProxy.o \
                   Foundation/Source/NSRange.o \
                   Foundation/Source/NSRegularExpression.o\
                   Foundation/Source/NSRunLoop.o \
                   Foundation/Source/NSScanner.o \
                   Foundation/Source/NSSerializer.o \
                   Foundation/Source/NSSet.o \
                   Foundation/Source/NSSortDescriptor.o \
                   Foundation/Source/NSSpellServer.o \
                   Foundation/Source/NSString.o \
                   Foundation/Source/NSTextCheckingResult.o\
                   Foundation/Source/NSThread.o \
                   Foundation/Source/NSTimeZone.o \
                   Foundation/Source/NSTimer.o \
                   Foundation/Source/NSURL.o \
                   Foundation/Source/NSURLAuthenticationChallenge.o \
                   Foundation/Source/NSURLCache.o \
                   Foundation/Source/NSURLConnection.o \
                   Foundation/Source/NSURLCredential.o \
                   Foundation/Source/NSURLCredentialStorage.o \
                   Foundation/Source/NSURLDownload.o \
                   Foundation/Source/NSURLHandle.o \
                   Foundation/Source/NSURLProtectionSpace.o \
                   Foundation/Source/NSURLProtocol.o \
                   Foundation/Source/NSURLRequest.o \
                   Foundation/Source/NSURLResponse.o \
                   Foundation/Source/NSUnarchiver.o \
                   Foundation/Source/NSUndoManager.o \
                   Foundation/Source/NSUserDefaults.o \
                   Foundation/Source/NSValue.o \
                   Foundation/Source/NSValueTransformer.o \
                   Foundation/Source/NSXMLDTD.o \
                   Foundation/Source/NSXMLDTDNode.o \
                   Foundation/Source/NSXMLDocument.o \
                   Foundation/Source/NSXMLElement.o \
                   Foundation/Source/NSXMLNode.o \
                   Foundation/Source/NSXMLParser.o \
                   Foundation/Source/NSZone.o \
                   Foundation/Source/externs.o \
                   Foundation/Source/NSHost.o \
                   Foundation/Source/NSStream.o \
                   Foundation/Source/GSStream.o \
                   Foundation/Source/msgSendv.o \
                   Foundation/Source/NSProcessInfo.o \
                   Foundation/Source/Additions/NSProcessInfo+GNUstepBase.o \
                   Foundation/stubs/accessors.o \
                   Foundation/stubs/GSFileHandle.o \
                   Foundation/stubs/GSFTPURLHandle.o \
                   Foundation/stubs/GSHTTPAuthentication.o \
                   Foundation/stubs/GSHTTPURLHandle.o \
                   Foundation/stubs/GSRunLoopCtxt.o \
                   Foundation/stubs/NSBundle.o \
                   Foundation/stubs/NSConnection.o \
                   Foundation/stubs/NSFileManager.o \
                   Foundation/stubs/NSMessagePort.o \
                   Foundation/stubs/NSMessagePortNameServer.o \
                   Foundation/stubs/NSSocketPort.o \
                   Foundation/stubs/NSSocketPortNameServer.o \
                   Foundation/stubs/NSHTTPCookieStorage.o \
                   Foundation/stubs/NSTask.o \
                   Foundation/stubs/objc-load.o \
                   Foundation/stubs/objc-class.o \
                   Foundation/stubs/syscall.o \
                   Foundation/stubs/strnstr.o \
                   Foundation/stubs/NSPlatform.o \
                   Foundation/stubs/gnustep_base_user_main.o \
                   Foundation/stubs/NSPathUtilities.o \

#                   Foundation/Source/NSRaise.o \

# LOCAL_SRC_FILES += \
#                    CFNetwork/CFHTTPMessage.o \
#                    CFNetwork/CFHTTPAuthentication.o \
#                    CFNetwork/CFSocketStream.o \
#                    CFNetwork/CFProxySupport.o \
#                    CFNetwork/CFHTTPStream.o \
#                    CFNetwork/CFNetworkErrors.o \
# 
# LOCAL_SRC_FILES += \
#                    Security/SecBase.o \

OBJECTS:=$(LOCAL_SRC_FILES)

ANDROID_NDK_ROOT=/Developer/DestinyCloudFist/crystax-ndk-r7
ANDROID_SDK_ROOT=/Developer/DestinyCloudFist/android-sdk-mac_x86

CXX_SYSTEM = -isystem $(ANDROID_NDK_ROOT)/sources/cxx-stl/gnu-libstdc++/include/4.4.3/ \
             -isystem $(ANDROID_NDK_ROOT)/sources/cxx-stl/gnu-libstdc++/libs/armeabi/4.4.3/include/ \
             -isystem $(ANDROID_NDK_ROOT)/sources/crystax/include \

CCLD=$(ANDROID_NDK_ROOT)/toolchains/arm-linux-androideabi-4.4.3/prebuilt/darwin-x86/bin/arm-linux-androideabi-g++ --sysroot=$(ANDROID_NDK_ROOT)/platforms/android-$(ANDROID_API_LEVEL)/arch-arm

CC= /Developer/DestinyCloudFist/clang-2.9/bin/clang --sysroot=$(ANDROID_NDK_ROOT)/platforms/android-8/arch-arm $(CXX_SYSTEM) -ccc-host-triple arm-linux-eabi -march=armv5
CPP= /Developer/DestinyCloudFist/clang-2.9/bin/clang --sysroot=$(ANDROID_NDK_ROOT)/platforms/android-8/arch-arm  $(CXX_SYSTEM)

CCAS=$(ANDROID_NDK_ROOT)/toolchains/arm-linux-androideabi-4.4.3/prebuilt/darwin-x86/bin/arm-linux-androideabi-gcc
AS=$(ANDROID_NDK_ROOT)/toolchains/arm-linux-androideabi-4.4.3/prebuilt/darwin-x86/bin/arm-linux-androideabi-as
LDR=
AR=$(ANDROID_NDK_ROOT)/toolchains/arm-linux-androideabi-4.4.3/prebuilt/darwin-x86/bin/arm-linux-androideabi-ar

OBJDIR = $(BINDIR)/$(MODULE)

MODULE_CFLAGS := $(COMMON_CFLAGS) $(CFLAGS) $(LOCAL_CFLAGS) 
MODULE_CCFLAGS := $(COMMON_CCFLAGS) $(CCFLAGS) $(LOCAL_CFLAGS) 
MODULE_ASFLAGS := $(COMMON_ASFLAGS) $(ASFLAGS) $(LOCAL_ASFLAGS) 
MODULE_OBJCFLAGS := $(COMMON_OBJCFLAGS) $(LOCAL_OBJCFLAGS)

$(OBJDIR)/%.o: $(ROOTDIR)/$(MODULE)/%.cc
	@echo $<
	@mkdir -p `echo $@ | sed s/[^/]*[.]o$$//`
	$(CC) $(MODULE_CCFLAGS) -S $< -o $@.s
	perl fixup_assembly.pl < $@.s > $@.fixed.s
	$(CCAS) $(MODULE_ASFLAGS) -c $@.fixed.s -o $@

$(OBJDIR)/%.o: $(ROOTDIR)/$(MODULE)/%.cpp
	@echo $<
	@mkdir -p `echo $@ | sed s/[^/]*[.]o$$//`
	$(CC) $(MODULE_CCFLAGS) -S $< -o $@.s
	perl fixup_assembly.pl < $@.s > $@.fixed.s
	$(CCAS) $(MODULE_ASFLAGS) -c $@.fixed.s -o $@

$(OBJDIR)/%.o: $(ROOTDIR)/$(MODULE)/%.c
	@echo $<
	@mkdir -p `echo $@ | sed s/[^/]*[.]o$$//`
	$(CC) $(MODULE_CFLAGS) $(MODULE_CCFLAGS) -S $< -o $@.s
	perl fixup_assembly.pl < $@.s > $@.fixed.s
	$(CCAS) $(MODULE_ASFLAGS) -c $@.fixed.s -o $@

$(OBJDIR)/%.o: $(ROOTDIR)/$(MODULE)/%.m
	@echo $<
	@mkdir -p `echo $@ | sed s/[^/]*[.]o$$//`
	$(CC) $(MODULE_CFLAGS) $(MODULE_CCFLAGS) $(MODULE_OBJCFLAGS) -S $< -o $@.s
	perl fixup_assembly.pl < $@.s > $@.fixed.s
	$(CCAS) $(MODULE_ASFLAGS) -c $@.fixed.s -o $@

$(OBJDIR)/%.o: $(ROOTDIR)/$(MODULE)/%.mm
	@echo $<
	@mkdir -p `echo $@ | sed s/[^/]*[.]o$$//`
	$(CC) $(MODULE_CCFLAGS) $(MODULE_OBJCFLAGS) -S $< -o $@.s
	perl fixup_assembly.pl < $@.s > $@.fixed.s
	$(CCAS) $(MODULE_ASFLAGS) -c $@.fixed.s -o $@

$(OBJDIR)/%.o: $(ROOTDIR)/$(MODULE)/%.s
	@echo $<
	@mkdir -p `echo $@ | sed s/[^/]*[.]o$$//`
	$(CCAS) $(MODULE_ASFLAGS) -c $< -o $@

include $(BUILD_SHARED_LIBRARY)


