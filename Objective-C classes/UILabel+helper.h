//
//  UILabel+AutoSize.h
//  Campedia
//
//  Created by venkatesh on 17/01/15.
//  Copyright (c) 2015 MasterSoftwareSolutions. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (helper)

/*
 With this method,label will automatically increase its height according to the text.
*/

- (void) autosizeForWidth;
- (void)alignTop;
@end
