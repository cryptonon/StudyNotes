//
//  UICustomizationHelper.h
//  StudyNotes
//
//  Created by Aayush Mani Phuyal on 8/4/20.
//  Copyright © 2020 Aayush Phuyal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UICustomizationHelper : NSObject

// MARK: Methods

+ (void)setShadowFor: (UIView *)view
           withColor: (CGColorRef)shadowColor
         withOpacity: (CGFloat)shadowOpacity
          withOffset: (CGSize)shadowOffset
          withRadius: (CGFloat)shadowRadius;

+ (void)setBorderFor: (UIView *)view
           withColor: (CGColorRef) borderColor
           withWidth: (CGFloat)borderWidth;

+ (void)setCornerRadiusFor: (UIView *)view withRadius: (CGFloat)cornerRadius;

@end

NS_ASSUME_NONNULL_END
