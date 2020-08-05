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
#import "UICustomizationHelpers.h"

@interface NoteDetailsViewController () <CreateNoteViewControllerDelegate>

// MARK: Properties
@property (weak, nonatomic) IBOutlet UIImageView *noteImageView;
@property (weak, nonatomic) IBOutlet UILabel *noteTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *noteDescriptionLabel;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *noteImageViewContainer;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;

@end

@implementation NoteDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureEditAccess];
    [self setViewProperties];
    [self customizeScrollView];
    [self customizeNoteImageView];
    [self animateNoteImage];
}

// Method to hide/unhide editing access depending upon note ownership
- (void)configureEditAccess {
    if (![self.note.author.objectId isEqualToString:[PFUser currentUser].objectId]) {
        self.editButton.enabled = NO;
        self.editButton.tintColor = [UIColor clearColor];
    }
}

// Method that sets properties of DetailsViewController
- (void) setViewProperties {
    self.navigationItem.title = self.note.noteTitle;
    self.noteTitleLabel.text = self.note.noteTitle;
    self.noteDescriptionLabel.text = self.note.noteDescription;
    [self.note.noteImage getDataInBackgroundWithBlock:^(NSData * _Nullable imageData, NSError * _Nullable error) {
        self.noteImageView.image = [UIImage imageWithData:imageData];
    }];
}

// Method that customizes scrollView's appearance
- (void)customizeScrollView {
    UIImage *scrollViewBgImage = [UIImage imageNamed:@"note"];
    setBackgroundForScrollView(self.scrollView, self.contentView, scrollViewBgImage, 0.25);
}

// Method that adds border and shadow to noteImageView
-(void)customizeNoteImageView {
    CGColorRef borderColor = [[[UIColor darkGrayColor] colorWithAlphaComponent:0.75] CGColor];
    CGFloat borderWidth = 1.0f;
    CGColorRef shadowColor = [[UIColor colorWithRed:0 green:0 blue:0 alpha:0.9f] CGColor];
    CGSize shadowOffset = CGSizeMake(0.0f, 2.5f);
    CGFloat shadowOpacity = 0.0f;
    CGFloat shadowRadius = 5.0f;
    setShadowForView(self.noteImageViewContainer, shadowColor, shadowOpacity, shadowOffset, shadowRadius);
    setBorderForView(self.noteImageView, borderColor, borderWidth);
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
    [UIView animateWithDuration:0.625 animations:^{
        [self.view addSubview:fullScreenImageView];
        [self.navigationController setNavigationBarHidden:YES];
        [self.tabBarController.tabBar setHidden:YES];
        fullScreenImageView.alpha = 1;
    }];
}

// Method to dismiss full screen image when full screen view is tapped
- (void)dismissFullScreenImage: (UITapGestureRecognizer *)sender {
    self.view.alpha = 0;
    [UIView animateWithDuration:0.625 animations:^{
        [self.navigationController setNavigationBarHidden:NO];
        [self.tabBarController.tabBar setHidden:NO];
        [sender.view removeFromSuperview];
        self.view.alpha = 1;
    }];
}

// Method that fades in the note image
- (void) animateNoteImage {
    [self.noteImageView setAlpha:0];
    [UIView animateWithDuration:0.625 animations:^{
        [self.noteImageView setAlpha:1];
        self.noteImageViewContainer.layer.shadowOpacity = 1.0f;
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
