//
//  HAHFile.h
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/7/30.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HAHFile : NSObject
@property (readonly) NSString *text;
- (instancetype)initWithText:(NSString *)text;
@end
