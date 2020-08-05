//
//  DateTimeHelpers.m
//  StudyNotes
//
//  Created by Aayush Mani Phuyal on 8/5/20.
//  Copyright © 2020 Aayush Phuyal. All rights reserved.
//

#import "DateTimeHelpers.h"

// MARK: Helper Methods Implementation

// Method to get hour and minute components from NSDate
NSDateComponents *hourAndMinuteComponentForTimeOfNSDate(NSDate *dateTime) {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *hourAndMinuteComponents = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:dateTime];
    return hourAndMinuteComponents;
}

// Method that combines date and time (returns NSDate with date of first and with time of second)
NSDate *combineDateWithTimeOfNSDate(NSDate *date, NSDate *dateTime) {
    NSInteger hourComponent = hourAndMinuteComponentForTimeOfNSDate(dateTime).hour;
    NSInteger minuteComponent = hourAndMinuteComponentForTimeOfNSDate(dateTime).minute;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier: NSCalendarIdentifierGregorian];
    NSDate *combinedNSDate = [calendar dateBySettingHour:hourComponent minute:minuteComponent second:00 ofDate:date options:0];
    return combinedNSDate;
}

// Method to compare two dates (if one is earlier than other)
BOOL dateTimeIsBefore(NSDate *dateTime, NSDate *referenceDateTime) {
    if ([dateTime compare:referenceDateTime] == NSOrderedDescending) {
        return NO;
    } else {
        return YES;
    }
}

// Method to calculate daily skip interval to go to tomorrow
NSTimeInterval dailySkipIntervalInSecondsBetweenStartAndEndTime(NSDate *notificationStartDateTime, NSDate *notificationEndDateTime) {
    NSDate *endTimeForToday = combineDateWithTimeOfNSDate(notificationStartDateTime, notificationEndDateTime);
    NSDate *tomorrow = [notificationStartDateTime dateByAddingTimeInterval:24*60*60];
    NSDate *startTimeForTomorrow = combineDateWithTimeOfNSDate(tomorrow, notificationStartDateTime);
    NSTimeInterval timeIntervalInSeconds = [startTimeForTomorrow timeIntervalSinceDate:endTimeForToday];
    return timeIntervalInSeconds;
}
