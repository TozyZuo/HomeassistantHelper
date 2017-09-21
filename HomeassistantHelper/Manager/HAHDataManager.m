//
//  HAHDataManager.m
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/7/9.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import "HAHDataManager.h"
#import "HAHEntityParser.h"
#import "HAHGroupModel.h"
#import "HAHPageModel.h"
#import "HAHConfigurationFile.h"
#import "HAHGroupFile.h"
#import <NMSSH/NMSSH.h>
#import <WebKit/WebKit.h>


#define LoadFileFromLocal // 本地开发测试


#ifdef LoadFileFromLocal

static NSString * const HAHHomeassistantPath = @"/Homeassistant/";

#else

static NSString * const HAHHomeassistantPath = @"/home/homeassistant/.homeassistant/";

#endif


@interface HAHDataManager ()
<WKNavigationDelegate>
@property (nonatomic, strong) WKWebView             *webView;
@property (nonatomic, strong) WKNavigation          *homeNavigation;
@property (nonatomic, assign) NSInteger             delayTime;
@property (nonatomic, strong) NSString              *URL;
@property (nonatomic, strong) NSMutableArray        *unreadyModels;
@property (nonatomic, strong) dispatch_queue_t      sshQueue;
@property (nonatomic, strong) NMSSHSession          *session;
@property (nonatomic, strong) NSArray<HAHEntityModel *> *entities;
@property (nonatomic, strong) HAHConfigurationFile  *configurationFile;

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

- (void)requestDataWithURL:(NSString *)url user:(NSString *)user password:(NSString *)password complete:(void (^)(NSArray<HAHEntityModel *> *, NSArray<HAHPageModel *> *))completeBlock
{
    self.delayTime = 1;
    self.URL = url;
    self.requestDataCompleteBlock = completeBlock;
    self.entities = nil;
    self.configurationFile = nil;

    [self startEntitiesRequestWithURL:url];
    [self startFileRequestWithURL:url user:user password:password];
}

#pragma mark Private

- (void)startEntitiesRequestWithURL:(NSString *)url
{
#ifdef LoadFileFromLocal

    self.entities = [NSKeyedUnarchiver unarchiveObjectWithFile:@"/Homeassistant/entities"];
    [self tryToCallBack];

    // 删掉这行会崩溃，编译器bug？？？
    if (self.webView) {
        [WKWebView class];
    }

#else

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

        NSView *view = NSApp.mainWindow.contentView;
        self.webView.left = view.right;
        self.webView.size = [NSScreen mainScreen].visibleFrame.size;
        [view addSubview:self.webView];
    }

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    self.homeNavigation = [self.webView loadRequest:request];

#endif
}

- (void)startFileRequestWithURL:(NSString *)url user:(NSString *)user password:(NSString *)password
{
#ifdef LoadFileFromLocal

    self.configurationFile = [[HAHConfigurationFile alloc] initWithText:[self requestFile:@"configuration.yaml"]];
    [self tryToCallBack];

#else

    dispatch_async(self.sshQueue, ^{

        if (!self.session) {
            self.session = [NMSSHSession connectToHost:[NSURL URLWithString:url].host withUsername:user];
        }

        if (self.session.isConnected) {
            [self.session authenticateByPassword:password];

            if (self.session.isAuthorized) {

                self.configurationFile = [[HAHConfigurationFile alloc] initWithText:[self requestFile:@"configuration.yaml"]];

                dispatch_async(dispatch_get_main_queue(), ^{
                    [self tryToCallBack];
                });
            }
        }

        // TODO
        [self.session disconnect];
    });

#endif
}

- (NSString *)requestFile:(NSString *)fileName
{
    NSError *error;

#ifdef LoadFileFromLocal

    NSString *string = [NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@%@", HAHHomeassistantPath, fileName] encoding:NSUTF8StringEncoding error:&error];

#else

    NSString *string = [self.session.channel execute:[NSString stringWithFormat:@"cat %@%@", HAHHomeassistantPath, fileName] error:&error];

#endif

    if (error) {
        HAHLOG(@"%@ %s(%d)", error, __PRETTY_FUNCTION__, __LINE__);
    }
    return string;
}

- (void)tryToCallBack
{
    if (self.requestDataCompleteBlock && self.entities && self.configurationFile)
    {
        [self.configurationFile mergeInfomationWithEntities:self.entities];
        self.requestDataCompleteBlock([self filterUngroupedEntitiesWithAllEntities:self.entities pages:self.configurationFile.group.pages], self.configurationFile.group.pages);
    }
}

- (NSArray<HAHEntityModel *> *)filterUngroupedEntitiesWithAllEntities:(NSArray<HAHEntityModel *> *)entities pages:(NSArray<HAHPageModel *> *)pages
{
    NSMutableArray<HAHEntityModel *> *allEntities = entities.mutableCopy;

    for (HAHPageModel *pageModels in pages) {
        for (HAHGroupModel *groupModels in pageModels.groups) {
//            [allEntities removeObjectsInArray:groupModels.entities];
            for (HAHEntityModel *entity in groupModels.entities) {
                [allEntities removeObject:entity];
            }
        }
    }

    return allEntities.copy;
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
