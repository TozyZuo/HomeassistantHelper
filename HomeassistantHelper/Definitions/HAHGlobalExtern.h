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
FOUNDATION_EXPORT NSString *HAHUDUserNameKey;
FOUNDATION_EXPORT NSString *HAHUDPasswordKey;
FOUNDATION_EXPORT NSString *HAHUDKeepPasswordKey;

FOUNDATION_EXPORT NSString *HAHUDMainWindowFrameKey;
FOUNDATION_EXPORT NSString *HAHUDBrowserWindowFrameKey;
FOUNDATION_EXPORT NSString *HAHUDConsoleWindowFrameKey;

FOUNDATION_EXPORT NSString *HAHUDConsoleFontSizeKey;

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

FOUNDATION_EXPORT NSString const * HAHSFriendlyName;
