//
//  FoundationTestsActivity.m
//  FoundationTests
//
//  Created by Paul Beusterien on 10/1/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#include <jni.h>
#import <Foundation/Foundation.h>
#include <stdio.h>
#import "FoundationTests.h"

void Java_com_apportable_FoundationTests_FoundationTestsActivity_run( JNIEnv* env, jobject thiz )
{
    printf("hello from printf");
    NSLog(@"hello from NSLog");
    @autoreleasepool {
        runFoundationTests();
    }
}
