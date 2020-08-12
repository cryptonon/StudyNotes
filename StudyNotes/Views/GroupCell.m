//
//  GroupCell.m
//  StudyNotes
//
//  Created by Aayush Mani Phuyal on 8/2/20.
//  Copyright © 2020 Aayush Phuyal. All rights reserved.
//

#import "GroupCell.h"
#import "UICustomizationHelpers.h"

@interface GroupCell()

// MARK: Properties
@property (weak, nonatomic) IBOutlet UILabel *groupNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *groupDescriptionLabel;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIView *ownerColorView;

@end

@implementation GroupCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

// Setter method that sets GroupCell properties if provided a group
- (void)setGroup:(Group *)group {
    self.containerView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.825];
    SetCornerRadiusForView(self.containerView, 12.5f);
    if ([group.createdBy.objectId isEqualToString:[PFUser currentUser].objectId]) {
        self.ownerColorView.backgroundColor = [UIColor cyanColor];
    } else {
        self.ownerColorView.backgroundColor = [UIColor systemYellowColor];
    }
    SetShadowForView(self.containerView, [[UIColor blackColor] CGColor], 1.0f, CGSizeMake(0.0f, 2.0f), 8.0f);
    self.groupNameLabel.text = group.groupName;
    self.groupDescriptionLabel.text = group.groupDescription;
}

@end
