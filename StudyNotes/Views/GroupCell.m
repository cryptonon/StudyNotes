//
//  GroupCell.m
//  StudyNotes
//
//  Created by Aayush Mani Phuyal on 8/2/20.
//  Copyright © 2020 Aayush Phuyal. All rights reserved.
//

#import "GroupCell.h"
#import "UICustomizationHelper.h"

@interface GroupCell()

// MARK: Properties
@property (weak, nonatomic) IBOutlet UILabel *groupNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *groupDescriptionLabel;
@property (weak, nonatomic) IBOutlet UIView *containerView;

@end

@implementation GroupCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

// Setter method that sets GroupCell properties if provided a group
- (void)setGroup:(Group *)group {
    self.containerView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.825];
    [UICustomizationHelper setCornerRadiusFor:self.containerView withRadius:12.5f];
    [UICustomizationHelper setBorderFor:self.containerView withColor:[[UIColor grayColor] CGColor] withWidth:1];
    [UICustomizationHelper setShadowFor:self.containerView withColor:[[UIColor blackColor] CGColor] withOpacity:1.0 withOffset:CGSizeMake(0, 2) withRadius:8];
    self.groupNameLabel.text = group.groupName;
    self.groupDescriptionLabel.text = group.groupDescription;
}

@end
