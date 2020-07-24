//
//  DateTimeHelper.m
//  StudyNotes
//
//  Created by Aayush Mani Phuyal on 7/24/20.
//  Copyright © 2020 Aayush Phuyal. All rights reserved.
//

#import "DateTimeHelper.h"

@implementation DateTimeHelper

// Method to get hour and minute components from NSDate
+ (NSDateComponents *)hourAndMinuteComponentForTimeOfNSDate:(NSDate *)dateTime {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *hourAndMinuteComponents = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:dateTime];
    return hourAndMinuteComponents;
}

// Method that combines date and time (returns NSDate with date of first and with time of second)
+ (NSDate *)combinedDate:(NSDate *)date withTimeOfNSDate:(NSDate *)dateTime {
    NSInteger hourComponent = [self hourAndMinuteComponentForTimeOfNSDate:dateTime].hour;
    NSInteger minuteComponent = [self hourAndMinuteComponentForTimeOfNSDate:dateTime].minute;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier: NSCalendarIdentifierGregorian];
    NSDate *combinedNSDate = [calendar dateBySettingHour:hourComponent minute:minuteComponent second:00 ofDate:date options:0];
    return combinedNSDate;
}

// Method to compare two dates (if one is earlier than other)
+ (BOOL)dateTime: (NSDate * )firstTime isBefore: (NSDate * )secondTime {
    if ([firstTime compare:secondTime] == NSOrderedDescending) {
        return NO;
    } else {
        return YES;
    }
}

// Method to calculate daily skip interval to go to tomorrow
+ (NSTimeInterval)dailySkipIntervalInSecondsForStart:(NSDate *)notificationStartDateTime andEnd:(NSDate *)notificationEndDateTime {
    NSDate *endTimeForToday = [self combinedDate:notificationStartDateTime withTimeOfNSDate:notificationEndDateTime];
    NSDate *tomorrow = [notificationStartDateTime dateByAddingTimeInterval:24*60*60];
    NSDate *startTimeForTomorrow = [self combinedDate:tomorrow withTimeOfNSDate:notificationStartDateTime];
    NSTimeInterval timeIntervalInSeconds = [startTimeForTomorrow timeIntervalSinceDate:endTimeForToday];
    return timeIntervalInSeconds;
}

@end
