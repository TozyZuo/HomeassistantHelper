//
//  HAHPageModel.m
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/7/11.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import "HAHPageModel.h"

@implementation HAHPageModel

- (HAHObservableArray<HAHGroupModel *> *)groups
{
    if (!_groups) {
        _groups = [[HAHObservableArray alloc] init];
    }
    return _groups;
}

@end
