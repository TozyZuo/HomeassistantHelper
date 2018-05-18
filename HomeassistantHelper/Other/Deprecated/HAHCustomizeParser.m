//
//  HAHCustomizeParser.m
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/7/30.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import "HAHCustomizeParser.h"

@implementation HAHCustomizeParser

- (NSMutableDictionary<NSString *,NSMutableDictionary<NSString *,NSString *> *> *)pars
{
    text = HAHTrimAllWhiteSpaceWithText(HAHFilterCommentsAndEmptyLineWithText(text));

    NSMutableDictionary *parseResult = [[NSMutableDictionary alloc] init];
    NSError *error;
    NSString *pattern = @".*:(\\n.+\\:.+)+";

    NSRegularExpression *rex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive|NSRegularExpressionAllowCommentsAndWhitespace error:&error];
    if (error) {
        HAHLOG(@"%@", error);
    }
    [rex enumerateMatchesInString:text options:NSMatchingReportCompletion range:NSMakeRange(0, text.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop)
     {
         if (result.range.length)
         {
             NSString *textBlock = [text substringWithRange:result.range];

             NSMutableArray *lines = [textBlock componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]].mutableCopy;

             NSString *identifier = [lines.firstObject componentsSeparatedByString:@":"].firstObject;
             // 移除第一行id
             [lines removeObjectAtIndex:0];
             parseResult[identifier] = [self propertiesWithLines:lines];
         }
     }];

    return parseResult;
}

- (NSMutableDictionary *)propertiesWithLines:(NSArray *)lines
{
    NSMutableDictionary *properties = [[NSMutableDictionary alloc] init];
    for (NSString *line in lines) {
        NSArray<NSString *> *keyValue = [line componentsSeparatedByString:@":"];
        properties[[keyValue.firstObject stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\t"]]] = keyValue.lastObject;
    }
    return properties;
}

@end
