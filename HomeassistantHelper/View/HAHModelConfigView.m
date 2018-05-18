//
//  HAHModelConfigView.m
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/7/16.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import "HAHModelConfigView.h"
#import "HAHModel.h"
#import "HAHConfigManager.h"
#import "NSTextField_HAH.h"
#import <objc/runtime.h>

CGFloat HAHModelConfigViewTopMargin = 20;
CGFloat HAHModelConfigViewLeftMargin = 20;
CGFloat HAHModelConfigViewRightMargin = 20;
CGFloat HAHModelConfigViewBottomMargin = 20;
CGFloat HAHModelConfigViewVerticalSpace = 5;


@interface HAHModelConfigView ()
<NSTextFieldDelegate>
@property (nonatomic, readonly) NSArray         *disabledProperties;
@property (nonatomic,  strong ) HAHModel        *model;
@property (nonatomic,  strong ) NSMutableArray  *controlViews;
@property (nonatomic, readonly) NSDictionary    *dispatchDictionary;
@property (nonatomic,  assign ) BOOL isEditing;
@end

@implementation HAHModelConfigView

- (void)initialize
{
    [super initialize];
    self.controlViews = [[NSMutableArray alloc] init];
    _enabled = YES;
}

- (NSArray *)disabledProperties
{
    static NSArray *disabledProperties = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        disabledProperties = @[@"id",];
    });

    return disabledProperties;
}

- (NSDictionary *)dispatchDictionary
{
    static NSDictionary *dispatchDictionary = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dispatchDictionary = @{
            @"NSString" : NSStringFromSelector(@selector(viewWithStringProperty:)),
            @"BOOL" : NSStringFromSelector(@selector(viewWithBOOLProperty:)),
        };
    });

    return dispatchDictionary;
}

- (void)setEnabled:(BOOL)enabled
{
    if (_enabled != enabled) {
        _enabled = enabled;
        for (NSControl *control in self.controlViews) {
            control.enabled = enabled;
        }
    }
}

- (void)clear
{
    [self.controlViews removeAllObjects];
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.height = self.superview.height;
}

- (void)reloadWithModel:(HAHModel *)model
{
    self.model = model;

    [self clear];

    HAHModelInformation *information = model.infomation;

    for (NSString *property in information.propertyNames) {
        NSString *selectorString = self.dispatchDictionary[[information classStringForProperty:property]];
        if (selectorString) {

            HAH_CLANG_WARNING_IGNORE_BEGIN(-Warc-performSelector-leaks)

            NSView *view = [self performSelector:NSSelectorFromString(selectorString) withObject:property];

            HAH_CLANG_WARNING_IGNORE_END

            view.top = self.subviews.lastObject.bottom;
            [self addSubview:view];
        }
    }

    self.height = MAX(self.superview.height, self.subviews.lastObject.bottom + HAHModelConfigViewBottomMargin);
}

- (NSView *)viewWithStringProperty:(NSString *)property
{
    NSView *view = [[HAHView alloc] initWithFrame:NSZeroRect];
    view.width = HAHModelConfigViewWidth;

    CGFloat width = HAHModelConfigViewWidth - HAHModelConfigViewLeftMargin - HAHModelConfigViewRightMargin;

    NSTextField *title = [[NSTextField alloc] initWithFrame:NSMakeRect(HAHModelConfigViewLeftMargin, HAHModelConfigViewTopMargin, width, 22)];
    [title enableLabelStyle];
    title.stringValue = [HAHConfigManager sharedManager].modelConfigMap[property] ?: property;
    [view addSubview:title];

    NSTextField *value = [[NSTextField alloc] initWithFrame:NSMakeRect(HAHModelConfigViewLeftMargin, title.bottom + HAHModelConfigViewVerticalSpace, width, 22)];
    value.delegate = self;
    [value bind:NSValueBinding toObject:self.model withKeyPath:property options:nil];
    if ([self.disabledProperties containsObject:property]) {
        value.enabled = NO;
    } else {
        [self.controlViews addObject:value];
    }
    [view addSubview:value];

    view.height = value.bottom;

    return view;
}

- (NSView *)viewWithBOOLProperty:(NSString *)property
{
    NSView *view = [[HAHView alloc] initWithFrame:NSZeroRect];
    view.width = HAHModelConfigViewWidth;

    CGFloat width = HAHModelConfigViewWidth - HAHModelConfigViewLeftMargin - HAHModelConfigViewRightMargin;

    NSButton *button = [NSButton checkboxWithTitle:[HAHConfigManager sharedManager].modelConfigMap[property] ?: property target:nil action:NULL];
    button.font = [NSFont systemFontOfSize:13];
    button.frame = NSMakeRect(HAHModelConfigViewLeftMargin, HAHModelConfigViewTopMargin, width, 20);
    button.width = width;
    [button bind:NSValueBinding toObject:self.model withKeyPath:property options:nil];
    [view addSubview:button];
    [self.controlViews addObject:button];

    view.height = button.bottom;

    return view;
}

#pragma mark - NSTextFieldDelegate

- (BOOL)control:(NSControl *)control textShouldBeginEditing:(NSText *)fieldEditor
{
    self.isEditing = YES;
    return YES;
}

- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor
{
    self.isEditing = NO;
    return YES;
}

@end
