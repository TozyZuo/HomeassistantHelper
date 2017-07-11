//
//  HAHGroupModel.h
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/7/11.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import "HAHModel.h"

@class HAHEntityModel;

@interface HAHGroupModel : HAHModel
@property (nonatomic, strong) NSMutableArray<HAHEntityModel *> *entities;
@end
