//
//  HAHBrowserManager.m
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/7/15.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import "HAHBrowserManager.h"
#import <WebKit/WebKit.h>

@interface HAHBrowserManager ()
<WKNavigationDelegate>
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) NSString  *URL;
@end

@implementation HAHBrowserManager

- (void)windowDidLoad
{
    [super windowDidLoad];
    if (!self.webView) {
        WKWebViewConfiguration * config = [[WKWebViewConfiguration alloc] init];
        //The minimum font size in points default is 0;
        config.preferences.minimumFontSize = 10;
        //是否支持JavaScript
        config.preferences.javaScriptEnabled = YES;
        //不通过用户交互，是否可以打开窗口
        config.preferences.javaScriptCanOpenWindowsAutomatically = NO;

        NSView *view = self.window.contentView;

        self.webView = [[WKWebView alloc] initWithFrame:view.bounds configuration:config];
        self.webView.navigationDelegate = self;
        [view addSubview:self.webView];
    }
}

- (BOOL)performKeyEquivalent:(NSEvent *)event
{
    if ((event.modifierFlags & NSEventModifierFlagDeviceIndependentFlagsMask) == NSEventModifierFlagCommand)
    {
        if ([event.characters isEqualToString:@"r"])
        {
            [self loadWithURL:self.URL];
            return YES;
        }
    }
    return [super performKeyEquivalent:event];
}

- (NSString *)windowFrameKey
{
    return HAHUDBrowserWindowFrameKey;
}

- (void)loadWithURL:(NSString *)url
{
    self.URL = url;
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}

@end


@implementation HAHBrowserManagerController

- (Class)managerClass
{
    return [HAHBrowserManager class];
}

@end
