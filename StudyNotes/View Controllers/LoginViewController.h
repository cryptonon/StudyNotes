//
//  LoginViewController.h
//  StudyNotes
//
//  Created by Aayush Mani Phuyal on 7/13/20.
//  Copyright © 2020 Aayush Phuyal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserSetting.h"

NS_ASSUME_NONNULL_BEGIN

// MARK: Protocols
@protocol ResumingNotificationDelegate

// Required Methods
- (void)resumeNotificationsWithSetting: (UserSetting *)setting;

@end

@interface LoginViewController : UIViewController

// MARK: Properties
@property (weak, nonatomic) id<ResumingNotificationDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
