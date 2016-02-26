//
//  HelperIphoneCheck.h
//  HelperApp
//
//  Created by Poonam Parmar on 2/9/15.
//  Copyright (c) 2015 MSS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface HelperIphoneCheck : NSObject
/*  This is the method to check device compatibilty for iphone 4 */
int isiPhone4(void);

/*  This is the method to check device compatibilty for iphone 5 */
int isiPhone5(void);

/*  This is the method to check device compatibilty for ipad */
int isipad(void);

/*  This is the method to check device compatibilty for iphone 6Plus*/
int isiphone6Plus(void);

/*  This is the method to check device compatibilty for iphone 6*/
int isiphone6(void);

/*  These are the methods to check for ios 7 or 8  */
+   (BOOL) isIOS7;

+(BOOL) isIOS8;

@end
