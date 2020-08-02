//
//  GroupCell.m
//  StudyNotes
//
//  Created by Aayush Mani Phuyal on 8/2/20.
//  Copyright © 2020 Aayush Phuyal. All rights reserved.
//

#import "GroupCell.h"

@interface GroupCell()

// MARK: Properties
@property (weak, nonatomic) IBOutlet UILabel *groupNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *groupDescriptionLabel;

@end

@implementation GroupCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

// Setter method that sets GroupCell properties if provided a group
- (void)setGroup:(Group *)group {
    self.groupNameLabel.text = group.groupName;
    self.groupDescriptionLabel.text = group.groupDescription;
}

@end
