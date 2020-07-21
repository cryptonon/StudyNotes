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
+ (void)scheduleNotificationFrom:(NSDate *)fromDate to:(NSDate *)toDate separatedByInterval:(NSInteger)interval fromStartTime:(NSDate *)startTime toEndTime:(NSDate *)endTime {
    NSDate *trackingDate = fromDate;
    while ([self dateTime:trackingDate isBefore:toDate]) {
        [self scheduleNotificationWithNote:nil forTime:trackingDate];
        trackingDate = [trackingDate dateByAddingTimeInterval:interval];
        if ([self hourComponentForTime:trackingDate] > [self hourComponentForTime:endTime] ) {
            trackingDate = endTime;
            trackingDate = [trackingDate dateByAddingTimeInterval:(24-([self hourComponentForTime:endTime] - [self hourComponentForTime:startTime]))*3600];
        }
    }
}

#pragma mark - Helper Methods for Notification Scheduling

// Method to get hour components from a Date
+ (NSInteger) hourComponentForTime: (NSDate *)dateTime {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:dateTime];
    return [components hour];
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
+ (void) scheduleNotificationWithNote: (Note * _Nullable)note forTime: (NSDate * _Nullable)dateTime {
    [Note getNoteforPushNotificationWithCompletion:^(Note * _Nullable note, NSError * _Nullable error) {
        if (note) {
            UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
            UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
            content.title =note.noteTitle;
            content.body = note.noteDescription;;
            content.sound = [UNNotificationSound defaultSound];

            NSCalendar *calendar = [NSCalendar currentCalendar];
            NSDateComponents *components = [calendar components:( NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:dateTime];
            UNCalendarNotificationTrigger *dateTimeTrigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:components repeats:NO];
            UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:[NSString stringWithFormat:@"%u", arc4random()] content:content trigger:dateTimeTrigger];
            [center addNotificationRequest:request withCompletionHandler:nil];
        }
    }];
}

@end
