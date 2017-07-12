//
//  HAHPageModel.m
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/7/11.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import "HAHPageModel.h"

@implementation HAHPageModel

- (NSMutableArray<HAHGroupModel *> *)groups
{
    if (!_groups) {
        _groups = [[NSMutableArray alloc] init];
    }
    return _groups;
}

@end
