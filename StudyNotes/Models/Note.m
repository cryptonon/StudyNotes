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
    [self saveInBackground];
}

// Method for resetting isPushNotified boolean flag for all Notes
+ (void)resetPushNotifiedFlagForAllNotes {
    PFQuery *noteQuery = [Note query];
    [noteQuery whereKey:@"author" equalTo:[PFUser currentUser]];
    [noteQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable notes, NSError * _Nullable error) {
        if (notes.count) {
            for (Note *note in notes) {
                note.isPushNotified = NO;
            }
            [Note saveAllInBackground:notes];
        }
    }];
}

// Method that returns a note for every push notification
+ (void)getNoteforPushNotificationWithCompletion:(void (^)(Note * _Nullable, NSError * _Nullable))completion {
    PFQuery *noteQuery = [Note query];
    [noteQuery whereKey:@"author" equalTo:[PFUser currentUser]];
    [noteQuery whereKey:@"isPushNotified" equalTo:@(NO)];
    [noteQuery orderByAscending:@"updatedAt"];
    [noteQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable notes, NSError * _Nullable error) {
        if (!error) {
            if (notes.count) {
                Note *noteToBePushNotified = [notes firstObject];
                [noteToBePushNotified updatePushNotifiedFlag];
                completion(noteToBePushNotified, nil);
            } else {
                [Note resetPushNotifiedFlagForAllNotes];
                [Note getNoteforPushNotificationWithCompletion:^(Note * note, NSError * error) {
                    if (note) {
                        completion(note, nil);
                    } else {
                        completion(nil, error);
                    }
                }];
            }
        } else {
            completion(nil, error);
        }
    }];
}

# pragma mark - Delegate Methods

// Required delegate method for conforming to PFSubclassing protocol
+ (nonnull NSString *)parseClassName {
    return @"Note";
}

@end
