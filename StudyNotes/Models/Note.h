//
//  Note.h
//  StudyNotes
//
//  Created by Aayush Mani Phuyal on 7/15/20.
//  Copyright © 2020 Aayush Phuyal. All rights reserved.
//

#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface Note : PFObject <PFSubclassing>

// MARK: Properties
@property (nonatomic, strong) NSString *noteID;
@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) PFUser *author;
@property (nonatomic, strong) NSString *noteTitle;
@property (nonatomic, strong) NSString *noteDescription;
@property (nonatomic, strong) PFFileObject *noteImage;
@property (nonatomic) BOOL isPushNotified;
@property (nonatomic) BOOL isPersonalNote;

//MARK: Methods
+ (void) postNote: ( NSString * _Nonnull )title
  withDescription: ( NSString * _Nullable )description
        withImage: ( UIImage * _Nullable )image
       withNoteID: ( NSString * _Nonnull )noteID
   withCompletion: (PFBooleanResultBlock  _Nullable)completion;

- (void) updateNoteWithTitle: ( NSString * _Nonnull )title
             withDescription: ( NSString * _Nullable )description
                   withImage: ( UIImage * _Nullable )image
              withCompletion: (PFBooleanResultBlock  _Nullable)completion;

+ (Note *) getNoteforPushNotification;

+ (PFFileObject *)getPFFileFromImage: (UIImage * _Nullable)image;

@end

NS_ASSUME_NONNULL_END
