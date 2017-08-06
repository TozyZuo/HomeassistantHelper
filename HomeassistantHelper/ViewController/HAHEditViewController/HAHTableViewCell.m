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
// HAHUsedForEdit
@property (nonatomic, assign) BOOL      editing;
@property (nonatomic, assign) NSPoint   startOrigin;
@property (nonatomic,  weak ) HAHTableViewCell *cellInTableView;
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

- (void)setText:(NSString *)text
{
    _text = text;

    self.textField.stringValue = text;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    NSNib *nib = [[NSNib alloc] initWithNibNamed:@"HAHTableViewCell" bundle:nil];

    NSArray *array;
    [nib instantiateWithOwner:nil topLevelObjects:&array];
    for (HAHTableViewCell *obj in array) {
        if ([obj isKindOfClass:self.class]) {
            obj.text = self.text;
            obj.frame = self.frame;
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
