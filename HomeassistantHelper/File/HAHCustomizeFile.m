//
//  HAHCustomizeFile.m
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/7/30.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import "HAHCustomizeFile.h"
#import "HAHCustomizeParser.h"

@interface HAHCustomizeFile ()
@property (nonatomic, strong) NSMutableDictionary<NSString */*id*/, NSMutableDictionary<NSString */*property*/, NSString */*value*/> *> *internal;
@end

@implementation HAHCustomizeFile

- (instancetype)initWithText:(NSString *)text
{
    if (self = [super initWithText:text]) {
        self.internal = [[[HAHCustomizeParser alloc] init] parse:text];
    }
    return self;
}

- (NSMutableDictionary<NSString */*property*/, NSString */*value*/> *)objectForKeyedSubscript:(NSString *)key
{
    return self.internal[key];
}

- (NSString *)text
{
    NSMutableString *text = [[NSMutableString alloc] initWithString:@""];

    [self.internal enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull identifier, NSMutableDictionary<NSString *, NSString *> *properties, BOOL * _Nonnull stop)
    {
        [text appendFormat:@"%@:\n", identifier];
        [properties enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
            [text appendFormat:@"\t%@: %@\n", key, obj];
        }];
    }];

    return text;
}

- (NSString *)name
{
    return (NSString *)HAHSCustomizeFileName;
}

- (NSString *)debugDescription
{
    return [[super debugDescription] stringByAppendingString:self.internal.debugDescription];
}

@end
