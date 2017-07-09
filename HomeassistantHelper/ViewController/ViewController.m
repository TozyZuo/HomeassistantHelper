//
//  ViewController.m
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/7/9.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import "ViewController.h"
#import "GDataXMLNode.h"
#import "HAHEntityModel.h"
#import <WebKit/WebKit.h>

#define MARK() NSLog(@"%s(%d)", __PRETTY_FUNCTION__, __LINE__)

//static NSString const * HAHFriendlyNameKey = @"friendly_name";
extern NSString const * HAHFriendlyNameKey;


@interface ViewController ()
<WKNavigationDelegate, NSXMLParserDelegate>
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) WKNavigation *homeNavigation;
@property (nonatomic, assign) NSInteger delayTime;
@property (nonatomic, strong) NSMutableArray *models;
@property (nonatomic, strong) NSMutableArray *unreadyModels;
@end

@implementation ViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    if (self = [super initWithCoder:coder]) {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    self.delayTime = 1;

    WKWebViewConfiguration * config = [[WKWebViewConfiguration alloc] init];
    //The minimum font size in points default is 0;
    config.preferences.minimumFontSize = 10;
    //是否支持JavaScript
    config.preferences.javaScriptEnabled = YES;
    //不通过用户交互，是否可以打开窗口
    config.preferences.javaScriptCanOpenWindowsAutomatically = NO;
    self.webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:config];
    self.webView.navigationDelegate = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    NSRect frame;
    frame.size = [NSScreen mainScreen].visibleFrame.size;
    self.view.frame = frame;

    self.webView.frame = self.view.bounds;
    [self.view addSubview:self.webView];

    [self startRequest];
}

- (void)startRequest
{
    NSURL *url = [NSURL URLWithString:@"http://192.168.10.147:8123"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    self.homeNavigation = [self.webView loadRequest:request];
}

- (void)parseResult:(NSString *)result
{
    NSLog(@"%@", result);
    NSError *error;
    GDataXMLElement *xml = [[GDataXMLElement alloc] initWithXMLString:result error:&error];
    if (error) {
        NSLog(@"%@", error);
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
                 // TODO model解析完毕
             }
         }];
        [models addObject:model];
    }
    self.models = models;
    self.unreadyModels = models.mutableCopy;
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation
{
    if ([navigation isEqual:self.homeNavigation]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.delayTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.webView evaluateJavaScript:@"document.querySelector(\"paper-icon-button[data-panel=dev-state]\").click()" completionHandler:^(id _Nullable obj, NSError * _Nullable error) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.delayTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    // 这里不能拿到所有数据，model还得再取一遍，太坑爹了
                    [self.webView evaluateJavaScript:@"document.querySelector(\".entities\").innerHTML" completionHandler:^(id _Nullable obj, NSError * _Nullable error) {
                        if (obj) {
                            [self parseResult:obj];
                        } else {
                            self.delayTime += 1;
                            [self startRequest];
                        }
                    }];
                });
            }];
        });
    }
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    [self startRequest];
}


- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    MARK();
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    MARK();
}

- (void)parser:(NSXMLParser *)parser foundNotationDeclarationWithName:(NSString *)name publicID:(nullable NSString *)publicID systemID:(nullable NSString *)systemID
{
    MARK();
}

- (void)parser:(NSXMLParser *)parser foundUnparsedEntityDeclarationWithName:(NSString *)name publicID:(nullable NSString *)publicID systemID:(nullable NSString *)systemID notationName:(nullable NSString *)notationName
{
    MARK();
}

- (void)parser:(NSXMLParser *)parser foundAttributeDeclarationWithName:(NSString *)attributeName forElement:(NSString *)elementName type:(nullable NSString *)type defaultValue:(nullable NSString *)defaultValue
{
    MARK();
}

- (void)parser:(NSXMLParser *)parser foundElementDeclarationWithName:(NSString *)elementName model:(NSString *)model
{
    MARK();
}

- (void)parser:(NSXMLParser *)parser foundInternalEntityDeclarationWithName:(NSString *)name value:(nullable NSString *)value
{
    MARK();
}

- (void)parser:(NSXMLParser *)parser foundExternalEntityDeclarationWithName:(NSString *)name publicID:(nullable NSString *)publicID systemID:(nullable NSString *)systemID
{
    MARK();
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(nullable NSString *)namespaceURI qualifiedName:(nullable NSString *)qName attributes:(NSDictionary<NSString *, NSString *> *)attributeDict
{
    MARK();
}
// sent when the parser finds an element start tag.
// In the case of the cvslog tag, the following is what the delegate receives:
//   elementName == cvslog, namespaceURI == http://xml.apple.com/cvslog, qualifiedName == cvslog
// In the case of the radar tag, the following is what's passed in:
//    elementName == radar, namespaceURI == http://xml.apple.com/radar, qualifiedName == radar:radar
// If namespace processing >isn't< on, the xmlns:radar="http://xml.apple.com/radar" is returned as an attribute pair, the elementName is 'radar:radar' and there is no qualifiedName.

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(nullable NSString *)namespaceURI qualifiedName:(nullable NSString *)qName
{
    MARK();
}
// sent when an end tag is encountered. The various parameters are supplied as above.

- (void)parser:(NSXMLParser *)parser didStartMappingPrefix:(NSString *)prefix toURI:(NSString *)namespaceURI
{
    MARK();
}
// sent when the parser first sees a namespace attribute.
// In the case of the cvslog tag, before the didStartElement:, you'd get one of these with prefix == @"" and namespaceURI == @"http://xml.apple.com/cvslog" (i.e. the default namespace)
// In the case of the radar:radar tag, before the didStartElement: you'd get one of these with prefix == @"radar" and namespaceURI == @"http://xml.apple.com/radar"

- (void)parser:(NSXMLParser *)parser didEndMappingPrefix:(NSString *)prefix
{
    MARK();
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    MARK();
}
// This returns the string of the characters encountered thus far. You may not necessarily get the longest character run. The parser reserves the right to hand these to the delegate as potentially many calls in a row to -parser:foundCharacters:

- (void)parser:(NSXMLParser *)parser foundIgnorableWhitespace:(NSString *)whitespaceString
{
    MARK();
}
// The parser reports ignorable whitespace in the same way as characters it's found.

- (void)parser:(NSXMLParser *)parser foundProcessingInstructionWithTarget:(NSString *)target data:(nullable NSString *)data
{
    MARK();
}

- (void)parser:(NSXMLParser *)parser foundComment:(NSString *)comment
{
    MARK();
}

- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock
{
    MARK();
}

- (nullable NSData *)parser:(NSXMLParser *)parser resolveExternalEntityName:(NSString *)name systemID:(nullable NSString *)systemID
{
    MARK();
    return nil;
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    MARK();
}

- (void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validationError
{
    MARK();
}

@end
