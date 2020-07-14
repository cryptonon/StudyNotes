//
//  NoteCell.m
//  StudyNotes
//
//  Created by Aayush Mani Phuyal on 7/13/20.
//  Copyright © 2020 Aayush Phuyal. All rights reserved.
//

#import "NoteCell.h"

@interface NoteCell()

// MARK: Properties
@property (weak, nonatomic) IBOutlet UILabel *noteTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *noteDescriptionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *noteImageView;

@end

@implementation NoteCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
