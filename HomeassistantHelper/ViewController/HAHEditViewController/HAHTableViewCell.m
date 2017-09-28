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
@property (nonatomic, assign) BOOL              editing;
@property (nonatomic, assign) NSUInteger        pageIndex;
@property (nonatomic, assign) NSUInteger        groupIndex;
@property (nonatomic, assign) NSUInteger        entityIndex;
@property (nonatomic, assign) NSPoint           startOrigin;
@end

@implementation HAHTableViewCell

void *runtimeHAHTableViewCellIdentifierKey = &runtimeHAHTableViewCellIdentifierKey;

- (void)awakeFromNib
{
    [super awakeFromNib];

    self.wantsLayer = YES;
    self.layer.borderWidth = 1;
    self.layer.borderColor = [NSColor tableViewCellBorderColor];
}

+ (NSString *)identifier
{
    NSString *identifier = objc_getAssociatedObject(self, runtimeHAHTableViewCellIdentifierKey);
    if (!identifier) {
        identifier = [NSString stringWithFormat:@"%@ID", NSStringFromClass(self)];
        objc_setAssociatedObject(self, runtimeHAHTableViewCellIdentifierKey, identifier, OBJC_ASSOCIATION_RETAIN);
    }
    return identifier;
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

- (void)setEditing:(BOOL)editing
{
    _editing = editing;
}

@end
