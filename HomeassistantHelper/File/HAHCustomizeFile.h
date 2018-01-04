//
//  HAHCustomizeFile.h
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/7/30.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import "HAHFile.h"

@interface HAHCustomizeFile : HAHFile

- (NSMutableDictionary<NSString */*property*/, NSString */*value*/> *)objectForKeyedSubscript:(NSString *)key;

@end
