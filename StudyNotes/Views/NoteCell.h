//
//  NoteCell.h
//  StudyNotes
//
//  Created by Aayush Mani Phuyal on 7/13/20.
//  Copyright © 2020 Aayush Phuyal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Note.h"

NS_ASSUME_NONNULL_BEGIN

@interface NoteCell : UITableViewCell

// MARK: Properties
@property (strong, nonatomic) Note *note;

@end

NS_ASSUME_NONNULL_END
