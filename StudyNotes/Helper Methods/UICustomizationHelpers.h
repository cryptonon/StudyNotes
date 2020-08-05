//
//  UICustomizationHelpers.h
//  StudyNotes
//
//  Created by Aayush Mani Phuyal on 8/5/20.
//  Copyright © 2020 Aayush Phuyal. All rights reserved.
//

#import <UIKit/UIKit.h>

// MARK: Helper Methods Declaration

void setShadowForView(UIView *view, CGColorRef shadowColor, CGFloat shadowOpacity, CGSize shadowOffset, CGFloat shadowRadius);
void setBorderForView(UIView *view, CGColorRef borderColor, CGFloat borderWidth);
void setCornerRadiusForView(UIView *view, CGFloat cornerRadius);
void setBackgroundForScrollView(UIScrollView *scrollView, UIView *contentView, UIImage *backgroundImage, CGFloat alpha);
void setBackgroundForTableView(UITableView *tableView, UIImage *backgroundImage, CGFloat alpha);
