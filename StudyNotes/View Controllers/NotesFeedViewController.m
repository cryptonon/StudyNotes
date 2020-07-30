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

@interface NotesFeedViewController () <UITableViewDelegate, UITableViewDataSource, CreateNoteViewControllerDelegate, DetailsViewControllerDelegate, NoteCellDelegate>

// MARK: Properties
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray<Note*> *notesArray;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@end

@implementation NotesFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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

// Method to fetch notes from the parse database
- (void) fetchNotes {
    JGProgressHUD *progressHUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
    progressHUD.textLabel.text = @"Loading...";
    [progressHUD showInView:self.view];
    PFQuery *noteQuery = [Note query];
    [noteQuery whereKey:@"author" equalTo:[PFUser currentUser]];
    [noteQuery orderByDescending:@"createdAt"];
    [noteQuery findObjectsInBackgroundWithBlock:^(NSArray<Note *> * _Nullable notes, NSError * _Nullable error) {
        if (notes) {
            self.notesArray = (NSMutableArray *) notes;
            [self.tableView reloadData];
        }
    }];
    [progressHUD dismiss];
    [self.refreshControl endRefreshing];
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
    [self.notesArray insertObject:newNote atIndex:0];
    [self.tableView reloadData];
}

// Method to update feed locally after a note has been updated (NoteDetailsViewController's delegate method)
- (void)updatedNoteAtIndexPath:(NSIndexPath *)indexPath toTitle:(NSString *)noteTitle toDescription:(NSString *)noteDescription toImage:(UIImage *)noteImage {
    self.notesArray[indexPath.row].noteTitle = noteTitle;
    self.notesArray[indexPath.row].noteDescription = noteDescription;
    NSData *imageData = UIImageJPEGRepresentation(noteImage, 0.6);
    self.notesArray[indexPath.row].noteImageData = imageData;
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
        composeController.delegate = self;
    }
}

@end
