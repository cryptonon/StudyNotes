//
//  APIManager.h
//  StudyNotes
//
//  Created by Aayush Mani Phuyal on 7/16/20.
//  Copyright © 2020 Aayush Phuyal. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface APIManager : NSObject

// MARK: Properties
@property (nonatomic, strong) NSURLSession *session;

// MARK: Methods
- (void)getNumberFactWithCompletion: (void(^)(NSString *factString, NSError *error))completion;

@end

NS_ASSUME_NONNULL_END
