//
//  Note.m
//  StudyNotes
//
//  Created by Aayush Mani Phuyal on 7/15/20.
//  Copyright © 2020 Aayush Phuyal. All rights reserved.
//

#import "Note.h"

@implementation Note

// Declaring all properties as @dynamic
@dynamic noteID;
@dynamic userID;
@dynamic author;
@dynamic noteTitle;
@dynamic noteDescription;
@dynamic noteImage;
@dynamic isPushNotified;

// Class method for making PFFileObject from UIImage
+ (PFFileObject *)getPFFileFromImage: (UIImage * _Nullable)image {
    if (!image) return nil;
    NSData *imageData = UIImagePNGRepresentation(image);
    if (!imageData) return nil;
    return [PFFileObject fileObjectWithName:@"image.png" data:imageData];
}

// Class method for posting a new note to parse
+ (void)postNote:(NSString *)title withDescription:(NSString *)description withImage:(UIImage *)image withCompletion:(PFBooleanResultBlock)completion {
    Note *newNote = [Note new];
    newNote.noteTitle = title;
    newNote.noteDescription = description;
    newNote.noteImage = [self getPFFileFromImage:image];
    newNote.author = [PFUser currentUser];
    newNote.isPushNotified = NO;
    [newNote saveInBackgroundWithBlock: completion];
}

// Method for updating existing notes
- (void)updateNoteWithTitle:(NSString *)title withDescription:(NSString *)description withImage:(UIImage *)image withCompletion:(PFBooleanResultBlock)completion {
    self.noteTitle = title;
    self.noteDescription = description;
    self.noteImage = [Note getPFFileFromImage:image];
    self.isPushNotified = NO;
    [self saveInBackgroundWithBlock: completion];
}

// Method for resetting isPushNotified boolean flag to NO after push notifying a note
- (void)updatePushNotifiedFlag {
    self.isPushNotified = YES;
    [self save];
}

// Method for resetting isPushNotified boolean flag for all Notes
+ (void)resetPushNotifiedFlagForAllNotes {
    PFQuery *noteQuery = [Note query];
    [noteQuery whereKey:@"author" equalTo:[PFUser currentUser]];
    NSArray *noteArray = [noteQuery findObjects];
    if (noteArray.count) {
        for (Note *note in noteArray) {
            note.isPushNotified = NO;
        }
        [Note saveAll:noteArray];
    }
}

// Method that returns a note for every push notification
+ (Note *)getNoteforPushNotification {
    Note *noteToBePushNotified = [self fetchNoteForPushNotification];
    if (noteToBePushNotified) {
        return noteToBePushNotified;
    } else {
        Note *noteToBePushNotified = [self fetchNoteForPushNotification];
        return noteToBePushNotified;
    }
}

// Helper method that fetches a note for getNoteforPushNotification method
+ (Note *)fetchNoteForPushNotification {
    PFQuery *noteQuery = [Note query];
    [noteQuery whereKey:@"author" equalTo:[PFUser currentUser]];
    [noteQuery whereKey:@"isPushNotified" equalTo:@(NO)];
    [noteQuery orderByAscending:@"updatedAt"];
    NSArray *noteArray = [noteQuery findObjects];
    if (noteArray) {
        if (noteArray.count) {
            Note *noteToBePushNotified = [noteArray firstObject];
            [noteToBePushNotified updatePushNotifiedFlag];
            return noteToBePushNotified;
        } else {
            [Note resetPushNotifiedFlagForAllNotes];
            return nil;
        }
    } else {
        return nil;
    }
}

# pragma mark - Delegate Methods

// Required delegate method for conforming to PFSubclassing protocol
+ (nonnull NSString *)parseClassName {
    return @"Note";
}

@end
