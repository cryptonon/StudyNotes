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
#import "UICustomizationHelpers.h"

@interface GroupViewController () <UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating>

// MARK: Properties
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *groupArray;
@property (strong, nonnull) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSMutableArray *filteredGroupArray;

@end

@implementation GroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addSearchBar];
    [self addSwipeGestureRecognizer];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self customizeTableView];
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchGroups) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
    [self fetchGroups];
}

// Method that adds searchBar
- (void)addSearchBar {
    UISearchController *searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    searchController.searchResultsUpdater = self;
    searchController.obscuresBackgroundDuringPresentation = NO;
    searchController.searchBar.placeholder = @"Search Groups";
    self.navigationItem.searchController = searchController;
    self.definesPresentationContext = YES;
}

// Method to add Swipe Gesture Recognizer to switch tabs (RightSwipe)
- (void)addSwipeGestureRecognizer {
    UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleTabSwitching:)];
    swipeGesture.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeGesture];
}

// Method that handles swipeGesture and tab switching (switches to group tab)
- (void)handleTabSwitching: (UISwipeGestureRecognizer *) swipeGesture {
    self.tabBarController.selectedIndex = 0;
}

// Method that customizes tableView
- (void)customizeTableView {
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    UIImage *tableViewBgImage = [UIImage imageNamed:@"note"];
    setBackgroundForTableView(self.tableView, tableViewBgImage, 0.25);
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
    JGProgressHUD *progressHUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleLight];
    progressHUD.textLabel.text = @"Loading";
    [progressHUD showInView:self.view];
    PFQuery *groupQuery = [Group query];
    [groupQuery orderByDescending:@"createdAt"];
    [groupQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable groups, NSError * _Nullable error) {
        if(groups) {
            self.groupArray = (NSMutableArray *) [[NSMutableArray alloc] initWithArray:groups];
            self.filteredGroupArray = [(NSMutableArray *) [NSMutableArray alloc] initWithArray:groups];
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
        if ([self validGroupName:groupName andDescription:groupDescription forGroup:nil]) {
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
                    [self.filteredGroupArray insertObject:newGroup atIndex:0];
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
- (BOOL)validGroupName: (NSString *)groupName andDescription: (NSString *)groupDescription forGroup: (Group *)group {
    if ([groupName isEqualToString:@""] || [groupDescription isEqualToString: @""]) {
        [self configureNavAndTabBarUserInteraction];
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        [alert addButton:@"Try Again" actionBlock:^(void) {
            if (group) {
                [self presentEditAlertAndEditGroup:group];
            } else {
                [self onCreateGroup:self];
            }
        }];
        [alert showError:self title:@"Failed!" subTitle:@"Group Details Cannot be Empty!" closeButtonTitle:@"Cancel" duration:0.0f];
        [alert alertIsDismissed:^{
            [self configureNavAndTabBarUserInteraction];
        }];
        return NO;
    }
    return YES;
}

// Method to present alert and delete the group
- (void) presentDeleteAlertAndDeleteGroup: (Group *)group {
    UIAlertController *deleteAlert = [UIAlertController alertControllerWithTitle:@"Are you sure you want to delete the Group?"
                                                                         message:@"Deleting the Group will also delete all notes posted in the Group"
                                                                  preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.groupArray removeObject:group];
        [self.filteredGroupArray removeObject:group];
        [self.tableView reloadData];
        [PFObject deleteAllInBackground:group.notes];
        [group deleteInBackground];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"No"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    [deleteAction setValue:[UIColor redColor] forKey:@"titleTextColor"];
    [deleteAlert addAction:deleteAction];
    [deleteAlert addAction:cancelAction];
    [self presentViewController:deleteAlert animated:YES completion:nil];
}

// Method to present edit alert and edit group details
- (void)presentEditAlertAndEditGroup: (Group *)group {
    [self configureNavAndTabBarUserInteraction];
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    alert.backgroundType = SCLAlertViewBackgroundBlur;
    alert.customViewColor = [UIColor systemBlueColor];
    UITextField *groupNameField = [alert addTextField:@"New Group Name"];
    UITextField *groupDescriptionField = [alert addTextField:@"New Description"];
    groupNameField.text = group.groupName;
    groupDescriptionField.text = group.groupDescription;
    [alert addButton:@"Update" actionBlock:^(void) {
        NSCharacterSet *whiteSpaceSet = [NSCharacterSet characterSetWithCharactersInString:@" "];
        NSString *groupName = [groupNameField.text stringByTrimmingCharactersInSet:whiteSpaceSet];
        NSString *groupDescription = [groupDescriptionField.text stringByTrimmingCharactersInSet:whiteSpaceSet];
        if ([self validGroupName:groupName andDescription:groupDescription forGroup:group]) {
            NSString *groupID = group.groupID;
            PFQuery *groupQuery = [Group query];
            [groupQuery whereKey:@"groupID" equalTo:groupID];
            [groupQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable groups, NSError * _Nullable error) {
                if (groups) {
                    Group *groupToEdit = groups[0];
                    groupToEdit.groupName = groupName;
                    groupToEdit.groupDescription = groupDescription;
                    [groupToEdit saveInBackground];
                    group.groupName = groupName;
                    group.groupDescription = groupDescription;
                    [self.tableView reloadData];
                }
            }];
        }
    }];
    [alert showEdit:self title:@"Update Group" subTitle:@"Enter the New Group Details" closeButtonTitle:@"Cancel" duration:0.0f];
    [alert alertIsDismissed:^{
        [self configureNavAndTabBarUserInteraction];
    }];
}

// Helper method to check group ownership
- (BOOL)groupIsOwnedByCurrentUser: (Group *) group {
    return [group.createdBy.objectId isEqualToString:[PFUser currentUser].objectId];
}

// Helper method to present cannot delete the note (depending upon ownership)
- (void)presentCannotEditAlert {
    [self configureNavAndTabBarUserInteraction];
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    alert.backgroundType = SCLAlertViewBackgroundBlur;
    [alert showError:self title:@"Oops!" subTitle:@"You do not have permissions to make changes to this group!" closeButtonTitle:@"OK" duration:0.0f];
    [alert alertIsDismissed:^{
        [self configureNavAndTabBarUserInteraction];
    }];
}

# pragma mark - Delegate Methods

// Method to find out the number of rows in Table View (Table View Data Source's required method)
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredGroupArray.count;
}

// Method to configure the Table View's cell (Table View Data Source's required method)
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GroupCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GroupCell"];
    cell.group = self.filteredGroupArray[indexPath.row];
    return cell;
}

