//
//  NotificationViewController.m
//  StudyNotesNotification
//
//  Created by Aayush Mani Phuyal on 7/16/20.
//  Copyright © 2020 Aayush Phuyal. All rights reserved.
//

#import "NotificationViewController.h"
#import <UserNotifications/UserNotifications.h>
#import <UserNotificationsUI/UserNotificationsUI.h>
#import "Note.h"

@interface NotificationViewController () <UNNotificationContentExtension>

// MARK: Properties
@property IBOutlet UILabel *label;
@property (strong, nonatomic) NSArray<Note *> *notesArray;

@end

@implementation NotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveNotification:(UNNotification *)notification {
    [self fetchNotes];
}

// Method to fetch notes from database
- (void)fetchNotes {
    PFQuery *noteQuery = [PFQuery queryWithClassName:@"Note"];
    [noteQuery orderByDescending:@"createdAt"];
    [noteQuery findObjectsInBackgroundWithBlock:^(NSArray<Note *> * _Nullable notes, NSError * _Nullable error) {
        if (notes.count) {
            self.notesArray = notes;
            self.label.text = [self.notesArray firstObject].noteDescription;
        }
    }];
}

@end
