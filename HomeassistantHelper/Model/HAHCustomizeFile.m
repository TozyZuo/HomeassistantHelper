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
@property (nonatomic, strong) NSDictionary *internal;
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

@end
