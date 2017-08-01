//
//  HAHCustomizeParser.m
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/7/30.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import "HAHCustomizeParser.h"

@implementation HAHCustomizeParser

- (NSDictionary *)parse:(NSString *)text
{
    NSMutableArray *lines = [text componentsSeparatedByString:@"\n"].mutableCopy;

    NSInteger idx = 0;
    while (idx < lines.count) {
        NSString *line = [lines[idx] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

        if ([line hasPrefix:@"#"]) // 清除注释
        {
            [lines removeObjectAtIndex:idx];
        }
        else if (!line.length) // 空行
        {
            [lines removeObjectAtIndex:idx];
        }
        else // 替换成去掉空格的行
        {
            [lines replaceObjectAtIndex:idx withObject:line];
            idx++;
        }
    }

    if (lines.count%2 != 0) {
        HAHLOG(@"解析Customize行数不对");
        [lines removeLastObject];
    }

    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    for (int i = 0; i < lines.count - 1; i += 2) {
        NSString *key = lines[i];
        key = [[key componentsSeparatedByString:@":"].firstObject stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

        NSString *value = lines[i+1];
        value = [[value componentsSeparatedByString:@":"].lastObject stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        result[key] = value;
    }

    return result;
}

@end
