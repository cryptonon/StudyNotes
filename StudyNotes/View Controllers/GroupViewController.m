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

@interface GroupViewController () <UITableViewDelegate, UITableViewDataSource>

// MARK: Properties
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *groupArray;

@end

@implementation GroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self customizeTableView];
    [self fetchGroups];
}

// Method that customizes tableView
- (void)customizeTableView {
    self.tableView.separatorColor = [UIColor blackColor];
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"note"]];
    backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    backgroundImageView.alpha = 0.25;
    self.tableView.backgroundView = backgroundImageView;
}

// Method to deselect the selected row
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
    [self.tableView deselectRowAtIndexPath:selectedIndexPath animated:YES];
}

// Method that fetches groups form parse
-(void)fetchGroups {
    PFQuery *groupQuery = [Group query];
    [groupQuery orderByDescending:@"createdAt"];
    [groupQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable groups, NSError * _Nullable error) {
        if(groups) {
            self.groupArray = (NSMutableArray *) groups;
            [self.tableView reloadData];
        }
    }];
}

// Method that handles new group creation
- (IBAction)onCreateGroup:(id)sender {
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle: @"New Group"
                                                                              message: @"Enter group details"
                                                                       preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Name";
        textField.clearsOnInsertion =YES;
    }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Description";
        textField.clearsOnInsertion =YES;
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Create" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSArray * textfields = alertController.textFields;
        UITextField *groupNameField = textfields[0];
        UITextField *groupDescriptionField = textfields[1];
        NSString *groupName = groupNameField.text;
        NSString *groupDescription = groupDescriptionField.text;
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
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

// Helper method to check valid user input (handling empty name/description case)
- (BOOL)validGroupName: (NSString *)groupName andDescription: (NSString *)groupDescription {
    if ([groupName isEqualToString:@""] || [groupDescription isEqualToString: @""]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Creation Failed!"
                                                                       message:@"Name and Description cannot be empty."
                                                                preferredStyle:(UIAlertControllerStyleAlert)];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * _Nonnull action) {
            [self onCreateGroup:nil];
        }];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
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
