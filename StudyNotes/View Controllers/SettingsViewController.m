//
//  SettingsViewController.m
//  StudyNotes
//
//  Created by Aayush Mani Phuyal on 7/13/20.
//  Copyright © 2020 Aayush Phuyal. All rights reserved.
//

#import "SettingsViewController.h"
#import "UserSetting.h"
#import "Note.h"
#import <UserNotifications/UserNotifications.h>

@interface SettingsViewController ()

// MARK: Properties
@property (weak, nonatomic) IBOutlet UIDatePicker *fromDatePicker;
@property (weak, nonatomic) IBOutlet UIDatePicker *toDatePicker;
@property (weak, nonatomic) IBOutlet UIDatePicker *intervalTimePicker;
@property (weak, nonatomic) IBOutlet UISwitch *notificationSwitch;
@property (strong, nonatomic) NSDate *startTime;
@property (strong, nonatomic) NSDate *endTime;
@property (strong, nonatomic) Note *notificationNote;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

// Method to update user settings when Update button is tapped
- (IBAction)onUpdate:(id)sender {
    [[UNUserNotificationCenter currentNotificationCenter] removeAllPendingNotificationRequests];
    PFQuery *settingQuery = [UserSetting query];
    [settingQuery whereKey:@"user" equalTo:[PFUser currentUser]];
    [settingQuery findObjectsInBackgroundWithBlock:^(NSArray<UserSetting*> * _Nullable settings, NSError * _Nullable error) {
        if (!error) {
            if (settings.count) {
                UserSetting *currentSetting = settings[0];
                [currentSetting updateSettingWithNotificationsTurnedOn:self.notificationSwitch.on from:self.fromDatePicker.date to:self.toDatePicker.date withIntervalOf:@(self.intervalTimePicker.countDownDuration) withCompletion:nil];
            } else {
                [UserSetting postSettingWithNotificationsTurnedOn:self.notificationSwitch.on from:self.fromDatePicker.date to:self.toDatePicker.date withIntervalOf:@(self.intervalTimePicker.countDownDuration) withCompletion:nil];
            }
        }
    }];
    self.startTime = [NSDate date];
    self.endTime = [[NSDate date] dateByAddingTimeInterval:300];
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.notificationSwitch.on) {
            [self scheduleNotificationTo:self.toDatePicker.date separatedByInterval:self.intervalTimePicker.countDownDuration];
        }
    }];
}

// Helper method to compare two dates
- (BOOL) dateTime: (NSDate * )firstTime isBefore: (NSDate * )secondTime {
    if ([firstTime compare:secondTime] == NSOrderedDescending) {
        return NO;
    } else {
        return YES;
    }
}

// Method to schedule a single notification at given time
- (void) scheduleNotificationWithNote: (Note * _Nullable)note forTime: (NSDate * _Nullable)dateTime {
    [Note getNoteforPushNotificationWithCompletion:^(Note * _Nullable note, NSError * _Nullable error) {
        if (note) {
            self.notificationNote = note;
        }
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
        content.title = self.notificationNote.noteTitle;
        content.body = self.notificationNote.noteDescription;;
        content.sound = [UNNotificationSound defaultSound];
        
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [calendar components:( NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:dateTime];
        UNCalendarNotificationTrigger *dateTimeTrigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:components repeats:NO];
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:[NSString stringWithFormat:@"%u", arc4random()] content:content trigger:dateTimeTrigger];
        [center addNotificationRequest:request withCompletionHandler:nil];
    }];
}

// Method to schedule all notifications using loop
- (void) scheduleNotificationTo: (NSDate * _Nullable)toDate separatedByInterval: (NSInteger)interval {
    NSDate *trackingDate = self.startTime;
    while ([self dateTime:trackingDate isBefore:toDate]) {
        //NSLog(@"Loop Entered!");
        [self scheduleNotificationWithNote:nil forTime:trackingDate];
        trackingDate = [trackingDate dateByAddingTimeInterval:interval];
        if ([self hourComponentForTime:trackingDate] > [self hourComponentForTime:self.endTime] ) {
            trackingDate = self.endTime;
            trackingDate = [trackingDate dateByAddingTimeInterval:(24-([self hourComponentForTime:self.endTime] - [self hourComponentForTime:self.startTime]))*3600];
        }
    }
}

// Method to get hour components from a Date
- (NSInteger) hourComponentForTime: (NSDate *)dateTime {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:dateTime];
    return [components hour];
}

@end
