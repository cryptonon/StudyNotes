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

@interface HomeViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UIAdaptivePresentationControllerDelegate>

// MARK: Properties
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSArray *segueIdentifierArray;
@property (strong, nonatomic) NSArray *cellNameArray;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    self.segueIdentifierArray = @[@"notesSegue", @"numbersFactSegue"];
    self.cellNameArray = @[@"Notes", @"Numbers"];
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

// Method that handles popover menu and its actions
- (IBAction)onMenu:(id)sender {
    NSArray *titles = @[@"Notifications", @"Logout", @"Cancel"];
    NSArray *descriptions = @[@"Go to Notifications Settings", @"Logout from Current Account", @"Go back to previous Screen"];
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
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Are you sure you want to logout?"
                                                                   message:nil
                                                            preferredStyle:(UIAlertControllerStyleActionSheet)];
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Log Out"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull action) {
        [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
            if (!error) {
                SceneDelegate *sceneDelegate = (SceneDelegate *)self.view.window.windowScene.delegate;
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
                sceneDelegate.window.rootViewController = loginViewController;
            } else {
                SCLAlertView *alert = [[SCLAlertView alloc] init];
                alert.backgroundType = SCLAlertViewBackgroundBlur;
                [alert showError:self title:@"Logout Failed!" subTitle:error.localizedDescription closeButtonTitle:@"OK" duration:0.0f];
            }
        }];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"No"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    [yesAction setValue:[UIColor redColor] forKey:@"titleTextColor"];
    [alert addAction:yesAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
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

@end
