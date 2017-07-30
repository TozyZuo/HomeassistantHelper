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

@implementation HAHConfigurationFile

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
                [self setValue:[[[fileMap[key] alloc] init] initWithText:text] forKey:key];
            }
        }

        // 更新汉化
        for (HAHPageModel *pageModels in self.group.pages) {
            pageModels.name = self.customize[pageModels.id] ?: pageModels.name;
            for (HAHGroupModel *groupModels in pageModels.groups) {
                groupModels.name = self.customize[groupModels.id] ?: groupModels.name;
                for (HAHEntityModel *entity in groupModels.entities) {
                    entity.name = self.customize[entity.id] ?: entity.name;
                }
            }
        }
    }
    return self;
}

- (void)mergeInfomationWithEntities:(NSArray<HAHEntityModel *> *)entities
{
    for (HAHPageModel *pageModels in self.group.pages) {
        for (HAHGroupModel *groupModels in pageModels.groups) {
            for (HAHEntityModel *entity in groupModels.entities) {

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
            }
        }
    }
}

@end
