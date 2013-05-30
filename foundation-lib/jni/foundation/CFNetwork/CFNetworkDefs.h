#ifndef _CFNETWORK_DEFS_H_
#define _CFNETWORK_DEFS_H_

#if __cplusplus
#define CFN_EXPORT extern "C" __attribute__((visibility("default")))
#else
#define CFN_EXPORT extern __attribute__((visibility("default")))
#endif

#endif /*_CFNETWORK_DEFS_H_*/