//
//  HAHPageCollectionViewItem.h
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/7/16.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class HAHPageModel;

@interface HAHPageCollectionViewItem : NSCollectionViewItem
@property (nonatomic, assign) NSSize    size;
+ (CGFloat)widthWithText:(NSString *)text;
- (void)bindPageModel:(HAHPageModel *)pageModel;
@end
