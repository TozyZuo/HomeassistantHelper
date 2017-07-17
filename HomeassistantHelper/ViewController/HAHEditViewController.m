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
#import "HAHPageCollectionViewItem.h"
#import "NSString_HAH.h"

NSString * const HAHPageCollectionViewItemViewIdentifier = @"HAHPageCollectionViewItemViewIdentifier";

@interface HAHEditViewController ()
<
    NSCollectionViewDelegate,
    NSCollectionViewDataSource,
    NSTableViewDelegate,
    NSTableViewDataSource
>
@property (weak) IBOutlet NSLayoutConstraint *configViewWidthConstraint;
@property (weak) IBOutlet HAHModelConfigView *configView;
@property (weak) IBOutlet NSCollectionView *collectionView;
@property (weak) IBOutlet NSTableView *tableView;

@property (nonatomic, strong) NSArray<HAHPageModel *> *pages;

@end

@implementation HAHEditViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.collectionView registerClass:[HAHPageCollectionViewItem class] forItemWithIdentifier:HAHPageCollectionViewItemViewIdentifier];
}

#pragma mark - Action

- (IBAction)separateButtonAction:(NSButton *)sender
{
    sender.image = [NSImage imageNamed:sender.state ? @"default_edit_ separate_on" : @"default_edit_ separate_off"];
    self.configViewWidthConstraint.constant = HAHModelConfigViewWidth - self.configViewWidthConstraint.constant;
}

#pragma mark - Public

- (void)reloadWithPages:(NSArray<HAHPageModel *> *)pages
{
    self.pages = pages;
    [self.collectionView reloadData];
    [self.tableView reloadData];
//    [self.configView reloadWithModel:pages.firstObject.groups.firstObject];
}

#pragma mark - NSCollectionViewDelegate

- (void)collectionView:(NSCollectionView *)collectionView didSelectItemsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths
{

}

- (void)collectionView:(NSCollectionView *)collectionView didDeselectItemsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths
{

}

#pragma mark - NSCollectionViewDelegateFlowLayout

- (NSSize)collectionView:(NSCollectionView *)collectionView layout:(NSCollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static HAHPageCollectionViewItem *item;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        item = [[HAHPageCollectionViewItem alloc] init];
        [item view];
    });

    HAHPageModel *page = self.pages[indexPath.item];
    if (page.name.length) {
        return NSMakeSize([item widthWithText:page.name], collectionView.height);
    } else if (page.id) {
        return NSMakeSize([item widthWithText:page.id], collectionView.height);
    }
    return NSMakeSize(30, 30);
}

- (CGFloat)collectionView:(NSCollectionView *)collectionView layout:(NSCollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (CGFloat)collectionView:(NSCollectionView *)collectionView layout:(NSCollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

#pragma mark - NSCollectionViewDataSource

- (NSInteger)collectionView:(NSCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.pages.count;
}

- (NSCollectionViewItem *)collectionView:(NSCollectionView *)collectionView itemForRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath
{
    HAHPageCollectionViewItem *item = [collectionView makeItemWithIdentifier:HAHPageCollectionViewItemViewIdentifier forIndexPath:indexPath];
    HAHPageModel *page = self.pages[indexPath.item];
    item.text = page.name ?: page.id;
    item.size = NSMakeSize([item widthWithText:item.text], collectionView.height);
    return item;
}
#pragma mark - NSTableViewDelegate
#pragma mark - NSTableViewDataSource



@end
