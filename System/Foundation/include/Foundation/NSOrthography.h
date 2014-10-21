#import <Foundation/NSObject.h>

@class NSString, NSArray, NSDictionary;

@interface NSOrthography : NSObject <NSCopying, NSCoding>

@property (readonly) NSString *dominantScript;
@property (readonly) NSDictionary *languageMap;

@end

@interface NSOrthography (NSOrthographyExtended)

- (NSArray *)languagesForScript:(NSString *)script;
- (NSString *)dominantLanguageForScript:(NSString *)script;

@property (readonly) NSString *dominantLanguage;
@property (readonly) NSArray *allScripts;
@property (readonly) NSArray *allLanguages;

@end

@interface NSOrthography (NSOrthographyCreation)

+ (id)orthographyWithDominantScript:(NSString *)script languageMap:(NSDictionary *)map;
- (id)initWithDominantScript:(NSString *)script languageMap:(NSDictionary *)map;

@end
