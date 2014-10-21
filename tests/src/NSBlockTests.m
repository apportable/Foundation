//
//  NSBlockTests.m
//  FoundationTests
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "FoundationTests.h"

@testcase(NSBlock)

test(GlobalBlock)
{
    NSString *desc = [^{

    } description];
    testassert(desc != nil);

    return YES;
}

test(BlockCopy)
{
    id block = [^{

    } copy];
    testassert(block != nil);

    return YES;
}

test(BlockRelease)
{
    void (^block)() = Block_copy(^{

    });
    [block release];

    return YES;
}

test(BlockInvoke)
{
    __block BOOL invoked = NO;
    [^{
        invoked = YES;
    } invoke];
    testassert(invoked);

    return YES;
}

test(BlockNSInvocation)
{
    __block BOOL invoked = NO;
    void (^block)(char ch) = ^(char c){
        invoked = c == 'B';
    };
    char t = 'B';
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[(id)block methodSignatureForSelector:@selector(invoke)]];
    [inv setTarget:block];
    [inv setSelector:@selector(invoke)];
    [inv setArgument:&t atIndex:1];
    [inv invoke];
    testassert(invoked);
    return YES;
}

@end
