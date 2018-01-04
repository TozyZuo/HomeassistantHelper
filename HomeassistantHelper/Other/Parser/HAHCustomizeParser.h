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
 @return @{id: @{friendly_name: NSString,
                 ...
                 }
          }
 */
- (NSMutableDictionary<NSString */*id*/, NSMutableDictionary<NSString */*property*/, NSString */*value*/> *> *)parse:(NSString *)text;
@end
