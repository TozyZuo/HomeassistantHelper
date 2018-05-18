//
//  HAHEntityParser.m
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/7/11.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import "HAHEntityParser.h"
#import "HAHEntityModel.h"

@implementation HAHEntityParser

+ (NSArray<HAHEntityModel *> *)parse:(NSArray *)array
{
    NSMutableArray *models = [[NSMutableArray alloc] init];

    for (NSDictionary *entityDictionary in array) {

        HAHEntityModel *model = [[HAHEntityModel alloc] init];
        model.id = entityDictionary[@"entity_id"];
        model.name = entityDictionary[@"attributes"][HAHSFriendlyName] ?: model.id;

//        HAHLOG(@"%@", model);
        [models addObject:model];
    }
    
    HAHLOG(@"Entity解析成功");
    return models;
}

@end
