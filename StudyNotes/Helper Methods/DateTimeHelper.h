//
//  DateTimeHelper.h
//  StudyNotes
//
//  Created by Aayush Mani Phuyal on 7/24/20.
//  Copyright © 2020 Aayush Phuyal. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DateTimeHelper : NSObject

// MARK: Methods
+ (NSDateComponents *)hourAndMinuteComponentForTimeOfNSDate:(NSDate *)dateTime;

+ (NSDate *)combinedDate:(NSDate *)date withTimeOfNSDate:(NSDate *)dateTime;

+ (BOOL)dateTime: (NSDate * )firstTime isBefore: (NSDate * )secondTime;

+ (NSTimeInterval)dailySkipIntervalInSecondsForStart:(NSDate *)notificationStartDateTime andEnd:(NSDate *)notificationEndDateTime;


@end

NS_ASSUME_NONNULL_END
