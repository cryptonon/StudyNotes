//
//  NoteCell.m
//  StudyNotes
//
//  Created by Aayush Mani Phuyal on 7/13/20.
//  Copyright © 2020 Aayush Phuyal. All rights reserved.
//

#import "NoteCell.h"
@import Parse;
#import "UICustomizationHelpers.h"

@interface NoteCell()

// MARK: Properties
@property (weak, nonatomic) IBOutlet UILabel *noteTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *noteDescriptionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *noteImageView;
@property (weak, nonatomic) IBOutlet UIView *noteImageViewContainer;
@property (weak, nonatomic) IBOutlet UIView *ownerColorView;


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
    self.backgroundColor = [UIColor clearColor];
    self.noteTitleLabel.text = note.noteTitle;
    self.noteDescriptionLabel.text = note.noteDescription;
    [note.noteImage getDataInBackgroundWithBlock:^(NSData * _Nullable imageData, NSError * _Nullable error) {
        self.noteImageView.image = [UIImage imageWithData:imageData];
    }];
    [self setOwnerColorIndicator];
    [self setShadowToNoteImageViewContainer];
    [self animateNoteImageView];
    [self configureLongPressGesture];
}

// Method that sets owner color indicator for group notes
- (void)setOwnerColorIndicator {
    Note *note = self.note;
    if (!self.note.isPersonalNote) {
        if ([note.author.objectId isEqualToString:[PFUser currentUser].objectId]) {
            self.ownerColorView.backgroundColor = [[UIColor cyanColor] colorWithAlphaComponent:0.425];
        } else {
            self.ownerColorView.backgroundColor = [[UIColor systemYellowColor] colorWithAlphaComponent:0.425];
        }
    }
}

// Method that sets shadow to noteImageViewContainer
-(void)setShadowToNoteImageViewContainer {
    CGColorRef shadowColor = [[UIColor colorWithRed:0 green:0 blue:0 alpha:0.975f] CGColor];;
    CGSize shadowOffset = CGSizeMake(0.0f, 2.0f);
    CGFloat shadowOpacity = 0.0f;
    CGFloat shadowRadius = 2.5f;
    SetShadowForView(self.noteImageViewContainer, shadowColor, shadowOpacity, shadowOffset, shadowRadius);
}

// Method that animates noteImageView
- (void)animateNoteImageView {
    self.noteImageView.alpha = 0;
    [UIView animateWithDuration:0.625 animations:^{
        self.noteImageView.alpha = 1;
        self.noteImageViewContainer.layer.shadowOpacity = 1.0f;
    }];
}

// Method that configures longPressGesture on noteImageView
- (void) configureLongPressGesture {
    [self.noteImageView setUserInteractionEnabled:YES];
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPressNoteImage:)];
    [self.noteImageView addGestureRecognizer:longPressGesture];
}

// Method that handles actions when Note Image is long pressed
- (void) didLongPressNoteImage: (UILongPressGestureRecognizer *) longPressGesture {
    if (longPressGesture.state == UIGestureRecognizerStateEnded) {
        UIImageView *fullScreenImageView = [[UIImageView alloc] initWithImage:self.noteImageView.image];
        fullScreenImageView.frame = [[UIScreen mainScreen] bounds];
        fullScreenImageView.backgroundColor = [UIColor blackColor];
        fullScreenImageView.contentMode = UIViewContentModeScaleAspectFit;
        fullScreenImageView.userInteractionEnabled = YES;
        fullScreenImageView.alpha = 0;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissFullScreenImage:)];
        [fullScreenImageView addGestureRecognizer:tapGesture];
        [UIView animateWithDuration:1 animations:^{
            [self.superview.superview addSubview:fullScreenImageView];
            [self.delegate hideNavigationBar];
            [self.delegate hideTabBarController];
           fullScreenImageView.alpha = 1;
        }];
    }
}

// Method that dismisses full screen Note Image
- (void) dismissFullScreenImage: (UITapGestureRecognizer *) tapGesture {
    self.superview.alpha = 0;
    [UIView animateWithDuration:1 animations:^{
        [self.delegate unhideNavigationBar];
        [self.delegate unhideTabBarController];
        [tapGesture.view removeFromSuperview];
        self.superview.alpha = 1;
    }];
}

@end
