#import <Foundation/Foundation.h>

static NSBundle* _mainBundle = nil;
static Boolean noDefaultLocalizableStrings = NO;

@implementation NSBundle

+ (NSBundle*) bundleForClass: (Class)aClass
{
    // NOTIMPLEMENTED  // called from Unicode.m
    return [self mainBundle];
}

@end
