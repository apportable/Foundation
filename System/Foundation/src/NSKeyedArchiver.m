//
//  NSKeyedArchiver.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/NSKeyedArchiver.h>
#import "NSArchiver.h"
#import <Foundation/NSArray.h>

#import "NSCoderInternal.h"
#import <Foundation/NSDictionary.h>
#import <Foundation/NSFileManager.h>
#import <Foundation/NSException.h>
#import <Foundation/NSNull.h>
#import <Foundation/NSSet.h>
#import <Foundation/NSURL.h>
#import "NSTemporaryDirectory.h"
#import "NSObjectInternal.h"
#import <CoreFoundation/CFDictionary.h>
#import <CoreFoundation/CFNumber.h>
#import "ForFoundationOnly.h"
#import <dispatch/dispatch.h>
#import <objc/runtime.h>
#import <stdlib.h>

NSString *const NSInvalidArchiveOperationException = @"NSInvalidArchiveOperationException";

@implementation NSObject (NSKeyedArchiverObjectSubstitution)

+ (id)classFallbacksForKeyedArchiver
{
    return nil;
}

- (id)replacementObjectForKeyedArchiver:(NSKeyedArchiver *)archiver
{
    return [self replacementObjectForCoder:archiver];
}

- (Class)classForKeyedArchiver
{
    return [self classForArchiver];
}

@end

@implementation NSObject (NSKeyedUnarchiverObjectSubstitution)

+ (Class)classForKeyedUnarchiver
{
    return self;
}

@end

static dispatch_once_t archiverClassesOnce = 0L;
static NSMutableDictionary *archiverClasses = nil;

@implementation NSKeyedArchiver {
    CFTypeRef _stream;
    unsigned int _flags;
    id<NSKeyedArchiverDelegate> _delegate;
    NSMutableArray *_containers;
    NSMutableArray *_objects;
    CFMutableDictionaryRef _objRefMap;
    CFMutableDictionaryRef _replacementMap;
    id _classNameMap;
    CFMutableDictionaryRef _conditionals;
    id _classes;
    NSUInteger _genericKey;
    CFKeyedArchiverUIDRef *_cache;
    unsigned int _cacheSize;
    unsigned int _estimatedCount;
    CFMutableSetRef _visited;
}

static NSString *escapeKey(NSString *key)
{
    if (key == nil)
    {
        return nil;
    }

    if ([key length] == 0)
    {
        return key;
    }

    if ([key characterAtIndex:0] == '$')
    {
        return [@"$" stringByAppendingString:key];
    }

    return key;
}

static NSString *freshGenericKey(NSKeyedArchiver *archiver)
{
    NSUInteger key = archiver->_genericKey++;
    return [NSString stringWithFormat:@"$%d", key];
}

static BOOL raiseIfFinished(NSKeyedArchiver *archiver)
{
    if ((archiver->_flags & NSArchiverFinished) != 0)
    {
        [NSException raise:NSInvalidArchiveOperationException format:@"Tried to encode after archiver has completed"];
        return YES;
    }
    return NO;
}

static void encodeFinalValue(NSKeyedArchiver *archiver, id value, NSString *key)
{
    if (value == nil)
    {
        return;
    }

    NSUInteger containersCount = [archiver->_containers count];
    id container = [archiver->_containers objectAtIndex:containersCount - 1];

    if (key == nil || (archiver->_flags & NSKeyedArchiverKeyFlag) != 0)
    {
        [container addObject:value];
    }
    else
    {
        if ([container objectForKey:key])
        {
            RELEASE_LOG("NSKeyedArchiver warning: replacing existing value for key '%s'. Likely duplication of encoding keys", [key UTF8String]);
        }
        [container setObject:value forKey:key];
    }
}

