//
//  NSLocalizableString.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "NSLocalizableString.h"
#import <Foundation/NSBundle.h>
#import <Foundation/NSPathUtilities.h>
#import <Foundation/NSCoder.h>

@interface NSBundle (UINSBundleLocalizableStringAdditions)

+ (NSBundle *)currentNibLoadingBundle;
+ (NSString *)currentNibPath;

@end

static NSString *const NSKeyKey = @"NSKey";
static NSString *const NSDevKey = @"NSDev";

@implementation NSLocalizableString

@synthesize developmentLanguageString = _developmentLanguageString;
@synthesize stringsFileKey = _stringsFileKey;

+ (id)localizableStringWithStringsFileKey:(NSString *)key developmentLanguageString:(NSString *)devLang
{
    return [[[self alloc] initWithStringsFileKey:key developmentLanguageString:devLang] autorelease];
}

- (id)initWithStringsFileKey:(NSString *)key developmentLanguageString:(NSString *)devLang
{
    self = [super init];
    
    if (self)
    {
        _stringsFileKey = [key copy];
        _developmentLanguageString = [devLang copy];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self)
    {
        _stringsFileKey = [[aDecoder decodeObjectForKey:NSKeyKey] copy];
        _developmentLanguageString = [[aDecoder decodeObjectForKey:NSDevKey] copy];
    }
    
    return self;
}

- (void)dealloc
{
    [_stringsFileKey release];
    [_developmentLanguageString release];
    
    [super dealloc];
}

- (Class)classForCoder
{
    return [self class];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_stringsFileKey forKey:NSKeyKey];
    [aCoder encodeObject:_developmentLanguageString forKey:NSDevKey];
}

- (id)awakeAfterUsingCoder:(NSCoder *)coder
{
    NSString *table = [[[NSBundle currentNibPath] lastPathComponent] stringByDeletingPathExtension];
    NSBundle *bundle = [NSBundle currentNibLoadingBundle];
    NSString *str = nil;
    
    if (table)
    {
        str = [bundle localizedStringForKey:_stringsFileKey value:_developmentLanguageString table:table];
    }
    else
    {
        str = _developmentLanguageString;
    }
    
    str = [str retain];
    [self release];
    return str;
}

- (id)copyWithZone:(NSZone *)zone
{
    return [self retain];
}

- (void)setDevelopmentLanguageString:(NSString *)str
{
    if (_developmentLanguageString != str)
    {
        [_developmentLanguageString release];
        _developmentLanguageString = [str copy];
    }
}

- (void)setStringsFileKey:(NSString *)key
{
    if (_stringsFileKey != key)
    {
        [_stringsFileKey release];
        _stringsFileKey = [key copy];
    }
}

- (unichar)characterAtIndex:(NSUInteger)index
{
    return [_developmentLanguageString characterAtIndex:index];
}

- (NSUInteger)length
{
    return [_developmentLanguageString length];
}

@end
