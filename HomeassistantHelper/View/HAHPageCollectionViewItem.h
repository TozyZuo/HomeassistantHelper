//
//  HAHPageCollectionViewItem.h
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/7/16.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface HAHPageCollectionViewItem : NSCollectionViewItem
@property (nonatomic, strong) NSString  *text;
@property (nonatomic, assign) NSSize    size;
- (CGFloat)widthWithText:(NSString *)text;
@end