static CFKeyedArchiverUIDRef _NSKeyedArchiverUIDCreateCached(NSKeyedArchiver *archiver, NSUInteger index)
{
    if (archiver->_cacheSize == 0)
    {
        archiver->_cacheSize = 0x100;
        archiver->_cache = (CFKeyedArchiverUIDRef *)calloc(archiver->_cacheSize, sizeof(CFKeyedArchiverUIDRef));
    }
    if (index >= archiver->_cacheSize)
    {
        size_t newSize = index * 4 * sizeof(CFKeyedArchiverUIDRef);
        archiver->_cache = (CFKeyedArchiverUIDRef *)realloc(archiver->_cache, newSize);
        memset(&archiver->_cache[archiver->_cacheSize], 0, newSize - archiver->_cacheSize * sizeof(CFKeyedArchiverUIDRef));
        archiver->_cacheSize = index * 4;
    }

    CFKeyedArchiverUIDRef val = archiver->_cache[index];
    if (val == NULL)
    {
        val = archiver->_cache[index] = _CFKeyedArchiverUIDCreate(NULL, index);
    }
    return CFRetain(val);
#warning TODO find CFRelease point for UID cache
}


static void _encodeObject(NSKeyedArchiver *archiver, id object, NSString *key)
{
    BOOL visited = NO;
    if (archiver->_visited != nil && CFSetContainsValue((CFSetRef)archiver->_visited, object))
    {
        visited = YES;
    }

    if (archiver->_replacementMap != nil && CFDictionaryContainsKey((CFDictionaryRef)archiver->_replacementMap, object))
    {
        // TODO
    }

    id old = [object replacementObjectForKeyedArchiver:archiver];
    if (old)
    {
        [archiver replaceObject:old withObject:object];
    }
    Class class = [object classForKeyedArchiver];
    if ([archiver requiresSecureCoding])
    {
        // TODO secureCoding
        DEBUG_BREAK();
    }
    int end = CFArrayGetCount((CFArrayRef)archiver->_objects);
    if (object == nil)
    {
        CFKeyedArchiverUIDRef cka = _NSKeyedArchiverUIDCreateCached(archiver, 0);
        encodeFinalValue(archiver, (id)cka, key);
        CFRelease(cka);
    }
    else
    {
        id mapObject;
        int uidIndex;
        if (CFDictionaryGetValueIfPresent(archiver->_objRefMap, object, (const void **)&mapObject))
        {
            // This object has already been encoded
            uidIndex = (int)mapObject;
        }
        else
        {
            if (CFDictionaryGetValueIfPresent(archiver->_conditionals, object, (const void **)&mapObject))
            {
                // TODO
            }
            CFArrayAppendValue((CFMutableArrayRef)archiver->_objects, @"$null"); // placeholder
            CFDictionarySetValue(archiver->_objRefMap, object, (const void *)end);
            uidIndex = end;
        }
        CFKeyedArchiverUIDRef cka = _NSKeyedArchiverUIDCreateCached(archiver, uidIndex);
        encodeFinalValue(archiver, (id)cka, key);
        CFRelease(cka);

        if (visited)
        {
            return;
        }

        //if ([archiver classNameForClass:class] == nil && [NSKeyedArchiver classNameForClass:class])
        //{
            // TODO
        //}
        if ([object isNSString__])
        {
            if ([object length] == 5)
            {
                // TODO - handle @"$null" -- _genericKey and fall through to main object code?
            }
            CFArraySetValueAtIndex((CFMutableArrayRef)archiver->_objects, end, object);
            if (archiver->_delegate)
            {
                // TODO
            }

        }
        else if ([object isNSNumber__] || [object isNSData__])
        {
            CFArraySetValueAtIndex((CFMutableArrayRef)archiver->_objects, end, object);
            if (archiver->_delegate)
            {
                // TODO
            }
        }
        else
        {
            NSMutableDictionary *dict = [NSMutableDictionary new];
            [archiver->_containers addObject:dict];
            [dict release];
            NSUInteger count = CFArrayGetCount((CFArrayRef)archiver->_containers);
            [object encodeWithCoder:archiver];

            BOOL inContainer = NO;
            if (CFDictionaryGetValueIfPresent(archiver->_objRefMap, class, (const void **)&mapObject))
            {
                // This class has already been encoded
                uidIndex = (int)mapObject;
                inContainer = YES;
            } 
            else
            {
                if (CFDictionaryGetValueIfPresent(archiver->_conditionals, object, (const void **)&mapObject))
                {
                    // TODO
                }
                CFArrayAppendValue((CFMutableArrayRef)archiver->_objects, @"$null"); // Another placeholder $null
                uidIndex = CFArrayGetCount((CFArrayRef)archiver->_objects) - 1;
                CFDictionarySetValue(archiver->_objRefMap, class, (const void *)uidIndex);
            }
            cka = _NSKeyedArchiverUIDCreateCached(archiver, uidIndex);
            encodeFinalValue(archiver, (id)cka, @"$class");
            CFRelease(cka);

            if (!inContainer)
            {
                dict = [NSMutableDictionary new];
                [archiver->_containers addObject:dict];
                [dict release];

                encodeFinalValue(archiver, NSStringFromClass(class), @"$classname");

                NSMutableArray *classes = [NSMutableArray new];
                do
                {
                    CFArrayAppendValue((CFMutableArrayRef)classes, NSStringFromClass(class));
                    class = [class superclass];
                } 
                while (class != nil);

                encodeFinalValue(archiver, classes, @"$classes");
                [classes release];
            }
            if ([NSObject classFallbacksForKeyedArchiver])
            {
                // TODO
            }
            int index = CFArrayGetCount((CFArrayRef)archiver->_containers);
            int objectsIndex = CFArrayGetCount((CFArrayRef)archiver->_objects) - 1;
            while (index-- >= count)
            {
                const void *val = CFArrayGetValueAtIndex((CFArrayRef)archiver->_containers, index);
                for (;;)
                {
                    id obj = CFArrayGetValueAtIndex((CFArrayRef)archiver->_objects, objectsIndex);
                    if ([obj isNSString__] && [obj isEqualToString:@"$null"])
                    {
                        break;
                    }
                    objectsIndex--;
                    if (objectsIndex <= 0) DEBUG_BREAK();  // Should never happen
                }
                CFArraySetValueAtIndex((CFMutableArrayRef)archiver->_objects, objectsIndex, val);
                [archiver->_containers removeObjectAtIndex:index];
            }
        }
    }
}

