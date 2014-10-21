#import "NSKeyValueProperty.h"

@class NSArray;

CF_PRIVATE
@interface NSKeyValueUnnestedProperty : NSKeyValueProperty
{
    NSArray *_affectingProperties;
    BOOL _cachedIsaForAutonotifyingIsValid;
    Class _cachedIsaForAutonotifying;
}

- (NSString *)_keyPathIfAffectedByValueForMemberOfKeys:(NSSet *)keys;
- (NSString *)_keyPathIfAffectedByValueForKey:(NSString *)key exactMatch:(BOOL *)exactMatch;
- (Class)isaForAutonotifying;
- (Class)_isaForAutonotifying;
- (void)_addDependentValueKey:(NSString *)key;
- (void)_givenPropertiesBeingInitialized:(CFMutableSetRef)properties getAffectingProperties:(NSMutableArray *)affectingProperties;
- (id)description;
- (void)dealloc;

@end
