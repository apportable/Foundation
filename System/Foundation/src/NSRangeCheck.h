#import <Foundation/NSException.h>

static inline BOOL NSRangeCheckOverflow(NSRange range)
{
    if (NSMaxRange(range) < range.length)
    {
        [NSException raise:NSRangeException format:@"range {%d,%d} causes overflow", range.location, range.length];
        return NO;
    }
    return YES;
}

static inline BOOL NSRangeCheckException(NSRange range, NSUInteger length)
{
    if (!NSRangeCheckOverflow(range))
    {
        return NO;
    }
    if (range.location > length || NSMaxRange(range) > length)
    {
        [NSException raise:NSRangeException format:@"range {%d,%d} exceeds length %d", range.location, range.length, length];
        return NO;
    }
    return YES;
}

static inline BOOL NSRangeLengthCheckException(NSRange range, NSUInteger length)
{
    if (!NSRangeCheckOverflow(range))
    {
        return NO;
    }
    if (range.location > length)
    {
        [NSException raise:NSRangeException format:@"range {%d,%d} exceeds length %d", range.location, range.length, length];
        return NO;
    }
    return YES;
}
