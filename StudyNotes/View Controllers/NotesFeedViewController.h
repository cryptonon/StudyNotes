//
//  NotesFeedViewController.h
//  StudyNotes
//
//  Created by Aayush Mani Phuyal on 7/13/20.
//  Copyright © 2020 Aayush Phuyal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Group.h"

NS_ASSUME_NONNULL_BEGIN

@interface NotesFeedViewController : UIViewController

// MARK: Properties
@property (strong, nonatomic) Group *group;

@end

NS_ASSUME_NONNULL_END
