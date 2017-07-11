//
//  HAHPageParser.m
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/7/11.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import "HAHPageParser.h"
#import "HAHPageModel.h"

@implementation HAHPageParser

- (NSArray<HAHPageModel *> *)parse:(NSString *)text
{
    NSArray *lines = [text componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    return @[];
}

@end
