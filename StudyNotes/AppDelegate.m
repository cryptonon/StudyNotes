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
@import Parse;

@interface AppDelegate () <UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Parse Configuration
    ParseClientConfiguration *config = [ParseClientConfiguration   configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {
        configuration.applicationId = @"myAppId";
        configuration.server = @"https://aayushstudynotes.herokuapp.com/parse";
    }];
    [Parse initializeWithConfiguration:config];
    [PFFacebookUtils initializeFacebookWithApplicationLaunchOptions:launchOptions];
    // Notification configuration
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate = self;
    return YES;
}

#pragma mark - Facebook SDK setup

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    return [FBSDKApplicationDelegate.sharedInstance application:app openURL:url sourceApplication:options[UIApplicationLaunchOptionsSourceApplicationKey] annotation:UIApplicationLaunchOptionsAnnotationKey];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
  [FBSDKAppEvents activateApp];
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
