//
//  HomeViewController.m
//  StudyNotes
//
//  Created by Aayush Mani Phuyal on 7/13/20.
//  Copyright © 2020 Aayush Phuyal. All rights reserved.
//

#import "HomeViewController.h"
#import "HomeCollectionCell.h"
#import <Parse/Parse.h>
#import "SceneDelegate.h"
#import "LoginViewController.h"
#import <UserNotifications/UserNotifications.h>

@interface HomeViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

// MARK: Properties
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSArray *segueIdentifierArray;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    self.segueIdentifierArray = @[@"notesSegue", @"mathSegue"];
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *) self.collectionView.collectionViewLayout;
    layout.minimumInteritemSpacing = 2.5;
    layout.minimumLineSpacing = 2.5;
    CGFloat postersPerLine = 2;
    CGFloat itemWidth = (self.collectionView.frame.size.width - layout.minimumInteritemSpacing * (postersPerLine - 1))/postersPerLine;
    layout.itemSize = CGSizeMake(itemWidth, itemWidth*1.5);
    
    [self askNotificationPermission];
}

// Method that asks permission for notification and sending a test notification
- (void) askNotificationPermission {
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    UNAuthorizationOptions options = UNAuthorizationOptionAlert+UNAuthorizationOptionSound;
    [center requestAuthorizationWithOptions:options completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (granted) {
            [self scheduleNotification];
            
            
        }
    }];
}

// Method that schedules notification
- (void) scheduleNotification {
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    UNNotificationCategory *category = [UNNotificationCategory categoryWithIdentifier:@"testPushNotification" actions:@[] intentIdentifiers:@[] options:UNNotificationCategoryOptionNone];
    [center setNotificationCategories:[[NSSet alloc] initWithArray:@[category]]];
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.categoryIdentifier = @"testPushNotification";
    content.title = @"StudyNotes Notification";
    content.body = @"Please check out the note by pulling down or using 3D touch";
    content.sound = [UNNotificationSound defaultSound];
    
    UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:60 repeats:YES];
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"Test" content:content trigger:trigger];
    [center addNotificationRequest:request withCompletionHandler:nil];
}

// Logging out the user when Logout button is tapped
- (IBAction)onLogout:(id)sender {
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
        if (!error) {
            SceneDelegate *sceneDelegate = (SceneDelegate *)self.view.window.windowScene.delegate;
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
            sceneDelegate.window.rootViewController = loginViewController;
        }
    }];
}

#pragma mark - Delegate Methods

// Method to configure the Collection View's cell (Collection View Data Source's required method)
- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    HomeCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HomeCollectionCell" forIndexPath:indexPath];
    return cell;
}

// Method to find out the number of items in Collection View (Collection View Data Source's required method)
- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.segueIdentifierArray.count;
}

// Method to manually segue from collection cell to respective view controllers
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *segueIdentifier = self.segueIdentifierArray[indexPath.item];
    [self performSegueWithIdentifier:segueIdentifier sender:nil];
}

@end
