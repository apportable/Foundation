//
//  NSPointerFunctionsTests.m
//  FoundationTests
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "FoundationTests.h"

@testcase(NSPointerFunctions)

static NSUInteger constTen(const void *str)
{
    return 10;
}

test(CStringHash)
{
    NSPointerFunctions *functions = [[[NSPointerFunctions alloc] initWithOptions:NSPointerFunctionsCStringPersonality] autorelease];
    NSUInteger (*hashFunction)(const void *item, NSUInteger (*size)(const void *item)) = [functions hashFunction];

    testassert(hashFunction != NULL);

    NSUInteger emptyHash = hashFunction("", &strlen);
    testassert(emptyHash == 0);

    const char nuls[10] = {0};
    NSUInteger tenNulsHash = hashFunction(nuls, &constTen);
#if __LP64__
    testassert(tenNulsHash == 7832317117341010954ull);
#else
    testassert(tenNulsHash == 3142749194);
#endif

    char chars[2] = {0};
    for (int i = 0; i < 256; i++)
    {
        chars[0] = i;
        NSUInteger hash = hashFunction(chars, &strlen);
        testassert(hash == (i ? 771 + 3 * i : 0));
    }

    const char *alphabet = "abcdefghijklmnopqrstuvwxyz";
    NSUInteger alphabetHash = hashFunction(alphabet, &strlen);
#if __LP64__
    testassert(alphabetHash == 3027273625588202553ull);
#else
    testassert(alphabetHash == 3273129017);
#endif

    return YES;
}

@end
