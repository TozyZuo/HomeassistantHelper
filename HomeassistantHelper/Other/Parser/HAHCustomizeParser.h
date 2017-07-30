//
//  HAHCustomizeParser.h
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/7/30.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import "HAHParser.h"

@interface HAHCustomizeParser : HAHParser
/**
 @return @{id: friendly_name}
 */
- (NSDictionary *)parse:(NSString *)text;
@end
