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
    self.cellPosterView.alpha = 0.875;
    [self configureColorGradient];
}

// Method that configures color gradient over cell images
- (void)configureColorGradient {
    [self layoutIfNeeded];
    UIView *gradientView = [[UIView alloc] initWithFrame: self.contentView.frame];
    CAGradientLayer *gradientLayer = [[CAGradientLayer alloc] init];
    gradientLayer.frame = gradientView.frame;
    gradientLayer.colors = @[ (id)[[UIColor clearColor] CGColor], (id)[[UIColor blackColor] CGColor] ];
    gradientLayer.locations = @[@0.0, @1.0];
    [gradientView.layer insertSublayer:gradientLayer atIndex:0];
    [self.cellPosterView addSubview:gradientView];
    [self.cellPosterView bringSubviewToFront:gradientView];
}

@end
