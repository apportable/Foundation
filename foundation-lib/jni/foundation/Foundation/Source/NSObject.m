#import "Foundation/NSObject.h"
#import "Foundation/NSString.h"
#import "Foundation/NSMethodSignature.h"
#import "Foundation/NSInvocation.h"

@implementation NSObject (Foundation)

+ (NSMethodSignature *)instanceMethodSignatureForSelector:(SEL)sel
{
    if (sel == NULL)
    {
        return nil;
    }
    Method m = class_getInstanceMethod(self, sel);
    if (m == NULL)
    {
        return nil;
    }
    return [NSMethodSignature signatureWithObjCTypes:method_getTypeEncoding(m)];
}

+ (NSMethodSignature *)methodSignatureForSelector:(SEL)sel
{
    if (sel == NULL)
    {
        return nil;
    }
    Method m = class_getClassMethod(self, sel);
    if (m == NULL)
    {
        return nil;
    }
    return [NSMethodSignature signatureWithObjCTypes:method_getTypeEncoding(m)];
}


- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel
{
    if (sel == NULL)
    {
        return nil;
    }
    Method m = class_getInstanceMethod(object_getClass(self), sel);
    if (m == NULL)
    {
        return nil;
    }
    return [NSMethodSignature signatureWithObjCTypes:method_getTypeEncoding(m)];
}

+ (NSString *)debugDescription {
    return [self description];
}

+ (NSString *)description
{
    return [NSString stringWithUTF8String:class_getName(self)];
}

- (NSString *)debugDescription {
    return [self description];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%s:%p>", object_getClassName(self), self];
}

- (NSString *)className {
    return NSStringFromClass([self class]);
}

@end

@implementation NSObject (NSCoderMethods)

- (id)initWithCoder:(NSCoder *)coder
{
    return self;
}

+ (NSInteger)version
{
    return class_getVersion(self);
}

+ (void)setVersion:(NSInteger)aVersion
{
    class_setVersion(self, aVersion);
}

- (Class)classForArchiver {
    return [self classForCoder];
}

- (Class)classForCoder
{
    return [self class];
}

- (id)replacementObjectForArchiver:(NSArchiver *)anArchiver {
    return [self replacementObjectForCoder:anArchiver];
}

- (id)replacementObjectForCoder:(NSCoder *)aCoder
{
    return self;
}

- (id)awakeAfterUsingCoder:(NSCoder *)aDecoder
{
    return self;
}

- (void)forwardInvocation:(NSInvocation *)inv
{
    [inv invoke];
}

@end
