//
//  AppDelegate.m
//  StudyNotes
//
//  Created by Aayush Mani Phuyal on 7/13/20.
//  Copyright © 2020 Aayush Phuyal. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import <UserNotifications/UserNotifications.h>

@interface AppDelegate () <UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Parse Configuration
    [Parse enableDataSharingWithApplicationGroupIdentifier:@"group.com.aayushphuyal.StudyNotes"];
    Parse.server = @"https://aayushstudynotes.herokuapp.com/parse";
    [Parse setApplicationId:@"myAppId" clientKey:@""];
    
    // Notification Configuration
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate = self;
    
    return YES;
}

#pragma mark - Delegate Methods

// UNUserNotificationCenterDelegate method to show notification in foreground
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    UNNotificationPresentationOptions presentationOptions = UNNotificationPresentationOptionAlert + UNNotificationPresentationOptionSound;
    completionHandler(presentationOptions);
}

#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
}


@end
