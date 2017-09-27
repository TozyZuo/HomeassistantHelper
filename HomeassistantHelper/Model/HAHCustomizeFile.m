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
@property (nonatomic, strong) NSMutableDictionary *internal;
@end

@implementation HAHCustomizeFile

- (instancetype)initWithText:(NSString *)text
{
    if (self = [super initWithText:text]) {
        self.internal = [[[HAHCustomizeParser alloc] init] parse:text];
    }
    return self;
}

- (NSString *)objectForKeyedSubscript:(NSString *)key
{
    return self.internal[key];
}

- (void)setObject:(NSString *)obj forKeyedSubscript:(NSString *)key
{
    self.internal[key] = obj;
}

- (NSString *)text
{
    NSMutableString *text = [[NSMutableString alloc] initWithString:@""];

    [self.internal enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull identifier, id  _Nonnull name, BOOL * _Nonnull stop)
    {
        [text appendFormat:@"%@:\n", identifier];
        [text appendFormat:@"   friendly_name: %@\n", name];
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
