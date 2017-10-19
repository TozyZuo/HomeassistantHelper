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

static NSString * const HAHBackupDirectory = @"HomeassistantHelperBackup";

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
@property (nonatomic, strong) NSMutableSet          *filesToSave;
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
        self.filesToSave = [[NSMutableSet alloc] init];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(init) name:NSApplicationWillTerminateNotification object:nil];
    }
    return self;
}

#pragma mark - Notification

- (void)applicationWillTerminateNotification:(NSNotification *)notification
{
    [self.session disconnect];
}

#pragma mark - Public

- (void)requestDataWithURL:(NSString *)url user:(NSString *)user password:(NSString *)password complete:(void (^)(NSArray<HAHEntityModel *> *, NSArray<HAHPageModel *> *))completeBlock
{
    self.delayTime = 1;
    self.URL = url;
    self.requestDataCompleteBlock = completeBlock;
    self.entities = nil;
    self.configurationFile = nil;

#ifndef LoadFileFromLocal
    [self initializeSSHWithURL:url user:user password:password];
#endif

    [self startEntitiesRequestWithURL:url];
    [self startFileRequest];
}

- (void)saveFile:(HAHFile *)file
{
    // 多次保存同一个文件，只保存一次
    [self.filesToSave addObject:file];

    // 下个loop一起保存
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

        // 子线程保存
        dispatch_async(self.sshQueue, ^{

            if (self.filesToSave.count) {

                [self backupFile:file.name];

                HAHFile *file = self.filesToSave.anyObject;
                [self execute:@"echo", [NSString stringWithFormat:@"\"%@\">%@%@", file.text, HAHHomeassistantPath, file.name], nil];
                [self.filesToSave removeObject:file];
            }

        });
    });
}

#pragma mark - Private

- (void)initializeSSHWithURL:(NSString *)url user:(NSString *)user password:(NSString *)password
{
    if (self.session) {
        return;
    }

    dispatch_async(self.sshQueue, ^{

        self.session = [NMSSHSession connectToHost:[NSURL URLWithString:url].host withUsername:user];

        if (self.session.isConnected) {
            [self.session authenticateByPassword:password];

            if (self.session.isAuthorized) {
                HAHLOG(@"SSH通道建立");
            }
        }
    });
}

- (void)startEntitiesRequestWithURL:(NSString *)url
{
#ifdef LoadFileFromLocal

    self.entities = [NSKeyedUnarchiver unarchiveObjectWithFile:[NSString stringWithFormat:@"%@entities", HAHHomeassistantPath]];
    [self tryToCallBack];

    // FIXME 删掉这行会崩溃，编译器bug？？？，暂时不找根本原因
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

- (void)startFileRequest
{
#ifdef LoadFileFromLocal

    self.configurationFile = [[HAHConfigurationFile alloc] initWithText:[self requestFile:(NSString *)HAHSConfigurationFileName]];
    [self tryToCallBack];

#else

    dispatch_async(self.sshQueue, ^{

        if (self.session.isAuthorized) {

            self.configurationFile = [[HAHConfigurationFile alloc] initWithText:[self requestFile:(NSString *)HAHSConfigurationFileName]];

            dispatch_async(dispatch_get_main_queue(), ^{
                [self tryToCallBack];
            });
        }
    });

#endif
}

- (void)tryToCallBack
{
    if (self.requestDataCompleteBlock && self.entities && self.configurationFile)
    {
        [self.configurationFile mergeInfomationWithEntities:self.entities];
        self.requestDataCompleteBlock([self filterUngroupedEntitiesWithAllEntities:self.entities pages:self.configurationFile.groupFile.pages], self.configurationFile.groupFile.pages);
        self.requestDataCompleteBlock = nil;
    }
}

- (NSArray<HAHEntityModel *> *)filterUngroupedEntitiesWithAllEntities:(NSArray<HAHEntityModel *> *)entities pages:(NSArray<HAHPageModel *> *)pages
{
    NSMutableArray<HAHEntityModel *> *allEntities = entities.mutableCopy;

    for (HAHPageModel *pageModels in pages) {
        for (HAHGroupModel *groupModels in pageModels.groups) {
            [allEntities removeObjectsInArray:groupModels.entities];
        }
    }

    return allEntities.copy;
}

#pragma mark SSH

- (NSString *)execute:(NSString *)command, ... NS_REQUIRES_NIL_TERMINATION
{
    NSMutableArray *arguments = [[NSMutableArray alloc] init];

    va_list ap;
    va_start(ap, command);
    NSString *arg;
    while ((arg = va_arg(ap, NSString *))) {
        [arguments addObject:arg];
    }
    va_end(ap);

#ifdef LoadFileFromLocal

    NSTask *task = [[NSTask alloc] init];
    task.launchPath = [NSString stringWithFormat:@"/bin/%@", command];
    task.arguments = arguments;
    task.currentDirectoryPath = @"/";

    NSPipe *pipe = [NSPipe pipe];
    task.standardOutput = pipe;

    NSFileHandle *fileHandle = pipe.fileHandleForReading;

    [task launch];

    return [[NSString alloc] initWithData:[fileHandle readDataToEndOfFile] encoding:NSUTF8StringEncoding];

#else

    [arguments insertObject:command atIndex:0];
    [arguments insertObject:@"sudo" atIndex:0];

    NSError *error;
    NSString *result = [self.session.channel execute:[arguments componentsJoinedByString:@" "] error:&error];
    HAHLogError(error);
    return result;
    
#endif
}

- (NSString *)requestFile:(NSString *)fileName
{
    return [self execute:@"cat", [NSString stringWithFormat:@"%@%@", HAHHomeassistantPath, fileName], nil];
}

- (BOOL)makeDirectoryWithPath:(NSString *)path directory:(NSString *)directory
{
    NSString *result = [self execute:@"ls", path, nil];
    if (![result containsString:directory]) {
        [self execute:@"mkdir", [NSString stringWithFormat:@"%@%@%@", path, [path hasSuffix:@"/"] ? @"" : @"/", directory], nil];
        return YES;
    }
    return NO;
}

- (void)backupFile:(NSString *)fileName
{
    [self makeDirectoryWithPath:HAHHomeassistantPath directory:HAHBackupDirectory];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyyMMdd";
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    NSString *today = [dateFormatter stringFromDate:[NSDate date]];

    NSString *backupPath = [NSString stringWithFormat:@"%@%@/", HAHHomeassistantPath, HAHBackupDirectory];
    [self makeDirectoryWithPath:backupPath directory:today];

    [self execute:@"cp", @"-n", [NSString stringWithFormat:@"%@%@", HAHHomeassistantPath, fileName], [NSString stringWithFormat:@"%@%@/%@", backupPath, today, fileName], nil];
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
