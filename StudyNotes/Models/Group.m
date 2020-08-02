//
//  Group.m
//  StudyNotes
//
//  Created by Aayush Mani Phuyal on 8/2/20.
//  Copyright © 2020 Aayush Phuyal. All rights reserved.
//

#import "Group.h"

@implementation Group

// Declaring all properties @dynamic
@dynamic groupID;
@dynamic groupName;
@dynamic groupDescription;
@dynamic createdBy;
@dynamic notes;
@dynamic noOfNotes;

// Class Method that creates groups
+ (void)createGroup:(NSString *)groupName withGroupID:(NSString *)groupID withDescription:(NSString *)groupDescription withCompletion:(PFBooleanResultBlock)completion {
    Group *newGroup = [Group new];
    newGroup.groupName = groupName;
    newGroup.groupID = groupID;
    newGroup.groupDescription = groupDescription;
    newGroup.createdBy = [PFUser currentUser];
    newGroup.noOfNotes = @(0);
    [newGroup saveInBackgroundWithBlock:completion];
}

// Method that posts notes to the group
- (void)postNote:(NSString *)title withDescription:(NSString *)description withImage:(UIImage *)image withNoteID:(NSString *)noteID withCompletion:(PFBooleanResultBlock)completion {
    Note *newNote = [Note new];
    newNote.noteID = noteID;
    newNote.noteTitle = title;
    newNote.noteDescription = description;
    newNote.noteImage = [Note getPFFileFromImage:image];
    newNote.isPersonalNote = NO;
    newNote.author = [PFUser currentUser];
    
    if (self.notes) {
        NSMutableArray *noteArray = self.notes;
        [noteArray addObject:newNote];
        self.notes = noteArray;
    } else {
        self.notes = (NSMutableArray *) @[newNote];
    }
    [self saveInBackgroundWithBlock:completion];
}

# pragma mark - Delegate Methods

// Required delegate method for conforming to PFSubclassing protocol
+ (nonnull NSString *)parseClassName {
    return @"Group";
}

@end
