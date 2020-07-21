//
//  NotificationSetup.h
//  StudyNotes
//
//  Created by Aayush Mani Phuyal on 7/21/20.
//  Copyright © 2020 Aayush Phuyal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UserNotifications/UserNotifications.h>

NS_ASSUME_NONNULL_BEGIN

@interface NotificationSetup : NSObject

// MARK: Methods
+ (void) scheduleNotificationFrom:(NSDate * _Nonnull)fromDate
                               to:(NSDate * _Nonnull)toDate
              separatedByInterval:(NSInteger)interval
                         fromStartTime:(NSDate * _Nonnull)startTime
                           toEndTime:(NSDate * _Nonnull)endTime;

@end

NS_ASSUME_NONNULL_END
