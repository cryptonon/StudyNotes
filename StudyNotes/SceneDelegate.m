//
//  SceneDelegate.m
//  StudyNotes
//
//  Created by Aayush Mani Phuyal on 7/13/20.
//  Copyright © 2020 Aayush Phuyal. All rights reserved.
//

#import "SceneDelegate.h"
#import <Parse/Parse.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@interface SceneDelegate ()

@end

@implementation SceneDelegate


- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    // Persisting the logged in user
    PFUser *user = [PFUser currentUser];
    if (user != nil) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *homeNavigationController = [storyboard instantiateViewControllerWithIdentifier:@"HomeNavigationController"];
        self.window.rootViewController = homeNavigationController;
    }
}

# pragma mark - FBSDK Setup

- (void)scene:(UIScene *)scene openURLContexts:(NSSet<UIOpenURLContext *> *)URLContexts {
    UIOpenURLContext *urlContext = (UIOpenURLContext *)[[URLContexts allObjects] firstObject];
    if (!urlContext) return;
    NSURL *url = urlContext.URL;
    [FBSDKApplicationDelegate.sharedInstance application:UIApplication.sharedApplication openURL:url sourceApplication:nil annotation:@ [UIApplicationLaunchOptionsAnnotationKey]];
}

@end
