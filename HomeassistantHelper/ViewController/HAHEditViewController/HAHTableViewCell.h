//
//  HAHTableViewCell.h
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/7/30.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class HAHEntityModel;

@interface HAHTableViewCell : NSTableCellView
<NSCopying>

@property (  class  , readonly) NSString        *identifier;
@property (nonatomic, readonly) HAHEntityModel  *entity;
@property (nonatomic,  assign ) BOOL            selected;

- (void)bindEntityModel:(HAHEntityModel *)entityModel;

@end


@interface HAHTableViewCell (HAHUsedForEdit)
@property (nonatomic, assign) BOOL              isCopied;
@property (nonatomic, assign) NSUInteger        pageIndex;
@property (nonatomic, assign) NSUInteger        groupIndex;
@property (nonatomic, assign) NSUInteger        entityIndex;
@property (nonatomic, assign) NSPoint           startOrigin;
@end
