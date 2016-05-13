//
//  UILabel+SimpleFont.m
//  
//
//  Created by Krishna-Mac on 13/05/16.
//
//

#import "UILabel+SimpleFont.h"

@implementation UILabel (SimpleFont)

- (void) simpleRange: (NSRange) range {
    if (![self respondsToSelector:@selector(setAttributedText:)]) {
        return;
    }
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    [attributedText setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]} range:range];
    
    self.attributedText = attributedText;
}

- (void) simpleSubstring: (NSString*) substring {
    NSRange range = [self.text rangeOfString:substring];
    [self simpleRange:range];
}

@end
