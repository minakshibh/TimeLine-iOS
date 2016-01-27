//
//  VideoSquareCropper.h
//  Timeline
//
//  Created by Valentin Knabel on 13.08.15.
//  Copyright (c) 2015 Conclurer GbR. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

@interface VideoSquareCropper : NSObject

+(void)squaredVideoURL:(AVAsset *)asset fromOrientation:(UIInterfaceOrientation)from completion:(void(^)(NSURL *))completion;

@end
