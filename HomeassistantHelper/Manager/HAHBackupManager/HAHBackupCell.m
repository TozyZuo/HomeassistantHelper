//
//  HAHBackupCell.m
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/11/14.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import "HAHBackupCell.h"
#import "NSColor_HAH.h"

@implementation HAHBackupCell

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

@end
