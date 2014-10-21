//
//  NSBOMEncoding.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "NSBOMEncoding.h"

#import <Foundation/NSString.h>

struct BOMEncoding {
    uint32_t BOM;
    uint32_t mask;
    uint8_t length;
    NSStringEncoding encoding;
};

static struct BOMEncoding BOMEncodings[] = {
    {
        0xEFBBBF00,
        0xFFFFFF00,
        3,
        NSUTF8StringEncoding
    },
    {
        0xFEFF0000,
        0xFFFF0000,
        2,
        NSUTF16BigEndianStringEncoding
    },
    {
        0xFFFE0000,
        0xFFFF0000,
        2,
        NSUTF16LittleEndianStringEncoding
    },
    {
        0x0000FEFF,
        0xFFFFFFFF,
        4,
        NSUTF32BigEndianStringEncoding
    },
    {
        0xFFFE0000,
        0xFFFFFFFF,
        4,
        NSUTF32LittleEndianStringEncoding
    },
#warning TODO https://code.google.com/p/apportable/issues/detail?id=271
};

void _NSDetectEncodingFromBOM(uint32_t BOM, NSStringEncoding *encoding, NSUInteger *length)
{
    for (NSUInteger idx = 0; idx < sizeof(BOMEncodings)/sizeof(struct BOMEncoding); idx++)
    {
        if ((BOM & BOMEncodings[idx].mask) == BOMEncodings[idx].BOM)
        {
            if (length != NULL)
            {
                *length = BOMEncodings[idx].length;
            }
            if (encoding != NULL)
            {
                *encoding = BOMEncodings[idx].encoding;
            }
        }
    }
}
