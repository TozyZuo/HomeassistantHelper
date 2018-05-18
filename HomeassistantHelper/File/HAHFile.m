//
//  HAHFile.m
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/7/30.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import "HAHFile.h"
#import "HAHParser.h"

@interface HAHFile ()
@property (nonatomic, strong) NSString *initialText;
@property (nonatomic, strong) NSDictionary *data;
@end

@implementation HAHFile

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    if (self = [super init]) {
        self.data = dictionary;
    }
    return self;
}

- (NSString *)name
{
    return nil;
}

- (NSString *)text
{
    return [HAHParser YAMLFromObject:self.data];
}

@end

@implementation HAHFile (HAHDeprecated)

- (instancetype)initWithText:(NSString *)text
{
    if (!text.length) {
        HAHLOG(@"文件内容为空");
        return nil;
    }

    if (self = [self initWithDictionary:[HAHParser parseYAML:text]]) {
        self.initialText = text;
    }
    return self;
}

@end
