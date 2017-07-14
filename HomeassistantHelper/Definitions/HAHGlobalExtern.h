//
//  HAHGlobalExtern.h
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/7/10.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#pragma mark - UserDefaults

FOUNDATION_EXPORT NSString *HAHUDAdressKey;
FOUNDATION_EXPORT NSString *HAHUDWindowFrameKey;

#pragma mark - System

FOUNDATION_EXPORT BOOL HAHDebug;

#pragma mark - Function

FOUNDATION_EXPORT void HAHExecuteBlockOnMainThread(void (^block)());
