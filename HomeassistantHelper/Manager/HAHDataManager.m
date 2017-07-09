//
//  HAHDataManager.m
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/7/9.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import "HAHDataManager.h"
#import "GDataXMLNode.h"
#import "HAHEntityModel.h"
#import <WebKit/WebKit.h>


NSString const * HAHFriendlyNameKey = @"friendly_name";


@interface HAHDataManager ()
<WKNavigationDelegate>
@property (nonatomic, strong) WKWebView         *webView;
@property (nonatomic, strong) WKNavigation      *homeNavigation;
@property (nonatomic, assign) NSInteger         delayTime;
@property (nonatomic, strong) NSString          *entitiesRequestURL;
@property (nonatomic, strong) NSArray           *models;
@property (nonatomic, strong) NSMutableArray    *unreadyModels;

@property (nonatomic,  copy ) void (^requestEntitiesCompleteBlock)(NSArray<HAHEntityModel *> *);
@end

@implementation HAHDataManager

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

- (void)requestEntitiesWithURL:(NSString *)url complete:(void (^)(NSArray<HAHEntityModel *> *))completeBlock
{
    self.delayTime = 1;
    self.entitiesRequestURL = url;
    self.requestEntitiesCompleteBlock = completeBlock;

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

        NSView *view = NSApp.keyWindow.contentView;
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

- (void)parseResult:(NSString *)result
{
//    HAHLOG(@"%@", result);
    NSError *error;
    GDataXMLElement *xml = [[GDataXMLElement alloc] initWithXMLString:result error:&error];
    if (error) {
        HAHLOG(@"%@", error);
        // TODO
        return;
    }

    NSMutableArray *models = [[NSMutableArray alloc] init];
    NSArray *elements = xml.children;
    NSUInteger count = elements.count - 1;
    // 第0个是标题行，略过，最后一个是template，略过
    for (int i = 1; i < count; i++) {
        GDataXMLElement *element = elements[i];

        // 解析id
        GDataXMLElement *idElement = element.children.firstObject;
        GDataXMLElement *aElement = idElement.children.firstObject;
        GDataXMLNode *idNode = aElement.children.firstObject;

        // 解析name
        GDataXMLElement *nameElement = element.children[2];
        GDataXMLNode *nameNode = nameElement.children.firstObject;
        // 同步解析失败，进行异步解析
        if (!nameNode) {
            HAHLOG(@"同步解析失败，进行异步解析");
            [self parseResultAsync:result];
            return;
        }

        // 剥离friendly_name
        NSArray *attributesArray = [nameNode.XMLString componentsSeparatedByString:@"\n"];
        NSMutableDictionary *attributesDictionary = [[NSMutableDictionary alloc] init];
        for (NSString *oneAttribute in attributesArray) {
            NSArray *keyValueArray = [oneAttribute componentsSeparatedByString:@":"];

            NSString *key = [keyValueArray.firstObject stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

            NSString *value = [keyValueArray.lastObject stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

            attributesDictionary[key] = value;
        }

        // 生成model
        HAHEntityModel *model = [[HAHEntityModel alloc] init];
        model.id = idNode.XMLString;
        model.name = attributesDictionary[HAHFriendlyNameKey];

        HAHLOG(@"%@", model);
        [models addObject:model];
    }

    HAHLOG(@"同步解析成功");
    [self parseEntitiesSuccessfullyWithModels:models];
}

- (void)parseResultAsync:(NSString *)result
{
//    HAHLOG(@"%@", result);
    NSError *error;
    GDataXMLElement *xml = [[GDataXMLElement alloc] initWithXMLString:result error:&error];
    if (error) {
        HAHLOG(@"%@", error);
        // TODO
        return;
    }
    __weak typeof(self) weakSelf =self;
    NSMutableArray *models = [[NSMutableArray alloc] init];
    NSArray *elements = xml.children;
    NSUInteger count = elements.count - 1;
    // 第0个是标题行，略过，最后一个是template，略过
    for (int i = 1; i < count; i++) {
        GDataXMLElement *element = elements[i];
        GDataXMLElement *idElement = element.children.firstObject;
        GDataXMLElement *aElement = idElement.children.firstObject;
        GDataXMLNode *textNode = aElement.children.firstObject;

        HAHEntityModel *model = [[HAHEntityModel alloc] init];
        model.id = textNode.XMLString;

        // xml里没有解析出来friendly_name，还要在调用一遍js
        NSString *js = [NSString stringWithFormat:@"document.querySelectorAll(\"table tr\")[%d].querySelectorAll(\"td\")[2].innerHTML", i];
        [self.webView evaluateJavaScript:js completionHandler:^(NSString * _Nullable obj, NSError * _Nullable error)
         {
             NSArray *attributesArray = [textNode.XMLString componentsSeparatedByString:@"\n"];
             NSMutableDictionary *attributesDictionary = [[NSMutableDictionary alloc] init];
             for (NSString *oneAttribute in attributesArray) {
                 NSArray *keyValueArray = [oneAttribute componentsSeparatedByString:@":"];

                 NSString *key = [keyValueArray.firstObject stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

                 NSString *value = [keyValueArray.lastObject stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

                 attributesDictionary[key] = value;
             }

             model.name = attributesDictionary[HAHFriendlyNameKey];

             [weakSelf.unreadyModels removeObject:model];
             if (!weakSelf.unreadyModels.count) {
                 HAHLOG(@"异步解析成功");
                 [weakSelf parseEntitiesSuccessfullyWithModels:self.models];
             }
         }];
        [models addObject:model];
    }
    self.models = models;
    self.unreadyModels = models.mutableCopy;
}

- (void)parseEntitiesSuccessfullyWithModels:(NSArray<HAHEntityModel *> *)models
{
    [self.webView removeFromSuperview];
    self.webView = nil;
    if (self.requestEntitiesCompleteBlock) {
        self.requestEntitiesCompleteBlock(models);
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
                            [self parseResult:obj];
                        } else {
                            self.delayTime += 1;
                            [self startEntitiesRequestWithURL:self.entitiesRequestURL];
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
    [self startEntitiesRequestWithURL:self.entitiesRequestURL];
}

@end
