

#import "HelperIphoneCheck.h"

@implementation HelperIphoneCheck

//iphone compatibilty

int isiPhone4(void)
{
    CGSize iOSDeviceScreenSize = [[UIScreen mainScreen] bounds].size;
    if (iOSDeviceScreenSize.height == 480)
        return 1;
    else
        return 0;
}

int isiPhone5(void)
{
    CGSize iOSDeviceScreenSize = [[UIScreen mainScreen] bounds].size;
    if (iOSDeviceScreenSize.height == 568)
        return 1;
    else
        return 0;
}

int isiphone6Plus(void)
{
    CGSize iOSDeviceScreenSize = [[UIScreen mainScreen] bounds].size;
    if (iOSDeviceScreenSize.height == 736)
        return 1;
    else
        return 0;
}

int isiphone6(void)
{
    CGSize iOSDeviceScreenSize = [[UIScreen mainScreen] bounds].size;
    if (iOSDeviceScreenSize.height == 667)
        return 1;
    else
        return 0;
}

int isipad(void)
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        
        return 1;
    else
        return 0;
}


//to check ios

+ (BOOL) isIOS7 {
    return [[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0f;
}

+ (BOOL) isIOS8 {
    return [[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0f;
}
@end
