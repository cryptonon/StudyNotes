//
//  SettingsViewController.m
//  StudyNotes
//
//  Created by Aayush Mani Phuyal on 7/13/20.
//  Copyright © 2020 Aayush Phuyal. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

// MARK: Properties
@property (weak, nonatomic) IBOutlet UIDatePicker *fromDatePicker;
@property (weak, nonatomic) IBOutlet UIDatePicker *toDatePicker;
@property (weak, nonatomic) IBOutlet UIDatePicker *intervalTimePicker;
@property (weak, nonatomic) IBOutlet UISwitch *notificationSwitch;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

// Method to update user settings when Update button is tapped
- (IBAction)onUpdate:(id)sender {
}

@end
