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

@interface NoteDetailsViewController () <CreateNoteViewControllerDelegate>

// MARK: Properties
@property (weak, nonatomic) IBOutlet PFImageView *noteImageView;
@property (weak, nonatomic) IBOutlet UILabel *noteTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *noteDescriptionLabel;

@end

@implementation NoteDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setViewProperties];
    [self animateNoteImage];
}

// Method that sets properties of DetailsViewController
- (void) setViewProperties {
    self.navigationItem.title = self.note.noteTitle;
    self.noteTitleLabel.text = self.note.noteTitle;
    self.noteDescriptionLabel.text = self.note.noteDescription;
    self.noteImageView.file = self.note.noteImage;
    [self.noteImageView loadInBackground];
}

// Method to show image full screen on tapping noteImageView
- (IBAction)didTapNoteImage:(id)sender {
    UIImageView *fullScreenImageView = [[UIImageView alloc] initWithImage:self.noteImageView.image];
    fullScreenImageView.frame = [[UIScreen mainScreen] bounds];
    fullScreenImageView.backgroundColor = [UIColor blackColor];
    fullScreenImageView.contentMode = UIViewContentModeScaleAspectFit;
    fullScreenImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissFullScreenImage:)];
    [fullScreenImageView addGestureRecognizer:tapGestureRecognizer];
    fullScreenImageView.alpha = 0;
    [UIView animateWithDuration:1 animations:^{
        [self.view addSubview:fullScreenImageView];
        [self.navigationController setNavigationBarHidden:YES];
        [self.tabBarController.tabBar setHidden:YES];
        fullScreenImageView.alpha = 1;
    }];
}

// Method to dismiss full screen image when full screen view is tapped
- (void)dismissFullScreenImage: (UITapGestureRecognizer *)sender {
    self.view.alpha = 0;
    [UIView animateWithDuration:1 animations:^{
        [self.navigationController setNavigationBarHidden:NO];
        [self.tabBarController.tabBar setHidden:NO];
        [sender.view removeFromSuperview];
        self.view.alpha = 1;
    }];
}

// Method that fades in the note image
- (void) animateNoteImage {
    [self.noteImageView setAlpha:0];
    [UIView animateWithDuration:1 animations:^{
        [self.noteImageView setAlpha:1];
    }];
}

#pragma mark - Delegate Methods

// Method to update details after the note has been updated (CreateNoteViewController's delegate method)
- (void)updatedNoteToTitle:(NSString *)noteTitle toDescription:(NSString *)noteDescription toImage:(UIImage *)noteImage {
    self.noteTitleLabel.text = noteTitle;
    self.noteDescriptionLabel.text = noteDescription;
    self.noteImageView.image = noteImage;
    [self.delegate updatedNoteAtIndexPath:self.indexPath toTitle:noteTitle toDescription:noteDescription toImage:noteImage];
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"updateNoteSegue"]) {
        UINavigationController *navigationController = [segue destinationViewController];
        CreateNoteViewController *updateViewController = (CreateNoteViewController *) navigationController.topViewController;
        updateViewController.note = self.note;
        updateViewController.delegate = self;
    }
}

@end
