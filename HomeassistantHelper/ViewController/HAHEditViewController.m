//
//  HAHEditViewController.m
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/7/16.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import "HAHEditViewController.h"
#import "HAHPageModel.h"
#import "HAHModelConfigView.h"

@interface HAHEditViewController ()
@property (weak) IBOutlet NSLayoutConstraint *configViewWidthConstraint;
@property (weak) IBOutlet HAHModelConfigView *configView;

@end

@implementation HAHEditViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (IBAction)separateButtonAction:(NSButton *)sender
{
    sender.image = [NSImage imageNamed:sender.state ? @"default_edit_ separate_on" : @"default_edit_ separate_off"];
    self.configViewWidthConstraint.constant = HAHModelConfigViewWidth - self.configViewWidthConstraint.constant;
}

- (void)reloadWithPages:(NSArray<HAHPageModel *> *)pages
{
    [self.configView reloadWithModel:pages.firstObject.groups.firstObject];
}

@end
