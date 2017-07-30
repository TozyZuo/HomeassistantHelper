//
//  HAHEditViewController.h
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/7/16.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import "HAHViewController.h"

@class HAHPageModel, HAHEntityModel;
@interface HAHEditViewController : HAHViewController
- (void)reloadWithPages:(NSArray<HAHPageModel *> *)pages ungroupedEntities:(NSArray<HAHEntityModel *> *)ungroupedEntities;
@end
