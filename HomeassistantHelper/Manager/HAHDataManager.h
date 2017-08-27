//
//  HAHDataManager.h
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/7/9.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import "HAHManager.h"

@class HAHEntityModel, HAHPageModel;

@interface HAHDataManager : HAHManager

- (void)requestDataWithURL:(NSString *)url user:(NSString *)user password:(NSString *)password complete:(void (^)(NSArray<HAHEntityModel *> *ungroupedEntities, NSArray<HAHPageModel *> *pages))completeBlock;

// 同步，阻塞进程
- (NSString *)requestFile:(NSString *)fileName;

@end
