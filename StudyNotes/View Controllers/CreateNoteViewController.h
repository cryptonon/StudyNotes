//
//  CreateNoteViewController.h
//  StudyNotes
//
//  Created by Aayush Mani Phuyal on 7/13/20.
//  Copyright © 2020 Aayush Phuyal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Note.h"

NS_ASSUME_NONNULL_BEGIN

// MARK: Protocol
@protocol CreateNoteViewControllerDelegate

//Optional Methods
@optional
- (void) updatedNoteToTitle: (NSString *)noteTitle toDescription: (NSString *)noteDescription toImage: (UIImage *)noteImage;
- (void) postedNote: (Note *)newNote;

@end

@interface CreateNoteViewController : UIViewController

// MARK: Properties
@property (strong, nonatomic) Note *note;
@property (weak, nonatomic) id<CreateNoteViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
