#import <Foundation/NSData.h>

void *_NSReadBytesFromFile(NSString *path, NSDataReadingOptions readOptionsMask, NSUInteger *length, BOOL *vm, NSError **err) CF_PRIVATE;
BOOL _NSWriteBytesToFile(NSData *data, id pathOrURL, NSDataWritingOptions options, NSError **errorPtr) CF_PRIVATE;
