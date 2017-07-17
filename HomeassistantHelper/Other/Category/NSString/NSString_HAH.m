//
//  NSString_HAH.m
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/7/16.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import "NSString_HAH.h"

@implementation NSString (HAHSize)

- (NSSize)sizeWithFont:(NSFont *)font
{
    NSAttributedString *string = [[NSAttributedString alloc] initWithString:self attributes:@{NSFontAttributeName:font}];
    return string.size;
}

@end
