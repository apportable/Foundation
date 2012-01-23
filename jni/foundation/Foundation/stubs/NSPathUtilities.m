#import "common.h"
#include "objc-load.h"
#import "Foundation/NSPathUtilities.h"
#import "Foundation/NSException.h"
#import "Foundation/NSArray.h"
#import "Foundation/NSDictionary.h"
#import "Foundation/NSFileManager.h"
#import "Foundation/NSProcessInfo.h"
#import "Foundation/NSValue.h"
#import "Foundation/NSLock.h"
#import "Foundation/NSUserDefaults.h"
#import "GNUstepBase/NSString+GNUstepBase.h"
#import "Foundation/NSInvocation.h"

#import "GSPrivate.h"

NSString *NSUserName(void)
{
  return [[NSPlatform currentPlatform] userName];
}

NSString *NSHomeDirectory(void)
{
  return [[NSPlatform currentPlatform] homeDirectory];
}

NSString *NSHomeDirectoryForUser(NSString *loginName)
{
  return [[NSPlatform currentPlatform] homeDirectory];
}

NSString *NSFullUserName(void)
{
  return [[NSPlatform currentPlatform] userName];
}

NSArray *NSStandardApplicationPaths(void)
{
  return NSSearchPathForDirectoriesInDomains(NSAllApplicationsDirectory, NSAllDomainsMask, YES);
}

NSArray *NSStandardLibraryPaths(void)
{
  return NSSearchPathForDirectoriesInDomains(NSAllLibrariesDirectory, NSAllDomainsMask, YES);
}

NSString *GSDefaultsRootForUser(NSString *userName)
{
  return NSHomeDirectoryForUser(userName);
}

static NSDictionary *gnustepConfig = nil;
NSMutableDictionary *GNUstepConfig(NSDictionary *newConfig)
{
  if (!gnustepConfig)
    gnustepConfig = [[NSMutableDictionary alloc] initWithObjectsAndKeys:NULL];
  return gnustepConfig;
}

NSArray *NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory directoryKey, NSSearchPathDomainMask domainMask, BOOL expandTilde)
{
  return [NSArray arrayWithObject:NSHomeDirectory()];
}
