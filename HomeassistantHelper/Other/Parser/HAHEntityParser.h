//
//  HAHEntityParser.h
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/7/11.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import "HAHParser.h"

@class HAHEntityModel;

@interface HAHEntityParser : HAHParser
+ (NSArray<HAHEntityModel *> *)parse:(NSArray *)array;
@end