// Method for configuring trailing swipe for editing/deleting groups (Table View Delegate method)
- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    Group *selectedGroup = self.filteredGroupArray[indexPath.row];
    if ([self groupIsOwnedByCurrentUser:selectedGroup]) {
        UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"Delete" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
            completionHandler(YES);
            [self presentDeleteAlertAndDeleteGroup:selectedGroup];
        }];
        UIImage *deleteImage = [UIImage systemImageNamed:@"trash"];
        deleteAction.image = deleteImage;
        UIContextualAction *editAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"Edit" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
            completionHandler(YES);
            [self presentEditAlertAndEditGroup:selectedGroup];
        }];
        UIImage *editImage = [UIImage systemImageNamed:@"square.and.pencil"];
        editAction.image = editImage;
        editAction.backgroundColor = [UIColor systemBlueColor];
        UISwipeActionsConfiguration *actionConfigurations = [UISwipeActionsConfiguration configurationWithActions:@[deleteAction, editAction]];
        return actionConfigurations;
    } else {
        [self presentCannotEditAlert];
        return [UISwipeActionsConfiguration configurationWithActions:@[]];
    }
}

// Method to filter groups when searching starts (UISearchResultsUpdating's required method)
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *searchText = searchController.searchBar.searchTextField.text;
    NSCharacterSet *whiteSpaceSet = [NSCharacterSet characterSetWithCharactersInString:@" "];
    NSString *trimmedSearchText = [searchText stringByTrimmingCharactersInSet:whiteSpaceSet];
    if (trimmedSearchText.length != 0) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@("groupName contains[c] %@"), trimmedSearchText];
        NSArray *filteredArray = [self.groupArray filteredArrayUsingPredicate:predicate];
        self.filteredGroupArray = [(NSMutableArray *) [NSMutableArray alloc] initWithArray:filteredArray];
    } else {
        self.filteredGroupArray = self.groupArray;
    }
    [self.tableView reloadData];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UITableViewCell *tappedCell = sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
    Group *group = self.filteredGroupArray[indexPath.row];
    NotesFeedViewController *feedViewController = [segue destinationViewController];
    feedViewController.group = group;
}

@end
