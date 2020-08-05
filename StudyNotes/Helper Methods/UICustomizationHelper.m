//
//  UICustomizationHelper.m
//  StudyNotes
//
//  Created by Aayush Mani Phuyal on 8/4/20.
//  Copyright © 2020 Aayush Phuyal. All rights reserved.
//

#import "UICustomizationHelper.h"

@implementation UICustomizationHelper

// MARK: Methods

// Method that sets Shadow to a view with provided details
+ (void)setShadowFor:(UIView *)view withColor:(CGColorRef)shadowColor withOpacity:(CGFloat)shadowOpacity withOffset:(CGSize)shadowOffset withRadius:(CGFloat)shadowRadius {
    view.layer.shadowColor = shadowColor;
    view.layer.shadowOpacity = shadowOpacity;
    view.layer.shadowOffset = shadowOffset;
    view.layer.shadowRadius = shadowRadius;
}

// Method that sets Border to a view with provided details
+ (void)setBorderFor:(UIView *)view withColor:(CGColorRef)borderColor withWidth:(CGFloat)borderWidth {
    view.layer.borderColor = borderColor;
    view.layer.borderWidth = borderWidth;
}

// Method that sets Corner Radius to a view with provided details
+ (void)setCornerRadiusFor:(UIView *)view withRadius:(CGFloat)cornerRadius {
    view.layer.cornerRadius = cornerRadius;
}

// Method that sets scrollView Background Image
+ (void)setBackgroundForScrollView:(UIScrollView *)scrollView containgingContentView:(UIView *)contentView withImage:(UIImage *)backgroundImage withAlpha:(CGFloat)imageAlpha {
    contentView.backgroundColor = [UIColor clearColor];
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
    backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    backgroundImageView.alpha = imageAlpha;
    [scrollView insertSubview:backgroundImageView atIndex:0];
    
}

// Method that sets tableView Background Image
+ (void)setBackgroundForTableView:(UITableView *)tableView withImage:(UIImage *)backgroundImage withAlpha:(CGFloat)imageAlpha {
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
    backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    backgroundImageView.alpha = 0.25;
    tableView.backgroundView = backgroundImageView;
}

@end
