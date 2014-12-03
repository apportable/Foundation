#import "NSRegularExpression.h"

@implementation NSDataDetector {
    NSTextCheckingTypes _checkingTypes;
}

@synthesize checkingTypes = _checkingTypes;

+ (NSDataDetector *)dataDetectorWithTypes:(NSTextCheckingTypes)checkingTypes error:(NSError **)error
{
    return [[[self alloc] initWithTypes:checkingTypes error:error] autorelease];
}

- (id)initWithTypes:(NSTextCheckingTypes)checkingTypes error:(NSError **)error
{
    self = [super initWithPattern:@".*" options:0 error:error];

    if (self)
    {
        _checkingTypes = checkingTypes;
    }

    return self;
}

@end