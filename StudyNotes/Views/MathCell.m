//
//  MathCell.m
//  StudyNotes
//
//  Created by Aayush Mani Phuyal on 7/13/20.
//  Copyright © 2020 Aayush Phuyal. All rights reserved.
//

#import "MathCell.h"

@interface MathCell()

// MARK: Properties
@property (weak, nonatomic) IBOutlet UILabel *mathFactLabel;

@end

@implementation MathCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
