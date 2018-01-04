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
                id file = [[[fileMap[key] alloc] init] initWithText:text];
                if (file) {
                    [self setValue:file forKey:[key stringByAppendingString:@"File"]];
                }
            }
        }

        // 整合customizeFile
        for (HAHPageModel *pageModel in self.groupFile.pages) {
            [self entityModel:pageModel updateWithExtensions:self.customizeFile[pageModel.id]];
            for (HAHGroupModel *groupModel in pageModel.groups) {
                [self entityModel:groupModel updateWithExtensions:self.customizeFile[groupModel.id]];
                for (HAHEntityModel *entity in groupModel.entities) {
                    [self entityModel:entity updateWithExtensions:self.customizeFile[entity.id]];
                }
            }
        }
    }
    return self;
}

- (void)entityModel:(HAHEntityModel *)entityModel updateWithExtensions:(NSMutableDictionary *)extensions
{
    entityModel.name = extensions[HAHSFriendlyName] ?: entityModel.name ?: entityModel.id;
    entityModel.extensions = extensions;
    for (NSString *property in [extensions.allKeys sortedArrayUsingSelector:@selector(compare:)].reverseObjectEnumerator)
    {
        if ([property isEqualToString:HAHSFriendlyName]) {
            continue;
        }
        [entityModel.infomation addProperty:property classString:[self classStringInferredFromValue:extensions[property]]];
    }

    __weak typeof(self) weakSelf = self;
    static id block;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        block = ^(id info) {
            [[HAHDataManager sharedManager] saveFile:weakSelf.customizeFile];
        };
    });
    [entityModel.extensions removeObserver:self];
    [entityModel.extensions addObserver:self selector:@selector(setObject:forKey:) postprocessor:block];
    // TODO 【extensions添加属性动作】的监听
}

- (NSString *)classStringInferredFromValue:(NSString *)value
{
    static NSArray *BOOLValue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        BOOLValue = @[@"true", @"false"];
    });
    if ([BOOLValue containsObject:value.lowercaseString]) {
        return @"BOOL";
    }

    return @"NSString";
}

- (void)mergeInfomationWithEntities:(NSArray<HAHEntityModel *> *)entities
{
    __weak typeof(self) weakSelf = self;
    // 顺便添加监听
    // TODO 优化监听代码
    for (HAHPageModel *pageModel in self.groupFile.pages) {

        [pageModel.groups removeObserver:self];
        [pageModel.groups addObserver:self selector:@selector(removeObject:) postprocessor:^(id info, id object)
         {
             [[HAHDataManager sharedManager] saveFile:weakSelf.groupFile];
         }];

        [pageModel.groups addObserver:self selector:@selector(removeObjectAtIndex:) postprocessor:^(id info, NSUInteger index)
         {
             [[HAHDataManager sharedManager] saveFile:weakSelf.groupFile];
         }];

        [pageModel.groups addObserver:self selector:@selector(insertObject:atIndex:) postprocessor:^(id info, id object, NSUInteger index)
         {
             [[HAHDataManager sharedManager] saveFile:weakSelf.groupFile];
         }];

        [pageModel removeObserver:self];
        [pageModel addObserver:self selector:@selector(setName:) postprocessor:^(id info, NSString *name)
         {
             [[HAHDataManager sharedManager] saveFile:weakSelf.groupFile];
         }];
        for (HAHGroupModel *groupModel in pageModel.groups) {

            [groupModel removeObserver:self];
            [groupModel.entities addObserver:self selector:@selector(removeObject:) postprocessor:^(id info, id object)
             {
                 [[HAHDataManager sharedManager] saveFile:weakSelf.groupFile];
             }];

            [groupModel.entities addObserver:self selector:@selector(removeObjectAtIndex:) postprocessor:^(id info, NSUInteger index)
             {
                 [[HAHDataManager sharedManager] saveFile:weakSelf.groupFile];
             }];

            [groupModel.entities addObserver:self selector:@selector(insertObject:atIndex:) postprocessor:^(id info, id object, NSUInteger index)
             {
                 [[HAHDataManager sharedManager] saveFile:weakSelf.groupFile];
             }];

            __weak typeof(groupModel) weakGroup = groupModel;
            [groupModel removeObserver:self];
            [groupModel addObserver:self selector:@selector(setName:) postprocessor:^(id info, NSString *name)
             {
                 weakSelf.customizeFile[weakGroup.id][HAHSFriendlyName] = name;
                 [[HAHDataManager sharedManager] saveFile:weakSelf.customizeFile];
                 [[HAHDataManager sharedManager] saveFile:weakSelf.groupFile];
             }];

            for (HAHEntityModel *entity in groupModel.entities) {

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
                [entity addObserver:self selector:@selector(setName:) postprocessor:^(id info, NSString *name)
                 {
                     weakSelf.customizeFile[weakEntity.id][HAHSFriendlyName] = name;
                     [[HAHDataManager sharedManager] saveFile:weakSelf.customizeFile];
                 }];
            }
        }
    }
}

@end
