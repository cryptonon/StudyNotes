//
//  NoteDetailsViewController.m
//  StudyNotes
//
//  Created by Aayush Mani Phuyal on 7/13/20.
//  Copyright © 2020 Aayush Phuyal. All rights reserved.
//

#import "NoteDetailsViewController.h"
@import Parse;
#import "CreateNoteViewController.h"

@interface NoteDetailsViewController ()

// MARK: Properties
@property (weak, nonatomic) IBOutlet PFImageView *noteImageView;
@property (weak, nonatomic) IBOutlet UILabel *noteTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *noteDescriptionLabel;

@end

@implementation NoteDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setViewProperties];
}

// Method that sets properties of DetailsViewController
- (void) setViewProperties {
    self.noteTitleLabel.text = self.note.noteTitle;
    self.noteDescriptionLabel.text = self.note.noteDescription;
    self.noteImageView.file = self.note.noteImage;
    [self.noteImageView loadInBackground];
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"updateNoteSegue"]) {
        UINavigationController *navigationController = [segue destinationViewController];
        CreateNoteViewController *updateViewController = (CreateNoteViewController *) navigationController.topViewController;
        updateViewController.note = self.note;
    }
}

@end
