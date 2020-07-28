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

@interface HomeViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

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

@end
