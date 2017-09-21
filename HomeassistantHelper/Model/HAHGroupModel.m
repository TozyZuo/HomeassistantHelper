//
//  HAHGroupModel.m
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/7/11.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import "HAHGroupModel.h"

@implementation HAHGroupModel

- (NSString *)id
{
    if (![super id] && _shortID) {
        [super setId:[@"group." stringByAppendingString:_shortID]];
    }
    return [super id];
}

- (NSString *)shortID
{
    if (!_shortID && self.id) {
        _shortID = [self.id componentsSeparatedByString:@"."].lastObject;
    }
    return _shortID;
}

- (HAHObservableArray<HAHEntityModel *> *)entities
{
    if (!_entities) {
        _entities = [[HAHObservableArray alloc] init];
    }
    return _entities;
}

@end
