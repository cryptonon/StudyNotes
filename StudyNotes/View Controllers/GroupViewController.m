//
//  GroupViewController.m
//  StudyNotes
//
//  Created by Aayush Mani Phuyal on 8/2/20.
//  Copyright © 2020 Aayush Phuyal. All rights reserved.
//

#import "GroupViewController.h"
#import "GroupCell.h"
#import "NotesFeedViewController.h"
#import <SCLAlertView.h>
#import <JGProgressHUD/JGProgressHUD.h>
#import "UICustomizationHelper.h"

@interface GroupViewController () <UITableViewDelegate, UITableViewDataSource>

// MARK: Properties
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *groupArray;
@property (strong, nonnull) UIRefreshControl *refreshControl;

@end

@implementation GroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self customizeTableView];
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchGroups) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
    [self fetchGroups];
}

// Method that customizes tableView
- (void)customizeTableView {
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    UIImage *tableViewBgImage = [UIImage imageNamed:@"note"];
    [UICustomizationHelper setBackgroundForTableView:self.tableView withImage:tableViewBgImage withAlpha:0.25];
    self.tableView.tableFooterView = [UIView new];
}

// Method to deselect the selected row
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
    [self.tableView deselectRowAtIndexPath:selectedIndexPath animated:YES];
}

// Method that fetches groups form parse
-(void)fetchGroups {
    JGProgressHUD *progressHUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
    progressHUD.textLabel.text = @"Loading";
    [progressHUD showInView:self.view];
    PFQuery *groupQuery = [Group query];
    [groupQuery orderByDescending:@"createdAt"];
    [groupQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable groups, NSError * _Nullable error) {
        if(groups) {
            self.groupArray = (NSMutableArray *) groups;
            [self.tableView reloadData];
        }
        [progressHUD dismissAnimated:YES];
    }];
    [self.refreshControl endRefreshing];
}

// Method that handles new group creation
- (IBAction)onCreateGroup:(id)sender {
    [self configureNavAndTabBarUserInteraction];
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    alert.backgroundType = SCLAlertViewBackgroundBlur;
    alert.customViewColor = [UIColor systemBlueColor];
    UITextField *groupNameField = [alert addTextField:@"Name"];
    UITextField *groupDescriptionField = [alert addTextField:@"Description"];
    [alert addButton:@"Create" actionBlock:^(void) {
        NSCharacterSet *whiteSpaceSet = [NSCharacterSet characterSetWithCharactersInString:@" "];
        NSString *groupName = [groupNameField.text stringByTrimmingCharactersInSet:whiteSpaceSet];
        NSString *groupDescription = [groupDescriptionField.text stringByTrimmingCharactersInSet:whiteSpaceSet];
        if ([self validGroupName:groupName andDescription:groupDescription]) {
            NSString *newGroupID = [[NSUUID UUID] UUIDString];
            [Group createGroup:groupName withGroupID:newGroupID withDescription:groupDescription withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
                if (succeeded) {
                    Group *newGroup = [Group new];
                    newGroup.groupName = groupName;
                    newGroup.groupID = newGroupID;
                    newGroup.groupDescription = groupDescription;
                    newGroup.createdBy = [PFUser currentUser];
                    newGroup.noOfNotes = @(0);
                    [self.groupArray insertObject:newGroup atIndex:0];
                    [self.tableView reloadData];
                }
            }];
        }
    }];
    [alert showEdit:self title:@"Create Group" subTitle:@"Enter Group Details" closeButtonTitle:@"Cancel" duration:0.0f];
    [alert alertIsDismissed:^{
        [self configureNavAndTabBarUserInteraction];
    }];
}

// Helper method to enable/disble navBar and tabBar interaction while presenting group creation alert
- (void)configureNavAndTabBarUserInteraction {
    self.tabBarController.tabBar.userInteractionEnabled = !self.tabBarController.tabBar.userInteractionEnabled;
    self.navigationController.navigationBar.userInteractionEnabled = !self.navigationController.navigationBar.userInteractionEnabled;
}

// Helper method to check valid user input (handling empty name/description case)
- (BOOL)validGroupName: (NSString *)groupName andDescription: (NSString *)groupDescription {
    if ([groupName isEqualToString:@""] || [groupDescription isEqualToString: @""]) {
        [self configureNavAndTabBarUserInteraction];
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        [alert addButton:@"Try Again" actionBlock:^(void) {
            [self onCreateGroup:self];
        }];
        [alert showError:self title:@"Failed!" subTitle:@"Group Details Cannot be Empty!" closeButtonTitle:@"Cancel" duration:0.0f];
        [alert alertIsDismissed:^{
            [self configureNavAndTabBarUserInteraction];
        }];
        return NO;
    }
    return YES;
}


# pragma mark - Delegate Methods

// Method to find out the number of rows in Table View (Table View Data Source's required method)
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.groupArray.count;
}

// Method to configure the Table View's cell (Table View Data Source's required method)
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GroupCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GroupCell"];
    cell.group = self.groupArray[indexPath.row];
    return cell;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UITableViewCell *tappedCell = sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
    Group *group = self.groupArray[indexPath.row];
    NotesFeedViewController *feedViewController = [segue destinationViewController];
    feedViewController.group = group;
}

@end
