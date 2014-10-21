#import <Foundation/NSDictionary.h>

#import <Foundation/NSKeyValueObserving.h>

@class NSObject, NSIndexSet;

typedef struct
{
    NSKeyValueChange kind;
    NSObject *oldValue;
    NSObject *newValue;
    NSIndexSet *indexes;
    id extraData;
} NSKeyValueChangeDetails;

extern NSString * const NSKeyValueChangeKindKey;
extern NSString * const NSKeyValueChangeNewKey;
extern NSString * const NSKeyValueChangeOldKey;
extern NSString * const NSKeyValueChangeIndexesKey;
extern NSString * const NSKeyValueChangeOriginalObservableKey;
extern NSString * const NSKeyValueChangeNotificationIsPriorKey;


CF_PRIVATE
@interface NSKeyValueChangeDictionary : NSDictionary
{
    NSKeyValueChangeDetails _details;
    NSObject *_originalObservable;
    BOOL _isPriorNotification;
    BOOL _isRetainingObjects;
}

- (id)keyEnumerator;
- (id)objectForKey:(id)key;
- (NSUInteger)count;
- (void)dealloc;
- (void)retainObjects;
- (void)setOriginalObservable:(id)observable;
- (void)setDetailsNoCopy:(NSKeyValueChangeDetails)details originalObservable:(id)observable;
- (id)initWithDetailsNoCopy:(NSKeyValueChangeDetails)details originalObservable:(id)observable isPriorNotification:(BOOL)yn;

@end
