//
//  HAHConfigParser.h
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/7/11.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import "HAHParser.h"

@interface HAHConfigParser : HAHParser
/**
 @return @{
             group: text,
             customize: text,
             ...
          }
 */
- (NSDictionary *)parse:(NSString *)text;
@end
