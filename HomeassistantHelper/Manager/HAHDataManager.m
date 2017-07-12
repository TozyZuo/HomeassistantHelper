//
//  HAHDataManager.m
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/7/9.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import "HAHDataManager.h"
#import "HAHEntityModel.h"
#import "HAHGroupModel.h"
#import "HAHPageModel.h"
#import "HAHEntityParser.h"
#import "HAHPageParser.h"
#import "HAHConfigParser.h"
#import <NMSSH/NMSSH.h>
#import <WebKit/WebKit.h>


@interface HAHDataManager ()
<WKNavigationDelegate>
@property (nonatomic, strong) WKWebView         *webView;
@property (nonatomic, strong) WKNavigation      *homeNavigation;
@property (nonatomic, assign) NSInteger         delayTime;
@property (nonatomic, strong) NSString          *URL;
@property (nonatomic, strong) NSMutableArray    *unreadyModels;
@property (nonatomic, strong) dispatch_queue_t  sshQueue;
@property (nonatomic, strong) NSArray<HAHEntityModel *> *entities;
@property (nonatomic, strong) NSArray<HAHPageModel *>   *pages;

@property (nonatomic,  copy ) void (^requestDataCompleteBlock)(NSArray<HAHEntityModel *> *, NSArray<HAHPageModel *> *);
@end

@implementation HAHDataManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.sshQueue = dispatch_queue_create("HAH.ssh.queue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

#pragma mark Public

+ (instancetype)sharedManager
{
    static id _manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[self alloc] init];
    });
    return _manager;
}

- (void)requestDataWithURL:(NSString *)url user:(NSString *)user password:(NSString *)password complete:(void (^)(NSArray<HAHEntityModel *> *, NSArray<HAHPageModel *> *))completeBlock
{
    self.delayTime = 1;
    self.URL = url;
    self.requestDataCompleteBlock = completeBlock;

    [self requestEntitiesWithURL:url];
    [self startFileRequestWithURL:url user:user password:password];
}

- (void)requestEntitiesWithURL:(NSString *)url
{
    if (!self.webView) {
        WKWebViewConfiguration * config = [[WKWebViewConfiguration alloc] init];
        //The minimum font size in points default is 0;
        config.preferences.minimumFontSize = 10;
        //是否支持JavaScript
        config.preferences.javaScriptEnabled = YES;
        //不通过用户交互，是否可以打开窗口
        config.preferences.javaScriptCanOpenWindowsAutomatically = NO;
        self.webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:config];
        self.webView.navigationDelegate = self;

        NSView *view = NSApp.windows.firstObject.contentView;
        CGRect frame = view.frame;
        frame.origin.x = frame.size.width;
        self.webView.frame = frame;
        [view addSubview:self.webView];
    }

    [self startEntitiesRequestWithURL:url];
}

#pragma mark Private

- (void)startEntitiesRequestWithURL:(NSString *)url
{
//    NSURL *url = [NSURL URLWithString:@"http://192.168.10.147:8123"];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    self.homeNavigation = [self.webView loadRequest:request];
}

- (void)startFileRequestWithURL:(NSString *)url user:(NSString *)user password:(NSString *)password
{
    dispatch_async(self.sshQueue, ^{

        NMSSHSession *session = [NMSSHSession connectToHost:[NSURL URLWithString:url].host
                                               withUsername:user];

        if (session.isConnected) {
            [session authenticateByPassword:password];

            if (session.isAuthorized) {
                HAHLOG(@"Authentication succeeded");

                if ([session.channel downloadFile:@"/home/homeassistant/.homeassistant/groups.yaml" to:@"/tmp/groups.yaml"]) {
                    NSString *string = [NSString stringWithContentsOfFile:@"/tmp/groups.yaml" encoding:NSUTF8StringEncoding error:nil];
//                    HAHLOG(@"groups.yaml\n%@", string);
                    self.pages = [[[HAHPageParser alloc] init] parse:string];
                }
                if ([session.channel downloadFile:@"/home/homeassistant/.homeassistant/configuration.yaml" to:@"/tmp/configuration.yaml"]) {
                    NSString *string = [NSString stringWithContentsOfFile:@"/tmp/configuration.yaml" encoding:NSUTF8StringEncoding error:nil];
                    HAHLOG(@"configuration.yaml\n%@", string);
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self tryToCallBack];
                });
            }
        }

        // TODO
        [session disconnect];
    });
}

- (void)tryToCallBack
{
    if (self.requestDataCompleteBlock && self.entities && self.pages) {

        NSMutableArray<HAHEntityModel *> *ungroupedEntities = self.entities.mutableCopy;
        // 合并信息
        // TODO 可能有性能问题
        for (HAHPageModel *pageModels in self.pages) {
            for (HAHGroupModel *groupModels in pageModels.groups) {
                for (int i = 0; i < groupModels.entities.count; i++) {
                    BOOL notFound = YES;
                    for (int j = 0; j < self.entities.count; j++) {
                        if ([groupModels.entities[i].id isEqualToString:self.entities[j].id]) {
                            [groupModels.entities replaceObjectAtIndex:i withObject:self.entities[j]];
                            // 该entity有记录，移除
                            for (int k = 0; k < ungroupedEntities.count; k++) {
                                if ([ungroupedEntities[k].id isEqualToString:self.entities[j].id]) {
                                    [ungroupedEntities removeObjectAtIndex:k];
                                    break;
                                }
                            }
                            notFound = NO;
                            break;
                        }
                    }
                    if (notFound) {
                        HAHLOG(@"未找到设备 %@", groupModels.entities[i]);
                    }
                }
            }
        }

        NSLog(@"ungroupedEntities %@", ungroupedEntities);
        self.requestDataCompleteBlock(self.entities, self.pages);
        self.entities = nil;
        self.pages = nil;
    }
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation
{
    if ([navigation isEqual:self.homeNavigation]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.delayTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // 模拟点击bar上"<>"按钮
            [self.webView evaluateJavaScript:@"document.querySelector(\"paper-icon-button[data-panel=dev-state]\").click()" completionHandler:^(id _Nullable obj, NSError * _Nullable error) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.delayTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    // 取出设备数据
                    [self.webView evaluateJavaScript:@"document.querySelector(\".entities\").innerHTML" completionHandler:^(id _Nullable obj, NSError * _Nullable error) {
                        if (obj) {
                            [self.webView removeFromSuperview];
                            self.webView = nil;
                            self.entities = [[[HAHEntityParser alloc] init] parse:obj];
                            [self tryToCallBack];
                        } else {
                            self.delayTime += 1;
                            [self startEntitiesRequestWithURL:self.URL];
                        }
                    }];
                });
            }];
        });
    }
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    // TODO 错误处理
    [self startEntitiesRequestWithURL:self.URL];
}

@end
