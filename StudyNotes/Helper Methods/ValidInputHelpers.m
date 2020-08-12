//
//  ValidInputHelpers.m
//  StudyNotes
//
//  Created by Aayush Mani Phuyal on 8/7/20.
//  Copyright © 2020 Aayush Phuyal. All rights reserved.
//

#import "ValidInputHelpers.h"

// MARK: Helper Methods Implementation

// Method that trims leading and trailing whitespaces on a string
NSString *WhitespaceTrimmedString(NSString *rawString) {
    NSCharacterSet *whiteSpaceSet = [NSCharacterSet characterSetWithCharactersInString:@" "];
    NSString *trimmedString = [rawString stringByTrimmingCharactersInSet:whiteSpaceSet];
    return trimmedString;
}
