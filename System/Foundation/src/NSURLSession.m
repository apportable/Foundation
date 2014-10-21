//
//  NSURLSession.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "NSURLSession.h"
#import 
const int64_t NSURLSessionTransferSizeUnknown = -1LL;

@implementation NSURLSession

+ (void)initialize
{
    static dispatch_once_t once = 0L;
    dispatch_once(&once, ^{
        Class cls = objc_lookupClass("__NSCFURLSession");
        assert(cls != Nil);
        class_setSuperclass(self, cls);
    });
}

@end
