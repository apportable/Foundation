#if (TARGET_OS_MAC || TARGET_OS_EMBEDDED || TARGET_OS_IPHONE) || CF_BUILDING_CF || NSBUILDINGFOUNDATION

#if !defined(__COREFOUNDATION_CFFILESECURITY__)
#define __COREFOUNDATION_CFFILESECURITY__ 1

#include <sys/types.h>
#include <sys/acl.h>
#include <sys/fcntl.h>
#include <CoreFoundation/CFUUID.h>

CF_EXTERN_C_BEGIN

#define kCFFileSecurityRemoveACL(acl_t) _FILESEC_REMOVE_ACL

enum {
    kCFFileSecurityClearOwner             = 1UL << 0,
    kCFFileSecurityClearGroup             = 1UL << 1,
    kCFFileSecurityClearMode              = 1UL << 2,
    kCFFileSecurityClearOwnerUUID         = 1UL << 3,
    kCFFileSecurityClearGroupUUID         = 1UL << 4,
    kCFFileSecurityClearAccessControlList = 1UL << 5
};

typedef struct __CFFileSecurity* CFFileSecurityRef;

CF_EXPORT CFTypeID CFFileSecurityGetTypeID(void);
CF_EXPORT CFFileSecurityRef CFFileSecurityCreate(CFAllocatorRef allocator);
CF_EXPORT CFFileSecurityRef CFFileSecurityCreateCopy(CFAllocatorRef allocator, CFFileSecurityRef fileSec);
CF_EXPORT Boolean CFFileSecurityCopyOwnerUUID(CFFileSecurityRef fileSec, CFUUIDRef *ownerUUID);
CF_EXPORT Boolean CFFileSecuritySetOwnerUUID(CFFileSecurityRef fileSec, CFUUIDRef ownerUUID);
CF_EXPORT Boolean CFFileSecurityCopyGroupUUID(CFFileSecurityRef fileSec, CFUUIDRef *groupUUID);
CF_EXPORT Boolean CFFileSecuritySetGroupUUID(CFFileSecurityRef fileSec, CFUUIDRef groupUUID);
CF_EXPORT Boolean CFFileSecurityCopyAccessControlList(CFFileSecurityRef fileSec, acl_t *accessControlList);
CF_EXPORT Boolean CFFileSecuritySetAccessControlList(CFFileSecurityRef fileSec, acl_t accessControlList);
CF_EXPORT Boolean CFFileSecurityGetOwner(CFFileSecurityRef fileSec, uid_t *owner);
CF_EXPORT Boolean CFFileSecuritySetOwner(CFFileSecurityRef fileSec, uid_t owner);
CF_EXPORT Boolean CFFileSecurityGetGroup(CFFileSecurityRef fileSec, gid_t *group);
CF_EXPORT Boolean CFFileSecuritySetGroup(CFFileSecurityRef fileSec, gid_t group);
CF_EXPORT Boolean CFFileSecurityGetMode(CFFileSecurityRef fileSec, mode_t *mode);
CF_EXPORT Boolean CFFileSecuritySetMode(CFFileSecurityRef fileSec, mode_t mode);
CF_EXPORT Boolean CFFileSecurityClearProperties(CFFileSecurityRef fileSec, CFOptionFlags clearPropertyMask);

CF_EXTERN_C_END

#endif
#endif

