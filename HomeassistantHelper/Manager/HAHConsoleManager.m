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

+ (instancetype)sharedManager
{
    static id _manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[self alloc] initWithWindowNibName:NSStringFromClass(self)];
    });
    return _manager;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (void)showConsole
{
    [self showWindow:self.window];
}

- (void)log:(NSString *)format args:(va_list)args
{
    [self log:[[NSString alloc] initWithFormat:format arguments:args]];
}

- (void)log:(NSString *)text
{
    self.textView.string = [self.textView.string stringByAppendingFormat:@"\n%@", text];
    printf("\n%s", text.UTF8String);
}

@end

void CMLog(NSString *format, ...)
{
    va_list ap;
    va_start(ap, format);
    [[HAHConsoleManager sharedManager] log:format args:ap];
    va_end(ap);
}
