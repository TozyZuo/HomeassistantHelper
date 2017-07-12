//
//  HAHGroupModel.h
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/7/11.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import "HAHEntityModel.h"

@interface HAHGroupModel : HAHEntityModel
@property (nonatomic, strong) NSString *shortID;
@property (nonatomic, strong) NSMutableArray<HAHEntityModel *> *entities;
@end
