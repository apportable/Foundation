#import "NSKeyValueProperty.h"

@class NSString;

CF_PRIVATE
@interface NSKeyValueNestedProperty : NSKeyValueProperty

- (NSString *)_keyPathIfAffectedByValueForMemberOfKeys:(NSSet *)keys;
- (NSString *)_keyPathIfAffectedByValueForKey:(NSString *)key exactMatch:(BOOL *)exactMatch;
- (Class)_isaForAutonotifying;
- (void)_addDependentValueKey:(NSString *)key;
- (void)_givenPropertiesBeingInitialized:(CFMutableSetRef)properties getAffectingProperties:(NSMutableArray *)affectingProperties;
- (instancetype)_initWithContainerClass:(NSKeyValueContainerClass *)containerClass keyPath:(NSString *)keyPath firstDotIndex:(NSUInteger)firstDotIndex propertiesBeingInitialized:(CFMutableSetRef)propertiesBeingInitialized;
@end
