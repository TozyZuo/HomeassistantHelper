//
//  HAHDataManager.h
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/7/9.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import "HAHManager.h"

@class HAHEntityModel, HAHPageModel, HAHBackupModel, HAHFile;

typedef NS_ENUM(NSInteger, HAHType) {
    HAHTypeHassbian     =      0,
    HAHTypeHassio       =      1,
};

@interface HAHDataManager : HAHManager

@property (nonatomic, readonly) NSString *URL;
@property (nonatomic, readonly) NSString *user;
@property (nonatomic, readonly) NSString *password;

- (void)requestDataWithURL:(NSString *)url
                      user:(NSString *)user
                  password:(NSString *)password
                      type:(HAHType)type
                  complete:(void (^)(NSArray<HAHEntityModel *> *ungroupedEntities, NSArray<HAHPageModel *> *pages))completeBlock;

- (void)requestBackupWithComplete:(void (^)(HAHBackupModel *backup))completeBlock;
- (void)saveFile:(HAHFile *)file;
- (void)restoreBackupWithFolder:(NSString *)folder complete:(void (^)(NSString *result))completeBlock;

- (void)restartHomeassistantServiceWithComplete:(void (^)(NSString *result))completeBlock;;

// 同步，阻塞进程
- (NSString *)requestFile:(NSString *)fileName;

@end
