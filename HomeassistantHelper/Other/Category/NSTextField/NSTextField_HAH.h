//
//  NSTextField_HAH.h
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/7/15.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSTextField (HAHDisable)

@end

@interface NSTextField (UILabel)
- (void)enableLabelStyle;
- (void)sizeToFit;
// only numberOfLines == 1
- (void)widthToFit;
- (void)widthFitsMinWidth:(CGFloat)width;
- (void)widthFitsMaxWidth:(CGFloat)width;
// not change width
- (void)heightToFit;
- (void)heightFitsMinHeight:(CGFloat)height;
- (void)heightFitsMaxHeight:(CGFloat)height;
@end
