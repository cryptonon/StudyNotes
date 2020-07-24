//
//  NotificationSetup.m
//  StudyNotes
//
//  Created by Aayush Mani Phuyal on 7/21/20.
//  Copyright © 2020 Aayush Phuyal. All rights reserved.
//

#import "NotificationSetup.h"
#import "Note.h"
#import "DateTimeHelper.h"

@implementation NotificationSetup

// Method to schedule all notifications using a loop
+ (void)scheduleNotificationFrom:(NSDate *)fromDateTime to:(NSDate *)toDateTime separatedByIntervalInSeconds:(NSInteger)intervalInSeconds {
    NSDate *currentDateTime = [NSDate date];
    NSDate *notificationDateTime;
    if ([DateTimeHelper dateTime:fromDateTime isBefore:currentDateTime]) {
        notificationDateTime = currentDateTime;
    } else {
        notificationDateTime = fromDateTime;
    }
    NSDate *dailyEndTime = [DateTimeHelper combinedDate:fromDateTime withTimeOfNSDate:toDateTime];
    NSTimeInterval dailySkipIntervalInSeconds = [DateTimeHelper dailySkipIntervalInSecondsForStart:fromDateTime andEnd:toDateTime];

    while ([DateTimeHelper dateTime:notificationDateTime isBefore:toDateTime]) {
        [self scheduleNotificationForTime:notificationDateTime];
        notificationDateTime = [notificationDateTime dateByAddingTimeInterval:intervalInSeconds];
        // Skipping to tomorrow once notification is done for today
        if (![DateTimeHelper dateTime:notificationDateTime isBefore:dailyEndTime]) {
            notificationDateTime = [dailyEndTime dateByAddingTimeInterval:dailySkipIntervalInSeconds];
            dailyEndTime = [dailyEndTime dateByAddingTimeInterval:24*60*60];
        }
    }
}

#pragma mark - Helper Methods for Scheduling Notifications

// Method to schedule a single notification at given time
+ (void) scheduleNotificationForTime: (NSDate * _Nullable)dateTime {
    Note *notificationNote = [Note getNoteforPushNotification];
    if (notificationNote) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
        content.title = notificationNote.noteTitle;
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
