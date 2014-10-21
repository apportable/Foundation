#import <Foundation/NSArray.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSOrderedSet.h>
#import <Foundation/NSSet.h>

@class NSError, NSString;

FOUNDATION_EXPORT NSString *const NSUndefinedKeyException;
FOUNDATION_EXPORT NSString *const NSAverageKeyValueOperator;
FOUNDATION_EXPORT NSString *const NSCountKeyValueOperator;
FOUNDATION_EXPORT NSString *const NSDistinctUnionOfArraysKeyValueOperator;
FOUNDATION_EXPORT NSString *const NSDistinctUnionOfObjectsKeyValueOperator;
FOUNDATION_EXPORT NSString *const NSDistinctUnionOfSetsKeyValueOperator;
FOUNDATION_EXPORT NSString *const NSMaximumKeyValueOperator;
FOUNDATION_EXPORT NSString *const NSMinimumKeyValueOperator;
FOUNDATION_EXPORT NSString *const NSSumKeyValueOperator;
FOUNDATION_EXPORT NSString *const NSUnionOfArraysKeyValueOperator;
FOUNDATION_EXPORT NSString *const NSUnionOfObjectsKeyValueOperator;
FOUNDATION_EXPORT NSString *const NSUnionOfSetsKeyValueOperator;

@interface NSObject(NSKeyValueCoding)

+ (BOOL)accessInstanceVariablesDirectly;
- (id)valueForKey:(id)key;
- (void)setValue:(id)value forKey:(NSString *)key;
- (BOOL)validateValue:(inout id *)ioValue forKey:(NSString *)inKey error:(out NSError **)outError;
- (NSMutableArray *)mutableArrayValueForKey:(NSString *)key;
- (NSMutableOrderedSet *)mutableOrderedSetValueForKey:(NSString *)key NS_AVAILABLE(10_7, 5_0);
- (NSMutableSet *)mutableSetValueForKey:(NSString *)key;
- (id)valueForKeyPath:(id)key;
- (void)setValue:(id)value forKeyPath:(NSString *)keyPath;
- (BOOL)validateValue:(inout id *)ioValue forKeyPath:(NSString *)inKeyPath error:(out NSError **)outError;
- (NSMutableArray *)mutableArrayValueForKeyPath:(NSString *)keyPath;
- (NSMutableOrderedSet *)mutableOrderedSetValueForKeyPath:(NSString *)keyPath NS_AVAILABLE(10_7, 5_0);
- (NSMutableSet *)mutableSetValueForKeyPath:(NSString *)keyPath;
- (id)valueForUndefinedKey:(NSString *)key;
- (void)setValue:(id)value forUndefinedKey:(NSString *)key;
- (void)setNilValueForKey:(NSString *)key;
- (NSDictionary *)dictionaryWithValuesForKeys:(NSArray *)keys;
- (void)setValuesForKeysWithDictionary:(NSDictionary *)keyedValues;

@end

@interface NSArray(NSKeyValueCoding)

- (id)valueForKey:(id)key;
- (id)valueForKeyPath:(id)keyPath;
- (void)setValue:(id)value forKey:(id)key;

@end

@interface NSDictionary(NSKeyValueCoding)

- (id)valueForKey:(id)key;
- (id)valueForKeyPath:(id)keyPath;

@end

@interface NSMutableDictionary(NSKeyValueCoding)

- (void)setValue:(id)value forKey:(id)key;

@end

@interface NSOrderedSet(NSKeyValueCoding)

- (id)valueForKeyPath:(id)keyPath;
- (id)valueForKey:(id)key;
- (void)setValue:(id)value forKey:(id)key;

@end

@interface NSSet(NSKeyValueCoding)

- (id)valueForKeyPath:(id)keyPath;
- (id)valueForKey:(id)key;
- (void)setValue:(id)value forKey:(id)key;

@end
