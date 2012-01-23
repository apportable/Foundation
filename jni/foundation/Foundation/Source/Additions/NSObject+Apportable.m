//
//  NSObject+Apportable.m
//  
//
//  Created by Philippe Hausler on 12/27/11.
//  Copyright (c) 2011 Apportable. All rights reserved.
//

#import "Apportable/NSObject+Apportable.h"
#import <pthread.h>

typedef struct {
    id target;
    SEL selector;
    id object;
    pthread_t thread;
} NSObjectBackground;

@implementation NSObject (Apportable)

static void *backgroundPerformer(void *context)
{
    GSRegisterCurrentThread();
    NSObjectBackground *background = (NSObjectBackground *)context;
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [background->target performSelector:background->selector withObject:background->object];
    [background->object release];
    [pool drain];
    free(context);
    return NULL;
}

- (void)performSelectorInBackground:(SEL)selector withObject:(id)object
{
    NSObjectBackground *background = calloc(1, sizeof(NSObjectBackground));
    background->target = self;
    background->selector = selector;
    background->object = [object retain];
    pthread_create(&background->thread, NULL, backgroundPerformer, background);
}
@end
