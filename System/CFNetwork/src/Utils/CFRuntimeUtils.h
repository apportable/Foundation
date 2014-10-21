#ifndef __CFRUNTIMEUTILS__
#define __CFRUNTIMEUTILS__

#include "CFRuntime.h"

CF_EXTERN_C_BEGIN

CF_EXPORT void _CFRuntimeRegisterClassOnce(CFTypeID* typeID, const CFRuntimeClass* cls);

CF_EXTERN_C_END

#endif // __CFRUNTIMEUTILS__
