//
//  NotesFeedViewController.m
//  StudyNotes
//
//  Created by Aayush Mani Phuyal on 7/13/20.
//  Copyright © 2020 Aayush Phuyal. All rights reserved.
//

#import "NotesFeedViewController.h"
#import "NoteCell.h"
#import "Note.h"
#import "NoteDetailsViewController.h"
#import "CreateNoteViewController.h"
#import <JGProgressHUD/JGProgressHUD.h>
#import <SCLAlertView.h>
#import "UICustomizationHelpers.h"

@interface NotesFeedViewController () <UITableViewDelegate, UITableViewDataSource, CreateNoteViewControllerDelegate, DetailsViewControllerDelegate, NoteCellDelegate>

// MARK: Properties
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray<Note*> *notesArray;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@end

@implementation NotesFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavBarTitle];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self customizeTableView];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchNotes) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
    
    [self fetchNotes];
}

// Method that customizes tableView
- (void)customizeTableView {
    self.tableView.separatorColor = [UIColor blackColor];
    UIImage *tableViewBgImage = [UIImage imageNamed:@"note"];
    SetBackgroundForTableView(self.tableView, tableViewBgImage, 0.25);
    self.tableView.tableFooterView = [UIView new];
}

// Method that sets navBar title to Group's name if applicable
- (void)setNavBarTitle {
    if (self.group) {
        self.navigationItem.title = self.group.groupName;
    } else {
        self.navigationItem.title = @"Personal Notes";
    }
}

// Method to deselect the selected row
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
    [self.tableView deselectRowAtIndexPath:selectedIndexPath animated:YES];
}

// Method that fetches notes (for both group/user)
- (void)fetchNotes {
    JGProgressHUD *progressHUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleLight];
    progressHUD.textLabel.text = @"Loading";
    [progressHUD showInView:self.view];
    if (self.group) {
        [self fetchGroupNotes];
    } else {
        [self fetchUserNotes];
    }
    [progressHUD dismiss];
}

// Helper method to fetch user notes from the parse database
- (void)fetchUserNotes {
    PFQuery *noteQuery = [Note query];
    [noteQuery whereKey:@"author" equalTo:[PFUser currentUser]];
    [noteQuery whereKey:@"isPersonalNote" equalTo:@(YES)];
    [noteQuery orderByDescending:@"createdAt"];
    [noteQuery findObjectsInBackgroundWithBlock:^(NSArray<Note *> * _Nullable notes, NSError * _Nullable error) {
        if (notes) {
            self.notesArray = (NSMutableArray *) notes;
            if (self.notesArray.count) {
                [self.tableView reloadData];
            } else {
                [self presentNoNoteAlertWithError:nil];
            }
        } else {
            [self presentNoNoteAlertWithError:error];
        }
    }];
    [self.refreshControl endRefreshing];
}

// Helper method to fetch group notes from the parse database
- (void)fetchGroupNotes {
    PFQuery *groupQuery = [Group query];
    [groupQuery whereKey:@"groupName" equalTo:self.group.groupName];
    [groupQuery includeKey:@"notes"];
    [groupQuery findObjectsInBackgroundWithBlock:^(NSArray<Group *> * _Nullable groups, NSError * _Nullable error) {
        if (groups) {
            self.notesArray = groups[0].notes;
            if (self.notesArray.count) {
               [self.tableView reloadData];
            } else {
                [self presentNoNoteAlertWithError:nil];
            }
        } else {
            [self presentNoNoteAlertWithError:error];
        }
    }];
    [self.refreshControl endRefreshing];
}

// Helper method that presents no note alert
- (void)presentNoNoteAlertWithError: (NSError * _Nullable)error {
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    alert.backgroundType = SCLAlertViewBackgroundBlur;
    if (error) {
        [alert addButton:@"Try Again" actionBlock:^(void) {
            [self fetchNotes];
        }];
        [alert showError:self title:@"Error!" subTitle:error.localizedDescription closeButtonTitle:@"Cancel" duration:0.0f];
    } else {
        alert.customViewColor = [UIColor systemBlueColor];
        [alert addButton:@"Create Note" actionBlock:^(void) {
            [self performSegueWithIdentifier:@"composeNoteSegue" sender:self];
        }];
        [alert showEdit:self title:@"No Notes!" subTitle:@"Please create a new Note" closeButtonTitle:@"Cancel" duration:5.0f];
    }
}

