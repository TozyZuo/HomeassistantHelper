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

- (void)awakeFromNib
{
    [super awakeFromNib];

    NSNumber *fontSize = [[NSUserDefaults standardUserDefaults] objectForKey:HAHUDConsoleFontSizeKey];
    if (fontSize) {
        self.textView.font = [NSFont fontWithName:self.textView.font.fontName size:fontSize.doubleValue];
    }
}

- (void)windowDidLoad
{
    [super windowDidLoad];

    // 清除内容按钮
    NSButton *zoomButton = [self.window standardWindowButton:NSWindowZoomButton];
    NSButton *clearButton = [NSButton buttonWithImage:[NSImage imageNamed:@"default_console_ trash"] target:self action:@selector(clearAction:)];
    clearButton.bezelStyle = NSBezelStyleRoundRect;
    clearButton.bordered = NO;
    clearButton.size = NSMakeSize(20, 20);
    clearButton.centerY = zoomButton.centerY;
    clearButton.left = zoomButton.right + 6;
    [zoomButton.superview addSubview:clearButton];
}

- (BOOL)performKeyEquivalent:(NSEvent *)event
{
    if ((event.modifierFlags & NSEventModifierFlagDeviceIndependentFlagsMask) == NSEventModifierFlagCommand)
    {
        if ([event.characters isEqualToString:@"+"])
        {
            NSFont *font = self.textView.font;
            self.textView.font = [NSFont fontWithName:font.fontName size:font.pointSize + 1];
            [[NSUserDefaults standardUserDefaults]  setObject:@(self.textView.font.pointSize) forKey:HAHUDConsoleFontSizeKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            return YES;
        }
        else if ([event.characters isEqualToString:@"-"])
        {
            NSFont *font = self.textView.font;
            self.textView.font = [NSFont fontWithName:font.fontName size:font.pointSize - 1];
            [[NSUserDefaults standardUserDefaults]  setObject:@(self.textView.font.pointSize) forKey:HAHUDConsoleFontSizeKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            return YES;
        }
        else if ([event.characters isEqualToString:@"k"])
        {
            [self clearAction:nil];
            return YES;
        }
    }
    return [super performKeyEquivalent:event];
}

- (NSString *)windowFrameKey
{
    return HAHUDConsoleWindowFrameKey;
}

#pragma mark - Action

- (void)clearAction:(NSButton *)button
{
    self.textView.string = @"";
}

#pragma mark - Private

- (void)log:(NSString *)format args:(va_list)args
{
    [self log:[[NSString alloc] initWithFormat:format arguments:args]];
}

- (void)log:(NSString *)text
{
    HAHExecuteBlockOnMainThread(^{
        self.textView.string = [self.textView.string stringByAppendingFormat:@"%@\n", text];
        printf("%s\n", text.UTF8String);
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
