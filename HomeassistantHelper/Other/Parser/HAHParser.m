//
//  HAHParser.m
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/7/11.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import "HAHParser.h"
#import <YAML/YAMLSerialization.h>

@implementation HAHParser

+ (id)parse:(id)object
{
    return nil;
}

+ (id)parseYAML:(NSString *)text
{
    NSError *error;
    id result = [YAMLSerialization objectWithYAMLString:text options:kYAMLReadOptionStringScalars|kYAMLReadOptionMutableContainers error:&error];
    HAHLogError(error);

    return result;
}

+ (NSString *)YAMLFromObject:(id)object
{
    NSError *error;
    NSString *result = [YAMLSerialization YAMLStringWithObject:object options:kYAMLWriteOptionSingleDocument error:&error];
    HAHLogError(error);

    // unicode -> chinese
    result = [result stringByReplacingOccurrencesOfString:@"\\u" withString:@"\\U"];
    NSRegularExpression *rex = [NSRegularExpression regularExpressionWithPattern:@"\".*\\\\U.*\"" options:NSRegularExpressionCaseInsensitive|NSRegularExpressionAllowCommentsAndWhitespace error:&error];
    HAHLogError(error);

    NSArray *matches = [rex matchesInString:result options:NSMatchingReportCompletion range:NSMakeRange(0, result.length)];

    NSMutableString *correctString = result.mutableCopy;
    for (NSTextCheckingResult *checkingResult in matches) {
        NSString *subString = [result substringWithRange:checkingResult.range];

        NSString *chineseString = [NSPropertyListSerialization propertyListWithData:[subString dataUsingEncoding:NSUTF8StringEncoding] options:NSPropertyListImmutable format:NULL error:NULL];
        [correctString replaceOccurrencesOfString:subString withString:chineseString options:0 range:NSMakeRange(0, correctString.length)];
    }

    return correctString;
}

@end
