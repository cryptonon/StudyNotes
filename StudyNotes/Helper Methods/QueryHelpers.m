//
//  QueryHelpers.m
//  StudyNotes
//
//  Created by Aayush Mani Phuyal on 8/8/20.
//  Copyright © 2020 Aayush Phuyal. All rights reserved.
//

#import "QueryHelpers.h"

// MARK: Helper Methods Implementaion

// Method that fetches UserSetting provided a local UserSetting object
void FetchCompleteSettingWithCompletion(UserSetting *settingFromUserQuery, userSettingCompletion completionBlock) {
    [settingFromUserQuery fetchInBackgroundWithBlock:^(PFObject * _Nullable setting, NSError * _Nullable error) {
        UserSetting *userSetting = (UserSetting *) setting;
        completionBlock(userSetting, error);
    }];
}

// Method that fetches current user's setting
void QueryForCurrentUserSettingWithCompletion(userSettingCompletion completionBlock) {
    PFUser *currentUser = [PFUser currentUser];
    UserSetting *setting = currentUser[@"setting"];
    FetchCompleteSettingWithCompletion(setting, completionBlock);
}
