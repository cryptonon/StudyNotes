//
//  CreateNoteViewController.m
//  StudyNotes
//
//  Created by Aayush Mani Phuyal on 7/13/20.
//  Copyright © 2020 Aayush Phuyal. All rights reserved.
//

#import "CreateNoteViewController.h"
#import "Note.h"
@import Parse;
#import <JGProgressHUD/JGProgressHUD.h>
@import TOCropViewController;

@interface CreateNoteViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, TOCropViewControllerDelegate>

// MARK: Properties
@property (weak, nonatomic) IBOutlet UIImageView *noteImageView;
@property (weak, nonatomic) IBOutlet UITextField *noteTitleField;
@property (weak, nonatomic) IBOutlet UITextView *noteDescriptionTextView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *noteImageViewContainer;
@property (weak, nonatomic) IBOutlet UIView *noteDescriptionViewContainer;

@end

@implementation CreateNoteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setScrollViewBackground];
    [self addShadowToNoteTitleField];
    [self customizeNoteDescriptionTextView];
    [self customizeNoteImageView];
    [self registerForKeyboardNotifications];
    if (!self.note) {
        [self configureNoteImageView];
        [self presentSourceSelectionAlert];
    } else {
        [self setViewProperties];
    }
}

// Configure noteImageView
- (void)configureNoteImageView {
    self.noteImageView.image = [UIImage imageNamed:@"note"];
    self.noteImageView.alpha = 0.25;
}

// Method that sets properties of CreateNoteViewController
- (void)setViewProperties {
    self.noteTitleField.text = self.note.noteTitle;
    self.noteDescriptionTextView.text = self.note.noteDescription;
    [self.note.noteImage getDataInBackgroundWithBlock:^(NSData * _Nullable imageData, NSError * _Nullable error) {
        self.noteImageView.image = [UIImage imageWithData:imageData];
    }];
}

// Method that sets scrollView's background matching to app theme image
- (void)setScrollViewBackground {
    self.contentView.backgroundColor = [UIColor clearColor];
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"note"]];
    backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    backgroundImageView.alpha = 0.25;
    [self.scrollView insertSubview:backgroundImageView atIndex:0];
}

// Method that adds shadow to noteTitleField
-(void)addShadowToNoteTitleField {
    CGColorRef shadowColor = [[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5f] CGColor];
    CGSize shadowOffset = CGSizeMake(0, 2.0f);
    CGFloat shadowOpacity = 1.0f;
    CGFloat shadowRadius = 5.0f;
    self.noteTitleField.layer.shadowColor = shadowColor;
    self.noteTitleField.layer.shadowOffset = shadowOffset;
    self.noteTitleField.layer.shadowOpacity = shadowOpacity;
    self.noteTitleField.layer.shadowRadius = shadowRadius;
}

// Method that adds shadow, corner radius, and border to noteDescriptionTextView
-(void)customizeNoteDescriptionTextView {
    [self.noteDescriptionTextView.layer setBorderColor:[[[UIColor darkGrayColor] colorWithAlphaComponent:0.45] CGColor]];
    [self.noteDescriptionTextView.layer setBorderWidth:1.5];
    self.noteDescriptionTextView.layer.cornerRadius = 15;
    
    CGColorRef shadowColor = [[UIColor colorWithRed:0 green:0 blue:0 alpha:0.75f] CGColor];
    CGSize shadowOffset = CGSizeMake(0, 5.0f);
    CGFloat shadowOpacity = 1.0f;
    CGFloat shadowRadius = 12.5f;
    self.noteDescriptionViewContainer.layer.shadowColor = shadowColor;
    self.noteDescriptionViewContainer.layer.shadowOffset = shadowOffset;
    self.noteDescriptionViewContainer.layer.shadowOpacity = shadowOpacity;
    self.noteDescriptionViewContainer.layer.shadowRadius = shadowRadius;
    self.noteDescriptionViewContainer.layer.cornerRadius = 15.0f;
}

