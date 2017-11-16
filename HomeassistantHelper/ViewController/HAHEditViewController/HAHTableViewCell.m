//
//  HAHTableViewCell.m
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/7/30.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import "HAHTableViewCell.h"
#import "NSColor_HAH.h"
#import <objc/runtime.h>

@interface HAHTableViewCell ()
@property (nonatomic, strong) HAHEntityModel    *entity;
// HAHUsedForEdit
@property (nonatomic, assign) BOOL              isCopied;
@property (nonatomic, assign) NSUInteger        pageIndex;
@property (nonatomic, assign) NSUInteger        groupIndex;
@property (nonatomic, assign) NSUInteger        entityIndex;
@property (nonatomic, assign) NSPoint           startOrigin;
@property (nonatomic,  weak ) HAHTableViewCell  *associatedCell;
@end

@implementation HAHTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];

    self.wantsLayer = YES;
    self.layer.borderWidth = 1;
    self.layer.borderColor = [NSColor tableViewCellBorderColor];
}

+ (NSString *)identifier
{
    static NSString *identifier = nil;
    if (!identifier) {
        identifier = [NSString stringWithFormat:@"%@ID", NSStringFromClass(self)];
    }
    return identifier;
}

- (void)setSelected:(BOOL)selected
{
    if (_selected != selected) {
        _selected = selected;
        if (selected) {
            self.layer.borderColor = [NSColor tableViewCellSelectedBorderColor];
        } else {
            self.layer.borderColor = [NSColor tableViewCellBorderColor];
        }
    }
}

- (void)bindEntityModel:(HAHEntityModel *)entityModel
{
    [self.textField unbind:NSValueBinding];
    self.entity = entityModel;
    [self.textField bind:NSValueBinding toObject:entityModel withKeyPath:@"name" options:nil];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    NSNib *nib = [[NSNib alloc] initWithNibNamed:@"HAHTableViewCell" bundle:nil];

    NSArray *array;
    [nib instantiateWithOwner:nil topLevelObjects:&array];
    for (HAHTableViewCell *obj in array) {
        if ([obj isKindOfClass:self.class]) {
            obj.frame = self.frame;
            [obj bindEntityModel:self.entity];
            return obj;
        }
    }

    return nil;
}

#pragma mark - HAHUsedForEdit

- (void)setIsCopied:(BOOL)isCopied
{
    _isCopied = isCopied;
    if (isCopied) {
        self.alphaValue = 1;
    } else {
        self.alphaValue = .5;
    }
}

@end
