//
//  HAHFile.m
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/7/30.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import "HAHFile.h"

@interface HAHFile ()
@property (nonatomic, strong) NSString *text;
@end

@implementation HAHFile

- (instancetype)initWithText:(NSString *)text
{
    if (self = [super init]) {
        self.text = text;
    }
    return self;
}

@end