// Method that adds border and shadow to noteImageView
-(void)customizeNoteImageView {
    [self.noteImageView.layer setBorderColor:[[[UIColor darkGrayColor] colorWithAlphaComponent:0.75] CGColor]];
    [self.noteImageView.layer setBorderWidth:1.0f];
    self.noteImageViewContainer.layer.shadowColor = [[UIColor colorWithRed:0 green:0 blue:0 alpha:0.9f] CGColor];
    self.noteImageViewContainer.layer.shadowOffset = CGSizeMake(0.0f, 2.5f);
    self.noteImageViewContainer.layer.shadowOpacity = 1.0f;
    self.noteImageViewContainer.layer.shadowRadius = 5.0f;
}

// Method to dismiss modal view on tapping Cancel button
- (IBAction)onCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// Method to post note to parse on tapping Post button
- (IBAction)onPost:(id)sender {
    NSString *newNoteTitle = self.noteTitleField.text;
    NSString *newNoteDescription = self.noteDescriptionTextView.text;
    UIImage *newNoteImage = self.noteImageView.image;
    if (!self.note) {
        JGProgressHUD *progressHUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
        progressHUD.textLabel.text = @"Posting...";
        [progressHUD showInView:self.view];
        NSString *newNoteID = [[NSUUID UUID] UUIDString];
        if (self.group) {
            PFQuery *groupQuery = [Group query];
            [groupQuery whereKey:@"groupID" equalTo:self.group.groupID];
            [groupQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable groups, NSError * _Nullable error) {
                if (groups) {
                    Group *groupToPost = groups[0];
                    [groupToPost postNote:newNoteTitle withDescription:newNoteDescription withImage:newNoteImage withNoteID:newNoteID withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
                        if (succeeded) {
                            Note *newNote = [[Note alloc] init];
                            newNote.noteID = newNoteID;
                            newNote.noteTitle = self.noteTitleField.text;
                            newNote.noteDescription = self.noteDescriptionTextView.text;
                            newNote.noteImage = [Note getPFFileFromImage:self.noteImageView.image];
                            newNote.author = [PFUser currentUser];
                            [self.delegate postedNote:newNote];
                            [self dismissViewControllerAnimated:YES completion:nil];
                            [progressHUD dismiss];
                        }
                    }];
                }
            }];
        } else {
            [Note postNote:newNoteTitle withDescription:newNoteDescription withImage:newNoteImage withNoteID:newNoteID withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
                if (succeeded) {
                    Note *newNote = [[Note alloc] init];
                    newNote.noteID = newNoteID;
                    newNote.noteTitle = self.noteTitleField.text;
                    newNote.noteDescription = self.noteDescriptionTextView.text;
                    newNote.noteImage = [Note getPFFileFromImage:self.noteImageView.image];
                    newNote.author = [PFUser currentUser];
                    [self.delegate postedNote:newNote];
                    [self dismissViewControllerAnimated:YES completion:nil];
                    [progressHUD dismiss];
                }
            }];
        }
    } else {
        JGProgressHUD *progressHUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
        progressHUD.textLabel.text = @"Updating...";
        [progressHUD showInView:self.view];
        NSString *noteID = self.note.noteID;
        PFQuery *noteQuery = [Note query];
        [noteQuery whereKey:@"noteID" equalTo:noteID];
        [noteQuery findObjectsInBackgroundWithBlock:^(NSArray<Note *> * _Nullable notes, NSError * _Nullable error) {
            if (notes) {
                Note *noteToEdit = notes[0];
                [noteToEdit updateNoteWithTitle:newNoteTitle withDescription:newNoteDescription withImage:newNoteImage withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
                    if (succeeded) {
                        [self.delegate updatedNoteToTitle:newNoteTitle toDescription:newNoteDescription toImage:newNoteImage];
                        [self dismissViewControllerAnimated:YES completion:nil];
                        [progressHUD dismiss];
                    }
                }];
            }
        }];
    }
}

