//
//  HAHConfigurationFile.m
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/7/30.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import "HAHConfigurationFile.h"
#import "HAHConfigParser.h"
#import "HAHGroupModel.h"
#import "HAHPageModel.h"
#import "HAHGroupFile.h"
#import "HAHCustomizeFile.h"
#import "HAHDataManager.h"
#import "NSObject_HAH.h"

@implementation HAHConfigurationFile

- (void)dealloc
{
    
}

- (NSString *)name
{
    return (NSString *)HAHSConfigurationFileName;
}

- (instancetype)initWithText:(NSString *)text
{
    if (self = [super initWithText:text]) {

        NSDictionary *fileMap = @{
            @"group": NSClassFromString(@"HAHGroupFile"),
            @"customize": NSClassFromString(@"HAHCustomizeFile"),
        };

        NSDictionary *result = [[[HAHConfigParser alloc] init] parse:text];
        for (NSString *key in result) {
            @autoreleasepool {
                NSString *text = result[key];
                if ([text containsString:@"!include"]) {
                    text = [[HAHDataManager sharedManager] requestFile:[[text stringByReplacingOccurrencesOfString:@"!include" withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
                }
                // TODO text = nil
                [self setValue:[[[fileMap[key] alloc] init] initWithText:text] forKey:[key stringByAppendingString:@"File"]];
            }
        }

        // 更新汉化
        for (HAHPageModel *pageModels in self.groupFile.pages) {
            pageModels.name = self.customizeFile[pageModels.id] ?: pageModels.name ?: pageModels.id;
            for (HAHGroupModel *groupModels in pageModels.groups) {
                groupModels.name = self.customizeFile[groupModels.id] ?: groupModels.name ?: groupModels.id;
                for (HAHEntityModel *entity in groupModels.entities) {
                    entity.name = self.customizeFile[entity.id] ?: entity.name ?: entity.id;
                }
            }
        }
    }
    return self;
}

- (void)mergeInfomationWithEntities:(NSArray<HAHEntityModel *> *)entities
{
    __weak typeof(self) weakSelf = self;
    // 顺便添加监听
    for (HAHPageModel *pageModels in self.groupFile.pages) {
        for (HAHGroupModel *groupModels in pageModels.groups) {

            [groupModels.entities injectToSelector:@selector(removeObject:) postprocessor:^(id object)
             {
                 [[HAHDataManager sharedManager] saveFile:weakSelf.groupFile];
             }];

            [groupModels.entities injectToSelector:@selector(insertObject:atIndex:) postprocessor:^(id object, NSUInteger index)
             {
                 [[HAHDataManager sharedManager] saveFile:weakSelf.groupFile];
             }];

            for (HAHEntityModel *entity in groupModels.entities) {

                BOOL notFound = YES;

                for (HAHEntityModel *mergeEntity in entities) {
                    if ([entity.id isEqualToString:mergeEntity.id]) {
                        // 先以customize为准，理论上是一样的
//                        entity.name = mergeEntity.name;
                        notFound = NO;
                        break;
                    }
                }

                if (notFound) {
                    HAHLOG(@"未找到设备 %@, 请检查是否填写错误", entity.id);
                }
                __weak typeof(entity) weakEntity = entity;
                [entity removeObserver:self];
                [entity addObserver:self selector:@selector(setName:) postprocessor:^(NSString *name)
                 {
                     weakSelf.customizeFile[weakEntity.id] = weakEntity.name;
                     [[HAHDataManager sharedManager] saveFile:weakSelf.customizeFile];
                 }];
            }
        }
    }
}

@end
