//
//  UICustomizationHelpers.m
//  StudyNotes
//
//  Created by Aayush Mani Phuyal on 8/5/20.
//  Copyright © 2020 Aayush Phuyal. All rights reserved.
//

#import "UICustomizationHelpers.h"

// MARK: Helper Methods Implementation

// Method that sets Shadow to a view with provided details
void SetShadowForView(UIView *view, CGColorRef shadowColor, CGFloat shadowOpacity, CGSize shadowOffset, CGFloat shadowRadius) {
    view.layer.shadowColor = shadowColor;
    view.layer.shadowOpacity = shadowOpacity;
    view.layer.shadowOffset = shadowOffset;
    view.layer.shadowRadius = shadowRadius;
}

// Method that sets Border to a view with provided details
void SetBorderForView(UIView *view, CGColorRef borderColor, CGFloat borderWidth) {
    view.layer.borderColor = borderColor;
    view.layer.borderWidth = borderWidth;
}

// Method that sets Corner Radius to a view with provided details
void SetCornerRadiusForView(UIView *view, CGFloat cornerRadius) {
    view.layer.cornerRadius = cornerRadius;
}

// Method that sets scrollView Background Image
void SetBackgroundForScrollView(UIScrollView *scrollView, UIView *contentView, UIImage *backgroundImage, CGFloat alpha) {
    contentView.backgroundColor = [UIColor clearColor];
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
    backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    backgroundImageView.alpha = alpha;
    [scrollView insertSubview:backgroundImageView atIndex:0];
    
}

// Method that sets tableView Background Image
void SetBackgroundForTableView(UITableView *tableView, UIImage *backgroundImage, CGFloat alpha) {
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
    backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    backgroundImageView.alpha = alpha;
    tableView.backgroundView = backgroundImageView;
}

// Method that sets collectionView Background Image
void SetBackgroundForCollectionView(UICollectionView *collectionView, UIImage *backgroundImage, CGFloat alpha) {
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
    backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    backgroundImageView.alpha = alpha;
    collectionView.backgroundView = backgroundImageView;
}

// Helper method to enable/disble navBar and tabBar interaction while presenting group creation alert
void ConfigureNavAndTabBarUserInteractionForViewController(UIViewController *viewController) {
    viewController.tabBarController.tabBar.userInteractionEnabled = !viewController.tabBarController.tabBar.userInteractionEnabled;
    viewController.navigationController.navigationBar.userInteractionEnabled = !viewController.navigationController.navigationBar.userInteractionEnabled;
}
