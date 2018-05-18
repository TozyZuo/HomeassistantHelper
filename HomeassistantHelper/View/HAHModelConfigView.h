//
//  HAHModelConfigView.h
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/7/16.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import "HAHView.h"

@class HAHModel;

@interface HAHModelConfigView : HAHView
@property (nonatomic, readonly) BOOL isEditing;
@property (nonatomic,  assign ) BOOL enabled;

- (void)clear;
- (void)reloadWithModel:(HAHModel *)model;

@end
