//
//  HAHFile.m
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/7/30.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import "HAHFile.h"

@interface HAHFile ()
@property (nonatomic, strong) NSString *initialText;
@end

@implementation HAHFile

- (instancetype)initWithText:(NSString *)text
{
    if (!text.length) {
        HAHLOG(@"文件内容为空");
        return nil;
    }

    if (self = [super init]) {
        self.initialText = text;
    }
    return self;
}

- (NSString *)text
{
    return self.initialText;
}

- (NSString *)name
{
    return nil;
}

@end
