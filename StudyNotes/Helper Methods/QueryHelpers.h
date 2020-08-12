//
//  QueryHelpers.h
//  StudyNotes
//
//  Created by Aayush Mani Phuyal on 8/8/20.
//  Copyright © 2020 Aayush Phuyal. All rights reserved.
//

#import "UserSetting.h"

NS_ASSUME_NONNULL_BEGIN

// Typedef for passing block as a parameter
typedef void (^userSettingCompletion)(UserSetting * _Nullable setting, NSError * _Nullable error);

// MARK: Helper Methods Declaration

void FetchCompleteSettingWithCompletion(UserSetting *settingFromUserQuery, userSettingCompletion completionBlock);
void QueryForCurrentUserSettingWithCompletion(userSettingCompletion completionBlock);

NS_ASSUME_NONNULL_END
