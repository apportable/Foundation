//
//  NSHTTPCookie+private.h
//  Foundation
//
//  Created by Sergey Klimov on 4/11/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#ifndef Foundation_NSHTTPCookie_private_h
#define Foundation_NSHTTPCookie_private_h
#import <CFNetwork/CFHTTPCookie.h>
@interface NSHTTPCookie(Internal)
- (id)initWithCookie:(CFHTTPCookieRef)cookie;
-(CFHTTPCookieRef)privateCookie;
@end


#endif
