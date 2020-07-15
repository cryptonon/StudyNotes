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

// Class method for posting a new note to parse
+ (void)postNote:(NSString *)title withDescription:(NSString *)description withImage:(UIImage *)image withCompletion:(PFBooleanResultBlock)completion {
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
