//
//  DateTimeHelpers.h
//  StudyNotes
//
//  Created by Aayush Mani Phuyal on 8/5/20.
//  Copyright © 2020 Aayush Phuyal. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// MARK: Helper Method Declarations

NSDateComponents *HourAndMinuteComponentForTimeOfNSDate(NSDate *dateTime);
NSDate *CombineDateWithTimeOfNSDate(NSDate *date, NSDate *dateTime);
BOOL DateTimeIsBefore(NSDate *dateTime, NSDate *referenceDateTime);
NSTimeInterval DailySkipIntervalInSecondsBetweenStartAndEndTime(NSDate *notificationStartDateTime, NSDate *notificationEndDateTime);

NS_ASSUME_NONNULL_END
