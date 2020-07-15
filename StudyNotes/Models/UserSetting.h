//
//  UserSetting.h
//  StudyNotes
//
//  Created by Aayush Mani Phuyal on 7/15/20.
//  Copyright © 2020 Aayush Phuyal. All rights reserved.
//

#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface UserSetting : PFObject <PFSubclassing>

// MARK: Properties
@property (nonatomic, strong) NSString *settingID;
@property (nonatomic, strong) PFUser *user;
@property (nonatomic, strong) NSDate *from;
@property (nonatomic, strong) NSDate *to;
@property (nonatomic) NSNumber *intervalBetweenNotifications;
@property (nonatomic) BOOL notificationTurnedOn;

//MARK: Methods
+ (void) postSettingWithNotificationsTurnedOn: ( BOOL )notificationTurnedOn
                                         from: ( NSDate * _Nonnull )from
                                           to: ( NSDate * _Nonnull )to
                               withIntervalOf:  ( NSNumber * _Nonnull )intervalBetweenNotifications
                               withCompletion: (PFBooleanResultBlock  _Nullable)completion;

- (void) updateSettingWithNotificationsTurnedOn: ( BOOL )notificationTurnedOn
                                           from: ( NSDate * _Nonnull )from
                                             to: ( NSDate * _Nonnull )to
                                 withIntervalOf:  ( NSNumber * _Nonnull )intervalBetweenNotifications
                                 withCompletion: (PFBooleanResultBlock  _Nullable)completion;

@end

NS_ASSUME_NONNULL_END
