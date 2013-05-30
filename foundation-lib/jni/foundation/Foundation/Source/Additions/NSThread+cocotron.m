/* Copyright (c) 2006-2007 Christopher J. W. Lloyd, 2008 Johannes Fortmann

   Permission is hereby granted, free of charge, to any person obtaining a copy
      of this software and associated documentation files (the "Software"), to
      deal in the Software without restriction, including without limitation the
      rights to use, copy, modify, merge, publish, distribute, sublicense,
      and/or sell copies of the Software, and to permit persons to whom the
      Software is furnished to do so, subject to the following conditions:

   The above copyright notice and this permission notice shall be included in
      all copies or substantial portions of the Software.

   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
      IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
      FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
      THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
      LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
      FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
      DEALINGS IN THE SOFTWARE. */

#import <Foundation/Foundation.h>
#import <cocotron/NSThread+cocotron.h>

NSThread *NSCurrentThread() {
    return [NSThread currentThread];
}

@interface NSThreadPrivate : NSObject {
    @public
    NSMutableDictionary *_sharedObjects;
    NSLock *_sharedObjectLock;
}
- init;
@end

@implementation NSThreadPrivate
- init
{
    _sharedObjects = [NSMutableDictionary new];
    _sharedObjectLock = [NSLock new];
    return self;
}
@end

@interface NSThread (NSThreadPrivate)
// @property(nonatomic, readonly) NSThreadPrivate *private;
@end

@implementation NSThread (NSThreadPrivate)
- (NSThreadPrivate*)private
{
    if (_unused) {
        return (NSThreadPrivate*)_unused;
    }
    _unused = (void*)[[NSThreadPrivate alloc] init];
    return (NSThreadPrivate*)_unused;
}
@end

static inline id _NSThreadSharedInstance(NSThread *thread,NSString *className,BOOL create) {
    NSMutableDictionary *shared = [thread private]->_sharedObjects;
    if(!shared) {
        return nil;
    }
    id result = nil;
    [[thread private]->_sharedObjectLock lock];
    result = [shared objectForKey:className];
    [[thread private]->_sharedObjectLock unlock];

    if(result == nil && create) {
        // do not hold lock during object allocation
        result = [NSClassFromString(className) new];
        [[thread private]->_sharedObjectLock lock];
        [shared setObject:result forKey:className];
        [[thread private]->_sharedObjectLock unlock];
        [result release];
    }

    return result;
}

id NSThreadSharedInstance(NSString *className) {
    return _NSThreadSharedInstance(NSCurrentThread(), className, YES);
}

id NSThreadSharedInstanceDoNotCreate(NSString *className) {
    return _NSThreadSharedInstance(NSCurrentThread(), className, NO);
}

@implementation NSThread (Cocotron)

- (NSMutableDictionary *)sharedDictionary {
    return [self private]->_sharedObjects;
}

- (id)sharedObjectForClassName:(NSString *)className {
    return _NSThreadSharedInstance(self, className, YES);
}

- (void)setSharedObject:(id)object forClassName:(NSString *)className {
    [[self private]->_sharedObjectLock lock];
    if(object == nil) {
        [[self private]->_sharedObjects removeObjectForKey:className];
    }
    else{
        [[self private]->_sharedObjects setObject:object forKey:className];
    }
    [[self private]->_sharedObjectLock unlock];
}

@end