static void encodeConditionalObject(NSKeyedArchiver *archiver, id object, NSString *key)
{
#warning TODO
    DEBUG_BREAK();
}

static void encodeBytes(NSKeyedArchiver *archiver, const uint8_t *buffer, NSUInteger len, NSString *key)
{
    if (buffer == NULL)
    {
        encodeFinalValue(archiver, @"$null", key);
    }
    else
    {
        CFDataRef data = CFDataCreate(NULL, buffer, len);
        encodeFinalValue(archiver, (id)data, key);
        CFRelease(data);
    }
}

static void encodeInt32(NSKeyedArchiver *archiver, int32_t i, NSString *key)
{
    NSNumber *number = (NSNumber *)CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &i);
    encodeFinalValue(archiver, number, key);
    [number release];
}

static void encodeInt64(NSKeyedArchiver *archiver, int64_t i, NSString *key)
{
    NSNumber *number = (NSNumber *)CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt64Type, &i);
    encodeFinalValue(archiver, number, key);
    [number release];
}

static void encodeInt(NSKeyedArchiver *archiver, int i, NSString *key)
{
    NSNumber *number = (NSNumber *)CFNumberCreate(kCFAllocatorDefault, kCFNumberIntType, &i);
    encodeFinalValue(archiver, number, key);
    [number release];
}

static void encodeLong(NSKeyedArchiver *archiver, long l, NSString *key)
{
    NSNumber *number = (NSNumber *)CFNumberCreate(kCFAllocatorDefault, kCFNumberLongType, &l);
    encodeFinalValue(archiver, number, key);
    [number release];
}

static void encodeLongLong(NSKeyedArchiver *archiver, long long ll, NSString *key)
{
    NSNumber *number = (NSNumber *)CFNumberCreate(kCFAllocatorDefault, kCFNumberLongLongType, &ll);
    encodeFinalValue(archiver, number, key);
    [number release];
}

