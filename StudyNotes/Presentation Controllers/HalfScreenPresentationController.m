//
//  HalfScreenPresentationController.m
//  StudyNotes
//
//  Created by Aayush Mani Phuyal on 8/4/20.
//  Copyright © 2020 Aayush Phuyal. All rights reserved.
//

#import "HalfScreenPresentationController.h"

@implementation HalfScreenPresentationController

// Method that sets size of view controller to be half (half the height of parent)
- (CGRect)frameOfPresentedViewInContainerView {
    CGRect frame = CGRectMake(0, self.containerView.bounds.size.height/2, self.containerView.bounds.size.width, self.containerView.bounds.size.height/2);
    return frame;
}

@end
