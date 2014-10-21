#import <Foundation/NSObject.h>

@class NSArray, NSString;

FOUNDATION_EXPORT NSString * const NSNegateBooleanTransformerName;
FOUNDATION_EXPORT NSString * const NSIsNilTransformerName;
FOUNDATION_EXPORT NSString * const NSIsNotNilTransformerName;
FOUNDATION_EXPORT NSString * const NSUnarchiveFromDataTransformerName;
FOUNDATION_EXPORT NSString * const NSKeyedUnarchiveFromDataTransformerName;

@interface NSValueTransformer : NSObject

+ (void)setValueTransformer:(NSValueTransformer *)transformer forName:(NSString *)name;
+ (NSValueTransformer *)valueTransformerForName:(NSString *)name;
+ (NSArray *)valueTransformerNames;
+ (Class)transformedValueClass;
+ (BOOL)allowsReverseTransformation;
- (id)transformedValue:(id)value;
- (id)reverseTransformedValue:(id)value;

@end
