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
@property (nonatomic, strong) NSMutableArray<HAHPageModel *> *pages;
@end

@implementation HAHGroupFile

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    if (self = [super initWithDictionary:dictionary]) {
        self.pages = [HAHPageParser parse:dictionary];
    }
    return self;
}

- (NSString *)name
{
    return (NSString *)HAHSGroupFileName;
}

- (NSString *)text
{
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];

    for (HAHPageModel *pageModel in self.pages) {
        [data addEntriesFromDictionary:[HAHPageParser transformPageModel:pageModel]];
    }

    return [HAHParser YAMLFromObject:data];
}

@end
