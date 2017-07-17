//
//  HAHPageCollectionViewItem.m
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/7/16.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import "HAHPageCollectionViewItem.h"

@interface HAHPageCollectionViewItem ()
@property (weak) IBOutlet NSButton *button;
@end

@implementation HAHPageCollectionViewItem

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (void)setText:(NSString *)text
{
    _text = text;
    self.button.title = text;
}

- (void)setSize:(NSSize)size
{
    self.view.size = size;
}

- (CGFloat)widthWithText:(NSString *)text
{
    NSString *title = self.button.title;
    self.button.title = text;
    [self.button sizeToFit];
    CGFloat width = self.button.width;
    self.button.title = title;
    return width;
}

@end