static void encodeBool(NSKeyedArchiver *archiver, BOOL b, NSString *key)
{
    CFBooleanRef boolean = b ? kCFBooleanTrue : kCFBooleanFalse;
    encodeFinalValue(archiver, (id) boolean, key);
}

static void encodeFloat(NSKeyedArchiver *archiver, float f, NSString *key)
{
    NSNumber *number = (NSNumber *)CFNumberCreate(kCFAllocatorDefault, kCFNumberFloatType, &f);
    encodeFinalValue(archiver, number, key);
    [number release];
}

static void encodeDouble(NSKeyedArchiver *archiver, double d, NSString *key)
{
    NSNumber *number = (NSNumber *)CFNumberCreate(kCFAllocatorDefault, kCFNumberDoubleType, &d);
    encodeFinalValue(archiver, number, key);
    [number release];
}

+ (void)initialize
{
#warning TODO -- https://code.google.com/p/apportable/issues/detail?id=528
    // [NSKeyedArchiver setClassName:@"NSLocalTimeZone" forClass:NSClassFromString(@"__NSLocalTimeZone")];
}

+ (NSString *)classNameForClass:(Class)cls
{
    dispatch_once(&archiverClassesOnce, ^{
            archiverClasses = [[NSMutableDictionary alloc] init];
        });
    return [archiverClasses objectForKey:cls];
}

+ (void)setClassName:(NSString *)codedName forClass:(Class)cls
{
    dispatch_once(&archiverClassesOnce, ^{
        archiverClasses = [[NSMutableDictionary alloc] init];
    });
    [archiverClasses setObject:codedName forKey:(id<NSCopying>)cls];
}

+ (BOOL)archiveRootObject:(id)rootObject toFile:(NSString *)path
{
    BOOL success = NO;
    @autoreleasepool {
        NSString *tempPath = nil;
        NSString *tempDir = nil;
        if (_NSTempFileCreate(path, &tempPath, &tempDir, NULL))
        {
            NSURL *url = [NSURL fileURLWithPath:tempPath isDirectory:NO];
            CFWriteStreamRef writeStream = CFWriteStreamCreateWithFile(kCFAllocatorDefault, (CFURLRef)url);
            if (CFWriteStreamOpen(writeStream))
            {
                NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] _initWithOutput:(NSOutputStream *)writeStream];
                [archiver encodeObject:rootObject forKey:@"root"];
                [archiver finishEncoding];
                CFWriteStreamClose(writeStream);
                [archiver release];
            }
            success = _NSTempFileSwap(tempPath, path);
            _NSTempCleanup(tempDir);
            CFRelease(writeStream);
        }
    }
    return success;
}

+ (NSData *)archivedDataWithRootObject:(id)rootObject
{
    NSMutableData *data = [[NSMutableData alloc] initWithLength:0];
    @autoreleasepool {
        NSKeyedArchiver *archiver = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
        [archiver encodeObject:rootObject forKey:@"root"];
        [archiver finishEncoding];
    }
    return [data autorelease];
}

- (id)initForWritingWithMutableData:(NSMutableData *)data
{
    return [self _initWithOutput:(CFTypeRef)data];
}

static const void *_retain(CFAllocatorRef allocator, const void *value)
{
    return CFRetain(value);
}

static void _release(CFAllocatorRef allocator, const void *value)
{
    CFRelease(value);
}

- (id)_initWithOutput:(CFTypeRef)output
{
    self = [super init];
    if (self)
    {
        // Output can be NSData or a stream. We check via CF calls
        // since it does not respond to isKindOfClass or isNSData__.
        _stream = CFRetain(output);

        _flags = NSPropertyListBinaryFormat_v1_0 << 16;

        _objects = [NSMutableArray new];
        _CFArraySetCapacity((CFMutableArrayRef)_objects, 0x400);
        CFArrayAppendValue((CFMutableArrayRef)_objects, @"$null");

        CFDictionaryKeyCallBacks callbacks = {
            0,
            &_retain,
            &_release,
            NULL,
            NULL,
            NULL
        };
        _objRefMap = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &callbacks, NULL);
        _conditionals = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &callbacks, NULL);

        _containers = [NSMutableArray new];
        NSMutableDictionary *dict = [NSMutableDictionary new];
        [_containers addObject:dict];
        [dict release];
    }
    return self;
}

