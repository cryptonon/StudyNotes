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
}

# pragma mark - Delegate Methods

// Required delegate method for conforming to PFSubclassing protocol
+ (nonnull NSString *)parseClassName {
    return @"Note";
}

@end
