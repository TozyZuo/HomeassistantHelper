//
//  HAHEntityParser.m
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/7/11.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import "HAHEntityParser.h"
#import "HAHEntityModel.h"
#import "GDataXMLNode.h"

@implementation HAHEntityParser

- (NSArray<HAHEntityModel *> *)parse:(NSString *)text
{
    NSError *error;
    GDataXMLElement *xml = [[GDataXMLElement alloc] initWithXMLString:text error:&error];
    if (error) {
        HAHLOG(@"解析Entity失败，xml初始化错误 %@", error);
        return nil;
    }

    NSMutableArray *models = [[NSMutableArray alloc] init];
    NSArray *elements = xml.children;
    NSUInteger count = elements.count - 1;
    // 第0个是标题行，略过，最后一个是template，略过
    for (int i = 1; i < count; i++) {
        GDataXMLElement *element = elements[i];

        // 解析id
        GDataXMLElement *idElement = element.children.firstObject;
        GDataXMLElement *aElement = idElement.children.firstObject;
        GDataXMLNode *idNode = aElement.children.firstObject;

        // 解析name
        GDataXMLElement *nameElement = element.children[2];
        GDataXMLNode *nameNode = nameElement.children.firstObject;
        if (!nameNode) {
            HAHLOG(@"未发现name标签，name为空");
        }

        // 剥离friendly_name
        NSArray *attributesArray = [nameNode.XMLString componentsSeparatedByString:@"\n"];
        NSMutableDictionary *attributesDictionary = [[NSMutableDictionary alloc] init];
        for (NSString *oneAttribute in attributesArray) {
            NSArray *keyValueArray = [oneAttribute componentsSeparatedByString:@":"];

            NSString *key = [keyValueArray.firstObject stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

            NSString *value = [keyValueArray.lastObject stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

            attributesDictionary[key] = value;
        }

        // 生成model
        HAHEntityModel *model = [[HAHEntityModel alloc] init];
        model.id = idNode.XMLString;
        model.name = attributesDictionary[HAHSFriendlyName];

//        HAHLOG(@"%@", model);
        [models addObject:model];
    }
    
    HAHLOG(@"Entity解析成功");
    return models;
}

@end
