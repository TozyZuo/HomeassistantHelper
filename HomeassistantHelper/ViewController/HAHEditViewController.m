//
//  HAHEditViewController.m
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/7/16.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import "HAHEditViewController.h"
#import "HAHGroupModel.h"
#import "HAHPageModel.h"
#import "HAHModelConfigView.h"
#import "HAHPageCollectionViewItem.h"
#import "NSString_HAH.h"

NSString * const HAHPageCollectionViewItemViewIdentifier = @"HAHPageCollectionViewItemViewIdentifier";
static CGFloat const TableHeaderCellTextMargin = 20;

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
    sender.image = [NSImage imageNamed:sender.state ? @"default_edit_separate_on" : @"default_edit_separate_off"];
    self.configViewWidthConstraint.constant = HAHModelConfigViewWidth - self.configViewWidthConstraint.constant;
}

#pragma mark - Public

- (void)reloadWithPages:(NSArray<HAHPageModel *> *)pages ungroupedEntities:(NSArray<HAHEntityModel *> *)ungroupedEntities
{
    HAHGroupModel *ungroupedGroup = [[HAHGroupModel alloc] init];
    ungroupedGroup.name = @"未分组";
    ungroupedGroup.shortID = @"ungroupedGroup";
    ungroupedGroup.entities = ungroupedEntities.mutableCopy;

    HAHPageModel *ungroupedPage = [[HAHPageModel alloc] init];
    ungroupedPage.name = @"未分组";
    ungroupedPage.id = @"ungroupedPage";
    ungroupedPage.groups = [[NSMutableArray alloc] initWithObjects:ungroupedGroup, nil];

    NSMutableArray *finalPages = pages.mutableCopy;
    [finalPages insertObject:ungroupedPage atIndex:0];

    self.pages = finalPages;
    [self.collectionView reloadData];

    NSSet *selectionIndexPaths = [NSSet setWithObject:[NSIndexPath indexPathForItem:1 inSection:0]];

    self.collectionView.selectionIndexPaths = selectionIndexPaths;
    [self reloadTableView];
}

#pragma mark - Private

- (void)reloadTableView
{
    // TODO 复用NSTableColumn
    NSArray *columns = self.tableView.tableColumns.copy;
    for (NSTableColumn *column in columns) {
        [self.tableView removeTableColumn:column];
    }

    HAHPageModel *page = self.pages[self.collectionView.selectionIndexPaths.anyObject.item];

    // 算宽度，所有entities中最长
    CGFloat width = 0;
    NSFont *font = [NSFont systemFontOfSize:14];
    for (HAHGroupModel *group in page.groups) {
        width = MAX(width, [group.name ?: group.shortID sizeWithFont:font].width);
        for (HAHEntityModel *entity in group.entities) {
            width = MAX(width, [entity.name ?: entity.id sizeWithFont:font].width);
        }
    }

    width += TableHeaderCellTextMargin;

    for (HAHGroupModel *group in page.groups) {
        NSTableColumn *column = [[NSTableColumn alloc] initWithIdentifier:group.shortID];
        column.title = group.name ?: group.shortID;
        column.headerCell.font = font;
        column.width = width;
        column.minWidth = [group.name ?: group.shortID sizeWithFont:font].width + TableHeaderCellTextMargin;
        [self.tableView addTableColumn:column];
    }

    [self.tableView reloadData];
}

#pragma mark - NSCollectionViewDelegate

- (void)collectionView:(NSCollectionView *)collectionView didSelectItemsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths
{
    [self reloadTableView];
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

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    if (!tableColumn) {
        return nil;
    }

    HAHPageModel *page = self.pages[self.collectionView.selectionIndexPaths.anyObject.item];

    NSString *title = @"未找到";
    for (HAHGroupModel *group in page.groups) {
        if ([tableColumn.identifier isEqualToString:group.shortID])
        {
            if (row < group.entities.count) {
                title = group.entities[row].name;
                break;
            } else {
                return nil;
            }
        }
    }

    NSTextField *tf = [[NSTextField alloc] init];
    tf.stringValue = title;

    return tf;
}

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    NSInteger row = 0;
    for (HAHGroupModel *group in self.pages[self.collectionView.selectionIndexPaths.anyObject.item].groups) {
        row = MAX(row, group.entities.count);
    }
    return row;
}

//- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
//{
//    return nil;
//}

@end
