//
//  NotesFeedViewController.m
//  StudyNotes
//
//  Created by Aayush Mani Phuyal on 7/13/20.
//  Copyright © 2020 Aayush Phuyal. All rights reserved.
//

#import "NotesFeedViewController.h"
#import "NoteCell.h"

@interface NotesFeedViewController () <UITableViewDelegate, UITableViewDataSource>

// MARK: Properties
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation NotesFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
}

// Method to deselect the selected row
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
    [self.tableView deselectRowAtIndexPath:selectedIndexPath animated:YES];
}

#pragma mark - Delegate Methods

// Method to configure the Table View's cell (Table View Data Source's required method)
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    NoteCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NoteCell"];
    return cell;
}

// Method to find out the number of rows in Table View (Table View Data Source's required method)
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 20;
}

@end
