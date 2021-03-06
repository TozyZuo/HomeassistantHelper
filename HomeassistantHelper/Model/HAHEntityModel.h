//
//  HAHEntityModel.h
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/7/9.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import "HAHModel.h"

@interface HAHEntityModel : HAHModel
@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *name;
@end


@interface HAHEntityModel (HAHRuntimeProperties)
@property (nonatomic, strong) NSMutableDictionary *extensions;
@end
