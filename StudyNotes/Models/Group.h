//
//  Group.h
//  StudyNotes
//
//  Created by Aayush Mani Phuyal on 8/2/20.
//  Copyright © 2020 Aayush Phuyal. All rights reserved.
//

#import <Parse/Parse.h>
#import "Note.h"

NS_ASSUME_NONNULL_BEGIN

@interface Group : PFObject <PFSubclassing>

// MARK: Properties
@property (nonatomic, strong) NSString *groupID;
@property (nonatomic, strong) NSString *groupName;
@property (nonatomic, strong) NSString *groupDescription;
@property (nonatomic, strong) PFUser *createdBy;
@property (nonatomic, strong) NSMutableArray <Note *> *notes;
@property (nonatomic, strong) NSNumber *noOfNotes;

//MARK: Methods
+ (void)createGroup: ( NSString * _Nonnull )groupName
        withGroupID: ( NSString * _Nonnull )groupID
    withDescription: ( NSString * _Nonnull )groupDescription
     withCompletion: (PFBooleanResultBlock  _Nullable)completion;

- (void) postNote: ( NSString * _Nonnull )title
  withDescription: ( NSString * _Nullable )description
        withImage: ( UIImage * _Nullable )image
       withNoteID: ( NSString * _Nonnull )noteID
   withCompletion: (PFBooleanResultBlock  _Nullable)completion;

@end

NS_ASSUME_NONNULL_END
