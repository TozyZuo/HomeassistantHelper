//
//  HAHConfigParser.m
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/7/11.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import "HAHConfigParser.h"
#import "HAHDataManager.h"

@implementation HAHConfigParser

- (NSDictionary *)parse:(NSString *)text
{
    static NSArray *keys;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        keys = @[
                 @"group",
                 @"customize",
                 ];
    });

    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    for (NSString *key in keys) {
        result[key] = [self findTextBlockFromText:text key:key];
    }

    return result;
}

- (NSString *)findTextBlockFromText:(NSString *)text key:(NSString *)key
{
    // TODO configuration.yaml中解析对应文本
    NSRange range = [text rangeOfString:[NSString stringWithFormat:@"%@:.*!include.*\n", key] options:NSRegularExpressionSearch];
    if (range.location != NSNotFound) {
        NSString *line = [text substringWithRange:range];
        NSString *fileName = [[line componentsSeparatedByString:@"!include"].lastObject stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        return [[HAHDataManager sharedManager] requestFile:fileName];
    } else {
        HAHLOG(@"暂不支持在configuration.yaml中解析%@", key);
    }

    return @"";
}

@end
