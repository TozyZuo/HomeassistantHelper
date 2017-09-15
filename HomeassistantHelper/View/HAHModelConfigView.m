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
@property (nonatomic, readonly) NSArray         *disabledProperties;
@property (nonatomic,  strong ) HAHModel        *model;
@property (nonatomic, readonly) NSDictionary    *dispatchDictionary;
@end

@implementation HAHModelConfigView

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

- (void)clear
{
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.height = self.superview.height;
}

- (void)reloadWithModel:(HAHModel *)model
{
    self.model = model;

    [self clear];

    HAHModelInformation *information = [model.class infomation];

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
    [value bind:NSValueBinding toObject:self.model withKeyPath:property options:nil];
    if ([self.disabledProperties containsObject:property]) {
        value.enabled = NO;
    }
    [view addSubview:value];

    view.height = value.bottom;

    return view;
}

- (NSView *)viewWithBOOLProperty:(NSString *)property
{
    return nil;
}

@end