// Method to present alert and delete the note
- (void) presentDeleteAlertAndDeleteNote: (Note *)note atIndexPath: (NSIndexPath *) indexPath {
    UIAlertController *deleteAlert = [UIAlertController alertControllerWithTitle:@"Are you sure you want to delete the note?"
                                                                         message:nil
                                                                  preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.notesArray removeObjectAtIndex:indexPath.row];
        [self.tableView reloadData];
        [note deleteInBackground];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"No"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    [deleteAction setValue:[UIColor redColor] forKey:@"titleTextColor"];
    [deleteAlert addAction:deleteAction];
    [deleteAlert addAction:cancelAction];
    [self presentViewController:deleteAlert animated:YES completion:nil];
}

// Method that handles deleting note feature availability (depending upon group/user notes)
- (BOOL)respondsToSelector:(SEL)aSelector {
    if (aSelector == @selector(tableView:commitEditingStyle:forRowAtIndexPath:)) {
        if (self.group) {
            return NO;
        } else {
            return YES;
        }
    }
    return [super respondsToSelector:aSelector];
}

#pragma mark - Delegate Methods

// Method to configure the Table View's cell (Table View Data Source's required method)
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    NoteCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NoteCell"];
    Note *note = self.notesArray[indexPath.row];
    cell.note = note;
    cell.delegate = self;
    return cell;
}

// Method to find out the number of rows in Table View (Table View Data Source's required method)
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.notesArray.count;
}

// Method to delete a note after swiping a Table View cell to left (Table View Data Source's optional method)
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    Note *selectedNote = self.notesArray[indexPath.row];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self presentDeleteAlertAndDeleteNote:selectedNote atIndexPath:indexPath];
    }
}

// Method to update feed locally after a note has been posted (CreateNoteViewController's delegate method)
- (void)postedNote:(Note *)newNote {
    if (self.notesArray) {
        [self.notesArray insertObject:newNote atIndex:0];
    } else {
        self.notesArray = (NSMutableArray *) @[newNote];
    }
    [self.tableView reloadData];
}

// Method to update feed locally after a note has been updated (NoteDetailsViewController's delegate method)
- (void)updatedNoteAtIndexPath:(NSIndexPath *)indexPath toTitle:(NSString *)noteTitle toDescription:(NSString *)noteDescription toImage:(UIImage *)noteImage {
    self.notesArray[indexPath.row].noteTitle = noteTitle;
    self.notesArray[indexPath.row].noteDescription = noteDescription;
    PFFileObject *imageFile = [Note getPFFileFromImage:noteImage];
    self.notesArray[indexPath.row].noteImage = imageFile;
    [self.tableView reloadData];
}

// Method to hide Nav Bar (NoteCell's required delegate method)
- (void)hideNavigationBar {
    [self.navigationController setNavigationBarHidden:YES];
}

// Method to unhide Nav Bar (NoteCell's required delegate method)
- (void)unhideNavigationBar {
    [self.navigationController setNavigationBarHidden:NO];
}

// Method to hide Tab Bar Controller (NoteCell's required delegate method)
- (void)hideTabBarController {
    [self.tabBarController.tabBar setHidden:YES];
}

// Method to unhide Tab Bar Controller (NoteCell's required delegate method)
- (void)unhideTabBarController {
    [self.tabBarController.tabBar setHidden:NO];
}

# pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"noteDetailsSegue"]) {
        UITableViewCell *tappedCell = sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
        Note *note = self.notesArray[indexPath.row];
        NoteDetailsViewController *detailsViewController = [segue destinationViewController];
        detailsViewController.note = note;
        detailsViewController.delegate = self;
        detailsViewController.indexPath = indexPath;
    } else if ([segue.identifier isEqualToString:@"composeNoteSegue"]) {
        UINavigationController *navigationController = [segue destinationViewController];
        CreateNoteViewController *composeController = (CreateNoteViewController *) navigationController.topViewController;
        composeController.group = self.group;
        composeController.delegate = self;
    }
}

@end
