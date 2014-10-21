//
//  ___FILENAME___
//  ___PACKAGENAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//___COPYRIGHT___
//

#include <jni.h>
#import <Foundation/Foundation.h>
#include <stdio.h>

void Java_com_apportable____PACKAGENAME_______FILEBASENAME____run( JNIEnv* env, jobject thiz )
{
    printf("hello from printf");
    NSLog(@"hello from NSLog"); 
}
