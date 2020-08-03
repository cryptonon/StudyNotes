//
//  SettingsViewController.m
//  StudyNotes
//
//  Created by Aayush Mani Phuyal on 7/13/20.
//  Copyright © 2020 Aayush Phuyal. All rights reserved.
//

#import "SettingsViewController.h"
#import "UserSetting.h"
#import "NotificationSetup.h"
#import <JGProgressHUD/JGProgressHUD.h>
#import "DateTimeHelper.h"
#import <SCLAlertView.h>
#import "CreateNoteViewController.h"

// Constants required for adding shadow to containers
#define shadeColor [[UIColor colorWithRed:0 green:0 blue:0 alpha:0.875f] CGColor];
const CGSize shadowOffset = {0.0f, 2.0f};
const CGFloat shadowOpacity = 1.0f;
const CGFloat shadowRadius = 5.0f;

@interface SettingsViewController () <CreateNoteViewControllerDelegate>

// MARK: Properties
@property (weak, nonatomic) IBOutlet UIDatePicker *fromDatePicker;
@property (weak, nonatomic) IBOutlet UIDatePicker *toDatePicker;
@property (weak, nonatomic) IBOutlet UIDatePicker *intervalTimePicker;
@property (weak, nonatomic) IBOutlet UISwitch *notificationSwitch;
@property (weak, nonatomic) IBOutlet UIDatePicker *startTimePicker;
@property (weak, nonatomic) IBOutlet UIDatePicker *endTimePicker;
@property (nonatomic) BOOL notificationPermissionAllowed;
@property (strong, nonatomic) UserSetting *currentUserSetting;
@property (weak, nonatomic) IBOutlet UIView *switchContainer;
@property (weak, nonatomic) IBOutlet UIView *fromDateContainer;
@property (weak, nonatomic) IBOutlet UIView *toDateContainer;
@property (weak, nonatomic) IBOutlet UIView *timeIntervalContainer;
@property (weak, nonatomic) IBOutlet UIView *startTimeContainer;
@property (weak, nonatomic) IBOutlet UIView *endTimeContainer;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *updateButton;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self askNotificationPermission];
    [self configureInitialView];
    [self setviewProperties];
    [self setScrollViewBackground];
    [self setShadowForAllContainers];
    [self checkNoteAvailability];
}

// Method that sets up first time default view of SettingViewController
- (void)configureInitialView {
    self.notificationSwitch.on = NO;
    [self setUpdateButtonHidden:YES];
    [self setTimePickeContainersHidden:YES];
}

// Method that updates SettingViewController's view as per user's saved settings
- (void)setviewProperties {
    PFQuery *settingQuery = [UserSetting query];
    [settingQuery whereKey:@"user" equalTo:[PFUser currentUser]];
    [settingQuery findObjectsInBackgroundWithBlock:^(NSArray<UserSetting*> * _Nullable settings, NSError * _Nullable error) {
        if (!error) {
            if (settings.count) {
                UserSetting *currentSetting = settings[0];
                self.notificationSwitch.on = currentSetting.notificationTurnedOn;
                self.toDatePicker.date = currentSetting.to;
                self.intervalTimePicker.countDownDuration = [currentSetting.intervalBetweenNotifications intValue];
                self.startTimePicker.date = currentSetting.from;
                self.endTimePicker.date = currentSetting.to;
                self.currentUserSetting = currentSetting;
                [self didTapNotificationSwitch:self.notificationSwitch];
            }
        }
    }];
}

// Method that sets scrollView's background
- (void)setScrollViewBackground {
    self.contentView.backgroundColor = [UIColor clearColor];
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"note"]];
    backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    backgroundImageView.alpha = 0.25;
    [self.scrollView insertSubview:backgroundImageView atIndex:0];
}

// Method that sets shadow for all containers
-(void)setShadowForAllContainers {
    [self setShadowForContainer:self.switchContainer];
    [self setShadowForContainer:self.fromDateContainer];
    [self setShadowForContainer:self.toDateContainer];
    [self setShadowForContainer:self.timeIntervalContainer];
    [self setShadowForContainer:self.startTimeContainer];
    [self setShadowForContainer:self.endTimeContainer];
}

// Helper method that sets shadow for a container
-(void)setShadowForContainer: (UIView *)container {
    container.layer.shadowColor = shadeColor;
    container.layer.shadowOffset = shadowOffset;
    container.layer.shadowOpacity = shadowOpacity;
    container.layer.shadowRadius = shadowRadius;
    container.layer.masksToBounds = NO;
}

