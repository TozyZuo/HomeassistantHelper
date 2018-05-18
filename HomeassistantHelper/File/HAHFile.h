//
//  HAHFile.h
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/7/30.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HAHFile : NSObject
@property (readonly) NSString     *text; // yaml文本
@property (readonly) NSString     *name; // 文件名
@property (readonly) NSDictionary *data; // yaml转换的数据
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
@end

@interface HAHFile (HAHDeprecated)
@property (readonly) NSString *initialText NS_DEPRECATED_MAC(10_7, 10_7);
- (instancetype)initWithText:(NSString *)text NS_DEPRECATED_MAC(10_7, 10_7);
@end

