//
//  HAHPanEditingGestureRecognizer.m
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/11/15.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import "HAHPanEditingGestureRecognizer.h"

@implementation HAHPanEditingGestureRecognizer
@dynamic delegate;

- (void)flagsChanged:(NSEvent *)event
{
    if ([self.delegate respondsToSelector:_cmd]) {
        [self.delegate flagsChanged:event];
    }
}

@end
