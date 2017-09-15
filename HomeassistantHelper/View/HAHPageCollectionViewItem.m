//
//  HAHPageCollectionViewItem.m
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/7/16.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import "HAHPageCollectionViewItem.h"
#import "NSColor_HAH.h"
#import "NSString_HAH.h"

@interface HAHPageCollectionViewItem ()
@property (weak) IBOutlet NSView *line;
@end

@implementation HAHPageCollectionViewItem

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.wantsLayer = YES;
    self.view.layer.backgroundColor = [NSColor pageCollectionViewItemNormalColor];

    self.line.wantsLayer = YES;
    self.line.layer.backgroundColor = [NSColor pageCollectionViewItemLineColor];
}

- (void)setSize:(NSSize)size
{
    _size = size;
    self.view.size = size;
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];

    if (selected) {
        self.view.layer.backgroundColor = [NSColor pageCollectionViewItemSelectedColor];
    } else {
        self.view.layer.backgroundColor = [NSColor pageCollectionViewItemNormalColor];
    }
}

+ (CGFloat)widthWithText:(NSString *)text
{
    static NSFont *font;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        HAHPageCollectionViewItem *item = [[HAHPageCollectionViewItem alloc] init];
        [item view];
        font = item.textField.font;
    });

    return [text sizeWithFont:font].width + 44;
}

- (void)bindPageModel:(HAHPageModel *)pageModel
{
    [self.textField unbind:NSValueBinding];
    [self.textField bind:NSValueBinding toObject:pageModel withKeyPath:@"name" options:nil];
}

@end
