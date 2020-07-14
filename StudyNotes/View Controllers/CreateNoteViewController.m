//
//  CreateNoteViewController.m
//  StudyNotes
//
//  Created by Aayush Mani Phuyal on 7/13/20.
//  Copyright © 2020 Aayush Phuyal. All rights reserved.
//

#import "CreateNoteViewController.h"

@interface CreateNoteViewController ()

// MARK: Properties
@property (weak, nonatomic) IBOutlet UIImageView *noteImageView;
@property (weak, nonatomic) IBOutlet UITextField *noteTitleField;
@property (weak, nonatomic) IBOutlet UITextView *noteDescriptionTextView;


@end

@implementation CreateNoteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

// Method to dismiss modal view on tapping Cancel button
- (IBAction)onCancel:(id)sender {
}

// Method to post note to parse on tapping Post button
- (IBAction)onPost:(id)sender {
}

// Method to bring camera on tapping noteImageView
- (IBAction)didTapNoteImage:(id)sender {
}

@end
