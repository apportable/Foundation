//
//  NSGenericDeallocHandler.m
//  CoreFoundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "NSGenericDeallocHandler.h"
#import <objc/runtime.h>
#import <Block.h>

@implementation __NSGenericDeallocHandler

void _NSSetDeallocHandler(id object, void (^block)(void))
{
    static void *deallocHandlerKey = &deallocHandlerKey;
    __NSGenericDeallocHandler *handler = class_createInstance(objc_getClass("__NSGenericDeallocHandler"), 0);
    handler->_block = Block_copy(block);
    objc_setAssociatedObject(object, &deallocHandlerKey, handler, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (void)initialize
{

}

- (void)release
{
    if (_block != nil)
    {
        _block();
        Block_release(_block);
        object_dispose(self);
    }
    else
    {
        abort();
    }
}

- (NSUInteger)retainCount
{
    return 1;
}

- (id)retain
{
    return self;
}

@end
