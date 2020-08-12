//
//  UICustomizationHelpers.h
//  StudyNotes
//
//  Created by Aayush Mani Phuyal on 8/5/20.
//  Copyright © 2020 Aayush Phuyal. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

// MARK: Helper Methods Declaration

void SetShadowForView(UIView *view, CGColorRef shadowColor, CGFloat shadowOpacity, CGSize shadowOffset, CGFloat shadowRadius);
void SetBorderForView(UIView *view, CGColorRef borderColor, CGFloat borderWidth);
void SetCornerRadiusForView(UIView *view, CGFloat cornerRadius);
void SetBackgroundForScrollView(UIScrollView *scrollView, UIView *contentView, UIImage *backgroundImage, CGFloat alpha);
void SetBackgroundForTableView(UITableView *tableView, UIImage *backgroundImage, CGFloat alpha);
void SetBackgroundForCollectionView(UICollectionView *collectionView, UIImage *backgroundImage, CGFloat alpha);
void ConfigureNavAndTabBarUserInteractionForViewController(UIViewController *viewController);

NS_ASSUME_NONNULL_END
