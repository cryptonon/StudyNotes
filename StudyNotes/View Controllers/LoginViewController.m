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

@interface LoginViewController ()

// MARK: Properties
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

// Logging in the user when Login button is tapped
- (IBAction)onLogin:(id)sender {
    JGProgressHUD *progressHUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
    progressHUD.textLabel.text = @"Logging in";
    [progressHUD showInView:self.view];
    if ([self inputIsValid]) {
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

@end