- (id)init
{
    [NSException raise:NSInvalidArgumentException format:@"Cannot use -init on %@", [self class]];
    [self release];
    return nil;
}

- (void)dealloc
{
    CFRelease(_stream);
    [_containers release];
    [_objects release];
    CFRelease(_objRefMap);
    CFRelease(_conditionals);
    if (_visited != nil)
    {
        CFRelease(_visited);
    }
    if (_cache != NULL)
    {
        free(_cache);
    }

    [super dealloc];
}

- (void)setRequiresSecureCoding:(BOOL)secured
{
    if (secured)
    {
        _flags |= NSSecureCodingFlag;
    }
    else
    {
        _flags &= ~NSSecureCodingFlag;
    }
}

- (BOOL)requiresSecureCoding
{
    return (_flags & NSSecureCodingFlag) != 0;
}

- (unsigned)systemVersion
{
    return NSKeyedArchiverSystemVersion;
}

- (NSInteger)versionForClassName:(NSString *)className
{
    Class c = NSClassFromString(className);

    if (c != nil)
    {
        return [c version];
    }
    else
    {
        return NSNotFound;
    }
}

- (void)encodeArrayOfObjCType:(const char *)type count:(NSUInteger)count at:(const void *)array
{
    if (raiseIfFinished(self))
    {
        return;
    }
    if (type == NULL)
    {
        [NSException raise:NSInvalidArgumentException format:@"NULL type"];
        return;
    }
    if (array == NULL)
    {
        [NSException raise:NSInvalidArgumentException format:@"NULL array"];
        return;
    }
    if (count == 0)
    {
        [NSException raise:NSInvalidArgumentException format:@"Zero count"];
        return;
    }

    switch (*type)
    {
        case _C_STRUCT_B:
        case _C_UNION_B:
        case _C_ARY_B:
            [NSException raise:NSInvalidArgumentException format:@"Unsupported type"];
            return;

        default:
        {
            _NSKeyedCoderOldStyleArray *coderArray = [[_NSKeyedCoderOldStyleArray alloc] initWithObjCType:*type count:count at:array];
            [self encodeObject:coderArray];
            [coderArray release];
            break;
        }
    }
}

