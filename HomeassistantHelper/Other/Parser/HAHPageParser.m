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

static NSMutableCharacterSet *HAHEntityParseCharacterSet;

@interface HAHPageParser ()
@property (nonatomic, class) NSMutableDictionary *allGroups;
@property (nonatomic, class) NSMutableDictionary *allEntities;
@end

@implementation HAHPageParser

static id _allGroups;
+ (NSMutableDictionary *)allGroups
{
    return _allGroups;
}

+ (void)setAllGroups:(NSMutableDictionary *)allGroups
{
    if (![_allGroups isEqual:allGroups]) {
        _allGroups = allGroups;
    }
}

static id _allEntities;
+ (NSMutableDictionary *)allEntities
{
    return _allEntities;
}

+ (void)setAllEntities:(NSMutableDictionary *)allEntities
{
    if (![_allEntities isEqual:allEntities]) {
        _allEntities = allEntities;
    }
}

+ (NSMutableArray<HAHPageModel *> *)parse:(NSDictionary *)dictionary
{
    self.allGroups = [[NSMutableDictionary alloc] init];
    self.allEntities = [[NSMutableDictionary alloc] init];

    NSMutableArray<HAHPageModel *> *pageModels = [[NSMutableArray alloc] init];
    NSMutableDictionary<NSString *, HAHGroupModel *> *groupModels = [[NSMutableDictionary alloc] init];

    for (NSString *key in dictionary) {
        NSDictionary *value = dictionary[key];
        NSAssert([value isKindOfClass:[NSDictionary class]], @"value should be a NSDictionary");

        if ([value[@"view"] boolValue]) {
            [pageModels addObject:[self pageModelFromDictionary:value identifier:key]];
        } else {
            HAHGroupModel *groupModel = [self groupModelFromDictionary:value shortID:key];
            groupModels[groupModel.id] = groupModel;
        }
    }

    // 防止用户写错写漏
    NSMutableDictionary *nonpagedGroups = groupModels.mutableCopy;
    for (HAHPageModel *pageModel in pageModels) {
        for (HAHGroupModel *groupModel in pageModel.groups) {
            if (groupModels[groupModel.id]) {
                nonpagedGroups[groupModel.id] = nil;
            } else {
                HAHLOG(@"未找到组 %@", groupModel);
            }
        }
    }

    if (nonpagedGroups.count) {
        HAHLOG(@"以下组未找到对应页面 %@", nonpagedGroups.allValues);
    }

    self.allGroups = nil;
    self.allEntities = nil;

    return pageModels;
}

+ (HAHPageModel *)pageModelFromDictionary:(NSDictionary *)dictionary identifier:(NSString *)identifier
{
    HAHPageModel *pageModel = [[HAHPageModel alloc] init];
    pageModel.id = identifier;
    pageModel.name = dictionary[@"name"];

    for (NSString *groupID in dictionary[@"entities"]) {
        [pageModel.groups addObject:[self groupModelWithIdentifier:groupID]];
    }

    return pageModel;
}

+ (HAHGroupModel *)groupModelFromDictionary:(NSDictionary *)dictionary shortID:(NSString *)shortID
{
    HAHGroupModel *groupModel = self.allGroups[shortID];
    if (!groupModel) {
        groupModel = [[HAHGroupModel alloc] init];
        groupModel.shortID = shortID;
        self.allGroups[shortID] = groupModel;
        self.allGroups[groupModel.id] = groupModel;
    }

    groupModel.name = dictionary[@"name"];

    for (NSString *entityID in dictionary[@"entities"]) {
        [groupModel.entities addObject:[self entityModelWithIdentifier:entityID]];
    }

    return groupModel;
}

+ (HAHGroupModel *)groupModelWithIdentifier:(NSString *)identifier
{
    HAHGroupModel *groupModel = self.allGroups[identifier];
    if (!groupModel) {
        groupModel = [[HAHGroupModel alloc] init];
        groupModel.id = identifier;
        self.allGroups[identifier] = groupModel;
        self.allGroups[groupModel.shortID] = groupModel;
    }
    return groupModel;
}

+ (HAHEntityModel *)entityModelWithIdentifier:(NSString *)identifier
{
    HAHEntityModel *entityModel = self.allEntities[identifier];
    if (!entityModel) {
        entityModel = [[HAHEntityModel alloc] init];
        entityModel.id = identifier;
        self.allEntities[identifier] = entityModel;
    }
    return entityModel;
}

+ (NSDictionary *)transformPageModel:(HAHPageModel *)pageModel
{
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];

    NSMutableArray *groupEntities = [[NSMutableArray alloc] init];

    for (HAHGroupModel *groupModel in pageModel.groups) {
        [groupEntities addObject:groupModel.id];

        NSMutableArray *entities = [[NSMutableArray alloc] init];
        for (HAHEntityModel *entityModel in groupModel.entities) {
            [entities addObject:entityModel.id];
        }

        NSMutableDictionary *basicData = @{
                                           @"name": groupModel.name,
                                           @"view": @"no",
                                           @"entities": entities,
                                           }.mutableCopy;
//        [basicData addEntriesFromDictionary:groupModel.extensions];
        result[groupModel.shortID] = basicData;
    }

    NSMutableDictionary *basicData = @{
                                       @"name": pageModel.name,
                                       @"view": @"yes",
                                       @"entities": groupEntities,
                                       }.mutableCopy;
