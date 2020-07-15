//
//  NoteCell.m
//  StudyNotes
//
//  Created by Aayush Mani Phuyal on 7/13/20.
//  Copyright © 2020 Aayush Phuyal. All rights reserved.
//

#import "NoteCell.h"
@import Parse;

@interface NoteCell()

// MARK: Properties
@property (weak, nonatomic) IBOutlet UILabel *noteTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *noteDescriptionLabel;
@property (weak, nonatomic) IBOutlet PFImageView *noteImageView;


@end

@implementation NoteCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

// Setter method that sets NoteCell's properties
- (void) setNote:(Note *)note {
    _note = note;
    self.noteTitleLabel.text = note.noteTitle;
    self.noteDescriptionLabel.text = note.noteDescription;
    self.noteImageView.file = note.noteImage;
    [self.noteImageView loadInBackground];
}
@end
