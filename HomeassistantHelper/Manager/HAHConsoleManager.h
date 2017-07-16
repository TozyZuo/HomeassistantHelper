//
//  HAHConsoleManager.h
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/7/11.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import "HAHWindowControllerManager.h"

FOUNDATION_EXPORT void CMLog(NSString *format, ...) NS_FORMAT_FUNCTION(1,2) NS_NO_TAIL_CALL;

@interface HAHConsoleManager : HAHWindowControllerManager

@end



@interface HAHConsoleManagerController : NSObjectController

@end
