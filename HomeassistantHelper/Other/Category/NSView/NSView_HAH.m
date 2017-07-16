//
//  NSView_HAH.m
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/7/15.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import "NSView_HAH.h"
#import <objc/runtime.h>

@implementation NSView (HAHKeyRespond)

+ (void)load
{
    Method origin = class_getInstanceMethod(self, @selector(performKeyEquivalent:));
    Method replace = class_getInstanceMethod(self, @selector(HAHPerformKeyEquivalent:));
    method_exchangeImplementations(origin, replace);
}

- (BOOL)HAHPerformKeyEquivalent:(NSEvent *)event
{
    if ([self.nextResponder isKindOfClass:[NSViewController class]]) {
        if ([self.nextResponder performKeyEquivalent:event]) {
            return YES;
        }
    }
    return [self HAHPerformKeyEquivalent:event];
}

@end

@implementation NSView (HAHDescription)

- (NSString *)description
{
    NSMutableArray *subviews = [[NSMutableArray alloc] init];
    for (NSView *subview in self.subviews) {
        [subviews addObject:[NSString stringWithFormat:@"<%@: %p; frame = %@>", [subview class], subview, NSStringFromRect(subview.frame)]];
    }

    return [NSString stringWithFormat:@"<%@: %p; frame = %@; subviews = %@>", self.class, self, NSStringFromRect(self.frame), subviews];
}

@end
