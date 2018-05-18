//
//  HAHParser.h
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/7/11.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HAHParser : NSObject
+ (id)parse:(id)object;
+ (id)parseYAML:(NSString *)text;
+ (NSString *)YAMLFromObject:(id)object;
@end
