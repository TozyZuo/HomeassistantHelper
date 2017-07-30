//
//  HAHTableViewCell.h
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/7/30.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class HAHEntityModel;

@interface HAHTableViewCell : NSTextField
@property (nonatomic, strong) HAHEntityModel *entity;
@end
