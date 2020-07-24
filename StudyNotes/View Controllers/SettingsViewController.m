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

@interface SettingsViewController ()

// MARK: Properties
@property (weak, nonatomic) IBOutlet UIDatePicker *fromDatePicker;
@property (weak, nonatomic) IBOutlet UIDatePicker *toDatePicker;
@property (weak, nonatomic) IBOutlet UIDatePicker *intervalTimePicker;
@property (weak, nonatomic) IBOutlet UISwitch *notificationSwitch;
@property (weak, nonatomic) IBOutlet UIDatePicker *startTimePicker;
@property (weak, nonatomic) IBOutlet UIDatePicker *endTimePicker;
@property (nonatomic) BOOL notificationPermissionAllowed;
@property (strong, nonatomic) UserSetting *currentUserSetting;
@property (weak, nonatomic) IBOutlet UILabel *fromDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *toDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeIntervalLabel;
@property (weak, nonatomic) IBOutlet UILabel *startTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *endTimeLabel;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self askNotificationPermission];
    [self configureInitialView];
    [self setviewProperties];
}

// Method that sets up first time default view of SettingViewController
- (void)configureInitialView {
    self.fromDatePicker.minimumDate = [NSDate date];
    self.toDatePicker.minimumDate = [NSDate date];
    self.notificationSwitch.on = NO;
    [self.fromDatePicker setHidden:YES];
    [self.toDatePicker setHidden:YES];
    [self.intervalTimePicker setHidden:YES];
    [self.startTimePicker setHidden:YES];
    [self.endTimePicker setHidden:YES];
    [self.fromDateLabel setHidden:YES];
    [self.toDateLabel setHidden:YES];
    [self.timeIntervalLabel setHidden:YES];
    [self.startTimeLabel setHidden:YES];
    [self.endTimeLabel setHidden:YES];
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
        [self.fromDatePicker setHidden:YES];
        [self.toDatePicker setHidden:YES];
        [self.intervalTimePicker setHidden:YES];
        [self.startTimePicker setHidden:YES];
        [self.endTimePicker setHidden:YES];
        [self.fromDateLabel setHidden:YES];
        [self.toDateLabel setHidden:YES];
        [self.timeIntervalLabel setHidden:YES];
        [self.startTimeLabel setHidden:YES];
        [self.endTimeLabel setHidden:YES];
    } else {
        [self.fromDatePicker setHidden:NO];
        [self.toDatePicker setHidden:NO];
        [self.intervalTimePicker setHidden:NO];
        [self.startTimePicker setHidden:NO];
        [self.endTimePicker setHidden:NO];
        [self.fromDateLabel setHidden:NO];
        [self.toDateLabel setHidden:NO];
        [self.timeIntervalLabel setHidden:NO];
        [self.startTimeLabel setHidden:NO];
        [self.endTimeLabel setHidden:NO];
    }
}

// Method to combine fromDate with startTime and toDate with endTime
- (void) combineDateTime {
    NSDate *notificationStartDateTime = [DateTimeHelper combinedDate:self.fromDatePicker.date withTimeOfNSDate:self.startTimePicker.date];
    NSDate *notificationEndDateTime = [DateTimeHelper combinedDate:self.toDatePicker.date withTimeOfNSDate:self.endTimePicker.date];
    self.fromDatePicker.date = notificationStartDateTime;
    self.toDatePicker.date = notificationEndDateTime;
}

@end
