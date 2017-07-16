//
//  NSTextField_HAH.m
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/7/15.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import "NSTextField_HAH.h"
#import <objc/runtime.h>

@implementation NSTextField (HAHDisable)

+ (void)load
{
    Method origin = class_getInstanceMethod(self, @selector(setEnabled:));
    Method replace = class_getInstanceMethod(self, @selector(HAHSetEnabled:));
    method_exchangeImplementations(origin, replace);
}

- (void)HAHSetEnabled:(BOOL)enabled
{
    NSString *text = self.stringValue;
    [self HAHSetEnabled:enabled];
    self.stringValue = text;
}

@end

@implementation NSTextField (UILabel)


- (void)enableLabelStyle
{
    self.font = [NSFont systemFontOfSize:13];
    self.editable = NO;
    self.selectable = NO;
    self.bezeled = NO;
    self.drawsBackground = YES;

    self.backgroundColor = [NSColor clearColor];
}

- (void)sizeToFit
{
    CGRect frame = self.frame;
    frame.size = [self.stringValue boundingRectWithSize:NSMakeSize(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:self.font}].size;
    self.frame = frame;
}

- (void)widthToFit
{
    CGRect frame = self.frame;
    frame.size.width = [self.stringValue sizeWithAttributes:@{NSFontAttributeName:self.font}].width;
    self.frame = frame;
}

- (void)widthFitsMaxWidth:(CGFloat)width
{
    [self widthToFit];
    CGRect rect = self.frame;
    if (rect.size.width > width) {
        rect.size.width = width;
    }
    self.frame = rect;
}

- (void)widthFitsMinWidth:(CGFloat)width
{

    [self widthToFit];
    CGRect rect = self.frame;
    if (rect.size.width < width) {
        rect.size.width = width;
    }
    self.frame = rect;
}

- (void)heightToFit
{
    CGRect frame = self.frame;
    frame.size.height = ceilf([self.stringValue boundingRectWithSize:CGSizeMake(frame.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:self.font}].size.height);
    self.frame = frame;
}

- (void)heightFitsMaxHeight:(CGFloat)height
{
    [self heightToFit];
    CGRect rect = self.frame;
    if (rect.size.height > height) {
        rect.size.height = height;
    }
    self.frame = rect;
}

- (void)heightFitsMinHeight:(CGFloat)height
{
    [self heightToFit];
    CGRect rect = self.frame;
    if (rect.size.height < height) {
        rect.size.height = height;
    }
    self.frame = rect;
}

@end
