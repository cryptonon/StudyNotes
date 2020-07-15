//
//  UserSetting.m
//  StudyNotes
//
//  Created by Aayush Mani Phuyal on 7/15/20.
//  Copyright © 2020 Aayush Phuyal. All rights reserved.
//

#import "UserSetting.h"

@implementation UserSetting

// Declaring all properties as @dynamic
@dynamic settingID;
@dynamic user;
@dynamic from;
@dynamic to;
@dynamic intervalBetweenNotifications;
@dynamic notificationTurnedOn;

// Class method to post new setting to parse
+ (void)postSettingWithNotificationsTurnedOn:(BOOL)notificationTurnedOn from:(NSDate *)from to:(NSDate *)to withIntervalOf:(NSNumber *)intervalBetweenNotifications withCompletion:(PFBooleanResultBlock)completion {
}

- (void)updateSettingWithNotificationsTurnedOn:(BOOL)notificationTurnedOn from:(NSDate *)from to:(NSDate *)to withIntervalOf:(NSNumber *)intervalBetweenNotifications withCompletion:(PFBooleanResultBlock)completion {
}

# pragma mark - Delegate Methods

// Required delegate method for conforming to PFSubclassing protocol
+ (nonnull NSString *)parseClassName {
    return @"UserSetting";
}

@end
