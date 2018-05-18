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

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    if (self = [super initWithDictionary:dictionary]) {

        NSDictionary *fileMap = @{
            @"group": NSClassFromString(@"HAHGroupFile"),
            @"homeassistant.customize": NSClassFromString(@"HAHCustomizeFile"),
        };

        for (NSString *key in fileMap) {
                id value = [dictionary valueForKeyPath:key];
                if ([value isKindOfClass:[NSString class]] && [value hasSuffix:@".yaml"]) {
                    value = [HAHParser parseYAML:[[HAHDataManager sharedManager] requestFile:value]];
                }
                id file = [[[fileMap[key] alloc] init] initWithDictionary:value];
                if (file) {
                    [self setValue:file forKey:[[key componentsSeparatedByString:@"."].lastObject stringByAppendingString:@"File"]];
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
    entityModel.extensions = extensions.mutableCopy;
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

- (NSArray<HAHEntityModel *> *)mergeInfomationWithEntities:(NSArray<HAHEntityModel *> *)entities
{
    NSMutableArray<HAHEntityModel *> *allEntities = entities.mutableCopy;
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

        [allEntities removeObject:pageModel];

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

            [allEntities removeObject:groupModel];

            for (HAHEntityModel *entity in groupModel.entities) {

                [entity removeObserver:self];

                BOOL notFound = YES;

                for (HAHEntityModel *mergeEntity in entities) {
                    if ([entity.id isEqualToString:mergeEntity.id]) {
                        entity.name = mergeEntity.name;
                        notFound = NO;
                        break;
                    }
                }

                if (notFound) {
                    HAHLOG(@"未找到设备 %@, 请检查是否填写错误", entity.id);
                }

                __weak typeof(entity) weakEntity = entity;
                [entity addObserver:self selector:@selector(setName:) postprocessor:^(id info, NSString *name)
                 {
                     weakSelf.customizeFile[weakEntity.id][HAHSFriendlyName] = name;
                     [[HAHDataManager sharedManager] saveFile:weakSelf.customizeFile];
                 }];
                [allEntities removeObject:entity];
            }
        }
    }

    // 未分组设备添加监听
    for (HAHEntityModel *entity in allEntities) {

        [entity removeObserver:self];

        __weak typeof(entity) weakEntity = entity;
        [entity addObserver:self selector:@selector(setName:) postprocessor:^(id info, NSString *name)
         {
             weakSelf.customizeFile[weakEntity.id][HAHSFriendlyName] = name;
             [[HAHDataManager sharedManager] saveFile:weakSelf.customizeFile];
         }];
    }

    return allEntities;
}

@end
