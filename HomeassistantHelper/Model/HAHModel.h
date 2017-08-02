//
//  HAHModel.h
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/7/11.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HAHModelInformation : NSObject
@property (nonatomic, readonly) NSArray *propertyNames;
- (NSString *)classStringForProperty:(NSString *)property;
@end

@interface HAHModel : NSObject
<NSCoding>
@property (readonly, class) HAHModelInformation *infomation;
@end
