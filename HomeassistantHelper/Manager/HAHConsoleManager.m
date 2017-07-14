//
//  HAHConsoleManager.m
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/7/11.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import "HAHConsoleManager.h"

@interface HAHConsoleManager ()
@property (weak) IBOutlet NSTextView *textView;

@end

@implementation HAHConsoleManager

#pragma mark - Life cycle

+ (instancetype)sharedManager
{
    static HAHConsoleManager *_manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[self alloc] initWithWindowNibName:NSStringFromClass(self)];
        [_manager window];
        [_manager close];
    });
    return _manager;
}

- (void)windowDidLoad
{
    [super windowDidLoad];

    // 清除内容按钮
    NSButton *zoomButton = [self.window standardWindowButton:NSWindowZoomButton];
    NSButton *clearButton = [NSButton buttonWithImage:[NSImage imageNamed:@"trash"] target:self action:@selector(clearAction:)];
    clearButton.bezelStyle = NSBezelStyleRoundRect;
    clearButton.bordered = NO;
    clearButton.size = NSMakeSize(20, 20);
    clearButton.centerY = zoomButton.centerY;
    clearButton.left = zoomButton.right + 6;
    [zoomButton.superview addSubview:clearButton];
}

#pragma mark - Action

- (void)clearAction:(NSButton *)button
{
    self.textView.string = @"";
}

#pragma mark - Public

- (void)toggleConsole
{
    // 第一次调用self.window.isVisible返回yes，但是需要show
    static BOOL firstShow = YES;
    if (firstShow) {
        firstShow = NO;
        [self showWindow:self.window];
        return;
    }
    if (self.window.isVisible) {
        [self close];
    } else {
        [self showWindow:self.window];
    }
}

#pragma mark - Private

- (void)log:(NSString *)format args:(va_list)args
{
    [self log:[[NSString alloc] initWithFormat:format arguments:args]];
}

- (void)log:(NSString *)text
{
    HAHExecuteBlockOnMainThread(^{
        self.textView.string = [self.textView.string stringByAppendingFormat:@"\n%@", text];
        printf("\n%s", text.UTF8String);
    });
}

@end


@implementation HAHConsoleManagerController


- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.objectClass = [HAHConsoleManager class];
        self.content = [HAHConsoleManager sharedManager];
    }
    return self;
}

- (BOOL)canAdd
{
    return NO;
}

- (BOOL)canRemove
{
    return NO;
}

- (void)addObject:(id)object
{

}

- (void)removeObject:(id)object
{

}

- (id)newObject
{
    return [HAHConsoleManager sharedManager];
}

@end

void CMLog(NSString *format, ...)
{
    va_list ap;
    va_start(ap, format);
    [[HAHConsoleManager sharedManager] log:format args:ap];
    va_end(ap);
}
