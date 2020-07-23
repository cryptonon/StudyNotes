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

@interface CreateNoteViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

// MARK: Properties
@property (weak, nonatomic) IBOutlet PFImageView *noteImageView;
@property (weak, nonatomic) IBOutlet UITextField *noteTitleField;
@property (weak, nonatomic) IBOutlet UITextView *noteDescriptionTextView;

@end

@implementation CreateNoteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self registerForKeyboardNotifications];
    if (!self.note) {
        [self presentSourceSelectionAlert];
    } else {
        [self setViewProperties];
    }
}

// Method that sets properties of CreateNoteViewController
- (void)setViewProperties {
    self.noteTitleField.text = self.note.noteTitle;
    self.noteDescriptionTextView.text = self.note.noteDescription;
    self.noteImageView.file = self.note.noteImage;
    [self.noteImageView loadInBackground];
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
    imagePickerVC.allowsEditing = YES;
    imagePickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:imagePickerVC animated:YES completion:nil];
}

// Method that brings library
- (void) showLibrary {
    UIImagePickerController *imagePickerVC = [UIImagePickerController new];
    imagePickerVC.delegate = self;
    imagePickerVC.allowsEditing = YES;
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
    [UIView animateWithDuration:0.2 animations:^{self.view.frame = CGRectMake(self.view.frame.origin.x, 0 - (keyboardSize.height), self.view.frame.size.width, self.view.frame.size.height);
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
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];
    self.noteImageView.image = [self resizeImage:editedImage withSize:CGSizeMake(399, 399)];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