//    [basicData addEntriesFromDictionary:pageModel.extensions];
    result[pageModel.id] = basicData;

    return result;
}

/*

 + (void)load
 {
 HAHEntityParseCharacterSet = [NSMutableCharacterSet whitespaceCharacterSet];
 [HAHEntityParseCharacterSet addCharactersInString:@"-"];
 }

- (NSMutableArray<HAHPageModel *> *)parse:(NSDictionary *)dictionary
{
    self.allGroups = [[NSMutableDictionary alloc] init];
    self.allEntities = [[NSMutableDictionary alloc] init];

    NSMutableArray<HAHPageModel *> *pageModels = [[NSMutableArray alloc] init];
    NSMutableDictionary<NSString *, HAHGroupModel *> *groupModels = [[NSMutableDictionary alloc] init];

    text = HAHFilterCommentsAndEmptyLineWithText(text);

    NSError *error;
    NSString *pattern = @".*:([\\w\\W]*?)view:([\\w\\W]*?)entities:.*(\\n.*\\-.*)+";

    NSRegularExpression *rex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive|NSRegularExpressionAllowCommentsAndWhitespace error:&error];
    HAHLogError(error);

    [rex enumerateMatchesInString:text options:NSMatchingReportCompletion range:NSMakeRange(0, text.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop)
     {
         if (result.range.length) {
             NSString *textBlock = [text substringWithRange:result.range];
             if ([self isPageFromTextBlock:textBlock]) {
                 [pageModels addObject:[self pageModelWithTextBlock:textBlock]];
             } else {
                 HAHGroupModel *groupModel = [self groupModelWithTextBlock:textBlock];
                 groupModels[groupModel.id] = groupModel;
             }
         }
     }];

    // 防止用户写错写漏
    NSMutableDictionary *nonpagedGroups = groupModels.mutableCopy;
    for (HAHPageModel *pageModel in pageModels) {
        for (HAHGroupModel *groupModel in pageModel.groups) {
            if (groupModels[groupModel.id]) {
                nonpagedGroups[groupModel.id] = nil;
            } else {
                HAHLOG(@"未找到组 %@", groupModel);
            }
        }
    }

    if (nonpagedGroups.count) {
        HAHLOG(@"以下组未找到对应页面 %@", nonpagedGroups.allValues);
    }

    self.allGroups = nil;
    self.allEntities = nil;

    return pageModels;
}

- (BOOL)isPageFromTextBlock:(NSString *)text
{
    for (NSString *line in [text componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]]) {
        if ([line containsString:@"view"]) {
            NSArray *parts = [line componentsSeparatedByString:@":"];
            if ([[parts.firstObject stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@"view"]) {
                return [[parts.lastObject stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].lowercaseString isEqualToString:@"yes"];
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
            [pageModel.groups addObject:[self groupModelWithLineText:line]];
        }
        else {
            if (HAHDebug) {
                if (!([line containsString:pageModel.id] ||
                      [line containsString:@"view"] ||
                      [line containsString:@"entities"]))
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

    NSString *shortID = [[lines.firstObject componentsSeparatedByString:@":"].firstObject stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

    HAHGroupModel *groupModel = self.allGroups[shortID];
    if (!groupModel) {
        groupModel = [[HAHGroupModel alloc] init];
        groupModel.shortID = shortID;
        self.allGroups[shortID] = groupModel;
        self.allGroups[groupModel.id] = groupModel;
    }

    for (NSString *line in lines) {
        if ([line containsString:@"name"]) {
            groupModel.name = [[line componentsSeparatedByString:@":"].lastObject stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        }
        else if ([line containsString:@"-"])
        {
            [groupModel.entities addObject:[self entityModelWithLineText:line]];
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

- (HAHGroupModel *)groupModelWithLineText:(NSString *)text
{
    NSString *identifier = [text stringByTrimmingCharactersInSet:HAHEntityParseCharacterSet];
    HAHGroupModel *groupModel = self.allGroups[identifier];
    if (!groupModel) {
        groupModel = [[HAHGroupModel alloc] init];
        groupModel.id = identifier;
        self.allGroups[identifier] = groupModel;
        self.allGroups[groupModel.shortID] = groupModel;
    }
    return groupModel;
}

- (HAHEntityModel *)entityModelWithLineText:(NSString *)text
{
    NSString *identifier = [text stringByTrimmingCharactersInSet:HAHEntityParseCharacterSet];
    HAHEntityModel *entityModel = self.allEntities[identifier];
    if (!entityModel) {
        entityModel = [[HAHEntityModel alloc] init];
        entityModel.id = identifier;
        self.allEntities[identifier] = entityModel;
    }
    return entityModel;
}
*/
@end
