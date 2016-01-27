//
//  UIAppearence+Swift.m
//  Timeline
//
//  Created by Valentin Knabel on 13.08.15.
//  Copyright (c) 2015 Conclurer GbR. All rights reserved.
//

#import "UIAppearence+Swift.h"

@implementation UIView (UIAppearence_Swift)

+ (instancetype)appearanceWhenContainedInSwiftFix:(Class<UIAppearanceContainer>)containerClass {
    return [self appearanceWhenContainedIn:containerClass, nil];
}

@end
