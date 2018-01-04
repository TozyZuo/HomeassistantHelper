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
- (void)addProperty:(NSString *)property classString:(NSString *)classString;
@end

@interface HAHModel : NSObject
<NSCoding>
@property (readonly) HAHModelInformation *infomation;
@property (readonly) NSArray *ignoreProperties;
@end
