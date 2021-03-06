//
//  HAHPageParser.h
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/7/11.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import "HAHParser.h"

@class HAHPageModel;

@interface HAHPageParser : HAHParser
+ (NSMutableArray<HAHPageModel *> *)parse:(NSDictionary *)dictionary;
+ (NSDictionary *)transformPageModel:(HAHPageModel *)pageModel;
@end
