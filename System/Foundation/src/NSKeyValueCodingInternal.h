#import <Foundation/NSKeyValueCoding.h>
#import <CoreFoundation/CFSet.h>

@class NSKeyValueGetter;
@class NSKeyValueSetter;
@class NSKeyValueProxyGetter;

CF_PRIVATE
extern NSString * const NSUnknownKeyException;

CF_PRIVATE
extern CFMutableSetRef NSKVOSetters;

CF_PRIVATE
extern CFMutableSetRef NSKVOGetters;

CF_PRIVATE
extern CFMutableSetRef NSKVOMutableArrayGetters;

CF_PRIVATE
extern CFMutableSetRef NSKVOMutableOrderedSetGetters;

CF_PRIVATE
extern CFMutableSetRef NSKVOMutableSetGetters;

CF_PRIVATE
CFSetCallBacks _NSKVOSetterCallbacks;

typedef struct {
    Class evil; // This is to account for the isa of NSKeyValueSetter (NSKeyValueAccessor)
    Class cls;
    NSString *key;
    IMP implementation;
    SEL selector;
} NSKVOSetterStruct;
typedef NSKVOSetterStruct NSKVOGetterStruct;

#pragma mark -

@interface NSObject (NSKeyValueCodingPrivate)

+ (NSKeyValueSetter*)_createValuePrimitiveSetterWithContainerClassID:(Class)cls key:(NSString *)key;
+ (NSKeyValueGetter*)_createValuePrimitiveGetterWithContainerClassID:(Class)cls key:(NSString *)key;
+ (NSKeyValueSetter*)_createOtherValueSetterWithContainerClassID:(Class)cls key:(NSString *)key;
+ (NSKeyValueGetter*)_createOtherValueGetterWithContainerClassID:(Class)cls key:(NSString *)key;
+ (NSKeyValueProxyGetter*)_createMutableArrayValueGetterWithContainerClassID:(Class)cls key:(NSString *)key;
+ (NSKeyValueProxyGetter*)_createMutableOrderedSetValueGetterWithContainerClassID:(Class)cls key:(NSString *)key;
+ (NSKeyValueProxyGetter*)_createMutableSetValueGetterWithContainerClassID:(Class)cls key:(NSString *)key;
+ (NSKeyValueSetter*)_createValueSetterWithContainerClassID:(Class)cls key:(NSString *)key;
+ (NSKeyValueGetter*)_createValueGetterWithContainerClassID:(Class)cls key:(NSString *)key;

@end

typedef enum {
    NSKVCNoOperatorType = 0,
    NSCountKeyValueOperatorType = 1, // "@count", "@max", etc
    NSMaximumKeyValueOperatorType,
    NSMinimumKeyValueOperatorType,
    NSAverageKeyValueOperatorType,
    NSSumKeyValueOperatorType,
    NSDistinctUnionOfObjectsKeyValueOperatorType,
    NSUnionOfObjectsKeyValueOperatorType,
    NSDistinctUnionOfArraysKeyValueOperatorType,
    NSUnionOfArraysKeyValueOperatorType,
    NSDistinctUnionOfSetsKeyValueOperatorType,
    NSUnionOfSetsKeyValueOperatorType,
} __NSKVCOperatorType;

typedef struct {
    NSString *key;
    NSString *remainderPath;
} __NSKeyPathComponents;

const void *NSKVOSetterRetain(CFAllocatorRef allocator, const void *value);
void NSKVOSetterRelease(CFAllocatorRef allocator, const void *value);
Boolean NSKVOSetterEqual(const void *value1, const void *value2);
CFHashCode NSKVOSetterHash(const void *value);
void _NSSetUsingKeyValueSetter(id obj, NSKeyValueSetter *setter, id value);
id _NSGetUsingKeyValueGetter(id obj, NSKeyValueGetter *getter);
id __NSMinOrMaxForKeyPath(id keyPath, NSComparisonResult order, NSEnumerator *enumerator);
id __NSSumForKeyPath(id keyPath, NSUInteger *countPtr, NSEnumerator *enumerator);
const NSString *__NSKVCKeyFromOperatorType(__NSKVCOperatorType op);
__NSKVCOperatorType __NSKVCOperatorTypeFromKey(const NSString *key);
__NSKeyPathComponents __NSGetComponentsFromKeyPath(NSString *key);
