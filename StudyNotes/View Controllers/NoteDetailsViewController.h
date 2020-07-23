//
//  NoteDetailsViewController.h
//  StudyNotes
//
//  Created by Aayush Mani Phuyal on 7/13/20.
//  Copyright © 2020 Aayush Phuyal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Note.h"

NS_ASSUME_NONNULL_BEGIN

//MARK: Protocol
@protocol DetailsViewControllerDelegate

//Methods
- (void)updatedNoteAtIndexPath:(NSIndexPath *)indexPath toTitle: (NSString *)noteTitle toDescription: (NSString *)noteDescription toImage: (UIImage *)noteImage;
@end

@interface NoteDetailsViewController : UIViewController

// MARK: Properties
@property (strong, nonatomic) Note *note;
@property (strong, nonatomic) NSIndexPath *indexPath;
@property (weak, nonatomic) id<DetailsViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
