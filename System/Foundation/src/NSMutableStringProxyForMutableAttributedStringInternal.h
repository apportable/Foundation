#import <Foundation/NSString.h>
#import <Foundation/NSAttributedString.h>

__attribute__((visibility("hidden")))
@interface NSMutableStringProxyForMutableAttributedString : NSMutableString

- (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)str;
- (void)getCharacters:(unichar *)buffer range:(NSRange)aRange;
- (unichar)characterAtIndex:(NSUInteger)index;
- (NSUInteger)length;
- (void)dealloc;
- (id)initWithMutableAttributedString:(NSMutableAttributedString *)owner;

@end