static size_t _encodeValueOfObjCType(NSKeyedArchiver *self, const char *type, const void *addr)
{
    switch (*type)
    {
        case _C_CLASS:
        {
            Class c = *(Class *)addr;
            NSString *className = NSStringFromClass(c);
            _encodeObject(self, className, freshGenericKey(self));
            return sizeof(Class);
        }

        case _C_ID:
        {
            id object = *(id *)addr;
            _encodeObject(self, object, freshGenericKey(self));
            return sizeof(id);
        }

        case _C_SEL:
        {
            SEL selector = *(SEL *)addr;
            NSString *selectorName = NSStringFromSelector(selector);
            _encodeObject(self, selectorName, freshGenericKey(self));
            return sizeof(SEL);
        }

        case _C_CHARPTR:
        case _C_ATOM:
        {
            const char *cString = *(const char **)addr;
            NSString *string = [NSString stringWithUTF8String:cString];
            _encodeObject(self, string, freshGenericKey(self));
            return sizeof(char *);
        }

        case _C_CHR:
        case _C_UCHR:
        {
            char c = *(char *)addr;
            int i = c;
            encodeInt(self, i, freshGenericKey(self));
            return sizeof(char);
        }

        case _C_SHT:
        case _C_USHT:
        {
            short s = *(short *)addr;
            int i = s;
            encodeInt(self, i, freshGenericKey(self));
            return sizeof(short);
        }

        case _C_INT:
        case _C_UINT:
        {
            int i = *(int *)addr;
            encodeInt(self, i, freshGenericKey(self));
            return sizeof(int);
        }

        case _C_LNG:
        case _C_ULNG:
        {
            long l = *(long *)addr;
            encodeLong(self, l, freshGenericKey(self));
            return sizeof(long);
        }

        case _C_LNG_LNG:
        case _C_ULNG_LNG:
        {
            long long ll = *(long long *)addr;
            encodeLongLong(self, ll, freshGenericKey(self));
            return sizeof(long long);
        }

        case _C_FLT:
        {
            float f = *(float *)addr;
            encodeFloat(self, f, freshGenericKey(self));
            return sizeof(float);
        }

        case _C_DBL:
        {
            double d = *(double *)addr;
            encodeDouble(self, d, freshGenericKey(self));
            return sizeof(double);
        }

        case _C_ARY_B:
        {
            char *elementType = NULL;
            NSUInteger count = strtol(type + 1, &elementType, 10);
            if (*elementType == _C_ARY_E)
            {
                [NSException raise:NSInvalidArgumentException format:@"Malformed array type encoding"];
                return 0;
            }

            [self encodeArrayOfObjCType:elementType count:count at:addr];
            switch (*(type + 1))
            {
                case _C_CLASS:
                    return count * sizeof(Class);
                case _C_ID:
                    return count * sizeof(id);
                case _C_SEL:
                    return count * sizeof(SEL);
                case _C_CHARPTR:
                case _C_ATOM:
                    return count * sizeof(char *);
                case _C_CHR:
                case _C_UCHR:
                    return count * sizeof(char);
                case _C_SHT:
                case _C_USHT:
                    return count * sizeof(short);
                case _C_INT:
                case _C_UINT:
                    return count * sizeof(int);
                case _C_LNG:
                case _C_ULNG:
                    return count * sizeof(long);
                case _C_LNG_LNG:
                case _C_ULNG_LNG:
                    return count * sizeof(long long);
                case _C_FLT:
                    return count * sizeof(float);
                case _C_DBL:
                    return count * sizeof(double);
            }
            // exception should have already been raised to get here...
            return 0;
        }

        case _C_STRUCT_B:
        {
            type++;
            size_t sz = 0;
            char *struct_addr = (char *)addr;
            while (*type != _C_STRUCT_E && *type != '=')
            {
                type++;
            }
            type++;
            while (*type != _C_STRUCT_E)
            {
                size_t s = _encodeValueOfObjCType(self, type, (const void *)struct_addr);
                struct_addr += s;
                sz += s;
                type++;
            }
            return sz;
        }
        case _C_UNION_B:
        default:
        {
            [NSException raise:NSInvalidArgumentException format:@"Unsupported type: %c", *type];
            return 0;
        }
    }
}

- (void)encodeValueOfObjCType:(const char *)type at:(const void *)addr
{
    if (raiseIfFinished(self))
    {
        return;
    }
    if (type == NULL)
    {
        [NSException raise:NSInvalidArgumentException format:@"NULL type"];
        return;
    }
    if (addr == NULL)
    {
        [NSException raise:NSInvalidArgumentException format:@"NULL address"];
        return;
    }

    _encodeValueOfObjCType(self, type, addr);
}

- (void)encodeValuesOfObjCTypes:(const char *)types, ...
{
    va_list addrs;
    va_start(addrs, types);

    while (*types)
    {
        const void *addr = va_arg(addrs, const void *);
        [self encodeValueOfObjCType:types at:addr];
        // Note that this method only supports primitive types, so we
        // can simply increment the pointer, as all allowed types have
        // one character encodings.
        types++;
    }

    va_end(addrs);
}

- (void)encodeBytes:(const void *)addr length:(NSUInteger)len
{
    if (raiseIfFinished(self))
    {
        return;
    }

    if (addr == NULL && len != 0)
    {
        [NSException raise:NSInvalidArgumentException format:@"Tried to encode NULL address with nonzero length"];
        return;
    }

    encodeBytes(self, addr, len, freshGenericKey(self));
}

- (void)encodeDataObject:(NSData *)data
{
    [self encodeObject:data];
}

- (void)encodeRootObject:(id)root
{
    [self encodeObject:root];
}

