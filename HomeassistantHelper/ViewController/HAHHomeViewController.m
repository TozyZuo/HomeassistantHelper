//
//  HAHHomeViewController.m
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/7/9.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import "HAHHomeViewController.h"
#import "HAHEntityModel.h"
#import "HAHDataManager.h"

@interface HAHHomeViewController ()
@property (nonatomic, strong) NSArray<HAHEntityModel *> *models;
@end

@implementation HAHHomeViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    if (self = [super initWithCoder:coder]) {
        [self initialize];
    }
    return self;
}

- (void)initialize
{

}

- (void)viewDidLoad {
    [super viewDidLoad];

    NSRect frame;
    frame.size = [NSScreen mainScreen].visibleFrame.size;
    self.view.frame = frame;
}

- (void)viewDidAppear
{
    [super viewDidAppear];

    __weak typeof(self) weakSelf = self;
    [[HAHDataManager sharedManager] requestEntitiesWithURL:@"http://192.168.10.147:8123" complete:^(NSArray<HAHEntityModel *> *models) {
        weakSelf.models = models;
        HAHLOG(@"%@", models);
    }];
}

@end
