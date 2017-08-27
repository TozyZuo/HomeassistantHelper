//
//  HAHManager.m
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/8/27.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import "HAHManager.h"
#import <objc/runtime.h>

@implementation HAHManager

void *HAHManagerKey = &HAHManagerKey;

+ (instancetype)sharedManager
{
    id _manager = objc_getAssociatedObject(self, HAHManagerKey);
    if (!_manager) {
        _manager = [[self alloc] init];
        objc_setAssociatedObject(self, HAHManagerKey, _manager, OBJC_ASSOCIATION_RETAIN);
    }
    return _manager;
}

@end
