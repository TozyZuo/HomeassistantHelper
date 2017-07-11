//
//  HAHConsoleManager.h
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/7/11.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

FOUNDATION_EXPORT void CMLog(NSString *format, ...) NS_FORMAT_FUNCTION(1,2) NS_NO_TAIL_CALL;

@interface HAHConsoleManager : NSWindowController

+ (instancetype)sharedManager;

- (void)showConsole;

@end
