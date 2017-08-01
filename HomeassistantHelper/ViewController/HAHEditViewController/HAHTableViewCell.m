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

@end
