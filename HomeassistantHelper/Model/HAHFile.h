//
//  HAHFile.h
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/7/30.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HAHFile : NSObject
@property (readonly) NSString *initialText;
@property (readonly) NSString *text;
@property (readonly) NSString *name;
- (instancetype)initWithText:(NSString *)text;
@end
