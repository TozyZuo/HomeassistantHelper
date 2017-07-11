//
//  HAHDataManager.h
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/7/9.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HAHEntityModel, HAHPageModel;

@interface HAHDataManager : NSObject

+ (instancetype)sharedManager;

- (void)requestDataWithURL:(NSString *)url user:(NSString *)user password:(NSString *)password complete:(void (^)(NSArray<HAHEntityModel *> *entities, NSArray<HAHPageModel *> *pages))completeBlock;

@end
