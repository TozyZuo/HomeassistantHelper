//
//  HAHGlobalExtern.m
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/7/10.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import "HAHGlobalExtern.h"

#pragma mark - UserDefaults

NSString const * HAHUDAdressKey = @"HAHUDAdressKey";
NSString const * HAHUDWindowFrameKey = @"HAHUDWindowFrameKey";

#pragma mark - System

BOOL HAHDebug = YES;

#pragma mark - Function

void HAHExecuteBlockOnMainThread(void (^block)())
{
    if (!block) {
        return;
    }

    if ([[NSThread currentThread] isMainThread]) {
        block();
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            block();
        });
    }
}
