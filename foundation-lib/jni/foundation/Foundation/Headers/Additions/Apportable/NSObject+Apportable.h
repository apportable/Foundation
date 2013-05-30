//
//  NSObject+Apportable.h
//  
//
//  Created by Philippe Hausler on 12/27/11.
//  Copyright (c) 2011 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Apportable)
- (void)performSelectorInBackground:(SEL)selector withObject:(id)object;
@end
