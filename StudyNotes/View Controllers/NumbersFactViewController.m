//
//  NumbersFactViewController.m
//  StudyNotes
//
//  Created by Aayush Mani Phuyal on 7/23/20.
//  Copyright © 2020 Aayush Phuyal. All rights reserved.
//

#import "NumbersFactViewController.h"
#import "APIManager.h"
#import "UIImageView+AFNetworking.h"

@interface NumbersFactViewController ()

// MARK: Properties
@property (weak, nonatomic) IBOutlet UIImageView *factImageView;
@property (weak, nonatomic) IBOutlet UILabel *factLabel;

@end

@implementation NumbersFactViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadNumberImage];
    [self generateNewFact:nil];
}

// Method to generate a new fact on tapping Refresh button
- (IBAction)generateNewFact:(id)sender {
    APIManager *factAPIManager = [APIManager new];
    [factAPIManager getNumberFactWithCompletion:^(NSString * _Nonnull factString, NSError * _Nonnull error) {
        if (factString) {
            NSString *numberString = [[factString componentsSeparatedByString:@" "] objectAtIndex:0];
            self.navigationItem.title = numberString;
            self.factLabel.text = factString;
        }
    }];
}

// Method to load a random image of numbers
- (void)loadNumberImage {
    NSURL *factImageURL = [NSURL URLWithString:@"https://source.unsplash.com/collection/4415411/720x720"];
    [self.factImageView setImageWithURL:factImageURL];
}

@end
