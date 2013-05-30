/* NSURL.h - Class NSURL
   Copyright (C) 1999 Free Software Foundation, Inc.
   
   Written by: 	Manuel Guesdon <mguesdon@sbuilders.com>
   Date:	Jan 1999
   
   This file is part of the GNUstep Library.
   
   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2 of the License, or (at your option) any later version.
   
   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.
   
   You should have received a copy of the GNU Lesser General Public
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
   Boston, MA 02111 USA.
*/

#ifndef __NSURL_h_GNUSTEP_BASE_INCLUDE
#define __NSURL_h_GNUSTEP_BASE_INCLUDE
#import	<GNUstepBase/GSVersionMacros.h>

#import	<Foundation/NSURLHandle.h>

#if	defined(__cplusplus)
extern "C" {
#endif

#if	OS_API_VERSION(GS_API_MACOSX, GS_API_LATEST)

@class NSNumber;

/**
 *  URL scheme constant for use with [NSURL-initWithScheme:host:path:].
 */
GS_EXPORT NSString* const NSURLFileScheme;

@interface NSURL: NSObject <NSCoding, NSCopying, NSURLHandleClient>
{
#if	GS_EXPOSE(NSURL)
@private
  NSString	*_urlString;
  NSURL		*_baseURL;
  void		*_clients;
  void		*_data;
#endif
}
        
+ (id) fileURLWithPath: (NSString*)aPath;
+ (id) fileURLWithPath: (NSString *)aPath isDirectory:(BOOL)isDir;
+ (id) URLWithString: (NSString*)aUrlString;
+ (id) URLWithString: (NSString*)aUrlString
       relativeToURL: (NSURL*)aBaseUrl;

- (id) initFileURLWithPath: (NSString*)aPath;
- (id) initFileURLWithPath: (NSString*)aPath isDirectory: (BOOL)isDirectory;
- (id) initWithScheme: (NSString*)aScheme
		 host: (NSString*)aHost
		 path: (NSString*)aPath;
- (id) initWithString: (NSString*)aUrlString;
- (id) initWithString: (NSString*)aUrlString
	relativeToURL: (NSURL*)aBaseUrl;

- (NSString*) absoluteString;
- (NSURL*) absoluteURL;
- (NSURL*) baseURL;
- (NSString*) fragment;
- (NSString*) host;
- (BOOL) isFileURL;
- (void) loadResourceDataNotifyingClient: (id)client
			      usingCache: (BOOL)shouldUseCache;
- (NSString*) parameterString;
- (NSString*) password;
- (NSString*) path;
- (NSNumber*) port;
- (id) propertyForKey: (NSString*)propertyKey;
- (NSString*) query;
- (NSString*) relativePath;
- (NSString*) relativeString;
- (NSData*) resourceDataUsingCache: (BOOL)shouldUseCache;
- (NSString*) resourceSpecifier;
- (NSString*) scheme;
- (BOOL) setProperty: (id)property
	      forKey: (NSString*)propertyKey;
- (BOOL) setResourceData: (NSData*)data;
- (NSURL*) standardizedURL;
- (NSURLHandle*)URLHandleUsingCache: (BOOL)shouldUseCache;
- (NSString*) user;

- (NSURL *)URLByDeletingLastPathComponent;
- (NSString *)pathExtension;
- (NSURL *)URLByDeletingPathExtension;

- (NSString *)lastPathComponent;

@end

@interface NSObject (NSURLClient)

/** <override-dummy />
 * Some data has become available.  Note that this does not mean that all data
 * has become available, only that a chunk of data has arrived.
 */
- (void) URL: (NSURL*)sender
  resourceDataDidBecomeAvailable: (NSData*)newBytes;

/** <override-dummy />
 * Loading of resource data is complete.
 */
- (void) URLResourceDidFinishLoading: (NSURL*)sender;

/** <override-dummy />
 * Loading of resource data was cancelled by programmatic request
 * (not an error).
 */
- (void) URLResourceDidCancelLoading: (NSURL*)sender;

/** <override-dummy />
 * Loading of resource data has failed, for given human-readable reason.
 */
- (void) URL: (NSURL*)sender
  resourceDidFailLoadingWithReason: (NSString*)reason;
@end

#endif	/* GS_API_MACOSX */

extern NSString * const NSURLNameKey;
extern NSString * const NSURLLocalizedNameKey;
extern NSString * const NSURLIsRegularFileKey;
extern NSString * const NSURLIsDirectoryKey;
extern NSString * const NSURLIsSymbolicLinkKey;
extern NSString * const NSURLIsVolumeKey;
extern NSString * const NSURLIsPackageKey;
extern NSString * const NSURLIsSystemImmutableKey;
extern NSString * const NSURLIsUserImmutableKey;
extern NSString * const NSURLIsHiddenKey;
extern NSString * const NSURLHasHiddenExtensionKey;
extern NSString * const NSURLCreationDateKey;
extern NSString * const NSURLContentAccessDateKey;
extern NSString * const NSURLContentModificationDateKey;
extern NSString * const NSURLAttributeModificationDateKey;
extern NSString * const NSURLLinkCountKey;
extern NSString * const NSURLParentDirectoryURLKey;
extern NSString * const NSURLVolumeURLKey;
extern NSString * const NSURLTypeIdentifierKey;
extern NSString * const NSURLLocalizedTypeDescriptionKey;
extern NSString * const NSURLLabelNumberKey;
extern NSString * const NSURLLabelColorKey;
extern NSString * const NSURLLocalizedLabelKey;
extern NSString * const NSURLEffectiveIconKey;
extern NSString * const NSURLCustomIconKey;
extern NSString * const NSURLFileResourceIdentifierKey;
extern NSString * const NSURLVolumeIdentifierKey;
extern NSString * const NSURLPreferredIOBlockSizeKey;
extern NSString * const NSURLIsReadableKey;
extern NSString * const NSURLIsWritableKey;
extern NSString * const NSURLIsExecutableKey;
extern NSString * const NSURLIsMountTriggerKey;
extern NSString * const NSURLFileSecurityKey;
extern NSString * const NSURLIsExcludedFromBackupKey;
extern NSString * const NSURLFileResourceTypeKey;
extern NSString * const NSURLFileResourceTypeNamedPipe;
extern NSString * const NSURLFileResourceTypeCharacterSpecial;
extern NSString * const NSURLFileResourceTypeDirectory;
extern NSString * const NSURLFileResourceTypeBlockSpecial;
extern NSString * const NSURLFileResourceTypeRegular;
extern NSString * const NSURLFileResourceTypeSymbolicLink;
extern NSString * const NSURLFileResourceTypeSocket;
extern NSString * const NSURLFileResourceTypeUnknown;
extern NSString * const NSURLFileSizeKey;
extern NSString * const NSURLFileAllocatedSizeKey;
extern NSString * const NSURLTotalFileSizeKey;
extern NSString * const NSURLTotalFileAllocatedSizeKey;
extern NSString * const NSURLIsAliasFileKey;
extern NSString * const NSURLVolumeLocalizedFormatDescriptionKey;
extern NSString * const NSURLVolumeTotalCapacityKey;
extern NSString * const NSURLVolumeAvailableCapacityKey;
extern NSString * const NSURLVolumeResourceCountKey;
extern NSString * const NSURLVolumeSupportsPersistentIDsKey;
extern NSString * const NSURLVolumeSupportsSymbolicLinksKey;
extern NSString * const NSURLVolumeSupportsHardLinksKey;
extern NSString * const NSURLVolumeSupportsJournalingKey;
extern NSString * const NSURLVolumeIsJournalingKey;
extern NSString * const NSURLVolumeSupportsSparseFilesKey;
extern NSString * const NSURLVolumeSupportsZeroRunsKey;
extern NSString * const NSURLVolumeSupportsCaseSensitiveNamesKey;
extern NSString * const NSURLVolumeSupportsCasePreservedNamesKey;
extern NSString * const NSURLVolumeSupportsRootDirectoryDatesKey;
extern NSString * const NSURLVolumeSupportsVolumeSizesKey;
extern NSString * const NSURLVolumeSupportsRenamingKey;
extern NSString * const NSURLVolumeSupportsAdvisoryFileLockingKey;
extern NSString * const NSURLVolumeSupportsExtendedSecurityKey;
extern NSString * const NSURLVolumeIsBrowsableKey;
extern NSString * const NSURLVolumeMaximumFileSizeKey;
extern NSString * const NSURLVolumeIsEjectableKey;
extern NSString * const NSURLVolumeIsRemovableKey;
extern NSString * const NSURLVolumeIsInternalKey;
extern NSString * const NSURLVolumeIsAutomountedKey;
extern NSString * const NSURLVolumeIsLocalKey;
extern NSString * const NSURLVolumeIsReadOnlyKey;
extern NSString * const NSURLVolumeCreationDateKey;
extern NSString * const NSURLVolumeURLForRemountingKey;
extern NSString * const NSURLVolumeUUIDStringKey;
extern NSString * const NSURLVolumeNameKey;
extern NSString * const NSURLVolumeLocalizedNameKey;
extern NSString * const NSURLIsUbiquitousItemKey;
extern NSString * const NSURLUbiquitousItemHasUnresolvedConflictsKey;
extern NSString * const NSURLUbiquitousItemIsDownloadedKey;
extern NSString * const NSURLUbiquitousItemIsDownloadingKey;
extern NSString * const NSURLUbiquitousItemIsUploadedKey;
extern NSString * const NSURLUbiquitousItemIsUploadingKey;
extern NSString * const NSURLUbiquitousItemPercentDownloadedKey;
extern NSString * const NSURLUbiquitousItemPercentUploadedKey;


#if	defined(__cplusplus)
}
#endif

#if     !NO_GNUSTEP && !defined(GNUSTEP_BASE_INTERNAL)
#import <GNUstepBase/NSURL+GNUstepBase.h>
#endif

#endif	/* __NSURL_h_GNUSTEP_BASE_INCLUDE */

