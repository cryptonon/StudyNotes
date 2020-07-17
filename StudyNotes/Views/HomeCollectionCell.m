//
//  HomeCollectionCell.m
//  StudyNotes
//
//  Created by Aayush Mani Phuyal on 7/14/20.
//  Copyright © 2020 Aayush Phuyal. All rights reserved.
//

#import "HomeCollectionCell.h"

@interface HomeCollectionCell()

// MARK: Properties
@property (weak, nonatomic) IBOutlet UIImageView *cellPosterView;

@end

@implementation HomeCollectionCell

// Setter method that sets Poster of cell when indexPath is provided
- (void)setIndexPath:(NSIndexPath *)indexPath {
    NSString *imageName = [NSString stringWithFormat:@"Cell%li", indexPath.item];
    self.cellPosterView.image = [UIImage imageNamed:imageName];
}

@end