// Method to update user settings when Update button is tapped
- (IBAction)onUpdate:(id)sender {
    JGProgressHUD *progressHUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
    progressHUD.textLabel.text = @"Updating...";
    [progressHUD showInView:self.view];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self performSelectorOnMainThread:@selector(updateUserSettingsAndScheduleNotifications) withObject:nil waitUntilDone:YES];
        [progressHUD dismiss];
        [self.navigationController popViewControllerAnimated:YES];
    });
}

// Helper method that checks note availability before updating settings
-(void)checkNoteAvailability {
    PFQuery *noteQuery = [PFQuery queryWithClassName:@"Note"];
    [noteQuery whereKey:@"author" equalTo:[PFUser currentUser]];
    [noteQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (objects) {
            if (objects.count) {
                [self setUpdateButtonHidden:NO];
            } else {
                [self presentNoNoteAlert];
            }
        }
    }];
}

// Helper Method that presents no note alert
- (void)presentNoNoteAlert {
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    alert.backgroundType = SCLAlertViewBackgroundBlur;
    alert.customViewColor = [UIColor systemBlueColor];
    [alert addButton:@"Create Note" actionBlock:^(void) {
        [self performSegueWithIdentifier:@"composeNoteSegue" sender:self];
    }];
    [alert showEdit:self title:@"No Notes!" subTitle:@"Please add a few Notes before updating notification settings" closeButtonTitle:@"Cancel" duration:0.0f];
}

// Helper method to hide/unhide update button
- (void)setUpdateButtonHidden: (BOOL)hidden {
    if (hidden) {
        [self.updateButton setEnabled:NO];
    } else {
        [self.updateButton setEnabled:YES];
    }
}

- (void)postedNote:(Note *)newNote {
    [self setUpdateButtonHidden:NO];
}

// Method that handles upating/creating settings and scheduling notifications
- (void)updateUserSettingsAndScheduleNotifications {
    [self combineDateTime];
    if (self.currentUserSetting) {
        [self.currentUserSetting updateSettingWithNotificationsTurnedOn:self.notificationSwitch.on from:self.fromDatePicker.date to:self.toDatePicker.date withIntervalOf:@(self.intervalTimePicker.countDownDuration) withCompletion:nil];
    } else {
        [UserSetting postSettingWithNotificationsTurnedOn:self.notificationSwitch.on from:self.fromDatePicker.date to:self.toDatePicker.date withIntervalOf:@(self.intervalTimePicker.countDownDuration) withCompletion:nil];
    }
    // Notification scheduling starts here
    [[UNUserNotificationCenter currentNotificationCenter] removeAllPendingNotificationRequests];
    if (self.notificationPermissionAllowed && self.notificationSwitch.on) {
        [NotificationSetup scheduleNotificationFrom:self.fromDatePicker.date to:self.toDatePicker.date separatedByIntervalInSeconds:self.intervalTimePicker.countDownDuration];
    }
}

// Method that asks permission for sending notifications
- (void) askNotificationPermission {
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    UNAuthorizationOptions options = UNAuthorizationOptionAlert+UNAuthorizationOptionSound;
    [center requestAuthorizationWithOptions:options completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (granted) {
            self.notificationPermissionAllowed = YES;
        }
    }];
}

// Method for hiding/unhiding time pickers based on notification switch
- (IBAction)didTapNotificationSwitch:(id)sender {
    if (!self.notificationSwitch.on) {
        [self setTimePickeContainersHidden:YES];
    } else {
        [self setTimePickeContainersHidden:NO];
    }
}

// Helper method for hiding/unhiding time picker containers
-(void)setTimePickeContainersHidden: (BOOL) hidden {
    [self.fromDateContainer setHidden:hidden];
    [self.toDateContainer setHidden:hidden];
    [self.timeIntervalContainer setHidden:hidden];
    [self.startTimeContainer setHidden:hidden];
    [self.endTimeContainer setHidden:hidden];
}

// Method to combine fromDate with startTime and toDate with endTime
- (void) combineDateTime {
    NSDate *notificationStartDateTime = [DateTimeHelper combinedDate:self.fromDatePicker.date withTimeOfNSDate:self.startTimePicker.date];
    NSDate *notificationEndDateTime = [DateTimeHelper combinedDate:self.toDatePicker.date withTimeOfNSDate:self.endTimePicker.date];
    self.fromDatePicker.date = notificationStartDateTime;
    self.toDatePicker.date = notificationEndDateTime;
}

# pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UINavigationController *navigationController = [segue destinationViewController];
    CreateNoteViewController *composeController = (CreateNoteViewController *) navigationController.topViewController;
    composeController.delegate = self;
}

@end
