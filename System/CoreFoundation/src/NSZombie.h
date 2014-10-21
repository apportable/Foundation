#import <objc/runtime.h>
#import <Foundation/NSObjCRuntime.h>

#define ZOMBIE_PREFIX "_NSZombie_"

extern uint8_t __CFZombieEnabled;
extern uint8_t __CFDeallocateZombies;

NS_ROOT_CLASS
@interface _NSZombie_ {
    Class isa;
}

@end
