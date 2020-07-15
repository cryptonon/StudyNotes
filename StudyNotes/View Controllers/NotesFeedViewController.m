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

@interface NotesFeedViewController () <UITableViewDelegate, UITableViewDataSource>

// MARK: Properties
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *notesArray;

@end

@implementation NotesFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self fetchNotes];
}

// Method to deselect the selected row
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
    [self.tableView deselectRowAtIndexPath:selectedIndexPath animated:YES];
}

// Method to fetch notes from the parse database
- (void) fetchNotes {
    PFQuery *noteQuery = [Note query];
    [noteQuery whereKey:@"author" equalTo:[PFUser currentUser]];
    [noteQuery orderByDescending:@"createdAt"];
    [noteQuery findObjectsInBackgroundWithBlock:^(NSArray<Note *> * _Nullable notes, NSError * _Nullable error) {
        if (notes) {
            self.notesArray = notes;
            [self.tableView reloadData];
        }
    }];
}


#pragma mark - Delegate Methods

// Method to configure the Table View's cell (Table View Data Source's required method)
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    NoteCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NoteCell"];
    Note *note = self.notesArray[indexPath.row];
    cell.note = note;
    return cell;
}

// Method to find out the number of rows in Table View (Table View Data Source's required method)
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.notesArray.count;
}

# pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"noteDetailsSegue"]) {
        UITableViewCell *tappedCell = sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
        Note *note = self.notesArray[indexPath.row];
        NoteDetailsViewController *detailsViewController = [segue destinationViewController];
        detailsViewController.note = note;
    }
}

@end
