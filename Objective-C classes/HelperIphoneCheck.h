

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
