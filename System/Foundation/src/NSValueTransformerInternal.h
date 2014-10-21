#import <Foundation/NSValueTransformer.h>

@interface NSValueTransformer (Internal)

+ (NSMutableDictionary *)_transformerRegistry;

@end

@interface _NSSharedValueTransformer : NSValueTransformer

- (BOOL)_isBooleanTransformer;
- (id)copyWithZone:(NSZone *)zone;
- (id)copy;
- (BOOL)_tryRetain;
- (BOOL)_isDeallocating;
- (oneway void)release;
- (id)autorelease;
- (id)retain;

@end

__attribute__((visibility("hidden")))
@interface _NSNegateBooleanTransformer : _NSSharedValueTransformer

+ (Class)transformedValueClass;
- (BOOL)_isBooleanTransformer;
- (id)description;
- (id)transformedValue:(id)value;

@end

__attribute__((visibility("hidden")))
@interface _NSIsNilTransformer : _NSNegateBooleanTransformer

+ (BOOL)supportsReverseTransformation;
- (id)description;
- (id)transformedValue:(id)value;

@end

__attribute__((visibility("hidden")))
@interface _NSIsNotNilTransformer : _NSNegateBooleanTransformer

+ (BOOL)supportsReverseTransformation;
- (id)description;
- (id)transformedValue:(id)value;

@end

__attribute__((visibility("hidden")))
@interface _NSKeyedUnarchiveFromDataTransformer : _NSSharedValueTransformer

- (id)description;
- (id)reverseTransformedValue:(id)value;
- (id)transformedValue:(id)value;

@end

__attribute__((visibility("hidden")))
@interface _NSUnarchiveFromDataTransformer : _NSSharedValueTransformer

- (id)description;
- (id)reverseTransformedValue:(id)value;
- (id)transformedValue:(id)value;

@end

