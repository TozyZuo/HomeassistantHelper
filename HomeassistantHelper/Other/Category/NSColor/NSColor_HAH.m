//
//  NSColor_HAH.m
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/8/1.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import "NSColor_HAH.h"


NSColor *NSColorWithHexadecimalColor(NSInteger color)
{
    return [NSColor colorWithRed:((CGFloat)((color & 0xFF0000) >> 16))/255.0 green:((CGFloat)((color & 0xFF00) >> 8))/255.0 blue:((CGFloat)(color & 0xFF))/255.0 alpha:1];
}

NSColor *NSColorWithRGBColor(unsigned char r, unsigned char g, unsigned char b)
{
    return [NSColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1];
}

@implementation NSColor (HAHColor)

+ (CGColorRef)pageCollectionViewItemNormalColor
{
    return NSColorWithRGBColor(217, 217, 217).CGColor;
}

+ (CGColorRef)pageCollectionViewItemSelectedColor
{
    return NSColorWithRGBColor(246, 246, 246).CGColor;
}

+ (CGColorRef)pageCollectionViewItemLineColor
{
    return NSColorWithRGBColor(197, 197, 197).CGColor;
}

+ (CGColorRef)tableViewCellBorderColor
{
    return NSColorWithRGBColor(197, 197, 197).CGColor;
}

+ (CGColorRef)tableViewCellSelectedBorderColor
{
    return [NSColor blueColor].CGColor;
}

@end
