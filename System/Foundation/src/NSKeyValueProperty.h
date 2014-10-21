#import <Foundation/NSObject.h>

#import "NSKeyValueContainerClass.h"
#import "NSKeyValueObservingInternal.h"
#import <CoreFoundation/CFSet.h>

@class NSString, NSKeyValueObservance;


CF_PRIVATE
@interface NSKeyValueProperty : NSObject <NSCopying>
{
    NSKeyValueContainerClass *_containerClass;
    NSString *_keyPath;
}

@property (retain, nonatomic) NSKeyValueContainerClass *containerClass;
@property (copy, nonatomic) NSString *keyPath;
@property (assign, nonatomic) Class cachedIsaForAutonotifying;

- (BOOL)matchesWithoutOperatorComponentsKeyPath:(NSString *)keyPath;
- (id)restOfKeyPathIfContainedByValueForKeyPath:(NSString *)keyPath;
- (id)dependentValueKeyOrKeysIsASet:(BOOL *)isASet;
- (void)object:(NSObject *)anObject withObservance:(NSKeyValueObservance *)observance didChangeValueForKeyOrKeys:(id)keyOrKeys recurse:(BOOL)shouldRecurse forwardingValues:(NSKeyValueForwardingValues)forwardingValues;
- (BOOL)object:(NSObject *)object withObservance:(NSKeyValueObservance *)observance willChangeValueForKeyOrKeys:(id)keyOrKeys recurse:(BOOL)shouldRecurse forwardingValues:(NSKeyValueForwardingValues *)forwardingValues;
- (void)object:(NSObject *)anObject didRemoveObservance:(NSKeyValueObservance *)observance recurse:(BOOL)recurse;
- (void)object:(NSObject *)observable didAddObservance:(NSKeyValueObservance *)observance recurse:(BOOL)shouldRecurse;
- (NSString *)keyPathIfAffectedByValueForMemberOfKeys:(NSSet *)keys;
- (NSString *)keyPathIfAffectedByValueForKey:(NSString *)key exactMatch:(BOOL *)exactMatch;
- (Class)isaForAutonotifying;
- (id)keyPath;
- (id)copyWithZone:(NSZone *)zone;
- (instancetype)_initWithContainerClass:(NSKeyValueContainerClass *)containerClass keyPath:(NSString *)key propertiesBeingInitialized:(CFMutableSetRef)propertiesBeingInitialized;

@end
