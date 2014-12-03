//
//  _DebugUtils.m
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//
// These provide some debug utils for use with GDB.
// - debug_dumpObject(obj) -> returns a string with all the methods and properties
// - dumpObjectMatching(obj, 'foobar') -> same as above, but only returns the methods/properties that match the given filter (wildcard based)

#ifndef NDEBUG
#import <objc/runtime.h>
#import <Foundation/Foundation.h>

__attribute__ ((visibility ("hidden")))
NSString* debug_dumpObjectMatching(id obj, char* filter);
__attribute__ ((visibility ("hidden")))
NSString*  debug_dumpObject(id obj);

static void dumpProperties(Class kls, NSMutableString* result) {
    unsigned int count;
    objc_property_t* all_properties = class_copyPropertyList(kls, &count);
    for (int i = 0; i < count; i++) {
        objc_property_t property = all_properties[i];
        const char* name = property_getName(property);
        char* type = property_copyAttributeValue(property, "T");
        [result appendFormat:@"T%s %s\n", type, name];
        free(type);
    }
    free(all_properties);
}


static void dumpMethodsInternal(Class kls, NSMutableString* result) {
    unsigned int count;
    Method* all_methods;
    
    char prefix = class_isMetaClass(kls) ? '+' : '-';
    // instance methods
    all_methods = class_copyMethodList(kls, &count);
    for (int i = 0; i < count; i++) {
        Method method = all_methods[i];
        const char* name = sel_getName(method_getName(method));
        
        [result appendFormat:@"%c%s\n", prefix, name];
    }
    free(all_methods);
}

static void dumpMethods(Class kls, NSMutableString* result) {
    dumpMethodsInternal(kls, result);
    
    if (!class_isMetaClass(kls)) {
        dumpMethodsInternal(object_getClass(kls), result);
    }
}

static  NSArray* getSuperClasses(id obj) {
    NSMutableArray* klasses = [NSMutableArray new];
    
    for (Class kls = object_getClass(obj); kls != Nil; kls = class_getSuperclass(kls))
    {
        [klasses addObject:kls];
    }
    
    return klasses;
}


__attribute__ ((visibility ("hidden")))
NSString*  debug_dumpObject(id obj) {
    NSMutableString* result = [NSMutableString new];
    NSArray* klasses = getSuperClasses(obj);
    
    for (Class kls in klasses) {
        dumpMethods(kls, result);
    }
    
    for (Class kls in klasses) {
        dumpProperties(kls, result);
    }
    
    
    return result;
}

// filter is matched
__attribute__ ((visibility ("hidden")))
NSString* debug_dumpObjectMatching(id obj, char* filter) {
    NSString* full_dump = debug_dumpObject(obj);
    NSMutableString* filtered_dump = [NSMutableString new];
    
    NSString* nsFilter = @(filter);
    for (NSString* line in [full_dump componentsSeparatedByString:@"\n"]) {
        NSRange range = [line rangeOfString:nsFilter options:NSCaseInsensitiveSearch];
        if (range.location != NSNotFound) {
            [filtered_dump appendFormat:@"%@\n", line];
        }
    }
    
    return filtered_dump;
}

#endif
