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

@end

@implementation CreateNoteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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

// Method to dismiss modal view on tapping Cancel button
- (IBAction)onCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// Method to post note to parse on tapping Post button
- (IBAction)onPost:(id)sender {
    if (!self.note) {
        JGProgressHUD *progressHUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
        progressHUD.textLabel.text = @"Posting...";
        [progressHUD showInView:self.view];
        [Note postNote:self.noteTitleField.text withDescription:self.noteDescriptionTextView.text withImage:self.noteImageView.image withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded) {
                Note *newNote = [[Note alloc] init];
                newNote.noteTitle = self.noteTitleField.text;
                newNote.noteDescription = self.noteDescriptionTextView.text;
                newNote.noteImage = [Note getPFFileFromImage:self.noteImageView.image];
                [self.delegate postedNote:newNote];
                [self dismissViewControllerAnimated:YES completion:nil];
                [progressHUD dismiss];
            }
        }];
    } else {
        JGProgressHUD *progressHUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
        progressHUD.textLabel.text = @"Updating...";
        [progressHUD showInView:self.view];
        NSString *noteObjectID = self.note.objectId;
        PFQuery *noteQuery = [Note query];
        [noteQuery whereKey:@"objectId" equalTo:noteObjectID];
        [noteQuery findObjectsInBackgroundWithBlock:^(NSArray<Note *> * _Nullable notes, NSError * _Nullable error) {
            if (notes) {
                Note *noteToEdit = notes[0];
                [noteToEdit updateNoteWithTitle:self.noteTitleField.text withDescription:self.noteDescriptionTextView.text withImage:self.noteImageView.image withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
                    if (succeeded) {
                        [self.delegate updatedNoteToTitle:self.noteTitleField.text toDescription:self.noteDescriptionTextView.text toImage:self.noteImageView.image];
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
