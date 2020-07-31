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
@property (weak, nonatomic) IBOutlet UILabel *studyNotesLabel;
@property (weak, nonatomic) IBOutlet UIButton *continueWithFBButton;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.usernameField.delegate = self;
    self.passwordField.delegate = self;
    [self disableLoginButton];
    [self addShadowToStudyNotesLabel];
    [self addShadowToTextFields];
    [self customizeLoginButtons];
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

// Method that adds shadow to usernameField and passwordField
-(void)addShadowToTextFields {
    CGColorRef shadowColor = [[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5f] CGColor];
    CGSize shadowOffset = CGSizeMake(0, 2.0f);
    CGFloat shadowOpacity = 1.0f;
    CGFloat shadowRadius = 5.0f;
    self.usernameField.layer.shadowColor = shadowColor;
    self.usernameField.layer.shadowOffset = shadowOffset;
    self.usernameField.layer.shadowOpacity = shadowOpacity;
    self.usernameField.layer.shadowRadius = shadowRadius;
    self.passwordField.layer.shadowColor = shadowColor;
    self.passwordField.layer.shadowOffset = shadowOffset;
    self.passwordField.layer.shadowOpacity = shadowOpacity;
    self.passwordField.layer.shadowRadius = shadowRadius;
}

// Method that adds shadow to studyNotesLabel
-(void)addShadowToStudyNotesLabel {
    CGColorRef shadowColor = [[UIColor colorWithRed:0 green:0 blue:0 alpha:0.625f] CGColor];
    CGSize shadowOffset = CGSizeMake(0, 2.0f);
    CGFloat shadowOpacity = 1.0f;
    CGFloat shadowRadius = 2.5f;
    self.studyNotesLabel.layer.shadowColor = shadowColor;
    self.studyNotesLabel.layer.shadowOffset = shadowOffset;
    self.studyNotesLabel.layer.shadowOpacity = shadowOpacity;
    self.studyNotesLabel.layer.shadowRadius = shadowRadius;
}

// Method that adds shadow and corner radius to Login and Continue with FB buttons
-(void)customizeLoginButtons {
    CGColorRef shadowColor = [[UIColor colorWithRed:0 green:0 blue:0 alpha:0.45f] CGColor];
    CGSize shadowOffset = CGSizeMake(0, 1.0f);
    CGFloat shadowOpacity = 1.0f;
    CGFloat shadowRadius = 1.25f;
    CGFloat cornerRadius = 15.0f;
    self.loginButton.layer.shadowColor = shadowColor;
    self.loginButton.layer.shadowOffset = shadowOffset;
    self.loginButton.layer.shadowOpacity = shadowOpacity;
    self.loginButton.layer.shadowRadius = shadowRadius;
    self.loginButton.layer.cornerRadius = cornerRadius;
    self.continueWithFBButton.layer.shadowColor = shadowColor;
    self.continueWithFBButton.layer.shadowOffset = shadowOffset;
    self.continueWithFBButton.layer.shadowOpacity = shadowOpacity;
    self.continueWithFBButton.layer.shadowRadius = shadowRadius;
    self.continueWithFBButton.layer.cornerRadius = cornerRadius;
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
  [PFFacebookUtils logInInBackgroundWithReadPermissions:@[@"public_profile", @"email"] block:^(PFUser * _Nullable user, NSError * _Nullable error) {
      if (user) {
          if (user.isNew) {
              FBSDKGraphRequest *graphRequest = [[FBSDKGraphRequest alloc] initWithGraphPath:@"/me" parameters:@{ @"fields": @"id,email",}];
              [graphRequest startWithCompletionHandler:^(FBSDKGraphRequestConnection * _Nullable connection, id  _Nullable result, NSError * _Nullable error) {
                  if (!error) {
                          user[@"FBID"] = result[@"id"];
                          user[@"email"] = result[@"email"];
                          user[@"username"] = [[result[@"email"] componentsSeparatedByString:@"@"] objectAtIndex:0];
                          [user saveInBackground];
                      }
                  }];
              }
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
