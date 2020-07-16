//
//  MathFeedViewController.m
//  StudyNotes
//
//  Created by Aayush Mani Phuyal on 7/13/20.
//  Copyright © 2020 Aayush Phuyal. All rights reserved.
//

#import "MathFeedViewController.h"
#import "MathCell.h"
#import "APIManager.h"

@interface MathFeedViewController () <UITableViewDataSource, UITableViewDelegate>

// MARK: Properties
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSString *numberFactString;

@end

@implementation MathFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self fetchMathFacts];
}

// Method to fetch math facts from numbersapi
- (void)fetchMathFacts {
    APIManager *factAPIManager = [[APIManager alloc] init];
    [factAPIManager getNumberFactWithCompletion:^(NSString * _Nonnull factString, NSError * _Nonnull error) {
        if (factString) {
            self.numberFactString = factString;
        }
        [self.tableView reloadData];
    }];
}

#pragma mark - Delegate Methods

// Method to configure the Table View's cell (Table View Data Source's required method)
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    MathCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MathCell"];
    cell.factString = self.numberFactString;
    return cell;
}

// Method to find out the number of rows in Table View (Table View Data Source's required method)
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

@end
