//
//  HAHWindowControllerManager.m
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/7/15.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import "HAHWindowControllerManager.h"
#import <objc/runtime.h>

@interface HAHWindowControllerManager ()
// 第一次调用self.window.isVisible返回yes，但是需要显示
@property (nonatomic, assign) BOOL notDisplayed;
@end

@implementation HAHWindowControllerManager

void *HAHWindowControllerManagerKey = &HAHWindowControllerManagerKey;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (instancetype)sharedManager
{
    id _manager = objc_getAssociatedObject(self, HAHWindowControllerManagerKey);
    if (!_manager) {
        _manager = [[self alloc] initWithWindowNibName:NSStringFromClass(self)];
        objc_setAssociatedObject(self, HAHWindowControllerManagerKey, _manager, OBJC_ASSOCIATION_RETAIN);
        [_manager window];
        [_manager close];
    }
    return _manager;
}

- (void)awakeFromNib
{
    self.notDisplayed = YES;
}

- (void)windowDidLoad
{
    [super windowDidLoad];

    NSButton *closeButton = [self.window standardWindowButton:NSWindowCloseButton];
    closeButton.target = self;
    closeButton.action = @selector(closeAction:);

    // 还原上次关闭时的位置
    NSString *windowFrame = [[NSUserDefaults standardUserDefaults] objectForKey:self.windowFrameKey];
    if (windowFrame) {
        [self.window setFrame:NSRectFromString(windowFrame) display:YES];
    }
}

- (void)closeAction:(NSButton *)button
{
    // 记录关闭时的位置
    [[NSUserDefaults standardUserDefaults]  setObject:NSStringFromRect(self.window.frame) forKey:self.windowFrameKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self close];
}

- (void)toggleDisplay
{
    if (self.notDisplayed) {
        self.notDisplayed = NO;
        [self showWindow:self.window];
        return;
    }
    if (self.window.isVisible) {
        [self closeAction:nil];
    } else {
        [self showWindow:self.window];
    }
}

@end

@implementation HAHManagerController

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.objectClass = self.managerClass;
        self.content = [self.managerClass sharedManager];
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
    return [self.managerClass sharedManager];
}

@end
