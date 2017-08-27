//
//  HAHConfigManager.h
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/8/27.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import "HAHManager.h"

@interface HAHConfigManager : HAHManager

@property (atomic) NSDictionary *modelConfigMap;

- (void)updateConfig;

@end
