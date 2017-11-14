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

@property (weak) IBOutlet WKWebView *webView;

@property (nonatomic, strong) NSString *URL;

@end

@implementation HAHBrowserManager

- (void)windowDidLoad
{
    [super windowDidLoad];

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
