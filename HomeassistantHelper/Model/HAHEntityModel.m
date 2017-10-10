//
//  HAHEntityModel.m
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/7/9.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import "HAHEntityModel.h"
#import <objc/runtime.h>

@implementation HAHEntityModel

- (void)dealloc
{
    NSLog(@"%@ %p %@", object_getClass(self), self, self.name);
//    NSLog(@"%@ %p %s", object_getClass(self), self, __PRETTY_FUNCTION__);
}

// TODO 暂时只重写了Entity的相等判断，后续考虑挪到基类
- (NSUInteger)hash
{
    return self.id.hash ^ self.name.hash;
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[self class]]) {
        return [self.name isEqualToString:[object name]] &&
        [self.id isEqualToString:[object id]];
    }
    return NO;
}

@end
