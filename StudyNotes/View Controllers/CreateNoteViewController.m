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

@interface CreateNoteViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

// MARK: Properties
@property (weak, nonatomic) IBOutlet PFImageView *noteImageView;
@property (weak, nonatomic) IBOutlet UITextField *noteTitleField;
@property (weak, nonatomic) IBOutlet UITextView *noteDescriptionTextView;

@end

@implementation CreateNoteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!self.note) {
       [self showCameraOrLibrary];
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
        [Note postNote:self.noteTitleField.text withDescription:self.noteDescriptionTextView.text withImage:self.noteImageView.image withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded) {
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }];
    } else {
        NSString *noteObjectID = self.note.objectId;
        PFQuery *noteQuery = [Note query];
        [noteQuery whereKey:@"objectId" equalTo:noteObjectID];
        [noteQuery findObjectsInBackgroundWithBlock:^(NSArray<Note *> * _Nullable notes, NSError * _Nullable error) {
            if (notes) {
                Note *noteToEdit = notes[0];
                [noteToEdit updateNoteWithTitle:self.noteTitleField.text withDescription:self.noteDescriptionTextView.text withImage:self.noteImageView.image withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
                    if (succeeded) {
                        [self dismissViewControllerAnimated:YES completion:nil];
                    }
                }];
            }
        }];
    }
}

// Method to bring camera/library on tapping noteImageView
- (IBAction)didTapNoteImage:(id)sender {
    [self showCameraOrLibrary];
}

// Method to bring up camera/library to select photo for note
- (void)showCameraOrLibrary {
    UIImagePickerController *imagePickerVC = [UIImagePickerController new];
    imagePickerVC.delegate = self;
    imagePickerVC.allowsEditing = YES;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
       imagePickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
    } else {
       imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
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

# pragma mark - Delegate Methods

// UIImagePickerController's Delegate method to get and process captured image locally
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];
    self.noteImageView.image = [self resizeImage:editedImage withSize:CGSizeMake(399, 399)];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
