//
//  UILabel+AutoSize.m
//  Campedia
//
//  Created by venkatesh on 17/01/15.
//  Copyright (c) 2015 MasterSoftwareSolutions. All rights reserved.
//

#import "UILabel+helper.h"

@implementation UILabel (helper)


- (void) autosizeForWidth {
    self.lineBreakMode = NSLineBreakByWordWrapping;
    self.numberOfLines = 0;
    CGSize maximumLabelSize = CGSizeMake(self.frame.size.width, FLT_MAX);
    CGSize expectedLabelSize = [self.text sizeWithFont:self.font constrainedToSize:maximumLabelSize lineBreakMode:self.lineBreakMode];
    self.contentMode = UIControlContentVerticalAlignmentTop;
    CGRect newFrame = self.frame;
    if (!(expectedLabelSize.height<newFrame.size.height)) {
        newFrame.size.height = expectedLabelSize.height;
    }
  //  [self alignTop];
    self.frame = newFrame;
//    CGSize constrainedSize = CGSizeMake(self.frame.size.width  , FLT_MAX);
//    
//    NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
//                                          [UIFont fontWithName:@"HelveticaNeue" size:11.0], NSFontAttributeName,
//                                          nil];
//    
//    //NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:self.text attributes:attributesDictionary];
//    
//    //CGRect requiredHeight = [string boundingRectWithSize:constrainedSize options:NSStringDrawingUsesLineFragmentOrigin context:nil];
//    NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
//    CGSize boundingBox = [self.text boundingRectWithSize:constrainedSize
//                                                  options:NSStringDrawingUsesLineFragmentOrigin
//                                               attributes:@{NSFontAttributeName:self.font}
//                                                  context:context].size;
//    
//    if (boundingBox.size.width > self.frame.size.width) {
//        requiredHeight = CGRectMake(0,0, self.frame.size.width, requiredHeight.size.height);
//    }
//    CGRect newFrame = self.frame;
//    newFrame.size.height = requiredHeight.size.height;
//    self.frame = newFrame;
}

- (void)alignTop
{
    CGSize fontSize = [self.text sizeWithFont:self.font];
    
    double finalHeight = fontSize.height * self.numberOfLines;
    double finalWidth = self.frame.size.width;    //expected width of label
    
    
    CGSize theStringSize = [self.text sizeWithFont:self.font constrainedToSize:CGSizeMake(finalWidth, finalHeight) lineBreakMode:self.lineBreakMode];
    
    
    int newLinesToPad = (finalHeight  - theStringSize.height) / fontSize.height;
    
    for(int i=0; i<= newLinesToPad; i++)
    {
        self.text = [self.text stringByAppendingString:@" \n"];
    }
}

@end
