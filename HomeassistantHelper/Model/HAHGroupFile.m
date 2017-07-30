//
//  HAHGroupFile.m
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/7/30.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import "HAHGroupFile.h"
#import "HAHPageParser.h"

@interface HAHGroupFile ()
@property (nonatomic, strong) NSArray<HAHPageModel *> *pages;
@end

@implementation HAHGroupFile

- (instancetype)initWithText:(NSString *)text
{
    if (self = [super initWithText:text]) {
        self.pages = [[[HAHPageParser alloc] init] parse:text];
    }
    return self;
}

@end
