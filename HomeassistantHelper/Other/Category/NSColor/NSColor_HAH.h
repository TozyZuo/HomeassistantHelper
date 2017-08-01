//
//  NSColor_HAH.h
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/8/1.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

FOUNDATION_EXPORT NSColor *NSColorWithHexadecimalColor(NSInteger color);
FOUNDATION_EXPORT NSColor *NSColorWithRGBColor(unsigned char r, unsigned char g, unsigned char b);

@interface NSColor (HAHColor)

+ (CGColorRef)pageCollectionViewItemNormalColor;
+ (CGColorRef)pageCollectionViewItemSelectedColor;
+ (CGColorRef)pageCollectionViewItemLineColor;

+ (CGColorRef)tableViewCellBorderColor;

@end
