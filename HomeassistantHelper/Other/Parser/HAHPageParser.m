//
//  HAHPageParser.m
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/7/11.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import "HAHPageParser.h"
#import "HAHPageModel.h"
#import "HAHGroupModel.h"

@implementation HAHPageParser

- (NSArray<HAHPageModel *> *)parse:(NSString *)text
{
    NSMutableArray<HAHPageModel *> *pageModels = [[NSMutableArray alloc] init];
    NSMutableArray<HAHGroupModel *> *groupModels = [[NSMutableArray alloc] init];

    while (text.length) {
        NSString *textBlock = [self cutTextBlockFromFullText:text];
//        printf("%s\n====================\n", textBlock.UTF8String);

        if ([self isPageFromTextBlock:textBlock]) {
            [pageModels addObject:[self pageModelWithTextBlock:textBlock]];
        } else {
            [groupModels addObject:[self groupModelWithTextBlock:textBlock]];
        }

        if (textBlock.length) {
            text = [[text substringWithRange:NSMakeRange(textBlock.length, text.length - textBlock.length)] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        } else {
            text = nil;
        }
    }

    for (HAHPageModel *pageModel in pageModels) {
        for (int i = 0; i < pageModel.groups.count; i++) {
            BOOL notFound = YES;
            for (int j = 0; j < groupModels.count; j++) {
                if ([pageModel.groups[i].id isEqualToString:groupModels[j].id]) {
                    [pageModel.groups replaceObjectAtIndex:i withObject:groupModels[j]];
                    [groupModels removeObjectAtIndex:j];
                    notFound = NO;
                    break;
                }
            }
            if (notFound) {
                HAHLOG(@"未找到组 %@", pageModel.groups[i]);
            }
        }

    }

    if (groupModels.count) {
        HAHLOG(@"以下组未找到对应页面 %@", groupModels);
    }

    return pageModels;
}

- (NSString *)cutTextBlockFromFullText:(NSString *)text
{
    if (!text.length) {
        return nil;
    }

    NSRange tmpRange = [text rangeOfString:@".*:([\\w\\W]*?)view:([\\w\\W]*?)entities:([\\w\\W]*?):" options:NSRegularExpressionSearch];

    if (tmpRange.location != NSNotFound)
    {
        NSString *tmpText = [text substringWithRange:tmpRange];
        return [[tmpText substringWithRange:NSMakeRange(0, [tmpText rangeOfString:@"\n" options:NSBackwardsSearch].location)] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    else
    {
        if ([[text componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]].lastObject containsString:@"-"]) {
            return text;
        } else {
            HAHLOG(@"解析错误！\n%@", text);
            return nil;
        }
    }
}

- (BOOL)isPageFromTextBlock:(NSString *)text
{
    for (NSString *line in [text componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]]) {
        if ([line containsString:@"view"]) {
            NSArray *parts = [line componentsSeparatedByString:@":"];
            if ([[parts.firstObject stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@"view"]) {
                return [[parts.lastObject stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@"yes"];
            }
        }
    }

    return NO;
}

- (HAHPageModel *)pageModelWithTextBlock:(NSString *)text
{
    NSArray *lines = [text componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];

    HAHPageModel *pageModel = [[HAHPageModel alloc] init];
    pageModel.id = [[lines.firstObject componentsSeparatedByString:@":"].firstObject stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

    for (NSString *line in lines) {
        if ([line containsString:@"name"]) {
            pageModel.name = [[line componentsSeparatedByString:@":"].lastObject stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        }
        else if ([line containsString:@"-"])
        {
            HAHGroupModel *groupModel = [[HAHGroupModel alloc] init];
            groupModel.id = [[line componentsSeparatedByString:@"-"].lastObject stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            [pageModel.groups addObject:groupModel];
        }
        else {
            if (HAHDebug) {
                if (!([line containsString:pageModel.id] ||
                      [line containsString:@"view"] ||
                      [line containsString:@"entities"] ||
                      [[line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] containsString:@"#"])) // 可能是注释
                {
                    HAHLOG(@"ERROR: 解析失败 %@", line);
                }
            }
        }
    }

    return pageModel;
}

- (HAHGroupModel *)groupModelWithTextBlock:(NSString *)text
{
    NSArray *lines = [text componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];

    HAHGroupModel *groupModel = [[HAHGroupModel alloc] init];
    groupModel.shortID = [[lines.firstObject componentsSeparatedByString:@":"].firstObject stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

    for (NSString *line in lines) {
        if ([line containsString:@"name"]) {
            groupModel.name = [[line componentsSeparatedByString:@":"].lastObject stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        }
        else if ([line containsString:@"-"])
        {
            HAHEntityModel *entityModel = [[HAHEntityModel alloc] init];
            entityModel.id = [[line componentsSeparatedByString:@"-"].lastObject stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            [groupModel.entities addObject:entityModel];
        }
        else {
            if (HAHDebug) {
                if (!([line containsString:groupModel.shortID] ||
                      [line containsString:@"view"] ||
                      [line containsString:@"entities"] ||
                      [[line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] containsString:@"#"])) // 可能是注释
                {
                    HAHLOG(@"ERROR: 解析失败 %@", line);
                }
            }
        }
    }

    return groupModel;
}

@end
