//
//  Foundation_Log.m
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/7/15.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSInteger __depth = 0;

@implementation NSArray(HAHLog)

- (NSString *)descriptionWithLocale:(id)locale
{
    NSString *logStr = [self descriptionWithDepth:++__depth];
    __depth--;
    return logStr;
}

- (NSString *)descriptionWithDepth:(NSInteger)depth
{
    NSMutableString *logStr = [NSMutableString string];

    [logStr appendFormat:@"(\n"];

    NSInteger count = self.count;
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        for (NSInteger i = 0; i < depth; i++) {
            [logStr appendFormat:@"\t"];
        }

        if (idx != count - 1) {
            [logStr appendFormat:@"%@,\n", obj];
        } else {
            [logStr appendFormat:@"%@\n", obj];
        }
    }];

    for (NSInteger i = 1; i < depth; ++i) {
        [logStr appendFormat:@"\t"];
    }

    [logStr appendFormat:@")"];

    return logStr;
}

@end;

@implementation NSDictionary(HAHLog)

- (NSString *)descriptionWithLocale:(id)locale
{
    NSString *logStr = [self descriptionWithDepth:++__depth];
    __depth--;
    return logStr;
}

- (NSString *)descriptionWithDepth:(NSInteger)depth
{
    NSMutableString *logStr = [NSMutableString string];

    [logStr appendFormat:@"{\n"];

    [self enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        for (NSInteger i = 0; i < depth; i++) {
            [logStr appendFormat:@"\t"];
        }

        [logStr appendFormat:@"%@ =\t%@;\n", key, obj];
    }];

    for (NSInteger i = 1; i < depth; ++i) {
        [logStr appendFormat:@"\t"];
    }

    [logStr appendFormat:@"}"];

    return logStr;
}

@end

@implementation NSSet(HAHLog)

- (NSString *)descriptionWithLocale:(id)locale
{
    NSString *logStr = [self descriptionWithDepth:++__depth];
    __depth--;
    return logStr;
}

- (NSString *)descriptionWithDepth:(NSInteger)depth
{
    NSMutableString *logStr = [NSMutableString string];

    [logStr appendFormat:@"{(\n"];

    NSInteger count = self.count;

    __block NSInteger idx = 0;
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop)
     {
         for (NSInteger i = 0; i < depth; i++) {
             [logStr appendFormat:@"\t"];
         }

         if (idx != count - 1) {
             [logStr appendFormat:@"%@,\n", obj];
         } else {
             [logStr appendFormat:@"%@\n", obj];
         }

         ++idx;
     }];

    for (NSInteger i = 1; i < depth; ++i) {
        [logStr appendFormat:@"\t"];
    }

    [logStr appendFormat:@")}"];
    
    return logStr;
}

@end
