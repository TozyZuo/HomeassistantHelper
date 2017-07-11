//
//  HAHPageModel.h
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/7/11.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import "HAHModel.h"

@class HAHGroupModel;

@interface HAHPageModel : HAHModel
@property (nonatomic, strong) NSMutableArray<HAHGroupModel *> *groups;
@end
