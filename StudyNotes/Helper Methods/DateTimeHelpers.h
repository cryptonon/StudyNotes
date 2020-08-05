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

NSDateComponents *hourAndMinuteComponentForTimeOfNSDate(NSDate *dateTime);
NSDate *combineDateWithTimeOfNSDate(NSDate *date, NSDate *dateTime);
BOOL dateTimeIsBefore(NSDate *dateTime, NSDate *referenceDateTime);
NSTimeInterval dailySkipIntervalInSecondsBetweenStartAndEndTime(NSDate *notificationStartDateTime, NSDate *notificationEndDateTime);

NS_ASSUME_NONNULL_END
