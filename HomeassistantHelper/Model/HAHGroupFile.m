//
//  HAHGroupFile.m
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/7/30.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import "HAHGroupFile.h"
#import "HAHPageParser.h"
#import "HAHPageModel.h"
#import "HAHGroupModel.h"
#import "HAHEntityModel.h"

@interface HAHGroupFile ()
@property (nonatomic, strong) HAHObservableArray<HAHPageModel *> *pages;
@end

@implementation HAHGroupFile

- (instancetype)initWithText:(NSString *)text
{
    if (self = [super initWithText:text]) {
        self.pages = [[[HAHPageParser alloc] init] parse:text];
    }
    return self;
}

- (NSString *)name
{
    return (NSString *)HAHSGroupFileName;
}

- (NSString *)text
{
    NSMutableString *text = [[NSMutableString alloc] initWithString:@""];

    for (HAHPageModel *pageModel in self.pages) {

        [text appendFormat:@"%@:\n", pageModel.id];
        [text appendFormat:@"   name: %@\n", pageModel.name];
        [text appendString:@"   view: yes\n"];
        [text appendString:@"   entities:\n"];

        NSMutableString *groups = [[NSMutableString alloc] initWithString:@""];

        for (HAHGroupModel *groupModel in pageModel.groups) {

            [text appendFormat:@"       - %@\n", groupModel.id];

            [groups appendFormat:@"%@:\n", groupModel.shortID];
            [groups appendString:@"   view: no\n"];
            [groups appendString:@"   entities:\n"];

            for (HAHEntityModel *entity in groupModel.entities) {
                [groups appendFormat:@"       - %@\n", entity.id];
            }
        }

        [text appendString:groups];
    }

    return text;
}

@end
