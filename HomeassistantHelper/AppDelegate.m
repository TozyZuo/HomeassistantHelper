//
//  AppDelegate.m
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/7/9.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import "AppDelegate.h"
#import "HAHConfigManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)windowDidLoad
{
    NSButton *closeButton = [self.window standardWindowButton:NSWindowCloseButton];
    closeButton.target = self;
    closeButton.action = @selector(closeAction:);

    // 还原上次关闭时的位置，如果是第一次打开，则全屏
    NSString *windowFrame = [[NSUserDefaults standardUserDefaults] objectForKey:HAHUDMainWindowFrameKey];
    if (windowFrame) {
        [self.window setFrame:NSRectFromString(windowFrame) display:YES];
    } else {
        [self.window setFrame:[NSScreen mainScreen].visibleFrame display:YES];
    }
}

- (void)closeAction:(NSButton *)button
{
    // 记录关闭时app的位置
    [[NSUserDefaults standardUserDefaults]  setObject:NSStringFromRect(self.window.frame) forKey:HAHUDMainWindowFrameKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSApplication sharedApplication] terminate:nil];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [[HAHConfigManager sharedManager] updateConfig];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
