//
//  NotificationSetup.m
//  StudyNotes
//
//  Created by Aayush Mani Phuyal on 7/21/20.
//  Copyright © 2020 Aayush Phuyal. All rights reserved.
//

#import "NotificationSetup.h"
#import "Note.h"

@implementation NotificationSetup

// Method to schedule all notifications using a loop
+ (void)scheduleNotificationFrom:(NSDate *)fromDateTime to:(NSDate *)toDateTime separatedByIntervalInSeconds:(NSInteger)intervalInSeconds {
    NSDate *notificationDateTime = fromDateTime;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier: NSCalendarIdentifierGregorian];
    NSInteger toHourComponent = [self hourAndMinuteComponentForTime:toDateTime].hour;
    NSInteger toMinuteComponent = [self hourAndMinuteComponentForTime:toDateTime].minute;
    NSDate *dailyEndTime = [calendar dateBySettingHour:toHourComponent minute:toMinuteComponent second:00 ofDate:fromDateTime options:0];

    while ([self dateTime:notificationDateTime isBefore:toDateTime]) {
        [self scheduleNotificationForTime:notificationDateTime];
        notificationDateTime = [notificationDateTime dateByAddingTimeInterval:intervalInSeconds];
        // Skipping to tomorrow once notification is done for today
        if (![self dateTime:notificationDateTime isBefore:dailyEndTime]) {
            // All differences are between today's EndTime and tomorrow's StartTime
            NSInteger dailyStartTimeHourComponent = [self hourAndMinuteComponentForTime:fromDateTime].hour;
            NSInteger dailyEndTimeHourComponent = [self hourAndMinuteComponentForTime:toDateTime].hour;
            NSInteger dailyStartTimeMinuteComponent = [self hourAndMinuteComponentForTime:fromDateTime].minute;
            NSInteger dailyEndTimeMinuteComponent = [self hourAndMinuteComponentForTime:toDateTime].minute;
            NSInteger hoursDifference = 24 - (dailyEndTimeHourComponent - dailyStartTimeHourComponent);
            NSInteger minutesDifference = dailyStartTimeMinuteComponent - dailyEndTimeMinuteComponent;
            NSInteger timeDifferenceInSeconds = hoursDifference*3600 + minutesDifference*60;
            notificationDateTime = [dailyEndTime dateByAddingTimeInterval:timeDifferenceInSeconds];
            dailyEndTime = [dailyEndTime dateByAddingTimeInterval:24*60*60];
        }
    }
}

#pragma mark - Helper Methods for Scheduling Notifications

// Method to get hour and minute components from a Date
+ (NSDateComponents *) hourAndMinuteComponentForTime: (NSDate *)dateTime {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:dateTime];
    return components;
}

// Method to compare two dates (one is earlier than other)
+ (BOOL) dateTime: (NSDate * )firstTime isBefore: (NSDate * )secondTime {
    if ([firstTime compare:secondTime] == NSOrderedDescending) {
        return NO;
    } else {
        return YES;
    }
}

// Method to schedule a single notification at given time
+ (void) scheduleNotificationForTime: (NSDate * _Nullable)dateTime {
    Note *notificationNote = [Note getNoteforPushNotification];
    if (notificationNote) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
        content.title =notificationNote.noteTitle;
        content.body = notificationNote.noteDescription;;
        content.sound = [UNNotificationSound defaultSound];

        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [calendar components:( NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:dateTime];
        UNCalendarNotificationTrigger *dateTimeTrigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:components repeats:NO];
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:[NSString stringWithFormat:@"%u", arc4random()] content:content trigger:dateTimeTrigger];
        [center addNotificationRequest:request withCompletionHandler:nil];
    }
}

@end
