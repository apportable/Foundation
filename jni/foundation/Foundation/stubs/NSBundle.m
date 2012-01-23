#import <Foundation/Foundation.h>

static NSBundle* _mainBundle = nil;
static Boolean noDefaultLocalizableStrings = NO;

@implementation NSBundle

+ (NSBundle *)mainBundle
{
    if (!_mainBundle)
        _mainBundle = [[NSBundle alloc] init];
    return _mainBundle;
}

+ (NSBundle*) bundleForClass: (Class)aClass
{
    // NOTIMPLEMENTED
    return [self mainBundle];
}

- (NSDictionary *) infoDictionary
{
    if (_infoDict)
        return _infoDict;

    NSString* path = [self pathForResource: @"Info" ofType: @"plist"];

    if (path)
    {
        _infoDict = [[NSDictionary alloc] initWithContentsOfFile: path];
    }
    else
    {
        _infoDict = RETAIN([NSDictionary dictionary]);
    }
    return _infoDict;
}

- (id)objectForInfoDictionaryKey:(NSString *)key
{
    return [[self infoDictionary] objectForKey:key]; // TODO: localize?
}

- (NSString*) pathForResource: (NSString*)name ofType: (NSString*)ext inDirectory: (NSString*)subPath
{
    if (subPath == nil)
        subPath = @"";
    return [self pathForResource:[[subPath stringByAppendingString:@"/"] stringByAppendingString:name] ofType:ext];
}

- (NSString*) pathForResource: (NSString*)name ofType: (NSString*)ext
{
    NSString *result = [ext length] > 0 ? [[name stringByAppendingString:@"."] stringByAppendingString:ext] : name;
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:result];
    return exists ? result : nil;
}

- (NSString*) resourcePath
{
#if defined(TARGET_OS_android) || defined(TARGET_OS_googletv)
// There should be a way to specify paths in the asset system vs. normal file system which is accessible in Android
// e.g. /:assets:/foo/bar. "" is the top level asset directory
    return @"";
#else
    return @"/";
#endif
}

- (NSString*) bundlePath
{
  return @"";
}

- (NSString*) localizedStringForKey: (NSString*)key value: (NSString*)value table: (NSString*)table
{
  // Cocotron implementation
  NSString     *result;
  NSString     *path;
  NSString     *contents=nil;
  NSDictionary *dictionary=nil;
  Boolean defaultTable = NO;

  if ([table length] == 0) {
    table = @"Localizable";
    defaultTable = YES;
  }

  if (!(noDefaultLocalizableStrings == YES && defaultTable == YES) &&
      (path = [self pathForResource:table ofType:@"strings"]) != nil) {
    if ((contents = [NSString stringWithContentsOfFile:path]) != nil) {
      dictionary = [contents propertyListFromStringsFileFormat];
    }
  }

  if (defaultTable == YES && dictionary == nil) {
    noDefaultLocalizableStrings = YES;
  }

  if ((result = [dictionary objectForKey:key]) == nil)
    result = (value != nil && [value length] > 0) ? value : key;

  result = (result == nil) ? @"" : result;

  return result;
}

@end
