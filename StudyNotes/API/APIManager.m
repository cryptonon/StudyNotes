//
//  APIManager.m
//  StudyNotes
//
//  Created by Aayush Mani Phuyal on 7/16/20.
//  Copyright © 2020 Aayush Phuyal. All rights reserved.
//

#import "APIManager.h"

@implementation APIManager

// Initializer Method
- (id)init {
    self = [super init];
    self.session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    return self;
}

// Method that fetches numbers fact from numbersapi
- (void)getNumberFactWithCompletion:(void (^)(NSString *factString , NSError *error))completion {
    NSURL *url = [NSURL URLWithString:@"http://numbersapi.com/random"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data) {
            NSString *factString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            completion(factString, nil);
        } else {
            completion(nil, error);
        }
    }];
    [task resume];
}

@end
