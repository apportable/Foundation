#import "common.h"
#import "GSPrivate.h"
#import "Foundation/NSInvocation.h"

#warning GSPrivateLoadModule is not available
long
GSPrivateLoadModule(NSString *filename, FILE *errorStream,
  void (*loadCallback)(Class, struct objc_category *),
  void **header, NSString *debugFilename)
{
	NSUnimplementedFunction();
	return 0;
}

#warning GSPrivateSymbolPath is not available
NSString *
GSPrivateSymbolPath(Class theClass, Category *theCategory)
{
	NSUnimplementedFunction();
	return nil;
}