- (void)encodeByrefObject:(id)obj
{
    [self encodeObject:obj];
}

- (void)encodeBycopyObject:(id)obj
{
    [self encodeObject:obj];
}

- (void)encodeConditionalObject:(id)object
{
    if (raiseIfFinished(self))
    {
        return;
    }

    encodeConditionalObject(self, object, freshGenericKey(self));
}

- (void)encodeObject:(id)obj
{
    if (raiseIfFinished(self))
    {
        return;
    }

    _encodeObject(self, obj, freshGenericKey(self));
}

- (void)_encodePropertyList:(id)plistObject forKey:(NSString *)key
{
    if (raiseIfFinished(self))
    {
        return;
    }

    encodeFinalValue(self, plistObject, escapeKey(key));
}

- (void)encodeBytes:(const uint8_t *)buffer length:(NSUInteger)len forKey:(NSString *)key
{
    if (raiseIfFinished(self))
    {
        return;
    }

    if (buffer == NULL && len != 0)
    {
        [NSException raise:NSInvalidArgumentException format:@"Tried to encode NULL buffer with nonzero length"];
        return;
    }

    encodeBytes(self, buffer, len, escapeKey(key));
}

- (void)encodeDouble:(double)realv forKey:(NSString *)key
{
    if (raiseIfFinished(self))
    {
        return;
    }

    encodeDouble(self, realv, escapeKey(key));
}

- (void)encodeFloat:(float)realv forKey:(NSString *)key
{
    if (raiseIfFinished(self))
    {
        return;
    }

    encodeFloat(self, realv, escapeKey(key));
}

- (void)encodeInt64:(int64_t)intv forKey:(NSString *)key
{
    if (raiseIfFinished(self))
    {
        return;
    }

    encodeInt64(self, intv, escapeKey(key));
}

- (void)encodeInt32:(int32_t)intv forKey:(NSString *)key
{
    if (raiseIfFinished(self))
    {
        return;
    }

    encodeInt32(self, intv, escapeKey(key));
}

- (void)encodeInt:(int)intv forKey:(NSString *)key
{
    if (raiseIfFinished(self))
    {
        return;
    }

    encodeInt(self, intv, escapeKey(key));
}

- (void)encodeBool:(BOOL)boolv forKey:(NSString *)key
{
    if (raiseIfFinished(self))
    {
        return;
    }

    encodeBool(self, boolv, escapeKey(key));
}

- (void)_encodeArrayOfObjects:(NSArray *)objects forKey:(NSString *)key
{
    if (raiseIfFinished(self))
    {
        return;
    }

    NSMutableArray *copyOfObjects = [NSMutableArray array];
    [_containers addObject:copyOfObjects];

    for (id object in objects)
    {
        _encodeObject(self, object, nil);
    }
    NSUInteger index = CFArrayGetCount((CFArrayRef)_containers);
    if (index > 0)
    {
        index--;
        id obj = CFArrayGetValueAtIndex((CFArrayRef)_containers, index);
        CFRetain(obj);
        [_containers removeObjectAtIndex:index];
        encodeFinalValue(self, obj, escapeKey(key));
        CFRelease(obj);
    }
}

- (void)encodeConditionalObject:(id)objv forKey:(NSString *)key
{
    if (raiseIfFinished(self))
    {
        return;
    }

    encodeConditionalObject(self, objv, escapeKey(key));
}

- (void)encodeObject:(id)objv forKey:(NSString *)key
{
    if (raiseIfFinished(self))
    {
        return;
    }

    _encodeObject(self, objv, escapeKey(key));
}

