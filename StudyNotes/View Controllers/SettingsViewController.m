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
            }
        }
    }];
}

// Method to update user settings when Update button is tapped
- (IBAction)onUpdate:(id)sender {
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
    } else {
        [self.fromDatePicker setHidden:NO];
        [self.toDatePicker setHidden:NO];
        [self.intervalTimePicker setHidden:NO];
        [self.startTimePicker setHidden:NO];
        [self.endTimePicker setHidden:NO];
    }
}

# pragma mark - Helper methods for DateTime processing

// Method to combine fromDate with startTime and toDate with endTime
- (void) combineDateTime {
    NSDate *fromDate = self.fromDatePicker.date;
    NSDate *fromTime = self.startTimePicker.date;
    NSDate *toDate = self.toDatePicker.date;
    NSDate *toTime = self.endTimePicker.date;
    NSInteger fromHourComponent = [self hourAndMinuteComponentForTime:fromTime].hour;
    NSInteger fromMinuteComponent = [self hourAndMinuteComponentForTime:fromTime].minute;
    NSInteger toHourComponent = [self hourAndMinuteComponentForTime:toTime].hour;
    NSInteger toMinuteComponent = [self hourAndMinuteComponentForTime:toTime].minute;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier: NSCalendarIdentifierGregorian];
    NSDate *combinedFromDateTime = [calendar dateBySettingHour:fromHourComponent minute:fromMinuteComponent second:00 ofDate:fromDate options:0];
    self.fromDatePicker.date = combinedFromDateTime;
    NSDate *combinedToDateTime = [calendar dateBySettingHour:toHourComponent minute:toMinuteComponent second:00 ofDate:toDate options:0];
    self.toDatePicker.date = combinedToDateTime;
}


// Method to get hour and minute components from a Date
- (NSDateComponents *) hourAndMinuteComponentForTime: (NSDate *)dateTime {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:dateTime];
    return components;
}

@end
