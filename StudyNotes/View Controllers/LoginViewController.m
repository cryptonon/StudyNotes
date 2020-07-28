//
//  LoginViewController.m
//  StudyNotes
//
//  Created by Aayush Mani Phuyal on 7/13/20.
//  Copyright © 2020 Aayush Phuyal. All rights reserved.
//

#import "LoginViewController.h"
#import <Parse/Parse.h>
@import Parse;
#import <JGProgressHUD/JGProgressHUD.h>

@interface LoginViewController () <UITextFieldDelegate>

// MARK: Properties
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *studyNoteLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *usernameFieldTopConstraint;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.usernameField.delegate = self;
    self.passwordField.delegate = self;
    [self disableLoginButton];
}

- (void)viewDidLayoutSubviews {
    CGFloat viewHeight = self.view.frame.size.height;
    // Changing constraints proportionally to view height
    self.studyNoteLabelTopConstraint.constant = viewHeight*0.14;
    self.usernameFieldTopConstraint.constant = viewHeight*0.07;
}

// Method to disable device rotation
- (BOOL)shouldAutorotate {
    return NO;
}

// Method to set supported device orientations
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

// Logging in the user when Login button is tapped
- (IBAction)onLogin:(id)sender {
    if ([self inputIsValid]) {
        JGProgressHUD *progressHUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
        progressHUD.textLabel.text = @"Logging in";
        [progressHUD showInView:self.view];
        NSString *username = self.usernameField.text;
        NSString *password = self.passwordField.text;
        [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser * user, NSError *  error) {
            if (!error) {
                [progressHUD dismiss];
                [self performSegueWithIdentifier:@"loginSegue" sender:nil];
            } else {
                [progressHUD dismiss];
                [self displayErrorAlertWithError:error];
            }
        }];
    }
}

// Signing the user with facebook when Continue with Facebook is tapped
- (IBAction)onContinueWithFB:(id)sender {
  [PFFacebookUtils logInInBackgroundWithReadPermissions:nil block:^(PFUser * _Nullable user, NSError * _Nullable error) {
      if (user) {
          [self performSegueWithIdentifier:@"loginSegue" sender:nil];
      }
    }];
}

// Method to display login error alert
- (void)displayErrorAlertWithError: (NSError * _Nonnull)error {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Login Failed!"
                                                                   message:error.localizedDescription
                                                            preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *tryAgainAction = [UIAlertAction actionWithTitle:@"Try Again"
                                                        style:UIAlertActionStyleCancel
                                                      handler:nil];
    [alert addAction:tryAgainAction];
    [self presentViewController:alert animated:YES completion:nil];
}

// Method to check valid user input (handling empty username/password case)
- (BOOL)inputIsValid {
    if ([self.usernameField.text isEqualToString:@""] || [self.passwordField.text isEqualToString: @""]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Signup Failed!"
                                                                       message:@"Username and password cannot be empty."
                                                                preferredStyle:(UIAlertControllerStyleAlert)];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleCancel
                                                     handler:nil];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
        return NO;
    }
    return YES;
}

// Helper Method to disable Login button
- (void) disableLoginButton {
    self.loginButton.enabled = NO;
    self.loginButton.alpha = 0.625;
}

// Helper Method to enable Login button
- (void) enableLoginButton {
    self.loginButton.enabled = YES;
    self.loginButton.alpha = 1;
}

# pragma mark - Delegate Methods

// Method that gets called everytime text in Text Field Changes (UITextField's Delegate Method) - enabling/disabling Login button is handled here
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *username, *password;
    if (textField == self.usernameField) {
        username = [self.usernameField.text stringByReplacingCharactersInRange:range withString:string];
        password = self.passwordField.text;
    } else {
        username = self.usernameField.text;
        password = [self.passwordField.text stringByReplacingCharactersInRange:range withString:string];
    }
    if ([username length] && [password length]) {
        [self enableLoginButton];
    } else {
        [self disableLoginButton];
    }
    return YES;
}

@end
