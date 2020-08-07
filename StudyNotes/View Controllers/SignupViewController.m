//
//  SignupViewController.m
//  StudyNotes
//
//  Created by Aayush Mani Phuyal on 7/17/20.
//  Copyright © 2020 Aayush Phuyal. All rights reserved.
//

#import "SignupViewController.h"
#import <Parse/Parse.h>
#import <JGProgressHUD/JGProgressHUD.h>
#import <SCLAlertView.h>
#import "UICustomizationHelpers.h"

@interface SignupViewController () <UITextFieldDelegate>

// MARK: Properties
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIButton *signupButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *studyNotesLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *usernameFieldTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *studyNotesLabel;

@end

@implementation SignupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.usernameField.delegate = self;
    self.passwordField.delegate = self;
    [self disableSignupButton];
    [self addShadowToStudyNotesLabel];
    [self addShadowToTextFields];
    [self customizeSignupButton];
}

- (void)viewDidLayoutSubviews {
    CGFloat viewHeight = self.view.frame.size.height;
    // Changing constraints proportionally to view height
    self.studyNotesLabelTopConstraint.constant = viewHeight*0.14;
    self.usernameFieldTopConstraint.constant = viewHeight*0.07;
}

// Method that adds shadow to usernameField and passwordField
-(void)addShadowToTextFields {
    CGColorRef shadowColor = [[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5f] CGColor];
    CGSize shadowOffset = CGSizeMake(0, 2.0f);
    CGFloat shadowOpacity = 1.0f;
    CGFloat shadowRadius = 5.0f;
    setShadowForView(self.usernameField, shadowColor, shadowOpacity, shadowOffset, shadowRadius);
    setShadowForView(self.passwordField, shadowColor, shadowOpacity, shadowOffset, shadowRadius);
}

// Method that adds shadow to studyNotesLabel
-(void)addShadowToStudyNotesLabel {
    CGColorRef shadowColor = [[UIColor colorWithRed:0 green:0 blue:0 alpha:0.625f] CGColor];
    CGSize shadowOffset = CGSizeMake(0, 2.0f);
    CGFloat shadowOpacity = 1.0f;
    CGFloat shadowRadius = 2.5f;
    setShadowForView(self.studyNotesLabel, shadowColor, shadowOpacity, shadowOffset, shadowRadius);
}

// Method that adds shadow and corner radius to Signup button
-(void)customizeSignupButton {
    CGColorRef shadowColor = [[UIColor colorWithRed:0 green:0 blue:0 alpha:0.45f] CGColor];
    CGSize shadowOffset = CGSizeMake(0, 1.0f);
    CGFloat shadowOpacity = 1.0f;
    CGFloat shadowRadius = 1.25f;
    CGFloat cornerRadius = 15.0f;
    setShadowForView(self.signupButton, shadowColor, shadowOpacity, shadowOffset, shadowRadius);
    setCornerRadiusForView(self.signupButton, cornerRadius);
}

// Signing up the new user when Signup button is tapped
- (IBAction)onSignup:(id)sender {
    if ([self inputIsValid]) {
        JGProgressHUD *progressHUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleLight];
        progressHUD.textLabel.text = @"Signing up";
        [progressHUD showInView:self.view];
        PFUser *newUser = [PFUser user];
        newUser.username = self.usernameField.text;
        newUser.password = self.passwordField.text;
        [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
            if (succeeded) {
                [progressHUD dismiss];
                [self performSegueWithIdentifier:@"loginSegue" sender:nil];
            } else {
                [progressHUD dismiss];
                [self displayErrorAlertWithError:error];
            }
        }];
    }
}

// Method to display login error alert
- (void)displayErrorAlertWithError: (NSError * _Nonnull)error {
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    alert.backgroundType = SCLAlertViewBackgroundBlur;
    [alert showError:self title:@"Signup Failed!" subTitle:error.localizedDescription closeButtonTitle:@"Try Again" duration:0.0f];
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

// Helper Method to disable Signup button
- (void)disableSignupButton {
    self.signupButton.enabled = NO;
    self.signupButton.alpha = 0.625;
}

// Helper Method to enable Signup button
- (void)enableSignupButton {
    self.signupButton.enabled = YES;
    self.signupButton.alpha = 1;
}

# pragma mark - Delegate Methods

// Method that gets called everytime text in Text Field Changes (UITextField's Delegate Method) - enabling/disabling Signup button is handled here
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
        [self enableSignupButton];
    } else {
        [self disableSignupButton];
    }
    return YES;
}

@end
