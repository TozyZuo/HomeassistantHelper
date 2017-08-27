//
//  HAHConfigManager.m
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/8/27.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import "HAHConfigManager.h"

@implementation HAHConfigManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.modelConfigMap = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"modelConfigMap" ofType:@"plist"]];
    }
    return self;
}

- (void)updateConfig
{

}

@end
