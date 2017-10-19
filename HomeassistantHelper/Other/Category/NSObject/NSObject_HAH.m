//
//  NSObject_HAH.m
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/9/28.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import "NSObject_HAH.h"
#import "Aspects.h"


@implementation NSObject (HAHObserve)

- (void)addObserver:(NSObject *)observer selector:(SEL)selector preprocessor:(id)block
{
    NSError *error;
    [self aspect_hookSelector:selector withOptions:AspectPositionBefore usingBlock:block error:nil];
    HAHLogError(error);
}

- (void)addObserver:(NSObject *)observer selector:(SEL)selector postprocessor:(id)block
{
    NSError *error;
    [self aspect_hookSelector:selector withOptions:AspectPositionAfter usingBlock:block error:nil];
    HAHLogError(error);
}
@end

