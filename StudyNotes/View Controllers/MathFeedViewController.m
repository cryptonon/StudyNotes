//
//  MathFeedViewController.m
//  StudyNotes
//
//  Created by Aayush Mani Phuyal on 7/13/20.
//  Copyright © 2020 Aayush Phuyal. All rights reserved.
//

#import "MathFeedViewController.h"
#import "MathCell.h"

@interface MathFeedViewController () <UITableViewDataSource, UITableViewDelegate>

// MARK: Properties
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation MathFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
}

#pragma mark - Delegate Methods

// Method to configure the Table View's cell (Table View Data Source's required method)
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    MathCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MathCell"];
    return cell;
}

// Method to find out the number of rows in Table View (Table View Data Source's required method)
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 20;
}

@end
