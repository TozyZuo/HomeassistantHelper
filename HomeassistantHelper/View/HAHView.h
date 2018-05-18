//
//  HAHView.h
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/7/16.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface HAHView : NSView

@property (readwrite) NSInteger tag;
@property (nonatomic, strong) NSColor *backgroundColor;

- (void)initialize NS_REQUIRES_SUPER;

@end
