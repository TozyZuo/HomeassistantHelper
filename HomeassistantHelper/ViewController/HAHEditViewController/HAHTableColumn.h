//
//  HAHTableColumn.h
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/7/30.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class HAHGroupModel;
@interface HAHTableColumn : NSTableColumn
@property (nonatomic, strong) HAHGroupModel *group;
@end
