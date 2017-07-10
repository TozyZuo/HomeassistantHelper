//
//  HAHDataManager.h
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/7/9.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HAHEntityModel;

@interface HAHDataManager : NSObject

+ (instancetype)sharedManager;

- (void)requestEntitiesWithURL:(NSString *)url complete:(void (^)(NSArray<HAHEntityModel *> *models))completeBlock;

- (void)startFileRequestWithURL:(NSString *)url user:(NSString *)user password:(NSString *)password;

@end
