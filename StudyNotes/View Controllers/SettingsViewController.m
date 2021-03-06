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
#import "DateTimeHelpers.h"
#import <SCLAlertView.h>
#import "CreateNoteViewController.h"
#import "UICustomizationHelpers.h"
#import "QueryHelpers.h"

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
    [self configureTimePickers];
}

// Method that sets up first time default view of SettingViewController
- (void)configureInitialView {
    self.notificationSwitch.on = NO;
    [self setUpdateButtonHidden:YES];
    [self setTimePickeContainersHidden:YES];
}

// Method that updates SettingViewController's view as per user's saved settings
- (void)setviewProperties {
    QueryForCurrentUserSettingWithCompletion(^(UserSetting * _Nullable setting, NSError * _Nullable error) {
        if (setting) {
            UserSetting *currentSetting = (UserSetting *) setting;
            self.currentUserSetting = currentSetting;
            self.notificationSwitch.on = currentSetting.notificationTurnedOn;
            self.toDatePicker.date = currentSetting.to;
            if (DateTimeIsBefore(self.toDatePicker.date, [NSDate date])) {
                self.toDatePicker.date = [NSDate date];
            }
            self.intervalTimePicker.countDownDuration = [currentSetting.intervalBetweenNotifications intValue];
            self.startTimePicker.date = currentSetting.from;
            self.endTimePicker.date = currentSetting.to;
            self.currentUserSetting = currentSetting;
            [self didTapNotificationSwitch:self.notificationSwitch];
        }
    });
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
    CGColorRef shadowColor = [[UIColor colorWithRed:0 green:0 blue:0 alpha:0.875f] CGColor];
    CGSize shadowOffset = {0.0f, 2.0f};
    CGFloat shadowOpacity = 1.0f;
    CGFloat shadowRadius = 5.0f;
    SetShadowForView(self.switchContainer, shadowColor, shadowOpacity, shadowOffset, shadowRadius);
    SetShadowForView(self.fromDateContainer, shadowColor, shadowOpacity, shadowOffset, shadowRadius);
    SetShadowForView(self.toDateContainer, shadowColor, shadowOpacity, shadowOffset, shadowRadius);
    SetShadowForView(self.timeIntervalContainer, shadowColor, shadowOpacity, shadowOffset, shadowRadius);
    SetShadowForView(self.startTimeContainer, shadowColor, shadowOpacity, shadowOffset, shadowRadius);
    SetShadowForView(self.endTimeContainer, shadowColor, shadowOpacity, shadowOffset, shadowRadius);
}

// Method to update user settings when Update button is tapped
- (IBAction)onUpdate:(id)sender {
    JGProgressHUD *progressHUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleLight];
    progressHUD.textLabel.text = @"Updating";
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
    [noteQuery whereKey:@"isPersonalNote" equalTo:@(YES)];
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
    [self.currentUserSetting updateSettingWithNotificationsTurnedOn:self.notificationSwitch.on from:self.fromDatePicker.date to:self.toDatePicker.date withIntervalOf:@(self.intervalTimePicker.countDownDuration) withCompletion:nil];
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
    NSDate *notificationStartDateTime = CombineDateWithTimeOfNSDate(self.fromDatePicker.date, self.startTimePicker.date);
    NSDate *notificationEndDateTime = CombineDateWithTimeOfNSDate(self.toDatePicker.date, self.endTimePicker.date);
    self.fromDatePicker.date = notificationStartDateTime;
    self.toDatePicker.date = notificationEndDateTime;
}

# pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UINavigationController *navigationController = [segue destinationViewController];
    CreateNoteViewController *composeController = (CreateNoteViewController *) navigationController.topViewController;
    composeController.delegate = self;
}

# pragma mark - Handling Timers

// Method that configures minimum time interval for each timePickers
- (void)configureTimePickers {
    NSDate *currentDateTime = [NSDate date];
    self.fromDatePicker.minimumDate = currentDateTime;
    self.toDatePicker.minimumDate = currentDateTime;
    [self.fromDatePicker addTarget:self action:@selector(setToDate) forControlEvents:UIControlEventValueChanged];
    [self.startTimePicker addTarget:self action:@selector(setEndTime) forControlEvents:UIControlEventValueChanged];
}

// Method that changes toDate depending on fromDate
- (void)setToDate {
    self.toDatePicker.minimumDate = self.fromDatePicker.date;
}

// Method that changes toTime depending on startTime
- (void)setEndTime {
    self.endTimePicker.minimumDate = [self.startTimePicker.date dateByAddingTimeInterval:30*60];
}

@end
