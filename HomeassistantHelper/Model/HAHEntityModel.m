//
//  HAHEntityModel.m
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/7/9.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import "HAHEntityModel.h"
#import "GDataXMLNode.h"
#import <WebKit/WebKit.h>

@implementation HAHEntityModel

- (NSString *)description
{
    return [[super description] stringByAppendingFormat:@"name:[%@] id:[%@]", self.name, self.id];
}

@end
