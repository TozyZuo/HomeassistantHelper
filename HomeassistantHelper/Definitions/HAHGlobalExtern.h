//
//  HAHGlobalExtern.h
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/7/10.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#pragma mark - UserDefaults

FOUNDATION_EXPORT NSString * const HAHUDAdressKey;
FOUNDATION_EXPORT NSString * const HAHUDUserNameKey;
FOUNDATION_EXPORT NSString * const HAHUDPasswordKey;
FOUNDATION_EXPORT NSString * const HAHUDKeepPasswordKey;

FOUNDATION_EXPORT NSString * const HAHUDMainWindowFrameKey;
FOUNDATION_EXPORT NSString * const HAHUDBrowserWindowFrameKey;
FOUNDATION_EXPORT NSString * const HAHUDConsoleWindowFrameKey;

FOUNDATION_EXPORT NSString * const HAHUDConsoleFontSizeKey;

#pragma mark - System

FOUNDATION_EXPORT BOOL HAHDebug;

#pragma mark - Function

FOUNDATION_EXPORT void HAHExecuteBlockOnMainThread(void (^block)());

FOUNDATION_EXPORT NSString  *HAHFilterCommentsAndEmptyLineWithText(NSString *text);
FOUNDATION_EXPORT NSArray   *HAHSeparateTextToLinesAndFilterCommentsAndEmptyLine(NSString *text);
FOUNDATION_EXPORT NSString  *HAHTrimAllWhiteSpaceWithText(NSString *text);

#pragma mark - Global

FOUNDATION_EXPORT CGFloat const HAHModelConfigViewWidth;

#pragma mark - String

FOUNDATION_EXPORT NSString * const HAHSFriendlyName;
FOUNDATION_EXPORT NSString * const HAHSConfigurationFileName;
FOUNDATION_EXPORT NSString * const HAHSGroupFileName;
FOUNDATION_EXPORT NSString * const HAHSCustomizeFileName;
