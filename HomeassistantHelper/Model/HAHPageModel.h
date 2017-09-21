//
//  HAHPageModel.h
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/7/11.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import "HAHEntityModel.h"

@class HAHGroupModel;

@interface HAHPageModel : HAHEntityModel
@property (nonatomic, strong) HAHObservableArray<HAHGroupModel *> *groups;
@end
