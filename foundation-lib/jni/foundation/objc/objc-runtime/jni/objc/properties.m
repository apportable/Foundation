#include "objc/runtime.h"
#include "objc/objc-arc.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include "class.h"
#include "properties.h"
#include "spinlock.h"
#include "visibility.h"
#include "nsobject.h"
#include "gc_ops.h"
#include "lock.h"

extern const char *_objc_copyPropertyAttributeString(const objc_property_attribute_t *attrs, unsigned int count);
extern objc_property_attribute_t *_objc_copyPropertyAttributeList(const char *attrs, unsigned int *outCount);
extern char *_objc_copyPropertyAttributeValue(const char *attrs, const char *name);

PRIVATE int spinlocks[spinlock_count];

/**
 * Public function for getting a property.  
 */
id objc_getProperty(id obj, SEL _cmd, ptrdiff_t offset, BOOL isAtomic)
{
	if (nil == obj) { return nil; }
	char *addr = (char*)obj;
	addr += offset;
	if (isGCEnabled)
	{
		return *(id*)addr;
	}
	id ret;
	if (isAtomic)
	{
		volatile int *lock = lock_for_pointer(addr);
		lock_spinlock(lock);
		ret = *(id*)addr;
		ret = objc_retain(ret);
		unlock_spinlock(lock);
		ret = objc_autoreleaseReturnValue(ret);
	}
	else
	{
		ret = *(id*)addr;
		ret = objc_retainAutoreleaseReturnValue(ret);
	}
	return ret;
}

void objc_setProperty(id obj, SEL _cmd, ptrdiff_t offset, id arg, BOOL isAtomic, BOOL isCopy)
{
	if (nil == obj) { return; }
	char *addr = (char*)obj;
	addr += offset;

	if (isGCEnabled)
	{
		if (isCopy)
		{
			arg = [arg copy];
		}
		*(id*)addr = arg;
		return;
	}
	if (isCopy)
	{
		arg = [arg copy];
	}
	else
	{
		arg = objc_retain(arg);
	}
	id old;
	if (isAtomic)
	{
		volatile int *lock = lock_for_pointer(addr);
		lock_spinlock(lock);
		old = *(id*)addr;
		*(id*)addr = arg;
		unlock_spinlock(lock);
	}
	else
	{
		old = *(id*)addr;
		*(id*)addr = arg;
	}
	objc_release(old);
}

void objc_copyStruct(void *dest,
                             void *src,
                             ptrdiff_t size,
                             BOOL atomic,
                             BOOL strong)
{
	if (atomic)
	{
		volatile int *lock = lock_for_pointer(src);
		volatile int *lock2 = lock_for_pointer(dest);
		if (lock > lock2) {
			lock = lock2;
			lock2 = lock_for_pointer(src);
		}
		else if (lock == lock2){
			lock2 = NULL;
		}
		lock_spinlock(lock);
		if (lock2) lock_spinlock(lock2);
		memcpy(dest, src, size);
		unlock_spinlock(lock);
		if (lock2) unlock_spinlock(lock2);
	}
	else
	{
		memcpy(dest, src, size);
	}
}

objc_property_t class_getProperty(Class cls, const char *name)
{
	// Old ABI classes don't have declared properties
	if (Nil == cls || !objc_test_class_flag(cls, objc_class_flag_new_abi))
	{
		return NULL;
	}
	struct objc_property_list *properties = cls->properties;
	while (NULL != properties)
	{
		for (int i=0 ; i<properties->count ; i++)
		{
			objc_property_t p = &properties->properties[i];
			if (strcmp(p->name, name) == 0)
			{
				return p;
			}
		}
		properties = properties->next;
	}

	if(cls->super_class != NULL) {
		return class_getProperty(cls->super_class, name);
	}

	return NULL;
}

objc_property_t* class_copyPropertyList(Class cls, unsigned int *outCount)
{
	if (Nil == cls || !objc_test_class_flag(cls, objc_class_flag_new_abi))
	{
		if (NULL != outCount) { *outCount = 0; }
		return NULL;
	}
	struct objc_property_list *properties = cls->properties;
	unsigned int count = 0;
	for (struct objc_property_list *l=properties ; NULL!=l ; l=l->next)
	{
		count += l->count;
	}

	if (0 == count)
	{
		if (NULL != outCount)
		{
			*outCount = 0;
		}
		return NULL;
	}
	objc_property_t *list = calloc(count,sizeof(objc_property_t));
	unsigned int out = 0;
	for (struct objc_property_list *l=properties ; NULL!=l ; l=l->next)
	{
		for (int i=0 ; i<properties->count ; i++)
		{
			list[out] = &l->properties[i];
			out++;
		}
	}
	
	if (NULL != outCount)
	{
		*outCount = out;
	}

	return list;
}

const char *property_getName(objc_property_t property)
{
	if (NULL == property) { return NULL; }

	const char *name = property->name;
	if (name[0] == 0)
	{
		name += name[1];
	}
	return name;
}

PRIVATE size_t lengthOfTypeEncoding(const char *types);

const char *property_getAttributes(objc_property_t property)
{
	if (!property) { return NULL; }
	return property->attributes;
}

objc_property_attribute_t *property_copyAttributeList(objc_property_t property,
                                                      unsigned int *outCount)
{
	if (property == NULL || property->attributes == NULL) {
		if (outCount)
			*outCount = 0;
		return NULL;
	}

	LOCK_RUNTIME_FOR_SCOPE();
	objc_property_attribute_t *result;
	result = _objc_copyPropertyAttributeList(property->attributes, outCount);
	return result;
}

BOOL _class_addProperty(Class cls,
                       const char *name,
                       const objc_property_attribute_t *attributes,
                       unsigned int attributeCount,
                       BOOL replace) {
	if (cls == Nil || name == NULL) {
		return NO;
	}

	objc_property_t old = class_getProperty(cls, name);
	if (old && !replace) {
		return NO;
	}
	else if (old) { // replacing
		LOCK_RUNTIME_FOR_SCOPE();

		//Apple cheats by checking malloc_size to see if the string was malloced or if it mapped. This is the best we can do.a
		if (malloc_usable_size((char *)old->attributes) != 0)
		{
			free((char *)old->attributes);
		}
		old->attributes = _objc_copyPropertyAttributeString(attributes, attributeCount);
		return YES;
	}
	else { //new
		LOCK_RUNTIME_FOR_SCOPE();
		struct objc_property_list *l = calloc(1,sizeof(struct objc_property_list)
			+ sizeof(struct objc_property));
		l->count = 1;
		l->properties[0].name = strdup(name);
		l->properties[0].attributes = _objc_copyPropertyAttributeString(attributes, attributeCount);
		l->next = cls->properties;
		cls->properties = l;
		return YES;
	}

}

BOOL class_addProperty(Class cls,
                       const char *name,
                       const objc_property_attribute_t *attributes, 
                       unsigned int attributeCount)
{
	return _class_addProperty(cls, name, attributes, attributeCount, YES);
}

void class_replaceProperty(Class cls,
                           const char *name,
                           const objc_property_attribute_t *attributes,
                           unsigned int attributeCount)
{
	_class_addProperty(cls, name, attributes, attributeCount, YES);
}


char *property_copyAttributeValue(objc_property_t property,
                                  const char *attributeName)
{
	if (property == NULL || attributeName == NULL || *attributeName == '\0')
		return NULL;

	LOCK_RUNTIME_FOR_SCOPE();
	char *result = _objc_copyPropertyAttributeValue(property->attributes, attributeName);
	return result;
}
