#import <Foundation/NSObject.h>
#import <Foundation/NSDate.h>

BLOCK_EXPORT void * _NSConcreteMallocBlock[32];
BLOCK_EXPORT void * _NSConcreteAutoBlock[32];
BLOCK_EXPORT void * _NSConcreteFinalizingBlock[32];
BLOCK_EXPORT void * _NSConcreteWeakBlockVariable[32];
BLOCK_EXPORT void * _NSConcreteGlobalBlock[32];
BLOCK_EXPORT void * _NSConcreteStackBlock[32];

extern bool _Block_tryRetain(const void *aBlock);
extern bool _Block_isDeallocating(const void *aBlock);

@interface NSBlock : NSObject

- (void)performAfterDelay:(NSTimeInterval)delay;
- (void)invoke;
- (id)copyWithZone:(NSZone *)zone;
- (id)copy;

@end

@interface __NSStackBlock : NSBlock

- (id)autorelease;
- (NSUInteger)retainCount;
- (oneway void)release;
- (id)retain;

@end

@interface __NSMallocBlock : NSBlock

- (BOOL)_isDeallocating;
- (BOOL)_tryRetain;
- (unsigned int)retainCount;
- (oneway void)release;
- (id)retain;

@end

@interface __NSAutoBlock : NSBlock

- (id)copyWithZone:(NSZone *)zone;
- (id)copy;

@end

@interface __NSFinalizingBlock : __NSAutoBlock

- (void)finalize;

@end

@interface __NSGlobalBlock : NSBlock

- (BOOL)_isDeallocating;
- (BOOL)_tryRetain;
- (NSUInteger)retainCount;
- (id)retain;
- (oneway void)release;
- (id)copyWithZone:(NSZone *)zone;
- (id)copy;

@end

struct Block_byref {
    void *_field1;
    struct Block_byref *_field2;
    int _field3;
    unsigned int _field4;
    void *_field5;
    void *_field6;
};

@interface __NSBlockVariable : NSObject {
    struct Block_byref *forwarding;
    int flags;
    int size;
    void *byref_keep;
    void *byref_destroy;
    id containedObject;
}

@end