// Method to bring camera/library on tapping noteImageView
- (IBAction)didTapNoteImage:(id)sender {
    [self presentSourceSelectionAlert];
}

// Method that presents alert that lets user choose camera or library
- (void) presentSourceSelectionAlert {
    UIAlertController *cameraOrLibraryAlert = [UIAlertController alertControllerWithTitle:@"Please Choose a Source"
                                                                                  message:nil
                                                                           preferredStyle:(UIAlertControllerStyleAlert)];
    
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"Camera"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
        [self showCamera];
    }];
    UIAlertAction *libraryAction = [UIAlertAction actionWithTitle:@"Library"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * _Nonnull action) {
        [self showLibrary];
    }];
    [cameraOrLibraryAlert addAction:cameraAction];
    [cameraOrLibraryAlert addAction:libraryAction];
    [self presentViewController:cameraOrLibraryAlert animated:YES completion:nil];
}

// Method that brings camera
- (void) showCamera {
    UIImagePickerController *imagePickerVC = [UIImagePickerController new];
    imagePickerVC.delegate = self;
    imagePickerVC.allowsEditing = NO;
    imagePickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:imagePickerVC animated:YES completion:nil];
}

// Method that brings library
- (void) showLibrary {
    UIImagePickerController *imagePickerVC = [UIImagePickerController new];
    imagePickerVC.delegate = self;
    imagePickerVC.allowsEditing = NO;
    imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:imagePickerVC animated:YES completion:nil];
}

// Method to resize the captured image
- (UIImage *)resizeImage:(UIImage *)image withSize:(CGSize)size {
    UIImageView *resizedImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    resizedImageView.contentMode = UIViewContentModeScaleAspectFill;
    resizedImageView.image = image;
    UIGraphicsBeginImageContext(size);
    [resizedImageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resizedImage;
}

// Method that registers keyboard notifications
- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillAppear:)
                                                 name:UIKeyboardWillShowNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillDisappear:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

// Method that pushes up the view once keyboard appears
- (void)keyboardWillAppear:(NSNotification*)keyboardNotification {
    NSDictionary* info = [keyboardNotification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    [UIView animateWithDuration:0.2 animations:^{self.view.frame = CGRectMake(self.view.frame.origin.x, 0 - (keyboardSize.height)*0.5, self.view.frame.size.width, self.view.frame.size.height);
    }];
}

// Method that pushes down the view to original state once keyboard disappers
- (void)keyboardWillDisappear:(NSNotification*)keyboardNotification {
    [UIView animateWithDuration:0.2 animations:^{self.view.frame = CGRectMake(self.view.frame.origin.x, 0, self.view.frame.size.width, self.view.frame.size.height);
    }];
}

# pragma mark - Delegate Methods

// UIImagePickerController's Delegate method to get and process captured image locally
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *originalImage = info[UIImagePickerControllerOriginalImage];
    [self dismissViewControllerAnimated:YES completion:nil];
    [self presentCropViewController:originalImage];
}

// TOCropViewController's Delegate method to present a cropping view
- (void)presentCropViewController:(UIImage*)image {
  TOCropViewController *cropViewController = [[TOCropViewController alloc] initWithImage:image];
  cropViewController.delegate = self;
  [self presentViewController:cropViewController animated:YES completion:nil];
}

// TOCropViewController's Delegate method to get and process cropped image
- (void)cropViewController:(TOCropViewController *)cropViewController didCropToImage:(UIImage *)image withRect:(CGRect)cropRect angle:(NSInteger)angle {
    self.noteImageView.alpha = 1.0;
    self.noteImageView.image = image;
    [self dismissViewControllerAnimated:NO completion:^{
        [self.noteTitleField becomeFirstResponder];
    }];
}


@end
