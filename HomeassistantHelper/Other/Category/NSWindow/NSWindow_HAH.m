//
//  NSWindow_HAH.m
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/7/15.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import "NSWindow_HAH.h"
#import <objc/runtime.h>

@implementation NSWindow (HAHKeyRespond)

+ (void)load
{
    Method origin = class_getInstanceMethod(self, @selector(performKeyEquivalent:));
    Method replace = class_getInstanceMethod(self, @selector(HAHPerformKeyEquivalent:));
    method_exchangeImplementations(origin, replace);
}

- (BOOL)HAHPerformKeyEquivalent:(NSEvent *)event
{
    if ([self.nextResponder isKindOfClass:[NSWindowController class]]) {
        if ([self.nextResponder performKeyEquivalent:event]) {
            return YES;
        }
    }
    return [self HAHPerformKeyEquivalent:event];
}

@end
