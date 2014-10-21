
/*
 NOTE: These are only here for the fastpath methods to avoid
 needing to have crazy dependency graphs just for headers...
 The defines should only be used for things that need to
 read/write for both 64 and 32 bit, else @encode is preferred
 */
#import <Foundation/NSString.h>

#define NSRANGE_32 "{_NSRange=II}"
#define NSRANGE_64 "{_NSRange=QQ}"
#define CGPOINT_32 "{CGPoint=ff}"
#define CGPOINT_64 "{CGPoint=dd}"
#define CGSIZE_32 "{CGSize=ff}"
#define CGSIZE_64 "{CGSize=dd}"
#define CGRECT_32 "{CGRect={CGPoint=ff}{CGSize=ff}}"
#define CGRECT_64 "{CGRect={CGPoint=dd}{CGSize=dd}}"
#define CGAFFINETRANSFORM_32 "{CGAffineTransform=ffffff}"
#define CGAFFINETRANSFORM_64 "{CGAffineTransform=dddddd}"
#define UIEDGEINSETS_32 "{UIEdgeInsets=ffff}"
#define UIEDGEINSETS_64 "{UIEdgeInsets=dddd}"
#define NSEDGEINSETS_64 "{NSEdgeInsets=ffff}"
#define NSEDGEINSETS_32 "{NSEdgeInsets=dddd}"
#define UIOFFSET_32 "{UIOffset=ff}"
#define UIOFFSET_64 "{UIOffset=dd}"

#define IVAR_NSRANGE_32 "{_NSRange=\"location\"I\"length\"I}"
#define IVAR_NSRANGE_64 "{_NSRange=\"location\"Q\"length\"Q}"
#define IVAR_CGPOINT_32 "{CGPoint=\"x\"f\"y\"f}"
#define IVAR_CGPOINT_64 "{CGPoint=\"x\"d\"y\"d}"
#define IVAR_CGSIZE_32 "{CGSize=\"width\"f\"height\"f}"
#define IVAR_CGSIZE_64 "{CGSize=\"width\"d\"height\"d}"
#define IVAR_CGRECT_32 "{CGRect=\"origin\"{CGPoint=\"x\"f\"y\"f}\"size\"{CGSize=\"width\"f\"height\"f}}"
#define IVAR_CGRECT_64 "{CGRect=\"origin\"{CGPoint=\"x\"d\"y\"d}\"size\"{CGSize=\"width\"d\"height\"d}}"

#if __LP64__
#define IVAR_NSRANGE IVAR_NSRANGE_64
#define IVAR_CGPOINT IVAR_CGPOINT_64
#define IVAR_CGSIZE IVAR_CGSIZE_64
#define IVAR_CGRECT IVAR_CGRECT_64
#else
#define IVAR_NSRANGE IVAR_NSRANGE_32
#define IVAR_CGPOINT IVAR_CGPOINT_32
#define IVAR_CGSIZE IVAR_CGSIZE_32
#define IVAR_CGRECT IVAR_CGRECT_32
#endif

#ifndef CGFLOAT_DEFINED
#if __LP64__
typedef double CGFloat;
#else
typedef float CGFloat;
#endif
#define CGFLOAT_DEFINED
#endif

struct CGPoint {
    CGFloat x;
    CGFloat y;
};
typedef struct CGPoint CGPoint;

struct CGSize {
    CGFloat width;
    CGFloat height;
};
typedef struct CGSize CGSize;

struct CGRect {
    CGPoint origin;
    CGSize size;
};
typedef struct CGRect CGRect;

typedef struct {
   CGFloat a;
   CGFloat b;
   CGFloat c;
   CGFloat d;
   CGFloat tx;
   CGFloat ty;
} CGAffineTransform;

typedef struct UIEdgeInsets {
    CGFloat top;
    CGFloat left;
    CGFloat bottom;
    CGFloat right;
} UIEdgeInsets;

typedef struct UIOffset {
    CGFloat horizontal;
    CGFloat vertical;
} UIOffset;

extern NSString *const NS_objects CF_PRIVATE;
extern NSString *const NS_keys CF_PRIVATE;
extern NSString *const NS_special CF_PRIVATE;
extern NSString *const NS_pointval CF_PRIVATE;
extern NSString *const NS_sizeval CF_PRIVATE;
extern NSString *const NS_rectval CF_PRIVATE;
extern NSString *const NS_rangeval_length CF_PRIVATE;
extern NSString *const NS_rangeval_location CF_PRIVATE;
extern NSString *const NS_atval_a CF_PRIVATE;
extern NSString *const NS_atval_b CF_PRIVATE;
extern NSString *const NS_atval_c CF_PRIVATE;
extern NSString *const NS_atval_d CF_PRIVATE;
extern NSString *const NS_atval_tx CF_PRIVATE;
extern NSString *const NS_atval_ty CF_PRIVATE;
extern NSString *const NS_edgeval_top CF_PRIVATE;
extern NSString *const NS_edgeval_left CF_PRIVATE;
extern NSString *const NS_edgeval_bottom CF_PRIVATE;
extern NSString *const NS_edgeval_right CF_PRIVATE;
extern NSString *const NS_offset_h CF_PRIVATE;
extern NSString *const NS_offset_v CF_PRIVATE;
extern NSString *const NS_time CF_PRIVATE;

NSString *NSStringFromPoint(CGPoint pt);
NSString *NSStringFromSize(CGSize sz);
NSString *NSStringFromRect(CGRect r);
CGSize NSSizeFromString(NSString *string);
CGPoint NSPointFromString(NSString *string);
CGRect NSRectFromString(NSString *string);
