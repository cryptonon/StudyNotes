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
#import <SCLAlertView.h>
@import PopOverMenu;
#import "UICustomizationHelpers.h"
#import "NotificationSetup.h"
#import "DateTimeHelpers.h"
#import <UserNotifications/UserNotifications.h>
#import "QueryHelpers.h"

@interface HomeViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UIAdaptivePresentationControllerDelegate>

// MARK: Properties
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSArray *segueIdentifierArray;
@property (strong, nonatomic) NSArray *cellNameArray;
@property (strong, nonatomic) NSString *username;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addSwipeGestureRecognizer];
    [self setCollectionViewBackground];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.username = [PFUser currentUser].username;
    self.segueIdentifierArray = @[@"notesSegue", @"numbersFactSegue"];
    self.cellNameArray = @[@"My Notes", @"Numbers"];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    // Collection view cell size setup
    CGFloat postersPerLine;
    CGSize collectionViewSize = self.collectionView.frame.size;
    if (collectionViewSize.width >= 800) {
        postersPerLine = 3;
    } else {
        postersPerLine = 2;
    }
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *) self.collectionView.collectionViewLayout;
    layout.minimumInteritemSpacing = 2.5;
    layout.minimumLineSpacing = 2.5;
    CGFloat itemWidth = (collectionViewSize.width - layout.minimumInteritemSpacing * (postersPerLine - 1))/postersPerLine;
    layout.itemSize = CGSizeMake(itemWidth, itemWidth);
}

// Method that sets collectionView Background to app theme image
- (void)setCollectionViewBackground {
    UIImage *collectionViewBgImage = [UIImage imageNamed:@"note"];
    SetBackgroundForCollectionView(self.collectionView, collectionViewBgImage, 0.25);
}

// Method to add Swipe Gesture Recognizer (LeftSwipe) to switch tabs
- (void)addSwipeGestureRecognizer {
    UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleTabSwitching:)];
    swipeGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeGesture];
}

// Method that handles swipeGesture and tab switching (switches to home tab)
- (void)handleTabSwitching: (UISwipeGestureRecognizer *) swipeGesture {
    self.tabBarController.selectedIndex = 1;
}

// Method that handles popover menu and its actions
- (IBAction)onMenu:(id)sender {
    NSArray *titles = @[@"Notifications", @"Logout", @"Cancel"];
    NSString *logoutMessage = [NSString stringWithFormat:@"Logout from %@", self.username];
    NSArray *descriptions = @[@"Go to Notifications Settings", logoutMessage, @"Cancel the Menu"];
    PopOverViewController *popOverViewController = [PopOverViewController instantiate];
    [popOverViewController setWithTitles:titles];
    [popOverViewController setWithDescriptions:descriptions];
    popOverViewController.popoverPresentationController.barButtonItem = sender;
    popOverViewController.preferredContentSize = CGSizeMake(400, 135);
    popOverViewController.presentationController.delegate = self;
    [popOverViewController setCompletionHandler:^(NSInteger selectRow) {
        switch (selectRow) {
            case 0:
                [self performSegueWithIdentifier:@"settingsSegue" sender:self];
                break;
            case 1:
                [self performLogout];
                break;
            case 2:
                break;
        }
    }];
    [self presentViewController:popOverViewController animated:YES completion:nil];
}

// Logging out the user when Logout is selected from dropdown menu
- (void)performLogout {
    PFUser *currentUser = [PFUser currentUser];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Are you sure you want to logout?"
                                                                   message:nil
                                                            preferredStyle:(UIAlertControllerStyleActionSheet)];
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Log Out"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull action) {
        [self logoutUser:currentUser];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"No"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    [yesAction setValue:[UIColor redColor] forKey:@"titleTextColor"];
    [alert addAction:yesAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

// Method that logs out the current user
- (void)logoutUser: (PFUser *)currentUser {
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
        if (!error) {
            [self removePendingNotificationsForUser:currentUser];
            [self presentLoginViewController];
        } else {
            SCLAlertView *alert = [[SCLAlertView alloc] init];
            alert.backgroundType = SCLAlertViewBackgroundBlur;
            [alert showError:self title:@"Logout Failed!" subTitle:error.localizedDescription closeButtonTitle:@"OK" duration:0.0f];
        }
    }];
}

// Helper method that presents LoginViewController after successful logout
- (void)presentLoginViewController {
    SceneDelegate *sceneDelegate = (SceneDelegate *)self.view.window.windowScene.delegate;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    sceneDelegate.window.rootViewController = loginViewController;
}

// Method that removes all pending notifications on Logout and updates notificationCanceledOnLogout flag
- (void)removePendingNotificationsForUser: (PFUser *)currentUser {
    [[UNUserNotificationCenter currentNotificationCenter] removeAllPendingNotificationRequests];
    UserSetting *setting = currentUser[@"setting"];
    FetchCompleteSettingWithCompletion(setting, ^(UserSetting * _Nullable setting, NSError * _Nullable error) {
        if (setting) {
            UserSetting *userSetting = (UserSetting *) setting;
            if ([self notificationNeedsResumingWithSettings:userSetting]) {
                setting.notificationCanceledOnLogout = YES;
            } else {
                setting.notificationTurnedOn = NO;
            }
            [setting saveInBackground];
        }
    });
}

#pragma mark - Delegate Methods

// Method to configure the Collection View's cell (Collection View Data Source's required method)
- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    HomeCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HomeCollectionCell" forIndexPath:indexPath];
    cell.indexPath = indexPath;
    cell.cellNameLabel.text = self.cellNameArray[indexPath.item];
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

// Method for setting menu presentation style (PopOverMenu Delegate Method)
- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationNone;
}

// Method for setting menu presentation style (PopOverMenu Delegate Method)
- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller traitCollection:(UITraitCollection *)traitCollection {
    return UIModalPresentationNone;
}

// Method that resumes/reschedules notification (ResumingNotificationDelegate's required method)
- (void)resumeNotificationsWithSetting:(UserSetting *)setting {
    setting.notificationCanceledOnLogout = NO;
    if ([self notificationNeedsResumingWithSettings:setting]) {
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        alert.backgroundType = SCLAlertViewBackgroundBlur;
        alert.customViewColor = [UIColor systemBlueColor];
        [alert addButton:@"Resume" actionBlock:^(void) {
            [NotificationSetup scheduleNotificationFrom:setting.from to:setting.to separatedByIntervalInSeconds:[setting.intervalBetweenNotifications intValue]];
        }];
        [alert showEdit:self title:@"Do you want to resume notifications" subTitle:@"Your scheduled notifications were canceled because you logged out. Do you want to resume notifications" closeButtonTitle:@"No Thanks" duration:0.0f];
    } else {
        setting.notificationTurnedOn = NO;
    }
    [setting saveInBackground];
}

# pragma mark - Helper Methods

// Helper Method that checks whether resuming notifications is needed (depending upon interval, current time, and toTime)
- (BOOL)notificationNeedsResumingWithSettings: (UserSetting *)setting {
    NSDate *currentTime = [NSDate date];
    NSInteger intervalBetweenNotificationsInSeconds = [setting.intervalBetweenNotifications intValue];
    NSDate *nextNotificationTime = [currentTime dateByAddingTimeInterval:intervalBetweenNotificationsInSeconds];
    NSDate *notificationEndTime = setting.to;
    BOOL notificationTurnedOn = setting.notificationTurnedOn;
    if (notificationTurnedOn) {
        if (DateTimeIsBefore(nextNotificationTime, notificationEndTime)) {
            return YES;
        }
    }
    return NO;
}

@end