- (void)replaceObject:(id)object withObject:(id)replacement
{
    if (raiseIfFinished(self))
    {
        return;
    }

    if (_visited == nil)
    {
        _visited = CFSetCreateMutable(kCFAllocatorDefault, 0, NULL);
    }
    CFSetAddValue(_visited, object);

    if (object == replacement)
    {
        return;
    }

    if (_delegate != nil && [_delegate respondsToSelector:sel_registerName("archiver:willReplaceObject:WithObject:")])
    {
        [_delegate archiver:self willReplaceObject:object withObject:replacement];
    }

    id objectRef = [(NSMutableDictionary *)_objRefMap objectForKey:object];
    if (objectRef != nil)
    {
        [(NSMutableDictionary *)_objRefMap removeObjectForKey:object];
        [(NSMutableDictionary *)_objRefMap setObject:objectRef forKey:replacement];
    }

    [(NSMutableDictionary *)_objRefMap setObject:replacement forKey:object];
}

- (void)finishEncoding
{
    if ((_flags & NSArchiverFinished) != 0)
    {
        return;
    }

    _flags |= NSArchiverFinished;

    NSInteger value = NSKeyedArchiverPlistVersion;
    CFNumberRef version = CFNumberCreate(NULL, kCFNumberSInt32Type, &value);
    CFMutableDictionaryRef dictionary = CFDictionaryCreateMutable(NULL, 8, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    CFDictionarySetValue(dictionary, @"$archiver", (CFStringRef)NSStringFromClass([self class]));
    CFDictionarySetValue(dictionary, @"$version", version);
    CFDictionarySetValue(dictionary, @"$objects", _objects);
    CFDictionarySetValue(dictionary, @"$top", CFArrayGetValueAtIndex((CFArrayRef)_containers, 0));
    CFRelease(version);

    if ((_delegate != nil) && [_delegate respondsToSelector:@selector(archiverWillFinish:)])
    {
        [_delegate archiverWillFinish:self];
    }

    switch ([self outputFormat])
    {
        case NSPropertyListXMLFormat_v1_0:
        {
            CFDataRef encoding = _CFPropertyListCreateXMLDataWithExtras(NULL, dictionary);
            // TODO verify _stream is a CFData
            const uint8_t *bytePtr = CFDataGetBytePtr(encoding);
            NSUInteger len = CFDataGetLength(encoding);
            CFDataAppendBytes((CFMutableDataRef)_stream, bytePtr, len);
            break;
        }

        case NSPropertyListBinaryFormat_v1_0:
        {
            __CFBinaryPlistWriteToStream(dictionary, _stream); // or __CFBinaryPlistWriteToStreamWithOptions(dictionary, _stream, _estimatedCount, 0)
            break;
        }

        default:
        {
            [NSException raise:NSInternalInconsistencyException format:@"Invalid NSPropertyListFormat"];
            return;
        }
    }

    if ((_delegate != nil) && [_delegate respondsToSelector:@selector(archiverDidFinish:)])
    {
        [_delegate archiverDidFinish:self];
    }
    CFRelease(dictionary);
}

- (NSUInteger)getAndIncrementGenericKey
{
    return _genericKey++;
}

- (NSPropertyListFormat)outputFormat
{
    return _flags >> 16;
}

- (void)setOutputFormat:(NSPropertyListFormat)format
{
    switch (format)
    {
        case NSPropertyListXMLFormat_v1_0:
        case NSPropertyListBinaryFormat_v1_0:
        {
            unsigned int newFlags = _flags & 0xffff;
            newFlags |= format << 16;
            _flags = newFlags;
            break;
        }

        default:
        {
            [NSException raise:NSInvalidArgumentException format:@"Invalid NSPropertyListFormat"];
            return;
        }
    }
}

- (id <NSKeyedArchiverDelegate>)delegate
{
    return _delegate;
}

- (void)setDelegate:(id <NSKeyedArchiverDelegate>)delegate
{
    if (_delegate != delegate)
    {
        _delegate = delegate;
    }
}

- (BOOL)allowsKeyedCoding
{
    return YES;
}

- (NSString *)description
{
    return [super description];
}

- (id)_blobForCurrentObject
{
    NSUInteger currentIndex = [_containers count] - 1;
    return [_containers objectAtIndex:currentIndex];
}

- (void)_setBlobForCurrentObject:(id)blob
{
    NSUInteger currentIndex = [_containers count] - 1;
    [_containers removeObjectAtIndex:currentIndex];
    [_containers addObject:blob];
}

@end
